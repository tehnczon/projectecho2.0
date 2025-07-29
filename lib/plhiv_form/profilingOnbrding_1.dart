import 'package:flutter/material.dart';
import 'package:projecho/model/registration_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/plhiv_form/mainplhivform.dart';

class ProfOnboard1Screen extends StatefulWidget {
  final RegistrationData registrationData;

  const ProfOnboard1Screen({super.key, required this.registrationData});

  @override
  State<ProfOnboard1Screen> createState() => _ProfOnboard1ScreenState();
}

class _ProfOnboard1ScreenState extends State<ProfOnboard1Screen> {
  bool showFirstText = true;

  void _onNextPressed() {
    if (showFirstText) {
      setState(() => showFirstText = false);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  PLHIVStepperScreen(registrationData: widget.registrationData),
          //
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 250),
                      child: Text(
                        'Welcome to',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF194F97),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 55,
                      child: Image.asset(
                        'assets/profiling/onboarding_1.png',
                        width: 400,
                        height: 220,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'the Profiling Form',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF194F97),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                /// ✨ Animated text section
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                  child: Text(
                    showFirstText
                        ? 'This is a safe space where your voice matters.'
                        : 'This form takes just a few minutes \nand covers your background, health, and wellness—all designed with care and respect.',
                    key: ValueKey<bool>(showFirstText),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5BA2D6),
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                InkWell(
                  onTap: _onNextPressed,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF96D2EC),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF73B8D5),
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
