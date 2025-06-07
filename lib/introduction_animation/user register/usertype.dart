import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UserTypeScreen extends StatelessWidget {
  const UserTypeScreen({super.key});

  void _handleSelection(BuildContext context, String userType) {
  // Navigate to the BirthdateScreen after the user selects the user type
  print('Selected: $userType');
  
  // Example: navigate to the BirthdateScreen
  Navigator.pushNamed(context, '/birthdate'); // This navigates to the BirthdateScreen
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
              'I am signing up as a:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            )
                .animate()
                .fade(duration: 500.ms)
                .slideY(begin: 0.3, duration: 500.ms),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _handleSelection(context, 'PLHIV'),
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
                      "Person living with HIV (PLHIV)",
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

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _handleSelection(context, 'Seeker'),
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
                      "Health information seeker",
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

            const SizedBox(height: 24),

            const Text(
              'All personal information, including health-related data, is handled with strict confidentiality and stored securely in accordance with data protection standards.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fade(duration: 800.ms)
                .slideY(begin: 0.3, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}