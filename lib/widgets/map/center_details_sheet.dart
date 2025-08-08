import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hiv_center.dart';
import '../../providers/location_provider.dart';
import '../common/service_badges_widget.dart';
import '../common/operating_hours_card.dart';
import '../common/action_buttons_row.dart';

class CenterDetailsSheet extends StatelessWidget {
  final HIVCenter center;
  final VoidCallback onClose;

  const CenterDetailsSheet({
    Key? key,
    required this.center,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.0,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.0, 0.4, 0.95],
      builder: (context, scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            if (notification.extent <= 0.05) {
              WidgetsBinding.instance.addPostFrameCallback((_) => onClose());
            }
            return true;
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  _buildHandleBar(),

                  // Header with photos
                  if (center.photos.isNotEmpty) _buildPhotoHeader(),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and address
                        _buildTitleSection(),

                        const SizedBox(height: 20),

                        // Service badges
                        ServiceBadgesWidget(center: center),

                        const SizedBox(height: 20),

                        // Info cards
                        _buildInfoCards(),

                        // Operating hours
                        if (center.operatingHours != null) ...[
                          const SizedBox(height: 20),
                          OperatingHoursCard(
                            operatingHours: center.operatingHours!,
                          ),
                        ],

                        // Description
                        if (center.description != null) ...[
                          const SizedBox(height: 24),
                          _buildDescription(),
                        ],

                        // Action buttons
                        const SizedBox(height: 24),
                        ActionButtonsRow(center: center),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandleBar() {
    return Center(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Text(
            'Swipe down to close',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPhotoHeader() {
    return Container(
      height: 200,
      child: PageView.builder(
        itemCount: center.photos.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(center.photos[index]),
                fit: BoxFit.cover,
                onError: (error, stackTrace) {},
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          center.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_rounded, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                center.contactInfo.address,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        return Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.access_time_filled_rounded,
                title: 'Hours',
                value: center.displayHours,
                color: center.isOpenNow ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            if (locationProvider.hasLocation)
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.navigation_rounded,
                  title: 'Distance',
                  value: _formatDistance(
                    locationProvider.distanceTo(
                      center.position.latitude,
                      center.position.longitude,
                    ),
                  ),
                  color: Colors.orange,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          center.description!,
          style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  String _formatDistance(double? distance) {
    if (distance == null) return 'Calculating...';
    return '${distance.toStringAsFixed(1)} km';
  }
}
