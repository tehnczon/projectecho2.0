import 'package:flutter/material.dart';

class CareView extends StatelessWidget {
  final AnimationController animationController;

  const CareView({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final firstHalfAnimation =
        Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(
        0.2,
        0.4,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    final secondHalfAnimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(-1, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(
        0.4,
        0.6,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    final relaxFirstHalfAnimation =
        Tween<Offset>(begin: Offset(2, 0), end: Offset(0, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(
        0.2,
        0.4,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    final relaxSecondHalfAnimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(-2, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(
        0.4,
        0.6,
        curve: Curves.fastOutSlowIn,
      ),
    ));

    final imageFirstHalfAnimation =
        Tween<Offset>(begin: Offset(4, 0), end: Offset(0, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(
        0.2,
        0.4,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    final imageSecondHalfAnimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(-4, 0))
            .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(
        0.4,
        0.6,
        curve: Curves.fastOutSlowIn,
      ),
    ));

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
                position: imageFirstHalfAnimation,
                child: SlideTransition(
                  position: imageSecondHalfAnimation,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 350, maxHeight: 250),
                    child: Image.asset(
                      'assets/introduction_animation/care_image.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SlideTransition(
  position: relaxSecondHalfAnimation,
  child: SlideTransition(
    position: relaxFirstHalfAnimation,
    child: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(
          color: Colors.black, // ensure text is visible
        ),
        children: [
          TextSpan(
            text: "Here, ",
            style: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
              color: Color(0xff21B8D3),
            ),
          ),
          TextSpan(
            text: "You’re Not Alone",
            style: TextStyle(
              fontSize: 16.0,
              color: Color(0xff73B8D5),
            ),
          ),
        ],
      ),
    ),
  ),
),

              Padding(
                padding:
                    EdgeInsets.only(left: 64, right: 64, bottom: 16, top: 16),
                child: Text(
                  "Our app provides content without judgment -live confidently, safely, and with dignity. ",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff2EBCD5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
