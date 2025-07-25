import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/model/registration_data.dart';
import 'package:projecho/plhiv%20form/trtmentHub.dart';

class ConfirmatoryCodeScreen extends StatefulWidget {
  final RegistrationData registrationData;

  const ConfirmatoryCodeScreen({super.key, required this.registrationData});

  @override
  State<ConfirmatoryCodeScreen> createState() => _ConfirmatoryCodeScreenState();
}

class _ConfirmatoryCodeScreenState extends State<ConfirmatoryCodeScreen> {
  final TextEditingController _codeController = TextEditingController();

  void _onSubmit() {
    widget.registrationData.confirmatoryCode = _codeController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                TreatmentHubScreen(registrationData: widget.registrationData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Do you have a confirmatory code?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ).animate().fade(duration: 500.ms).slideY(begin: 0.3),

              const SizedBox(height: 12),

              const Text(
                "This code helps us verify your HIV diagnosis confidentially. It is used only for validation and will not be shared.",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ).animate().fade(duration: 800.ms).slideY(begin: 0.2),

              const SizedBox(height: 24),

              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: "Enter Code (Optional)",
                  labelStyle: const TextStyle(
                    color: Color.fromARGB(255, 135, 136, 138),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ).animate().fade(duration: 600.ms).slideY(begin: 0.2),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ).animate().fade().slideY(begin: 0.1),

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: _onSubmit,
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
