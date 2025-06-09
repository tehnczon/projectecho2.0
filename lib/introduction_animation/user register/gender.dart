import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/introduction_animation/user register/auth.dart';

class GenderSelectionScreen extends StatelessWidget {
  const GenderSelectionScreen({super.key});

  void _handleSelection(BuildContext context, String gender) {
    // Navigate to the next screen after the gender is selected
    print('Selected: $gender');
    
    // Example: navigate to another screen (e.g., preferences or confirmation)
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordScreen(),
        ),
      ); // Replace with your next screen
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
            // Title
            const Text(
              'What’s your gender?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            )
                .animate()
                .fade(duration: 500.ms)
                .slideY(begin: 0.3, duration: 500.ms),

            const SizedBox(height: 24),

            // Male Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _handleSelection(context, 'Male'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Male",
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                  ],
                ),
              ),
            )
                .animate()
                .fade(duration: 600.ms)
                .slideY(begin: 0.3, duration: 600.ms),

            const SizedBox(height: 16),

            // Female Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _handleSelection(context, 'Female'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Female",
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                  ],
                ),
              ),
            )
                .animate()
                .fade(duration: 700.ms)
                .slideY(begin: 0.3, duration: 700.ms),

            const SizedBox(height: 16),

            // Non-binary Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _handleSelection(context, 'Non-binary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Non-binary",
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                  ],
                ),
              ),
            )
                .animate()
                .fade(duration: 800.ms)
                .slideY(begin: 0.3, duration: 800.ms),

            const SizedBox(height: 16),

            // Prefer not to say Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _handleSelection(context, 'Prefer not to say'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Prefer not to say",
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                  ],
                ),
              ),
            )
                .animate()
                .fade(duration: 900.ms)
                .slideY(begin: 0.3, duration: 900.ms),

            const SizedBox(height: 24),

            // Disclaimer text
            const Text(
              'You can change who sees your gender on your profile later.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fade(duration: 1000.ms)
                .slideY(begin: 0.3, duration: 1000.ms),
          ],
        ),
      ),
    );
  }
}