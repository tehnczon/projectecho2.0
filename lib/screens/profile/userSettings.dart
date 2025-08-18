import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:projecho/screens/analytics/researcher_request_screen.dart';

class BiometricAuthPage extends StatefulWidget {
  const BiometricAuthPage({super.key});

  @override
  State<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool canCheckBiometrics = false;
  bool isDeviceSupported = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    final bool canCheck = await auth.canCheckBiometrics;
    final bool isSupported = await auth.isDeviceSupported();

    setState(() {
      canCheckBiometrics = canCheck;
      isDeviceSupported = isSupported;
    });

    debugPrint('canCheckBiometrics: $canCheck');
    debugPrint('isDeviceSupported: $isSupported');
  }

  Future<void> _authenticate() async {
    try {
      if (!canCheckBiometrics || !isDeviceSupported) {
        _showError('Biometric authentication not available.');
        return;
      }

      final bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate using Face ID',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UpgradeRequestScreen()),
        );
      } else {
        _showError('Authentication failed.');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face ID Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: _authenticate,
          child: const Text('Authenticate with Face ID'),
        ),
      ),
    );
  }
}

class AuthSuccessPage extends StatelessWidget {
  const AuthSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('✅ Authenticated!')));
  }
}
