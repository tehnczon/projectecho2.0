import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/models/registration_data.dart';
import 'package:projecho/plhiv_form/profilingOnbrding_1.dart';
// import 'package:projecho/next_screen.dart'; // TODO: Replace with actual next screen

class TreatmentHubScreen extends StatefulWidget {
  final RegistrationData registrationData;

  const TreatmentHubScreen({super.key, required this.registrationData});

  @override
  State<TreatmentHubScreen> createState() => _TreatmentHubScreenState();
}

class _TreatmentHubScreenState extends State<TreatmentHubScreen> {
  final TextEditingController _hubController = TextEditingController();

  void _onContinue() {
    if (_hubController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your treatment hub.")),
      );
      return;
    }

    widget.registrationData.treatmentHub = _hubController.text.trim();

    // TODO: Navigate to next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                ProfOnboard1Screen(registrationData: widget.registrationData),
        //
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
                "Where do you receive your treatment?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ).animate().fade(duration: 500.ms).slideY(begin: 0.3),

              const SizedBox(height: 12),

              const Text(
                "Let us know where you currently receive treatment or support. This helps us understand how to better serve your needs. Your response is kept private.",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ).animate().fade(duration: 800.ms).slideY(begin: 0.2),

              const SizedBox(height: 24),

              TextField(
                controller: _hubController,
                decoration: InputDecoration(
                  labelText: "Enter Treatment Hub",
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
                  onPressed: _onContinue,
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
            ],
          ),
        ),
      ),
    );
  }
}
