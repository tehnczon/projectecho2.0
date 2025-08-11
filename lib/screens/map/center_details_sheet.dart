import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/hiv_center.dart';
import 'dart:ui';

// Main function to show the bottom sheet
void showCenterDetailsSheet(BuildContext context, HIVCenter center) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CenterDetailsSheet(center: center),
  ).then((_) {
    // Optional: Add any cleanup code here
  });
}

class CenterDetailsSheet extends StatefulWidget {
  final HIVCenter center;
  final VoidCallback? onClose;

  const CenterDetailsSheet({Key? key, required this.center, this.onClose})
    : super(key: key);

  @override
  State<CenterDetailsSheet> createState() => _CenterDetailsSheetState();
}

class _CenterDetailsSheetState extends State<CenterDetailsSheet> {
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();
  final PageController _pageController = PageController();
  int _currentPhotoIndex = 0;
  bool _isScrollingUp = false;
  double _lastPosition = 0.0;

  // Facebook-like color scheme
  final Color fbBlue = const Color(0xFF1877F2);
  final Color fbDarkBlue = const Color(0xFF1C4B8C);
  final Color fbLightGray = const Color(0xFFF0F2F5);
  final Color fbGray = const Color(0xFFE4E6EB);
  final Color fbTextPrimary = const Color(0xFF050505);
  final Color fbTextSecondary = const Color(0xFF65676B);
  final Color fbGreen = const Color(0xFF42B883);
  final Color fbCardBg = Colors.white;

  // Weekly schedule - you can modify this based on your data structure
  final Map<String, Map<String, dynamic>> weeklySchedule = {
    'Monday': {'open': '8:00 AM', 'close': '6:00 PM', 'isOpen': true},
    'Tuesday': {'open': '8:00 AM', 'close': '6:00 PM', 'isOpen': true},
    'Wednesday': {'open': '8:00 AM', 'close': '6:00 PM', 'isOpen': true},
    'Thursday': {'open': '8:00 AM', 'close': '6:00 PM', 'isOpen': true},
    'Friday': {'open': '8:00 AM', 'close': '5:00 PM', 'isOpen': true},
    'Saturday': {'open': '9:00 AM', 'close': '2:00 PM', 'isOpen': true},
    'Sunday': {'open': 'Closed', 'close': '', 'isOpen': false},
  };

  @override
  void initState() {
    super.initState();
    _draggableController.addListener(_onDragUpdate);
  }

