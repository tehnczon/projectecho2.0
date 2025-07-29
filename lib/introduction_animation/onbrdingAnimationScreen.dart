import 'package:flutter/material.dart';
import 'package:projecho/introduction_animation/OnboardingComponents/onbrding_3.dart';
import 'package:projecho/introduction_animation/OnboardingComponents/onbrdingController.dart';
import 'package:projecho/introduction_animation/OnboardingComponents/onbrding_4.dart';
import 'package:projecho/introduction_animation/OnboardingComponents/onbrding_2.dart';
import 'package:projecho/introduction_animation/OnboardingComponents/onbrding_1.dart';
import 'package:projecho/introduction_animation/OnboardingComponents/skip.dart';
import 'package:projecho/introduction_animation/OnboardingComponents/welcome_view.dart';
import 'package:projecho/login/login/inputNum.dart';

class MyOnboardingScreen extends StatefulWidget {
  const MyOnboardingScreen({super.key});

  @override
  _MyOnboardingScreenState createState() => _MyOnboardingScreenState();
}

class _MyOnboardingScreenState extends State<MyOnboardingScreen>
    with TickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    );
    _animationController?.animateTo(0.0);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<bool> _handleSystemBackButton() async {
    if (_animationController!.value > 0.0) {
      _onBackClick(); // Go to previous step
      return false; // Don't exit app
    } else {
      // Show confirmation dialog
      return await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Exit App?'),
                  content: Text('Do you want to exit the onboarding?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Exit'),
                    ),
                  ],
                ),
          ) ??
          false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleSystemBackButton,
      child: Scaffold(
        backgroundColor: Color(0xFFEAF1F9),
        body: ClipRect(
          child: Stack(
            children: [
              SplashView(animationController: _animationController!),
              RelaxView(animationController: _animationController!),
              CareView(animationController: _animationController!),
              MoodDiaryView(animationController: _animationController!),
              WelcomeView(animationController: _animationController!),
              TopBackSkipView(
                onBackClick: _onBackClick,
                onSkipClick: _onSkipClick,
                animationController: _animationController!,
              ),
              CenterNextButton(
                animationController: _animationController!,
                onNextClick: _onNextClick,
                onBackClick: _onBackClick, // <- pass this too!
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSkipClick() {
    _animationController?.animateTo(
      0.8,
      duration: Duration(milliseconds: 1200),
    );
  }

  void _onBackClick() {
    final value = _animationController!.value;
    if (value > 0.8) {
      _animationController?.animateTo(0.8);
    } else if (value > 0.6) {
      _animationController?.animateTo(0.6);
    } else if (value > 0.4) {
      _animationController?.animateTo(0.4);
    } else if (value > 0.2) {
      _animationController?.animateTo(0.2);
    } else {
      _animationController?.animateTo(0.0);
    }
  }

  void _onNextClick() {
    final value = _animationController!.value;
    if (value <= 0.2) {
      _animationController?.animateTo(0.4);
    } else if (value <= 0.4) {
      _animationController?.animateTo(0.6);
    } else if (value <= 0.6) {
      _animationController?.animateTo(0.8);
    } else if (value <= 0.8) {
      _signUpClick();
    }
  }

  void _signUpClick() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EnterNumberPage()),
    );
  }
}
