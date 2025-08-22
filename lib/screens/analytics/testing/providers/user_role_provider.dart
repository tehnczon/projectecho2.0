// lib/providers/user_role_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/../../utils/phone_number_utils.dart';
// lib/providers/user_role_provider.dart

class UserRoleProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _currentRole = 'infoSeeker';
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;
  String? _phoneNumber;

  // Role getters
  String get currentRole => _currentRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInfoSeeker => _currentRole == 'infoSeeker';
  bool get isPLHIV => _currentRole == 'plhiv';
  bool get isResearcher => _currentRole == 'researcher';

  // Data getters
  Map<String, dynamic>? get userData => _userData;
  Map<String, dynamic>? get uicData => _userData?['uicData'];
  Map<String, dynamic>? get demographics => _userData?['demographics'];
  Map<String, dynamic>? get location => _userData?['location'];
  Map<String, dynamic>? get healthInfo => _userData?['healthInfo'];
  Map<String, dynamic>? get plhivData => _userData?['plhivData'];

  // Computed properties
  bool get isMSM =>
      demographics?['sexAssignedAtBirth'] == 'Male' &&
      (healthInfo?['unprotectedSexWith'] == 'Male' ||
          healthInfo?['unprotectedSexWith'] == 'Both');

  String? get ageRange => uicData?['ageRange'];
  String? get treatmentHub => plhivData?['treatmentHub'];

  Future<void> checkUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.phoneNumber == null) {
        _currentRole = 'infoSeeker';
        _isAuthenticated = false;
        notifyListeners();
        return;
      }

      _phoneNumber = user.phoneNumber;
      _isAuthenticated = true;

      String cleanedPhone = PhoneNumberUtils.cleanForDocumentId(
        user.phoneNumber!,
      );
      // Check if user exists
      final userDoc =
          await _firestore.collection('users').doc(cleanedPhone).get();

      if (userDoc.exists) {
        _userData = userDoc.data();
        _currentRole = userDoc.data()?['role'] ?? 'infoSeeker';

        // Check if this user is also a researcher
        final researcherDoc =
            await _firestore.collection('researchers').doc(cleanedPhone).get();

        if (researcherDoc.exists) {
          _currentRole = 'researcher';
        }

        // Update last login
        await _firestore.collection('users').doc(cleanedPhone).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // User hasn't completed registration yet
        _currentRole = 'infoSeeker';
        _userData = null;
      }

      notifyListeners();
    } catch (e) {
      print('Error checking user role: $e');
      _currentRole = 'infoSeeker';
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  // Request upgrade to researcher
  Future<bool> requestResearcherAccess(Map<String, dynamic> credentials) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('researcher_requests').add({
        'userId': user.phoneNumber,
        'currentRole': _currentRole,
        'credentials': credentials,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error requesting researcher access: $e');
      return false;
    }
  }

  void logout() {
    _currentRole = 'infoSeeker';
    _isAuthenticated = false;
    _userData = null;
    _phoneNumber = null;
    notifyListeners();
  }
}
