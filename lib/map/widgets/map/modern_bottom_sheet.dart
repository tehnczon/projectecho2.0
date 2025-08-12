import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/hiv_center.dart';

class ModernBottomSheet extends StatelessWidget {
  final HIVCenter center;
  final VoidCallback onClose;

  const ModernBottomSheet({
    Key? key,
    required this.center,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.0,
      maxChildSize: 0.75,
      snap: true,
      snapSizes: const [0.0, 0.35, 0.75],
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
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),

                  // Photo Gallery (if available)
                  if (center.photos.isNotEmpty) _buildPhotoGallery(),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Status Badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    center.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    center.isMultiService
                                        ? 'Multi-Service Center'
                                        : center.primaryService.label,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Quick Actions
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickAction(
                                icon: Icons.directions,
                                label: 'Directions',
                                color: Colors.blue,
                                onTap: () => _launchMaps(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickAction(
                                icon: Icons.phone,
                                label: 'Call',
                                color: Colors.green,
                                onTap: () => _makePhoneCall(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickAction(
                                icon: Icons.share,
                                label: 'Share',
                                color: Colors.orange,
                                onTap: () => _shareLocation(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Services Section
                        _buildServicesSection(),

                        const SizedBox(height: 24),

                        // Contact Information
                        _buildContactSection(),

                        const SizedBox(height: 24),

                        // Operating Hours
                        _buildOperatingHours(),

                        // Description
                        if (center.description != null) ...[
                          const SizedBox(height: 24),
                          _buildDescription(),
                        ],
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

  Widget _buildOperatingHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Operating Hours',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 20,
                color: center.isOpenNow ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  center.displayHours,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (center.contactInfo.hasPhone)
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: Text(center.contactInfo.phone!),
            onTap: _makePhoneCall,
          ),
        if (center.contactInfo.hasEmail)
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blue),
            title: Text(center.contactInfo.email!),
            onTap: _sendEmail,
          ),
        if (center.contactInfo.hasWebsite)
          ListTile(
            leading: const Icon(Icons.language, color: Colors.orange),
            title: Text(center.contactInfo.website!),
            onTap: _openWebsite,
          ),
        if (center.contactInfo.hasFacebook)
          ListTile(
            leading: const Icon(Icons.facebook, color: Colors.blueAccent),
            title: Text(center.contactInfo.facebook!),
            onTap: _openFacebook,
          ),
      ],
    );
  }

  Widget _buildPhotoGallery() {
    return Container(
      height: 180,
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
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isOpen = center.isOpenNow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOpen ? Colors.green : Colors.red, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOpen ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? 'Open' : 'Closed',
            style: TextStyle(
              color: isOpen ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services Available',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 20,
                color: center.isOpenNow ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  center.displayHours,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          center.description!,
          style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  // Action methods
  Future<void> _launchMaps() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${center.position.latitude},${center.position.longitude}';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall() async {
    if (!center.contactInfo.hasPhone) return;
    final Uri phoneUri = Uri.parse('tel:${center.contactInfo.phone}');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _sendEmail() async {
    if (!center.contactInfo.hasEmail) return;
    final Uri emailUri = Uri.parse('mailto:${center.contactInfo.email}');
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _openWebsite() async {
    if (!center.contactInfo.hasWebsite) return;
    String url = center.contactInfo.website!;
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    final Uri websiteUri = Uri.parse(url);
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openFacebook() async {
    if (!center.contactInfo.hasFacebook) return;
    String url = center.contactInfo.facebook!;
    if (!url.startsWith('http')) {
      url = 'https://facebook.com/$url';
    }
    final Uri fbUri = Uri.parse(url);
    if (await canLaunchUrl(fbUri)) {
      await launchUrl(fbUri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareLocation() {
    // Implement share functionality
    // You can use share_plus package for this
  }
}
