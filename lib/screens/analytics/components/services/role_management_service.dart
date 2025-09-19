import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projecho/screens/analytics/components/models/user_model.dart'; // Adjust the import based on your project structure

class RoleManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check or create user role after phone auth
  Future<String> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.phoneNumber == null) {
        return 'basicUser';
      }

      // Use phone number as document ID (remove + and spaces)
      String phoneId = user.phoneNumber!.replaceAll(RegExp(r'[^\d]'), '');

      // Check if user document exists
      final userDoc = await _firestore.collection('user').doc(phoneId).get();

      if (userDoc.exists) {
        // Update last login
        await _firestore.collection('user').doc(phoneId).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        return userDoc.data()?['role'] ?? 'basicUser';
      } else {
        // Create new user document with basic role
        await _firestore.collection('user').doc(phoneId).set({
          'phoneNumber': user.phoneNumber,
          'role': 'basicUser',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'isActive': true,
        });
        return 'basicUser';
      }
    } catch (e) {
      print('Error getting user role: $e');
      return 'basicUser';
    }
  }

  // Admin function to upgrade user role
  Future<bool> upgradeUserRole(String phoneNumber, String newRole) async {
    try {
      String phoneId = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      await _firestore.collection('user').doc(phoneId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error upgrading user role: $e');
      return false;
    }
  }

  // Get all user with researcher role (for admin panel)
  Stream<List<UserModel>> getResearchers() {
    return _firestore
        .collection('user')
        .where('role', isEqualTo: 'researcher')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => UserModel.fromMap(doc.data()))
                  .toList(),
        );
  }
}