  @override
  void dispose() {
    _draggableController.removeListener(_onDragUpdate);
    _draggableController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onDragUpdate() {
    final currentSize = _draggableController.size;

    // Detect scroll direction
    if (currentSize > _lastPosition) {
      _isScrollingUp = true;
    } else if (currentSize < _lastPosition) {
      _isScrollingUp = false;
    }

    _lastPosition = currentSize;

    // Auto-close when dragged very low
    if (currentSize < 0.08 && !_isScrollingUp) {
      // Small delay to ensure smooth animation
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          if (widget.onClose != null) {
            widget.onClose!();
          } else {
            Navigator.of(context).maybePop();
          }
        }
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchMaps() {
    final address = widget.center.contactInfo.address ?? widget.center.name;
    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    _launchUrl(mapsUrl);
  }

  List<String> get _photos {
    // Return photos or placeholder
    if (widget.center.photos.isNotEmpty) {
      return widget.center.photos;
    }
    return [
      'https://via.placeholder.com/400x200/1877F2/FFFFFF?text=Health+Center',
    ];
  }

  String get _currentDay {
    final now = DateTime.now();
    final days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return days[now.weekday % 7];
  }

  bool get _isCurrentlyOpen {
    final schedule = weeklySchedule[_currentDay];
    return schedule?['isOpen'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        // If scrolling down at the top of the list, close the sheet
        if (scrollNotification is ScrollUpdateNotification) {
          if (scrollNotification.metrics.pixels < -50 &&
              scrollNotification.dragDetails != null &&
              scrollNotification.dragDetails!.delta.dy > 0) {
            // User is pulling down beyond the top
            if (widget.onClose != null) {
              widget.onClose!();
            } else {
              Navigator.of(context).maybePop();
            }
          }
        }
        return false;
      },
      child: DraggableScrollableSheet(
        controller: _draggableController,
        initialChildSize: 0.4, // Start at collapsed state like Google Maps
        minChildSize: 0.0,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [
          0.0,
          0.4,
          0.95,
        ], // Only 3 states: closed, collapsed, expanded
        snapAnimationDuration: const Duration(milliseconds: 150),
        shouldCloseOnMinExtent: false, // We handle closing manually
        builder: (context, scrollController) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: fbCardBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Stack(
              children: [
                CustomScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // Hero Image Carousel
                    SliverToBoxAdapter(
                      child: Stack(
                        children: [
                          // Photo Carousel
                          Container(
                            height: 200,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPhotoIndex = index;
                                });
                              },
                              itemCount: _photos.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(_photos[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.3),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Drag Handle with better touch target
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: GestureDetector(
                              onVerticalDragUpdate: (details) {
                                // Better drag feedback
                                _draggableController.jumpTo(
                                  _draggableController.size -
                                      (details.delta.dy / context.size!.height),
                                );
                              },
                              child: Container(
                                height: 30, // Larger touch area
                                color: Colors.transparent,
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  width: 40,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(2.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Photo Indicators
                          if (_photos.length > 1)
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _photos.length,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    width: index == _currentPhotoIndex ? 24 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color:
                                          index == _currentPhotoIndex
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Content Section
                    SliverToBoxAdapter(
                      child: Container(
                        color: fbCardBg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Info
                            _buildHeaderInfo(),

                            // Directions Button
                            _buildDirectionsButton(),

                            const Divider(height: 1),

                            // About Section
                            _buildSection(
                              icon: Icons.info_outline,
                              title: 'About',
                              child: _buildAboutContent(),
                            ),

                            // Services Section
                            _buildSection(
                              icon: Icons.medical_services,
                              title: 'Services Available',
                              child: _buildServicesContent(),
                            ),

                            // Operating Hours Section with Weekly Schedule
                            _buildSection(
                              icon: Icons.schedule,
                              title: 'Operating Hours',
                              child: _buildWeeklySchedule(),
                            ),

                            // Contact Section
                            _buildSection(
                              icon: Icons.location_on,
                              title: 'Contact & Location',
                              child: _buildContactContent(),
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Close Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        if (widget.onClose != null) {
                          widget.onClose!();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.center.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: fbTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.verified, size: 16, color: fbBlue),
              const SizedBox(width: 4),
              Text(
                'Verified Health Center',
                style: TextStyle(fontSize: 14, color: fbTextSecondary),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      _isCurrentlyOpen
                          ? fbGreen.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _isCurrentlyOpen ? 'OPEN NOW' : 'CLOSED',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isCurrentlyOpen ? fbGreen : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _launchMaps,
          icon: const Icon(Icons.directions, size: 20),
          label: const Text('Get Directions'),
          style: ElevatedButton.styleFrom(
            backgroundColor: fbBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: fbBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: fbTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildAboutContent() {
    return Text(
      widget.center.description ??
          'We provide comprehensive HIV testing and treatment services in a safe, confidential, and supportive environment. Our experienced medical team is dedicated to delivering quality healthcare with compassion and respect.',
      style: TextStyle(fontSize: 14, color: fbTextPrimary, height: 1.5),
    );
  }

  Widget _buildServicesContent() {
    return Row(
      children: [
        Expanded(
          child: _buildServiceCard(
            available: widget.center.hasTesting,
            icon: Icons.biotech,
            title: 'HIV Testing',
            description: 'Rapid & lab testing',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildServiceCard(
            available: widget.center.hasTreatment,
            icon: Icons.medical_services,
            title: 'Treatment',
            description: 'ART therapy',
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required bool available,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final color = available ? fbGreen : Colors.grey;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: fbTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            available ? description : 'Not available',
            style: TextStyle(fontSize: 12, color: fbTextSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current status
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                _isCurrentlyOpen
                    ? fbGreen.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _isCurrentlyOpen ? Icons.check_circle : Icons.cancel,
                color: _isCurrentlyOpen ? fbGreen : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _isCurrentlyOpen
                    ? 'Open now · Closes at ${weeklySchedule[_currentDay]?['close']}'
                    : 'Closed now',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isCurrentlyOpen ? fbGreen : Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Weekly schedule
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: fbGray),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children:
                weeklySchedule.entries.map((entry) {
                  final isToday = entry.key == _currentDay;
                  final isOpen = entry.value['isOpen'];

                  return InkWell(
                    onTap: () {
                      // You can add functionality here if needed
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${entry.key}: ${isOpen ? "${entry.value['open']} - ${entry.value['close']}" : "Closed"}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isToday
                                ? fbBlue.withOpacity(0.05)
                                : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color:
                                entry.key != 'Sunday'
                                    ? fbGray
                                    : Colors.transparent,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isToday
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                color: isToday ? fbBlue : fbTextPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              isOpen
                                  ? '${entry.value['open']} - ${entry.value['close']}'
                                  : 'Closed',
                              style: TextStyle(
                                fontSize: 14,
                                color: isOpen ? fbTextPrimary : Colors.red,
                                fontWeight:
                                    isToday
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isToday)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: fbBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'TODAY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: fbBlue,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContactContent() {
    return Column(
      children: [
        if (widget.center.contactInfo.address != null)
          _buildContactRow(
            icon: Icons.location_on,
            label: 'Address',
            value: widget.center.contactInfo.address!,
            color: fbBlue,
            onTap: _launchMaps,
          ),
        if (widget.center.contactInfo.phone != null) ...[
          const SizedBox(height: 12),
          _buildContactRow(
            icon: Icons.phone,
            label: 'Phone',
            value: widget.center.contactInfo.phone!,
            color: fbGreen,
            onTap: () => _launchUrl('tel:${widget.center.contactInfo.phone}'),
          ),
        ],
        if (widget.center.contactInfo.email != null) ...[
          const SizedBox(height: 12),
          _buildContactRow(
            icon: Icons.email,
            label: 'Email',
            value: widget.center.contactInfo.email!,
            color: fbBlue,
            onTap:
                () => _launchUrl('mailto:${widget.center.contactInfo.email}'),
          ),
        ],
        // Add Facebook if available
        if (widget.center.contactInfo.facebook != null) ...[
          const SizedBox(height: 12),
          _buildContactRow(
            icon: Icons.facebook,
            label: 'Facebook',
            value: widget.center.contactInfo.facebook!,
            color: const Color(0xFF1877F2), // Facebook blue
            onTap: () => _launchUrl(widget.center.contactInfo.facebook!),
          ),
        ],
        // Add Website if available
        if (widget.center.contactInfo.website != null) ...[
          const SizedBox(height: 12),
          _buildContactRow(
            icon: Icons.language,
            label: 'Website',
            value: widget.center.contactInfo.website!,
            color: fbTextSecondary,
            onTap: () => _launchUrl(widget.center.contactInfo.website!),
          ),
        ],
      ],
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Ink(
          decoration: BoxDecoration(
            color: fbLightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: fbTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: TextStyle(fontSize: 14, color: fbTextPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: fbTextSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
