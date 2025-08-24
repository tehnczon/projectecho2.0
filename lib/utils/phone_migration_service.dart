import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'phone_number_utils.dart';

class PhoneMigrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migrate user from any old phone format to standardized format
  static Future<bool> migrateUserIfNeeded() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.phoneNumber == null) return false;

      final correctPhone = PhoneNumberUtils.cleanForDocumentId(
        user!.phoneNumber!,
      );

      // Check if user already exists in correct format
      final correctDoc =
          await _firestore.collection('users').doc(correctPhone).get();
      if (correctDoc.exists) {
        print('✅ User already in correct format: $correctPhone');
        return true;
      }

      // Try to find user in any possible format
      final possibleFormats = PhoneNumberUtils.getAllPossibleFormats(
        user.phoneNumber!,
      );

      for (String format in possibleFormats) {
        if (format != correctPhone) {
          final doc = await _firestore.collection('users').doc(format).get();
          if (doc.exists) {
            print('🔄 Migrating user from $format to $correctPhone');

            final userData = doc.data()!;
            userData['cleanedPhone'] = correctPhone;
            userData['migratedAt'] = FieldValue.serverTimestamp();

            // Create new document
            await _firestore
                .collection('users')
                .doc(correctPhone)
                .set(userData);

            // Delete old document
            await doc.reference.delete();

            print('✅ Migration successful');
            return true;
          }
        }
      }

      print('ℹ️ No migration needed - user not found in any format');
      return false;
    } catch (e) {
      print('❌ Migration failed: $e');
      return false;
    }
  }

  /// Batch migrate all users (admin function)
  static Future<int> batchMigrateAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      int migratedCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final phoneNumber = data['phoneNumber'] as String?;

        if (phoneNumber != null) {
          final correctFormat = PhoneNumberUtils.cleanForDocumentId(
            phoneNumber,
          );

          if (doc.id != correctFormat) {
            print('🔄 Migrating user from ${doc.id} to $correctFormat');

            data['cleanedPhone'] = correctFormat;
            data['migratedAt'] = FieldValue.serverTimestamp();

            // Create new document
            await _firestore.collection('users').doc(correctFormat).set(data);

            // Delete old document
            await doc.reference.delete();

            migratedCount++;
          }
        }
      }

      print('✅ Batch migration complete: $migratedCount users migrated');
      return migratedCount;
    } catch (e) {
      print('❌ Batch migration failed: $e');
      return 0;
    }
  }
}
