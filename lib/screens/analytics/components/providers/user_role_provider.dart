// lib/screens/analytics/testing/providers/user_role_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecho/utils/phone_number_utils.dart';

class UserRoleProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _currentRole = 'infoSeeker';
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  // Getters
  String get currentRole => _currentRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  // Simple role checks
  bool get isInfoSeeker => _currentRole == 'infoSeeker';
  bool get isPLHIV => _currentRole == 'plhiv';
  bool get isResearcher => _currentRole == 'researcher';

  // Dashboard routing helper
  bool get shouldShowGeneralDashboard => isInfoSeeker || isPLHIV;
  bool get shouldShowResearcherDashboard => isResearcher;

  // User data getters - matching your existing structure
  Map<String, dynamic>? get userData => _userData;

  // 🆕 PLHIV-specific data getters
  String? get treatmentHub => _userData?['treatmentHub'];
  int? get yearDiagnosed => _userData?['yearDiagnosed'];
  String? get ageRange => _userData?['ageRange'];
  String? get city => _userData?['city'];
  String? get barangay => _userData?['barangay'];
  bool get isMSM => _userData?['isMSM'] ?? false;
  bool get isYouth => _userData?['isYouth'] ?? false;
  String? get genderIdentity => _userData?['genderIdentity'];
  String? get educationLevel => _userData?['educationLevel'];

  Future<void> checkUserRole() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null || user.phoneNumber == null) {
        _setGuestState();
        return;
      }

      _isAuthenticated = true;

      // ✅ UPDATED: Use PhoneNumberUtils for consistent phone cleaning
      String phoneId = PhoneNumberUtils.cleanForDocumentId(user.phoneNumber!);
      print('🔍 Checking user role for phone: ${user.phoneNumber} -> $phoneId');

      // Get user from unified 'users' collection
      final userDoc = await _firestore.collection('users').doc(phoneId).get();

      if (userDoc.exists) {
        _userData = userDoc.data();

        // ✅ UPDATED: Prioritize 'role' field, with fallback to 'userType'
        if (_userData!.containsKey('role')) {
          _currentRole = _userData!['role'];
        } else if (_userData!.containsKey('userType')) {
          // Map legacy userType to role
          String userType = _userData!['userType'].toString().toLowerCase();
          _currentRole = userType == 'plhiv' ? 'plhiv' : 'infoSeeker';

          // Update document with role field
          await _firestore.collection('users').doc(phoneId).update({
            'role': _currentRole,
          });
        } else if (_userData!.containsKey('yearDiagnosed')) {
          // Fallback: If has diagnosis data, assume PLHIV
          _currentRole = 'plhiv';
          await _firestore.collection('users').doc(phoneId).update({
            'role': 'plhiv',
          });
        } else {
          _currentRole = 'infoSeeker';
          await _firestore.collection('users').doc(phoneId).update({
            'role': 'infoSeeker',
          });
        }

        print('✅ User role determined: $_currentRole');
        print('📊 User data loaded: ${_userData!.keys.join(', ')}');

        // Update last login
        await _firestore.collection('users').doc(phoneId).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // 🆕 ENHANCEMENT: Try to find user with different phone format
        List<String> possibleFormats = PhoneNumberUtils.getAllPossibleFormats(
          user.phoneNumber!,
        );
        bool foundUser = false;

        for (String format in possibleFormats) {
          if (format != phoneId) {
            final fallbackDoc =
                await _firestore.collection('users').doc(format).get();
            if (fallbackDoc.exists) {
              print('🔄 Found user with legacy format, migrating...');

              _userData = fallbackDoc.data();
              _currentRole = _userData!['role'] ?? 'infoSeeker';

              // Migrate to new format
              _userData!['cleanedPhone'] = phoneId;
              await _firestore.collection('users').doc(phoneId).set(_userData!);
              await fallbackDoc.reference.delete();

              foundUser = true;
              break;
            }
          }
        }

        if (!foundUser) {
          print('🆕 Creating new user document');
          await _createNewUser(phoneId, user.phoneNumber!);
        }
      }
    } catch (e) {
      print('❌ Error checking user role: $e');
      if (_userData == null) {
        _setGuestState();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update _createNewUser method:
  Future<void> _createNewUser(String phoneId, String phoneNumber) async {
    final newUserData = {
      'phoneNumber': phoneNumber,
      'cleanedPhone': phoneId, // ✅ Store cleaned version
      'role': 'infoSeeker',
      'userType': 'InfoSeeker',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'isActive': true,
    };

    await _firestore.collection('users').doc(phoneId).set(newUserData);
    _userData = newUserData;
    _currentRole = 'infoSeeker';
  }

  void _setGuestState() {
    _currentRole = 'infoSeeker';
    _isAuthenticated = false;
    _userData = null;
  }

  // Remove the old _cleanPhoneNumber method and replace with:
  String _cleanPhoneNumber(String phone) {
    return PhoneNumberUtils.cleanForDocumentId(phone);
  }

  // Request researcher upgrade
  Future<bool> requestResearcherUpgrade({
    required String fullName,
    required String licenseNumber,
    required String institution,
    required String reason,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      String phoneId = _cleanPhoneNumber(user.phoneNumber!);

      await _firestore.collection('researcher_requests').add({
        'userId': phoneId,
        'phoneNumber': user.phoneNumber,
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

  // Check if user has pending request
  Future<Map<String, dynamic>?> getPendingRequest() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      String phoneId = _cleanPhoneNumber(user.phoneNumber!);

      final query =
          await _firestore
              .collection('researcher_requests')
              .where('userId', isEqualTo: phoneId)
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

  void logout() {
    _currentRole = 'infoSeeker';
    _isAuthenticated = false;
    _userData = null;
    notifyListeners();
  }
}
