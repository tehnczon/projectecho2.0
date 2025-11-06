import 'package:flutter/material.dart';

class SmoothPageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;
  final Curve curve;

  SmoothPageTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOutCubic,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         reverseTransitionDuration: Duration(milliseconds: 400),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return _buildTransition(animation, secondaryAnimation, child);
         },
       );

  static Widget _buildTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Multi-layered transition combining slide, fade, and scale

    // Slide from right
    var slideAnimation = Tween(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Fade in
    var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    // Scale with bounce effect
    var scaleAnimation = Tween(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Background fade for previous page
    var backgroundFade = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    return Stack(
      children: [
        // Fading background effect
        FadeTransition(
          opacity: backgroundFade,
          child: Container(color: Color(0xFFEAF1F9).withOpacity(0.5)),
        ),

        // Main transition
        SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(scale: scaleAnimation, child: child),
          ),
        ),
      ],
    );
  }
}

// Custom transition with ripple effect
class RipplePageTransition extends PageRouteBuilder {
  final Widget child;
  final Offset? startPosition;

  RipplePageTransition({required this.child, this.startPosition})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: const Duration(milliseconds: 900),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _buildRippleTransition(animation, child, startPosition);
        },
      );

  static Widget _buildRippleTransition(
    Animation<double> animation,
    Widget child,
    Offset? startPosition,
  ) {
    var rippleAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCirc),
      ),
    );

    var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return ClipPath(
          clipper: CircleRevealClipper(
            fraction: rippleAnimation.value,
            centerOffset: startPosition ?? Offset(0.5, 0.5),
          ),
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }
}

class CircleRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset centerOffset;

  CircleRevealClipper({required this.fraction, required this.centerOffset});

  @override
  Path getClip(Size size) {
    final center = Offset(
      size.width * centerOffset.dx,
      size.height * centerOffset.dy,
    );

    final radius = (size.longestSide * fraction) * 1.2;

    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) {
    return oldClipper.fraction != fraction ||
        oldClipper.centerOffset != centerOffset;
  }
}

// Shared element transition
class SharedAxisTransition extends PageRouteBuilder {
  final Widget child;
  final SharedAxisTransitionType transitionType;

  SharedAxisTransition({
    required this.child,
    this.transitionType = SharedAxisTransitionType.horizontal,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: const Duration(milliseconds: 600),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return _buildSharedAxisTransition(
             animation,
             secondaryAnimation,
             child,
             transitionType,
           );
         },
       );

  static Widget _buildSharedAxisTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    SharedAxisTransitionType type,
  ) {
    Offset primaryBegin, primaryEnd;

    switch (type) {
      case SharedAxisTransitionType.horizontal:
        primaryBegin = const Offset(1.0, 0.0);
        primaryEnd = Offset.zero;
        break;
      case SharedAxisTransitionType.vertical:
        primaryBegin = const Offset(0.0, 1.0);
        primaryEnd = Offset.zero;
        break;
    }

    var primarySlideAnimation = Tween(
      begin: primaryBegin,
      end: primaryEnd,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    var fadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    return SlideTransition(
      position: primarySlideAnimation,
      child: FadeTransition(opacity: fadeInAnimation, child: child),
    );
  }
}

enum SharedAxisTransitionType { horizontal, vertical }
