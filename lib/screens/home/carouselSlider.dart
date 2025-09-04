import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/main/app_theme.dart';
import 'webview_screen.dart'; // Import your WebView screen

class ModernBannerModel {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String imageUrl; // Logo URL
  final IconData fallbackIcon; // Fallback icon if image fails
  final String? url; // Website URL
  final Widget? destination; // Keep destination for non-URL navigation

  ModernBannerModel({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.imageUrl,
    required this.fallbackIcon,
    this.url,
    this.destination,
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
      title: '',
      subtitle:
          'Official U.S. government portal for federal HIV and AIDS resources and policy information',
      gradient: [const Color(0xFFFFD760), const Color(0xFFF5C6A1)],
      imageUrl:
          'https://files.hiv.gov/s3fs-public/2025-07/OIDP_HIVgov_Blog-Email_ClinicalInfo-v01-540x405_0_0%20%281%29.jpg',
      fallbackIcon: Icons.health_and_safety,
      url: 'https://www.hiv.gov/',
    ),
    ModernBannerModel(
      title: '',
      subtitle:
          'Provides information for the public, healthcare workers, and policymakers',
      gradient: [const Color(0xFFF1ACCF), const Color(0xFFFCCFE8)],
      imageUrl:
          'https://logos-world.net/wp-content/uploads/2021/09/CDC-Logo.png',
      fallbackIcon: Icons.article,
      url: 'https://www.cdc.gov/hiv/',
    ),
    ModernBannerModel(
      title: 'PNAC',
      subtitle:
          'Central advisory, planning, and policymaking body for HIV/AIDS prevention and control in the Philippines.',
      gradient: [AppColors.primary, AppColors.primaryLight],
      imageUrl:
          'https://scontent.fdvo8-1.fna.fbcdn.net/v/t39.30808-6/243165751_163231095982243_9153701041396663701_n.png?_nc_cat=110&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeHD7DF6W8KW923TfEgfBm6l8AY_BbNR_IjwBj8Fs1H8iIb1mgwMprymZyCb0KRnHaIvin2NX9QchRICjrN6U1B7&_nc_ohc=HlnZiAIkYO0Q7kNvwEvZL2H&_nc_oc=Adkm2RKyOoETqB5u-XJbqhC8UDDsVe0_XHDn4syfyaOOvK9k2J5xXywTZjN8GI162rc&_nc_zt=23&_nc_ht=scontent.fdvo8-1.fna&_nc_gid=AQqpCQF5eieAUOaeHfYq7g&oh=00_AfZq_36CvLoaULInSn8LphgBf-WPM8Uc28XO6t3A4wzbEQ&oe=68BE03AB',
      fallbackIcon: Icons.people,
      url: 'https://pnac.doh.gov.ph/',
    ),
  ];

  void _handleBannerTap(ModernBannerModel banner) {
    HapticFeedback.lightImpact();

    if (banner.url != null) {
      // Navigate to WebView for URL-based banners
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => WebViewScreen(url: banner.url!, title: banner.title),
        ),
      );
    } else if (banner.destination != null) {
      // Navigate to specific widget for non-URL banners
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => banner.destination!),
      );
    } else {
      // Show coming soon message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${banner.title} — Coming Soon'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

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
                          onTap: () => _handleBannerTap(banner),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: banner.gradient[0].withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(banner.imageUrl),
                                fit: BoxFit.cover, // Make it fill background
                                onError: (error, stackTrace) {
                                  // Fallback to a solid gradient if image fails
                                },
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Gradient overlay for text readability
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.black.withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                ),

                                // Main content (texts, button, etc.)
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
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
                                            Text(
                                              banner.url != null
                                                  ? 'Visit'
                                                  : 'Explore',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              banner.url != null
                                                  ? Icons.open_in_new
                                                  : Icons.arrow_forward,
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
