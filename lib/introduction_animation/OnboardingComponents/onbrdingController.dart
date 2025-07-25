import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class CenterNextButton extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback onNextClick;

  const CenterNextButton({
    super.key,
    required this.animationController,
    required this.onNextClick,
  });

  

  @override
  Widget build(BuildContext context) {
    final topMoveAnimation = Tween<Offset>(
      begin: Offset(0, 5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.0, 0.2, curve: Curves.fastOutSlowIn),
      ),
    );

    final signUpMoveAnimation = Tween<double>(
      begin: 0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.6, 0.8, curve: Curves.fastOutSlowIn),
      ),
    );

    final List<Color> iconColors = [
      Color(0xffD34156),
      Color(0xffB38EA5),
      Color(0xff73B8D5),
      Color.fromARGB(255, 5, 15, 22),
      Color(0xff9E1635),
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SlideTransition(
            position: topMoveAnimation,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) => AnimatedOpacity(
                opacity: animationController.value >= 0.2 &&
                        animationController.value <= 0.6
                    ? 1
                    : 0,
                duration: Duration(milliseconds: 480),
                child: _pageView(),
              ),
            ),
          ),
          SlideTransition(
            position: topMoveAnimation,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) => Padding(
                padding: EdgeInsets.only(
                  bottom: 38 - (38 * signUpMoveAnimation.value),
                ),
                child: Container(
                  height: 58,
                  width: 58 + (200 * signUpMoveAnimation.value),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        8 + 32 * (1 - signUpMoveAnimation.value)),
                    color: _getAnimatedColor(animationController.value),
                  ),
                  child: PageTransitionSwitcher(
                    duration: Duration(milliseconds: 480),
                    reverse: signUpMoveAnimation.value < 0.7,
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                    ) {
                      return SharedAxisTransition(
                        fillColor: Colors.transparent,
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.vertical,
                        child: child,
                      );
                    },
                    child: signUpMoveAnimation.value > 0.7
                        ? InkWell(
                            key: ValueKey('Sign Up button'),
                            onTap: onNextClick,

                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Padding(
                              
                              padding: EdgeInsets.symmetric(horizontal: 16.0,),

                              
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Get started',
                                    style: TextStyle(
                                      color: _getAnimatedIconColor(
                                          animationController.value,
                                          iconColors),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: _getAnimatedIconColor(
                                        animationController.value, iconColors),
                                  ),
                                ],
                                
                              ),
                              
                            ),
                            
                          )
                          
                        : InkWell(
                            key: ValueKey('next button'),
                            onTap: onNextClick,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: _getAnimatedIconColor(
                                    animationController.value, iconColors),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 70),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getPageIndex() {
    final value = animationController.value;
    if (value >= 0.75) return 3;
    if (value >= 0.5) return 2;
    if (value >= 0.25) return 1;
    return 0;
  }

  Widget _pageView() {
    int selectedIndex = _getPageIndex();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 4; i++)
            Padding(
              padding: const EdgeInsets.all(4),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 480),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: selectedIndex == i
                      ? Color(0xff132137)
                      : Color(0xffE3E4E4),
                ),
                width: 10,
                height: 10,
              ),
            )
        ],
      ),
    );
  }

  Color _getAnimatedColor(double value) {
    final colors = [
      Color(0xffFFB9B3), // Page 0 - soft pink
      Color(0xffD2C4DD), // Transition - soft lavender-gray
      Color(0xff96D2EC), // Page 1 - light blue
      Color(0xff0A7AEF), // Page 2 - strong blue
      Color(0xffF54971), // Page 3 - red-pink
    ];

    if (value < 0.25) {
      return ColorTween(begin: colors[0], end: colors[1])
          .transform(value / 0.25)!;
    } else if (value < 0.5) {
      return ColorTween(begin: colors[1], end: colors[2])
          .transform((value - 0.25) / 0.25)!;
    } else if (value < 0.75) {
      return ColorTween(begin: colors[2], end: colors[3])
          .transform((value - 0.5) / 0.25)!;
    } else if (value <= 1.0) {
      return ColorTween(begin: colors[3], end: colors[4])
          .transform((value - 0.75) / 0.25)!;
    } else {
      return colors[4];
    }
  }

  Color _getAnimatedIconColor(double value, List<Color> colors) {
    if (value < 0.25) {
      return ColorTween(begin: colors[0], end: colors[1])
          .transform(value / 0.25)!;
    } else if (value < 0.5) {
      return ColorTween(begin: colors[1], end: colors[2])
          .transform((value - 0.25) / 0.25)!;
    } else if (value < 0.75) {
      return ColorTween(begin: colors[2], end: colors[3])
          .transform((value - 0.5) / 0.25)!;
    } else if (value <= 1.0) {
      return ColorTween(begin: colors[3], end: colors[4])
          .transform((value - 0.75) / 0.25)!;
    } else {
      return colors[4];
    }
  }
}
