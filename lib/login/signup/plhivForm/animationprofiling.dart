import 'package:flutter/material.dart';

class AnimatedTextTransition extends StatefulWidget {
  const AnimatedTextTransition({super.key});

  @override
  State<AnimatedTextTransition> createState() => _AnimatedTextTransitionState();
}

class _AnimatedTextTransitionState extends State<AnimatedTextTransition> {
  bool showFirstText = true;

  void toggleText() {
    setState(() {
      showFirstText = !showFirstText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🌀 Text with transition
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                showFirstText
                    ? "This is a safe space where your voice matters."
                    : "This form takes just a few minutes \nand covers your background, health, and wellness—all designed with care and respect.",
                key: ValueKey<bool>(showFirstText), // must be unique on change
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 40),

            /// 🔘 Tapping this changes the text
            InkWell(
              onTap: toggleText,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.5),
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  "Next",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
