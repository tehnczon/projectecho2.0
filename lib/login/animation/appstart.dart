// lib/login/animation/appstart.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projecho/onboarding/onbrdingAnimationScreen.dart' as onboarding;
import 'package:projecho/main/mainPage.dart';
import 'package:projecho/login/welcomescreenlogin.dart'; // Your standalone welcome screen

class CustomSplashScreen extends StatefulWidget {
  final Function(Widget) onInitializationComplete;

  const CustomSplashScreen({super.key, required this.onInitializationComplete});

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<Color?> _backgroundColor;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    // Text animations
    _textController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlide = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Background animation
    _backgroundController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _backgroundColor = ColorTween(
      begin: Color(0xFFEAF1F9),
      end: Color(0xFFE3F2FD),
    ).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
  }

  void _startSplashSequence() async {
    // Start background animation
    _backgroundController.forward();

    // Delay then start logo
    await Future.delayed(Duration(milliseconds: 300));
    _logoController.forward();

    // Delay then start text
    await Future.delayed(Duration(milliseconds: 600));
    _textController.forward();

    // Initialize app in background
    await Future.delayed(Duration(milliseconds: 800));
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate minimum splash time for good UX
      await Future.delayed(Duration(milliseconds: 1500));

      // Check user state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      User? currentUser = FirebaseAuth.instance.currentUser;

      Widget nextScreen;

      if (!hasSeenOnboarding) {
        nextScreen = onboarding.MyOnboardingScreen();
      } else if (currentUser != null) {
        nextScreen = MainPage();
      } else {
        nextScreen = WelcomeScreen();
      }

      // Animate out and navigate
      await _animateOut();
      widget.onInitializationComplete(nextScreen);
    } catch (e) {
      print('Initialization error: $e');
      widget.onInitializationComplete(onboarding.MyOnboardingScreen());
    }
  }

  Future<void> _animateOut() async {
    await Future.wait([
      _logoController.reverse(),
      _textController.reverse(),
      _backgroundController.reverse(),
    ]);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoController,
        _textController,
        _backgroundController,
      ]),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundColor.value,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundColor.value ?? Color(0xFFEAF1F9),
                  Color(0xFFE8F4FD),
                  Color(0xFFF0F8FF),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Floating particles effect
                ..._buildFloatingParticles(),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Custom Logo Image
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(
                                    255,
                                    29,
                                    78,
                                    156,
                                  ).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                8,
                              ), // Add some padding around the image
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 104,
                                height: 104,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to icon if image fails to load
                                  return Icon(
                                    Icons.campaign_rounded,
                                    size: 60,
                                    color: Color.fromARGB(255, 29, 78, 156),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),

                      // App name
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textOpacity,
                          child: Text(
                            'ECHO',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 29, 78, 156),
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black26,
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Loading indicator
                      FadeTransition(
                        opacity: _textOpacity,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 29, 78, 156),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(6, (index) {
      return Positioned(
        left: (index * 60.0) % MediaQuery.of(context).size.width,
        top: (index * 80.0) % MediaQuery.of(context).size.height,
        child: AnimatedBuilder(
          animation: _backgroundController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                20 * _backgroundController.value * (index % 2 == 0 ? 1 : -1),
                30 * _backgroundController.value * (index % 3 == 0 ? 1 : -1),
              ),
              child: Opacity(
                opacity: 0.1 * _backgroundController.value,
                child: Container(
                  width: 20 + (index * 5),
                  height: 20 + (index * 5),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 29, 78, 156),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
