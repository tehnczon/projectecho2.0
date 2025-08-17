import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdjustedRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Clean phone number to match Firestore document ID format
  String cleanPhoneNumber(String phone) {
    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // If it starts with 63 (Philippines), keep it
    // Otherwise, return as is
    if (cleaned.startsWith('63')) {
      return cleaned;
    }
    return cleaned;
  }

  // Get user role based on your structure
  Future<String> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.phoneNumber == null) {
        return 'basicUser';
      }

      String phoneNumber = user.phoneNumber!;
      String cleanedPhone = cleanPhoneNumber(phoneNumber);

      // Check if super admin first (using UID)
      final adminDoc =
          await _firestore.collection('super_admin').doc(user.uid).get();

      if (adminDoc.exists) {
        return 'admin';
      }

      // Check if researcher (using phone number)
      // Try multiple formats
      final formats = [
        phoneNumber, // Original format (+639123456789)
        cleanedPhone, // Cleaned format (639123456789)
        phoneNumber.replaceAll('+63', ''), // Without +63
        phoneNumber.replaceAll('+', ''), // Without +
      ];

      for (String format in formats) {
        final researcherDoc =
            await _firestore.collection('researchers').doc(format).get();

        if (researcherDoc.exists) {
          return 'researcher';
        }
      }

      // Check users collection for stored role (if you add it)
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
