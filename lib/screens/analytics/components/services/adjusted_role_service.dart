import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projecho/utils/phone_number_utils.dart';

class AdjustedRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Clean phone number to match Firestore document ID format
  String cleanPhoneNumber(String phone) {
    return PhoneNumberUtils.cleanForDocumentId(phone);
  }

  // Get user role based on your structure
  Future<String> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.phoneNumber == null) {
        return 'basicUser';
      }

      // ✅ Use standardized cleaning
      String cleanedPhone = PhoneNumberUtils.cleanForDocumentId(
        user.phoneNumber!,
      );

      // Check if super admin first (using UID)
      final adminDoc =
          await _firestore.collection('super_admin').doc(user.uid).get();
      if (adminDoc.exists) {
        return 'admin';
      }

      // Check if researcher
      final researcherDoc =
          await _firestore.collection('researchers').doc(cleanedPhone).get();
      if (researcherDoc.exists) {
        return 'researcher';
      }

      // Check users collection for stored role
      final userDoc =
          await _firestore.collection('users').doc(cleanedPhone).get();
      if (userDoc.exists) {
        return userDoc.data()?['role'] ?? 'basicUser';
      }

      // Default to basic user
      return 'basicUser';
    } catch (e) {
      print('Error getting user role: $e');
      return 'basicUser';
    }
  }

  // Add researcher (for super admin use)
  Future<bool> addResearcher(
    String phoneNumber,
    Map<String, dynamic> data,
  ) async {
    try {
      String cleanedPhone = cleanPhoneNumber(phoneNumber);

      // Add to researchers collection
      await _firestore.collection('researchers').doc(cleanedPhone).set({
        'phoneNumber': phoneNumber,
        'cleanedPhone': cleanedPhone,
        'addedAt': FieldValue.serverTimestamp(),
        'addedBy': _auth.currentUser?.uid,
        'isActive': true,
        ...data,
      });

      // Also update users collection if it exists
      await _firestore.collection('users').doc(cleanedPhone).set({
        'phoneNumber': phoneNumber,
        'role': 'researcher',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error adding researcher: $e');
      return false;
    }
  }

  // Remove researcher access
  Future<bool> removeResearcher(String phoneNumber) async {
    try {
      String cleanedPhone = cleanPhoneNumber(phoneNumber);

      // Delete from researchers collection
      await _firestore.collection('researchers').doc(cleanedPhone).delete();

      // Update users collection to basic user
      await _firestore.collection('users').doc(cleanedPhone).update({
        'role': 'basicUser',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error removing researcher: $e');
      return false;
    }
  }

  // Get all researchers
  Stream<List<Map<String, dynamic>>> getResearchers() {
    return _firestore
        .collection('researchers')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList(),
        );
  }
}
