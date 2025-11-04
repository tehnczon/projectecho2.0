import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final LocalAuthentication _localAuth = LocalAuthentication();

  User? get currentUser => _auth.currentUser;

  /// Biometric authentication
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isSupported) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to view sensitive information',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      print('❌ Biometric auth error: $e');
      return false;
    }
  }

  /// Logout from all services
  Future<void> logout() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // Check if Google is linked
        final isGoogleLinked = user.providerData.any(
          (p) => p.providerId == 'google.com',
        );

        if (isGoogleLinked) {
          await _googleSignIn.signOut();
          print('✅ Google sign out');
        }
      }

      await _auth.signOut();
      print('✅ Firebase sign out');
    } catch (e) {
      print('❌ Logout error: $e');
      rethrow;
    }
  }
}
