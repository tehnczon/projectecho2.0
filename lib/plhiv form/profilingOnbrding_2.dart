import 'package:flutter/material.dart';
import 'package:projecho/model/registration_data.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfOnboard2Screen extends StatelessWidget {
  final RegistrationData registrationData;

  const ProfOnboard2Screen({super.key, required this.registrationData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32), // Top spacing
              // Image
              Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  // Text at the bottom
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 250,
                    ), // space for image to overlap
                    child: Text(
                      'Welcome to',
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF194F97),
                      ),
                    ),
                  ),

                  // Image that overlaps the text from the top
                  Positioned(
                    top: 55, // start at top of stack
                    child: Image.asset(
                      'assets/profiling/onboarding_1.png', // replace with your image path
                      width: 400, // customize size
                      height: 220, // customize size
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
                      color: Color(0xFF194F97),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'This form takes just a few minutes and covers your background, health, and wellness—all designed with care and respect.',

                style: TextStyle(fontSize: 16, color: Color(0xFF5BA2D6)),
              ),

              const SizedBox(height: 80),

              InkWell(
                onTap: () {
                  // your navigation or next logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ProfOnboard2Screen(
                            registrationData: registrationData,
                          ),
                      //
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(
                  30,
                ), // for ripple effect to match shape
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF96D2EC), // background color
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF73B8D5), // icon color
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
