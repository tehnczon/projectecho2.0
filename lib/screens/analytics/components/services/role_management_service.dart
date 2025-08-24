import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projecho/screens/analytics/components/models/user_model.dart'; // Adjust the import based on your project structure
import 'package:projecho/utils/phone_number_utils.dart';

class RoleManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ UPDATED: Use standardized phone cleaning
  Future<String> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.phoneNumber == null) {
        return 'infoSeeker';
      }

      // 🔧 FIX: Use PhoneNumberUtils for consistent phone cleaning
      String phoneId = PhoneNumberUtils.cleanForDocumentId(user.phoneNumber!);
      print('🔍 Getting role for cleaned phone: $phoneId');

      // Check if user document exists
      final userDoc = await _firestore.collection('users').doc(phoneId).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;

        // Update last login
        await _firestore.collection('users').doc(phoneId).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        // ✅ UPDATED: Prioritize 'role' field over 'userType'
        if (data.containsKey('role')) {
          return data['role'] ?? 'infoSeeker';
        } else if (data.containsKey('userType')) {
          // Fallback for legacy data
          String userType = data['userType'].toString().toLowerCase();
          String mappedRole = userType == 'plhiv' ? 'plhiv' : 'infoSeeker';

          // Update document to use 'role' field
          await _firestore.collection('users').doc(phoneId).update({
            'role': mappedRole,
          });

          return mappedRole;
        }

        return 'infoSeeker';
      } else {
        // 🆕 ENHANCEMENT: Try migration from old phone format
        List<String> possibleFormats = PhoneNumberUtils.getAllPossibleFormats(
          user.phoneNumber!,
        );

        for (String format in possibleFormats) {
          if (format != phoneId) {
            // Skip the already-tried format
            final fallbackDoc =
                await _firestore.collection('users').doc(format).get();
            if (fallbackDoc.exists) {
              print('🔄 Migrating user from format $format to $phoneId');

              final data = fallbackDoc.data()!;
              data['cleanedPhone'] = phoneId;

              // Create new document with correct phone format
              await _firestore.collection('users').doc(phoneId).set(data);

              // Delete old document
              await fallbackDoc.reference.delete();

              return data['role'] ?? 'infoSeeker';
            }
          }
        }

        // Create new user document with standardized phone
        await _firestore.collection('users').doc(phoneId).set({
          'phoneNumber': user.phoneNumber,
          'cleanedPhone': phoneId,
          'role': 'infoSeeker',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'isActive': true,
        });

        return 'infoSeeker';
      }
    } catch (e) {
      print('❌ Error getting user role: $e');
      return 'infoSeeker';
    }
  }

  // ✅ UPDATED: Admin function to upgrade user role
  Future<bool> upgradeUserRole(String phoneNumber, String newRole) async {
    try {
      String phoneId = PhoneNumberUtils.cleanForDocumentId(phoneNumber);

      await _firestore.collection('users').doc(phoneId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Role upgraded for $phoneId to $newRole');
      return true;
    } catch (e) {
      print('❌ Error upgrading user role: $e');
      return false;
    }
  }

  // ✅ UPDATED: Get all users with researcher role
  Stream<List<UserModel>> getResearchers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'researcher')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => UserModel.fromMap({'id': doc.id, ...doc.data()}),
                  )
                  .toList(),
        );
  }

  // 🆕 NEW: Batch migrate users from old phone format
  Future<void> migrateLegacyPhoneFormats() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      int migratedCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final docId = doc.id;
        final phoneNumber = data['phoneNumber'] as String?;

        if (phoneNumber != null) {
          final correctFormat = PhoneNumberUtils.cleanForDocumentId(
            phoneNumber,
          );

          if (docId != correctFormat) {
            print('🔄 Migrating user from $docId to $correctFormat');

            // Update data with correct phone
            data['cleanedPhone'] = correctFormat;

            // Create new document
            await _firestore.collection('users').doc(correctFormat).set(data);

            // Delete old document
            await doc.reference.delete();

            migratedCount++;
          }
        }
      }

      print('✅ Migration complete: $migratedCount users migrated');
    } catch (e) {
      print('❌ Migration failed: $e');
    }
  }
}
