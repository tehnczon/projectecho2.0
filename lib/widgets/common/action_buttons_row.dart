import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../models/hiv_center.dart';
import '../../providers/map_provider.dart';
import '../../providers/location_provider.dart';

class ActionButtonsRow extends StatelessWidget {
  final HIVCenter center;

  const ActionButtonsRow({Key? key, required this.center}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<MapProvider, LocationProvider>(
      builder: (context, mapProvider, locationProvider, _) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    onPressed:
                        mapProvider.isLoadingRoute
                            ? null
                            : () =>
                                _launchGoogleMapsDirections(locationProvider),
                    icon: Icons.directions_rounded,
                    label: 'Get Directions',
                    color: Colors.blue,
                    isLoading: mapProvider.isLoadingRoute,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    onPressed:
                        () => _showRouteOnMap(
                          context,
                          mapProvider,
                          locationProvider,
                        ),
                    icon: Icons.map_rounded,
                    label: 'Show Route',
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    onPressed: () => _makePhoneCall(context),
                    icon: Icons.phone_in_talk_rounded,
                    label: 'Call Now',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    onPressed: () => _bookmarkLocation(context),
                    icon: Icons.bookmark_add_rounded,
                    label: 'Save Place',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isLoading = false,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchGoogleMapsDirections(
    LocationProvider locationProvider,
  ) async {
    String googleMapsUrl;

    if (locationProvider.hasLocation) {
      final position = locationProvider.currentPosition!;
      googleMapsUrl =
          'https://www.google.com/maps/dir/${position.latitude},${position.longitude}/${center.position.latitude},${center.position.longitude}';
    } else {
      googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=${center.position.latitude},${center.position.longitude}';
    }

    final Uri url = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showRouteOnMap(
    BuildContext context,
    MapProvider mapProvider,
    LocationProvider locationProvider,
  ) async {
    if (!locationProvider.hasLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission required for directions'),
        ),
      );
      return;
    }

    await mapProvider.showRoute(locationProvider.currentPosition!);
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    final phoneNumber = center.contactInfo.phone;
    if (phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    final Uri phoneUrl = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  void _bookmarkLocation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${center.name} saved to bookmarks!'),
        action: SnackBarAction(
          label: 'VIEW',
          onPressed: () {
            // Navigate to bookmarks page
          },
        ),
      ),
    );
  }
}
