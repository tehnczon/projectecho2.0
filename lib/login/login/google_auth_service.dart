// google_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with Google - ALWAYS shows account picker
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // IMPORTANT: Sign out first to force account picker
      await _googleSignIn.signOut();

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Store or update Google account info
      await _storeGoogleAccountInfo(userCredential.user!);

      return userCredential;
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      rethrow;
    }
  }

  // Link Google account to existing phone number account
  Future<bool> linkGoogleAccount() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      // Sign out from Google first to show account picker
      await _googleSignIn.signOut();

      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Link the Google credential to the current user
      await currentUser.linkWithCredential(credential);

      // Update user document with Google info
      await _storeGoogleAccountInfo(currentUser, isLinking: true);

      return true;
    } catch (e) {
      if (e.toString().contains('credential-already-in-use')) {
        throw Exception(
          'This Google account is already linked to another user',
        );
      }
      print('❌ Error linking Google account: $e');
      rethrow;
    }
  }

  // Link phone number to existing Google account
  Future<bool> linkPhoneNumber(String verificationId, String smsCode) async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      // Create phone credential
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Link the phone credential to the current user
      await currentUser.linkWithCredential(credential);

      // Update user document with phone info
      await _firestore.collection('user').doc(currentUser.uid).set({
        'phone': currentUser.phoneNumber,
        'phoneLinked': true,
        'phoneLinkedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Phone number linked successfully');
      return true;
    } catch (e) {
      if (e.toString().contains('credential-already-in-use')) {
        throw Exception('This phone number is already linked to another user');
      }
      print('❌ Error linking phone number: $e');
      rethrow;
    }
  }

  // Store Google account information
  Future<void> _storeGoogleAccountInfo(
    User user, {
    bool isLinking = false,
  }) async {
    final googleEmail = user.email;
    final googleDisplayName = user.displayName;
    final googlePhotoUrl = user.photoURL;

    await _firestore.collection('user').doc(user.uid).set({
      'googleEmail': googleEmail,
      'googleDisplayName': googleDisplayName,
      'googlePhotoUrl': googlePhotoUrl,
      'googleLinked': true,
      'googleLinkedAt': FieldValue.serverTimestamp(),
      if (!isLinking) 'signInMethod': 'google',
      if (!isLinking) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print('✅ Google account info stored for UID: ${user.uid}');
  }

  // Unlink Google account
  Future<void> unlinkGoogleAccount() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      // Check if user has phone authentication as backup
      final hasPhone = currentUser.providerData.any(
        (info) => info.providerId == 'phone',
      );

      if (!hasPhone) {
        throw Exception(
          'Cannot unlink Google account. Link a phone number first for account recovery.',
        );
      }

      // Unlink Google provider
      await currentUser.unlink('google.com');

      // Update Firestore
      await _firestore.collection('user').doc(currentUser.uid).update({
        'googleLinked': false,
        'googleUnlinkedAt': FieldValue.serverTimestamp(),
      });

      // Sign out from Google
      await _googleSignIn.signOut();

      print('✅ Google account unlinked successfully');
    } catch (e) {
      print('❌ Error unlinking Google account: $e');
      rethrow;
    }
  }

  // Unlink phone number
  Future<void> unlinkPhoneNumber() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      // Check if user has Google authentication as backup
      final hasGoogle = currentUser.providerData.any(
        (info) => info.providerId == 'google.com',
      );

      if (!hasGoogle) {
        throw Exception(
          'Cannot unlink phone number. Link a Google account first for account recovery.',
        );
      }

      // Unlink phone provider
      await currentUser.unlink('phone');

      // Update Firestore
      await _firestore.collection('user').doc(currentUser.uid).update({
        'phoneLinked': false,
        'phoneUnlinkedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Phone number unlinked successfully');
    } catch (e) {
      print('❌ Error unlinking phone number: $e');
      rethrow;
    }
  }

  // Check if current user has Google linked
  Future<bool> isGoogleLinked() async {
    final User? user = _auth.currentUser;
    if (user == null) return false;

    return user.providerData.any((info) => info.providerId == 'google.com');
  }

  // Check if current user has phone linked
  Future<bool> isPhoneLinked() async {
    final User? user = _auth.currentUser;
    if (user == null) return false;

    return user.providerData.any((info) => info.providerId == 'phone');
  }

  // Get Google account info
  Future<Map<String, dynamic>?> getGoogleAccountInfo() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('user').doc(user.uid).get();
    final data = doc.data();

    if (data?['googleLinked'] == true) {
      return {
        'email': data?['googleEmail'],
        'displayName': data?['googleDisplayName'],
        'photoUrl': data?['googlePhotoUrl'],
      };
    }

    return null;
  }

  // Get phone number info
  Future<String?> getPhoneNumber() async {
    final User? user = _auth.currentUser;
    if (user == null) return null;

    return user.phoneNumber;
  }

  // Get all linked accounts info
  Future<Map<String, dynamic>> getLinkedAccounts() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return {'hasGoogle': false, 'hasPhone': false};
    }

    final hasGoogle = user.providerData.any(
      (info) => info.providerId == 'google.com',
    );
    final hasPhone = user.providerData.any(
      (info) => info.providerId == 'phone',
    );

    return {
      'hasGoogle': hasGoogle,
      'hasPhone': hasPhone,
      'googleEmail': hasGoogle ? user.email : null,
      'phoneNumber': hasPhone ? user.phoneNumber : null,
    };
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
