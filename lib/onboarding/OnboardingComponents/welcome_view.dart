import 'package:flutter/material.dart';

class WelcomeView extends StatelessWidget {
  final AnimationController animationController;
  const WelcomeView({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final firstHalfAnimation = Tween<Offset>(
      begin: Offset(1, 0),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.6, 0.8, curve: Curves.fastOutSlowIn),
      ),
    );
    final secondHalfAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(-1, 0),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.8, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );

    final welcomeFirstHalfAnimation = Tween<Offset>(
      begin: Offset(2, 0),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.6, 0.8, curve: Curves.fastOutSlowIn),
      ),
    );

    final welcomeImageAnimation = Tween<Offset>(
      begin: Offset(4, 0),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.6, 0.8, curve: Curves.fastOutSlowIn),
      ),
    );

    return SlideTransition(
      position: firstHalfAnimation,
      child: SlideTransition(
        position: secondHalfAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50, top: 26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: welcomeImageAnimation,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 300, maxHeight: 300),
                  child: Image.asset(
                    'assets/onboarding/welcome.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SlideTransition(
                position: welcomeFirstHalfAnimation,

                child: Text(
                  "Welcome",
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 64,
                  right: 64,
                  top: 16,
                  bottom: 16,
                ),
                child: Text(
                  "Stay informed and share your story with echo",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.0),
                ),
              ),

              // Padding(
              //   padding: EdgeInsets.only(
              //       bottom: MediaQuery.of(context).padding.bottom + 16),
              //   child: InkWell(
              //     onTap: () {
              //       animationController.animateTo(0.8);
              //     },
              //     child: Container(
              //       width: 200,
              //       height: 50,
              //       decoration: BoxDecoration(
              //         color: Color.fromARGB(255, 29, 78, 156),
              //         borderRadius: BorderRadius.circular(30),
              //       ),
              //       child: Center(
              //         child: Text(
              //           "Get Started",
              //           style: TextStyle(color: Colors.white, fontSize: 16),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
