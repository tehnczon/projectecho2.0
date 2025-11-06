import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'webview_screen.dart';

class ModernBannerModel {
  final String title;
  final String subtitle;
  // final List<Color> gradient;
  final String imageUrl;
  final IconData fallbackIcon;
  final String? url;
  final Widget? destination;

  ModernBannerModel({
    required this.title,
    required this.subtitle,
    // required this.gradient,
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
      title: ' HIV 101',
      subtitle: 'Understanding HIV',
      // gradient: [const Color(0xFF1877F2), const Color(0xFF0C63D4)],
      imageUrl:
          'https://www.cdc.gov/hiv/media/images/cdc-about-hiv-thumbnail_1.jpg',
      fallbackIcon: Icons.health_and_safety,
      url: 'https://www.cdc.gov/hiv/about/index.html',
    ),
    ModernBannerModel(
      title: 'PrEP, ART and PEP?',
      subtitle:
          'Address three crucial tools in the fight against HIV: PrEP, ART and PEP.',
      // gradient: [const Color(0xFF1877F2), const Color(0xFF0C63D4)],
      imageUrl:
          'https://www.cdi.net.co/images/blogs/mac_diferencias-entre-prep-tarv-y-pep-entendiendo-las-herramientas-contra-el-vih_1692998334_wmhcR.jpg',
      fallbackIcon: Icons.article,
      url:
          'https://www.cdi.net.co/blogs/news/differences-between-prep-art-and-pep-understanding-the-tools-against-hiv',
    ),
    ModernBannerModel(
      title: 'Common Myths About HIV and AIDS',
      subtitle:
          'Learned enough to know that HIV-positive aren\'t dangerous or doomed.',
      // gradient: [const Color(0xFF1877F2), const Color(0xFF0C63D4)],
      imageUrl: 'https://img.youtube.com/vi/2X0o_w8YyGo/maxresdefault.jpg',
      fallbackIcon: Icons.people,
      url:
          'https://www.webmd.com/hiv-aids/top-10-myths-misconceptions-about-hiv-aids',
    ),
  ];

  void _handleBannerTap(ModernBannerModel banner) {
    HapticFeedback.lightImpact();

    if (banner.url != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => WebViewScreen(url: banner.url!, title: banner.title),
        ),
      );
    } else if (banner.destination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => banner.destination!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${banner.title} — Coming Soon'),
          backgroundColor: const Color(0xFF1877F2),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          items:
              banners.asMap().entries.map((entry) {
                final index = entry.key;
                final banner = entry.value;
                return GestureDetector(
                      onTap: () => _handleBannerTap(banner),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            children: [
                              // Image Section (Top 60%)
                              Expanded(
                                flex: 6,
                                child: Container(
                                  width: double.infinity,
                                  // decoration: BoxDecoration(
                                  //   gradient: LinearGradient(
                                  //     colors: banner.gradient,
                                  //     begin: Alignment.topLeft,
                                  //     end: Alignment.bottomRight,
                                  //   ),
                                  // ),
                                  child: Stack(
                                    children: [
                                      // Background image with opacity
                                      Positioned.fill(
                                        child: Image.network(
                                          banner.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Center(
                                              child: Icon(
                                                banner.fallbackIcon,
                                                size: 60,
                                                color: Colors.white.withOpacity(
                                                  0.3,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 4,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Text(
                                        banner.title,
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF1C1E21),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Subtitle
                                      Expanded(
                                        child: Text(
                                          banner.subtitle,
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF65676B),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (200 + index * 80).ms)
                    .slideX(begin: 0.1, end: 0);
              }).toList(),
          options: CarouselOptions(
            height: 260,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayCurve: Curves.easeInOutCubic,
            enlargeCenterPage: true,
            enlargeFactor: 0.25,
            viewportFraction: 0.85,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              banners.asMap().entries.map((entry) {
                final isActive = _currentIndex == entry.key;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isActive ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:
                        isActive
                            ? const Color(0xFF1877F2)
                            : const Color(0xFFE4E6EB),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
