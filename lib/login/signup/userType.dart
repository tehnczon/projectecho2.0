import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/model/registration_data.dart';
import 'package:projecho/plhiv%20form/yeardiag.dart';
import 'package:projecho/login/signup/wlcmPrjecho.dart';

class UserTypeScreen extends StatefulWidget {
  final RegistrationData registrationData;

  const UserTypeScreen({super.key, required this.registrationData});

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  void _handleSelection(String selectedUserType) {
    setState(() {
      widget.registrationData.userType = selectedUserType;
    });

    Future.delayed(200.ms, () {
      if (selectedUserType == 'PLHIV') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>  YearDiagPage(registrationData: widget.registrationData),
          ),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const WelcomeScreen(),
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> userTypes = ['PLHIV', 'Health Information Seeker'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                "Let's get to know you! Please select your role:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              )
                  .animate()
                  .fade(duration: 500.ms)
                  .slideY(begin: 0.3)
                  .scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 12),

              // Subtitle
              const Text(
                "Your participation helps healthcare providers and researchers better understand and support communities affected by HIV.",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ).animate().fade(duration: 800.ms).slideY(begin: 0.2),

              const SizedBox(height: 24),

              // Buttons
              ...userTypes.asMap().entries.map((entry) {
                final index = entry.key;
                final type = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _handleSelection(type),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              type == 'PLHIV'
                                  ? "Person Living with HIV (PLHIV)"
                                  : "Health Information Seeker",
                              style: const TextStyle(
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ).animate(delay: (300 + index * 150).ms).fadeIn().slideY(begin: 0.2),
                );
              }),

              const SizedBox(height: 32),

              // Footer
              const Center(
                child: Text(
                  "Your information is kept confidential and secure.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ).animate().fade(duration: 1000.ms).slideY(begin: 0.3),
            ],
          ),
        ),
      ),
    );
  }
}
