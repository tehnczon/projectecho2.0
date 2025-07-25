import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projecho/mainPage.dart';

class ForgotPasswordFlow extends StatefulWidget {
  const ForgotPasswordFlow({super.key});

  @override
  State<ForgotPasswordFlow> createState() => _ForgotPasswordFlowState();
}

class _ForgotPasswordFlowState extends State<ForgotPasswordFlow> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  Timer? _inactivityTimer;

  @override
void initState() {
  super.initState();

  // Wait until the first frame is rendered before showing the dialog
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _showConfirmationDialog();
  });

  _startInactivityTimer();
}


  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: 2), () async {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logged out due to inactivity")),
        );
      }
    });
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  void _showConfirmationDialog() {
    final TextEditingController _confirmTextController = TextEditingController();
    String typedText = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Confirm Password Reset"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Type the phrase below to proceed:"),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Text(
                    "reset my password",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmTextController,
                  onChanged: (value) {
                    setState(() {
                      typedText = value.trim().toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Type here...",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // go back to login
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: typedText == "reset my password"
                    ? () => Navigator.pop(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("Yes, Continue"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handlePasswordReset() async {
    _resetInactivityTimer();

    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showSnackBar("Please fill in both fields");
    } else if (newPass != confirmPass) {
      _showSnackBar("Passwords do not match");
    } else if (!_isSecure(newPass)) {
      _showSnackBar("Password must be strong: 8+ chars, uppercase, number, symbol");
    } else {
      try {
        final user = FirebaseAuth.instance.currentUser;
        await user?.updatePassword(newPass);
        _showSnackBar("Password updated successfully");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } catch (e) {
        _showSnackBar("Failed to update password: $e");
      }
    }
  }

  bool _isSecure(String pass) {
    return pass.length >= 8 &&
        pass.contains(RegExp(r'[A-Z]')) &&
        pass.contains(RegExp(r'[0-9]')) &&
        pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetInactivityTimer,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Reset Password"),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Create a new password",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _newPasswordController,
          obscureText: !_showPassword,
          onChanged: (_) => _resetInactivityTimer(),
          decoration: InputDecoration(
            hintText: "New Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: !_showPassword,
          onChanged: (_) => _resetInactivityTimer(),
          decoration: InputDecoration(
            hintText: "Confirm Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text("Show Passwords"),
          value: _showPassword,
          onChanged: (value) {
            setState(() => _showPassword = value);
            _resetInactivityTimer();
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _handlePasswordReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text("Reset Password"),
          ),
        ),
      ],
    ),
  ),
),

    )
    );
  }
}
