import 'package:flutter/material.dart';

class RelaxView extends StatelessWidget {
  final AnimationController animationController;

  const RelaxView({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final firstHalfAnimation =
        Tween<Offset>(begin: Offset(0, 1), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.0, 0.2, curve: Curves.fastOutSlowIn),
      ),
    );

    final secondHalfAnimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(-1, 0)).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.2, 0.4, curve: Curves.fastOutSlowIn),
      ),
    );

    final textAnimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(-2, 0)).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.2, 0.4, curve: Curves.fastOutSlowIn),
      ),
    );

    final imageAnimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(-4, 0)).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.2, 0.4, curve: Curves.fastOutSlowIn),
      ),
    );

    final relaxAnimation =
        Tween<Offset>(begin: Offset(0, -2), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.0, 0.2, curve: Curves.fastOutSlowIn),
      ),
    );

    return SlideTransition(
      position: firstHalfAnimation,
      child: SlideTransition(
        position: secondHalfAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: relaxAnimation,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style.copyWith(
                      color: Colors.black, // ensure text is visible
                    ),
                    children: [
                      TextSpan(
                        text: "Tailored ",
                        
                        style: TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffB6385E),
                        ),
                      ),
                      TextSpan(
                        text: "information for you",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Color(0xffB0375E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SlideTransition(
                position: textAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: Text(
                    "Access articles, wellness tips, and mental health support based on your profile.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xffD34156)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SlideTransition(
                position: imageAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 350, maxHeight: 250),
                  child: Image.asset(
                    'assets/introduction_animation/relax_image.png',
                    fit: BoxFit.contain,
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
