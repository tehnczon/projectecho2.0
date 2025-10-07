// lib/screens/analytics/testing/providers/user_role_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRoleProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _currentRole = 'infoSeeker'; // fallback
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  bool _isInitialized = false; // NEW: Track if provider has been initialized

  // Getters
  String get currentRole => _currentRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized; // NEW
  Map<String, dynamic>? get userData => _userData;

  // Role helpers
  bool get isInfoSeeker => _currentRole == 'infoSeeker';
  bool get isPLHIV => _currentRole == 'plhiv';
  bool get isResearcher => _currentRole == 'researcher';

  // Dashboard helpers
  bool get shouldShowGeneralDashboard => isInfoSeeker || isPLHIV;
  bool get shouldShowResearcherDashboard => isResearcher;

  Future<void> checkUserRole() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _setGuestState();
        return;
      }

      _isAuthenticated = true;
      final userDoc = await _firestore.collection('user').doc(user.uid).get();

      if (userDoc.exists) {
        _userData = userDoc.data();

        // ✅ role should always be set by usertype page
        if (_userData!.containsKey('role')) {
          _currentRole = _userData!['role'];
        } else {
          _currentRole = 'infoSeeker'; // fallback
        }

        print('✅ Role loaded: $_currentRole');
        print('📊 User data: ${_userData!.keys.join(', ')}');

        // Update last login timestamp
        await _firestore.collection('user').doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        _isInitialized = true; // NEW: Mark as initialized
      } else {
        // No doc found – treat as guest
        print('⚠️ No user doc found for ${user.uid}');
        _setGuestState();
      }
    } catch (e) {
      print('❌ Error checking role: $e');
      if (_userData == null) {
        _setGuestState();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestResearcherUpgrade({
    required String fullName,
    required String licenseNumber,
    required String institution,
    required String reason,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final uid = user.uid;

      await _firestore.collection('requests').add({
        'userId': uid,
        'fullName': fullName,
        'licenseNumber': licenseNumber,
        'institution': institution,
        'reason': reason,
        'status': 'pending',
        'currentRole': _currentRole,
        'requestedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Researcher request submitted');
      return true;
    } catch (e) {
      print('❌ Error requesting researcher upgrade: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPendingRequest() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final uid = user.uid;

      final query =
          await _firestore
              .collection('researcher_requests')
              .where('userId', isEqualTo: uid)
              .where('status', isEqualTo: 'pending')
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      print('❌ Error checking pending request: $e');
      return null;
    }
  }

  void _setGuestState() {
    _currentRole = 'infoSeeker';
    _isAuthenticated = false;
    _userData = null;
    _isInitialized = true; // NEW: Even guest state counts as initialized
  }

  void logout() {
    _setGuestState();
    _isLoading = false; // NEW: Ensure loading is false
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _currentRole = 'infoSeeker';
    _isAuthenticated = false;
    _userData = null;
    _isInitialized = false; // NEW: Reset initialization flag
    notifyListeners();
  }
}
