import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/screens/home/carouselSlider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  // int _notificationCount = 3; // Sample notification count

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour <= 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return Icons.wb_sunny;
    } else if (hour >= 12 && hour <= 17) {
      return Icons.wb_cloudy;
    } else {
      return Icons.nights_stay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = _getGreetingMessage();
    final icon = _getGreetingIcon();

    return Scaffold(
      backgroundColor: AppColors.background,
      key: _scaffoldKey,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.background,
              elevation: 6,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                                children: [
                                  Icon(
                                    icon,
                                    color: AppColors.warning,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    message,
                                    style: GoogleFonts.poppins(
                                      color: const Color.fromARGB(
                                        255,
                                        48,
                                        51,
                                        56,
                                      ),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                              .animate()
                              .fadeIn(duration: 800.ms)
                              .slideX(begin: -0.1, end: 0),
                          const SizedBox(height: 4),
                        ],
                      ),
                      // Stack(
                      //   children: [
                      //     Container(
                      //       child: IconButton(
                      //         icon: Icon(
                      //           Icons.notifications,
                      //           color: AppColors.primary,
                      //           size: 24,
                      //         ),
                      //         onPressed: () {
                      //           HapticFeedback.lightImpact();
                      //           // Navigate to notifications
                      //         },
                      //       ),
                      //     ),
                      //     if (_notificationCount > 0)
                      //       Positioned(
                      //         right: 8,
                      //         top: 4,
                      //         child: Container(
                      //           padding: const EdgeInsets.all(2),
                      //           decoration: BoxDecoration(
                      //             color: AppColors.error,
                      //             shape: BoxShape.circle,
                      //             border: Border.all(
                      //               color: AppColors.surface, // outline color
                      //               width: 1, // outline thickness
                      //             ),
                      //           ),
                      //           constraints: const BoxConstraints(
                      //             minWidth: 14,
                      //             minHeight: 14,
                      //           ),

                      //           child: Text(
                      //             '$_notificationCount',
                      //             style: const TextStyle(
                      //               color: Colors.white,
                      //               fontSize: 10,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //             textAlign: TextAlign.center,
                      //           ),
                      //         ),
                      //       ),
                      //   ],
                      // ).animate().scale(
                      //   duration: 600.ms,
                      //   curve: Curves.elasticOut,
                      // ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section with Logo
                  Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),

                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShaderMask(
                                    shaderCallback:
                                        (bounds) => LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.primaryLight,
                                          ],
                                        ).createShader(bounds),
                                    child: Text(
                                      'Project ECHO',
                                      style: GoogleFonts.poppins(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'We care for you',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          size: 14,
                                          color: AppColors.success,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Your health matters',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _scaleController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1 + (_scaleController.value * 0.05),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    height: 100,
                                    width: 100,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.health_and_safety,
                                          size: 50,
                                          color: AppColors.primary,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 12),

                  //home
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Visit websites',
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 200.ms),

                  const SizedBox(height: 8),

                  // Carousel Slider
                  const ModernCarouselSlider(),

                  // Recommended Section
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Recommended for You',
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 600.ms),

                  Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.recommend_outlined,
                              size: 48,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Personalized recommendations coming soon',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 800.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                      ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
