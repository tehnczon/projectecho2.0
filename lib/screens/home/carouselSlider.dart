import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/main/app_theme.dart';

class ModernBannerModel {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  final Widget destination;

  ModernBannerModel({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.destination,
  });
}

class ModernCarouselSlider extends StatefulWidget {
  const ModernCarouselSlider({super.key});

  @override
  State<ModernCarouselSlider> createState() => _ModernCarouselSliderState();
}

class _ModernCarouselSliderState extends State<ModernCarouselSlider> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<ModernBannerModel> banners = [
    ModernBannerModel(
      title: 'Wellness Center',
      subtitle: 'Find support and care near you',
      gradient: [const Color(0xFFFFD760), const Color(0xFFF5C6A1)],
      icon: Icons.health_and_safety,
      destination: Container(),
    ),
    ModernBannerModel(
      title: 'Health Articles',
      subtitle: 'Stay informed with latest updates',
      gradient: [const Color(0xFFF1ACCF), const Color(0xFFFCCFE8)],
      icon: Icons.article,
      destination: Container(),
    ),
    ModernBannerModel(
      title: 'Community',
      subtitle: 'Connect with supportive people',
      gradient: [AppColors.primary, AppColors.primaryLight],
      icon: Icons.people,
      destination: Container(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260, // enough for carousel + spacing + indicators
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 230,
            child: CarouselSlider(
              carouselController: _carouselController,
              items:
                  banners.asMap().entries.map((entry) {
                    final index = entry.key;
                    final banner = entry.value;
                    return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => banner.destination,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: banner.gradient,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: banner.gradient[0].withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -30,
                                  bottom: -30,
                                  child: Icon(
                                    banner.icon,
                                    size: 150,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min, // Add this
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          banner.icon,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      Text(
                                        banner.title,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        banner.subtitle,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Explore',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: (300 + index * 100).ms)
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                        );
                  }).toList(),
              options: CarouselOptions(
                height: 260,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                banners.asMap().entries.map((entry) {
                  return Container(
                    width: _currentIndex == entry.key ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color:
                          _currentIndex == entry.key
                              ? AppColors.primary
                              : AppColors.divider,
                    ),
                  ).animate().fadeIn().scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
