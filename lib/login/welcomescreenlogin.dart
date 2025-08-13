import 'package:flutter/material.dart';
import 'package:projecho/login/login/inputNum.dart';
import 'package:projecho/login/animation/SmoothPageTransition.dart'; // Import the utilities

class AnimatedEnterNumberPage extends StatefulWidget {
  const AnimatedEnterNumberPage({super.key});

  @override
  _AnimatedEnterNumberPageState createState() =>
      _AnimatedEnterNumberPageState();
}

class _AnimatedEnterNumberPageState extends State<AnimatedEnterNumberPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeOutBack),
    );

    // Start animation with slight delay
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController?.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation!,
          child: SlideTransition(
            position: _slideAnimation!,
            child: ScaleTransition(
              scale: _scaleAnimation!,
              child: EnterNumberPage(),
            ),
          ),
        );
      },
    );
  }
}

class StandaloneWelcomeScreen extends StatefulWidget {
  const StandaloneWelcomeScreen({super.key});

  @override
  _StandaloneWelcomeScreenState createState() =>
      _StandaloneWelcomeScreenState();
}

class _StandaloneWelcomeScreenState extends State<StandaloneWelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _fadeAnimation;
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );

    // Start animation after a brief delay
    Future.delayed(Duration(milliseconds: 200), () {
      _animationController?.forward();
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  // Move the _navigateToLogin method INSIDE the State class
  void _navigateToLogin() async {
    // First animate out the current content
    await _animationController?.reverse();

    // Then navigate with custom smooth transition
    if (mounted) {
      Navigator.of(context).pushReplacement(
        SmoothPageTransition(
          child: AnimatedEnterNumberPage(),
          duration: Duration(milliseconds: 900),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAF1F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation!,
                    child: SlideTransition(
                      position: _slideAnimation!,
                      child: Column(
                        children: [
                          // Welcome Image
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: 300,
                              maxHeight: 300,
                            ),
                            child: Image.asset(
                              'assets/onboarding/welcome.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 32),

                          // Welcome Text
                          Text(
                            "Welcome Back!",
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 29, 78, 156),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Description
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              "Continue your journey with echo. Stay informed and share your story.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          SizedBox(height: 48),

                          // Get Started Button
                          AnimatedScale(
                            scale: _isButtonPressed ? 0.95 : 1.0,
                            duration: Duration(milliseconds: 100),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() => _isButtonPressed = true);
                                  Future.delayed(
                                    Duration(milliseconds: 100),
                                    () {
                                      setState(() => _isButtonPressed = false);
                                    },
                                  );
                                  _navigateToLogin();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    29,
                                    78,
                                    156,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  "Input your Number",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
