import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ArticleDetailPage extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;

  const ArticleDetailPage({super.key, required this.id, required this.data});

  @override
  Widget build(BuildContext context) {
    final imageUrl = data['imageUrl'] as String?;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Image Hero (if image exists)
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background:
                  hasImage
                      ? Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey[600],
                                  ),
                                ),
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                      : Container(color: AppColors.surface),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              data['category'],
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                data['emoji'] ?? '📄',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getCategoryLabel(data['category']),
                                style: TextStyle(
                                  color: _getCategoryColor(data['category']),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.1, end: 0),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                          data['title'] ?? 'Untitled',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 100.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 12),

                    // Meta Info
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${data['readTime'] ?? 5} min read',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.people,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _formatTargetRoles(data['targetRoles']),
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                    const SizedBox(height: 24),

                    // Divider
                    Divider(color: AppColors.divider),

                    const SizedBox(height: 24),

                    // Content
                    Text(
                          data['content'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.8,
                            letterSpacing: 0.2,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 300.ms)
                        .slideY(begin: 0.05, end: 0),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'basics':
        return Colors.blue;
      case 'prevention':
        return Colors.green;
      case 'treatment':
        return Colors.purple;
      case 'living':
        return Colors.orange;
      case 'transmission':
        return Colors.red;
      case 'testing':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(String? category) {
    switch (category) {
      case 'basics':
        return 'Basics';
      case 'prevention':
        return 'Prevention';
      case 'treatment':
        return 'Treatment';
      case 'living':
        return 'Living with HIV';
      case 'transmission':
        return 'Transmission';
      case 'testing':
        return 'Testing';
      default:
        return 'Article';
    }
  }

  String _formatTargetRoles(dynamic roles) {
    if (roles == null) return 'All Users';
    if (roles is! List) return 'All Users';

    if (roles.contains('all')) return 'All Users';

    final roleNames =
        roles.map((role) {
          switch (role) {
            case 'infoSeeker':
              return 'Info Seekers';
            case 'atRisk':
              return 'At Risk';
            case 'diagnosed':
              return 'Diagnosed';
            default:
              return role.toString();
          }
        }).toList();

    return roleNames.join(', ');
  }
}
