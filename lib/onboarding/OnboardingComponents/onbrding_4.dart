import 'package:flutter/material.dart';

class MoodDiaryView extends StatelessWidget {
  final AnimationController animationController;

  const MoodDiaryView({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final firstHalfAnimation = Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
        .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.4, 0.6, curve: Curves.fastOutSlowIn),
    ));

    final secondHalfAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(-1, 0))
        .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.6, 0.8, curve: Curves.fastOutSlowIn),
    ));

    final moodFirstHalfAnimation = Tween<Offset>(begin: Offset(2, 0), end: Offset(0, 0))
        .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.4, 0.6, curve: Curves.fastOutSlowIn),
    ));

    final moodSecondHalfAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(-2, 0))
        .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.6, 0.8, curve: Curves.fastOutSlowIn),
    ));

    final imageFirstHalfAnimation = Tween<Offset>(begin: Offset(4, 0), end: Offset(0, 0))
        .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.4, 0.6, curve: Curves.fastOutSlowIn),
    ));

    final imageSecondHalfAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(-4, 0))
        .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.6, 0.8, curve: Curves.fastOutSlowIn),
    ));

    return SlideTransition(
      position: firstHalfAnimation,
      child: SlideTransition(
        position: secondHalfAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Centered title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Secured",
                      style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "profile",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Description
                SlideTransition(
                  position: moodFirstHalfAnimation,
                  child: SlideTransition(
                    position: moodSecondHalfAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                      child: Text(
                        "Your profile stays confidential. You choose what to share, and you’re always in control of your experience.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                // Centered Image
                SlideTransition(
                  position: imageFirstHalfAnimation,
                  child: SlideTransition(
                    position: imageSecondHalfAnimation,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 350, maxHeight: 250),
                      child: Image.asset(
                        'assets/onboarding/onboarding_4.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
