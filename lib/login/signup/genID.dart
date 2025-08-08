import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/models/registration_data.dart';
import 'package:projecho/login/signup/userType.dart';

class GenderSelectionScreen extends StatelessWidget {
  final RegistrationData registrationData;

  const GenderSelectionScreen({super.key, required this.registrationData});

  void _handleSelection(BuildContext context, String gender) {
    registrationData.genderIdentity = gender;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => UserTypeScreen(registrationData: registrationData),
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
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                  'What’s Your Gender Identity?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                )
                .animate()
                .fade(duration: 500.ms)
                .slideY(begin: 0.3, duration: 500.ms),

            const SizedBox(height: 24),

            ...[
              'Male',
              'Female',
              'Transgender',
              'other',
              'Non-label',
            ].asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _handleSelection(context, label),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fade(duration: (600 + index * 100).ms)
                    .slideY(begin: 0.3),
              );
            }),

            const SizedBox(height: 24),
            const Text(
              'We respect all gender identities. Choose the one that best reflects you — your journey matters.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ).animate().fade(duration: 1000.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }
}
