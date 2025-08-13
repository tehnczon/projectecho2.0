import 'package:flutter/material.dart';
import 'package:projecho/login/login/inputNum.dart';

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
