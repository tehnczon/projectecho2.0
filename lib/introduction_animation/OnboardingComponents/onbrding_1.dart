import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  final AnimationController animationController;

  const SplashView({super.key, required this.animationController});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  Widget build(BuildContext context) {
    final introductionanimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(0.0, -1.0))
            .animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(
        0.0,
        0.2,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    return SlideTransition(
      position: introductionanimation,
      child: Container(
        child: SingleChildScrollView(
          child: Column(

            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top + 26,
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.top + 16,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'assets/onboarding/onboarding_1.png',
                  height: 250,
                ),
              ),
              Padding(
                padding: EdgeInsets.only( bottom: 8.0,right: 100),
                child: Text(
                  "ECHO",
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold, 
                  color: Color.fromARGB(255, 29, 78, 156)),
                ),
                
              ),
              Padding(
                padding: EdgeInsets.only(left: 64, right: 64),
                child: Text(
                  "a profiling platform for PLHIV. ECHO is your personal space to reflect, share your story and be heared.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                
                    color: Color(0xff21B8D3),
                  ),
                ),
              ),
              SizedBox(
                height: 28,
              ),
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 16),
                 child: InkWell(
                  onTap: () {
                    widget.animationController.animateTo(0.2);
                  },
                  child: Container(
                    height: 58,
                    padding: EdgeInsets.only(
                      left: 56.0,
                      right: 56.0,
                      top: 16,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(38.0),
                      color: Color(0xff96D2EC),
                    ),
                    child: Text(
                      "Let's begin",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        // ignore: use_full_hex_values_for_flutter_colors
                        color: Color.fromARGB(255, 68, 107, 124),
                      ),
                      
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }
}