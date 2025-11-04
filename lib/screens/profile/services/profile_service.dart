import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Load base user data (public info)
  Future<Map<String, dynamic>?> loadBaseUserData() async {
    try {
      if (currentUserId == null) return null;

      final userDoc =
          await _firestore.collection('user').doc(currentUserId).get();
      if (!userDoc.exists) return null;

      final baseData = userDoc.data() ?? {};

      // Load analytic data
      final analyticDoc =
          await _firestore.collection('analyticData').doc(currentUserId).get();
      if (analyticDoc.exists) {
        baseData.addAll(analyticDoc.data() ?? {});
      }

      // Load profile (UIC)
      final profileDoc =
          await _firestore.collection('profiles').doc(currentUserId).get();
      if (profileDoc.exists) {
        final uic = profileDoc.data()?['generatedUIC'];
        if (uic != null) baseData['generatedUIC'] = uic;
      }

      print('✅ Profile data loaded: ${baseData.keys.length} fields');
      return baseData;
    } catch (e) {
      print('❌ Failed to load base user data: $e');
      return null;
    }
  }

  /// Load secure user data (PII - requires authentication)
  Future<Map<String, dynamic>?> loadSecureUserData() async {
    try {
      if (currentUserId == null) return null;

      final secureDoc =
          await _firestore
              .collection('secureUserData')
              .doc(currentUserId)
              .get();

      if (secureDoc.exists) {
        print('🔓 Secure data loaded');
        return secureDoc.data();
      }
      return null;
    } catch (e) {
      print('❌ Failed to load secure data: $e');
      return null;
    }
  }
}
