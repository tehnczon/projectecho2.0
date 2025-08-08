// lib/widgets/map/center_details_sheet.dart - ENHANCED VERSION
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/hiv_center.dart';

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
      initialChildSize: 0.5,
      minChildSize: 0.0,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.0, 0.5, 0.9],
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
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),

                  // Photo Gallery
                  if (center.photos.isNotEmpty) _buildPhotoGallery(),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Status
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
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Address
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          center.contactInfo.address,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    center.isOpenNow
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      center.isOpenNow
                                          ? Colors.green
                                          : Colors.orange,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color:
                                          center.isOpenNow
                                              ? Colors.green
                                              : Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    center.isOpenNow ? 'Open' : 'Closed',
                                    style: TextStyle(
                                      color:
                                          center.isOpenNow
                                              ? Colors.green
                                              : Colors.orange,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                center.isMultiService
                                    ? Colors.purple.withOpacity(0.1)
                                    : center.primaryService.color.withOpacity(
                                      0.1,
                                    ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  center.isMultiService
                                      ? Colors.purple
                                      : center.primaryService.color,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                center.isMultiService
                                    ? Icons.auto_awesome
                                    : center.primaryService.icon,
                                size: 16,
                                color:
                                    center.isMultiService
                                        ? Colors.purple
                                        : center.primaryService.color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                center.isMultiService
                                    ? 'Multi-Service Center'
                                    : center.primaryService.label,
                                style: TextStyle(
                                  color:
                                      center.isMultiService
                                          ? Colors.purple
                                          : center.primaryService.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Services
                        const Text(
                          'Services Available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              center.services.map((service) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: service.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: service.color.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        service.icon,
                                        size: 16,
                                        color: service.color,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        service.label,
                                        style: TextStyle(
                                          color: service.color,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Contact Information
                        if (center.contactInfo.hasAnyContact) ...[
                          const Text(
                            'Contact Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildContactSection(),
                          const SizedBox(height: 24),
                        ],

                        // Hours
                        const Text(
                          'Operating Hours',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 20,
                                color:
                                    center.isOpenNow
                                        ? Colors.green
                                        : Colors.orange,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  center.displayHours,
                                  style: TextStyle(
                                    color:
                                        center.isOpenNow
                                            ? Colors.green
                                            : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Description
                        if (center.description != null) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'About This Center',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            center.description!,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ],

                        // Action Buttons
                        const SizedBox(height: 32),
                        _buildActionButtons(),

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

  Widget _buildPhotoGallery() {
    if (center.photos.isEmpty) return const SizedBox.shrink();

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
              child: Stack(
                children: [
                  if (center.photos.length > 1)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${index + 1}/${center.photos.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: [
        // Phone
        if (center.contactInfo.hasPhone)
          _buildContactItem(
            icon: Icons.phone,
            label: 'Phone',
            value: center.contactInfo.phone!,
            color: Colors.green,
            onTap: () => _makePhoneCall(center.contactInfo.phone!),
          ),

        // Email
        if (center.contactInfo.hasEmail)
          _buildContactItem(
            icon: Icons.email,
            label: 'Email',
            value: center.contactInfo.email!,
            color: Colors.blue,
            onTap: () => _sendEmail(center.contactInfo.email!),
          ),

        // Facebook
        if (center.contactInfo.hasFacebook)
          _buildContactItem(
            icon: Icons.facebook,
            label: 'Facebook',
            value: center.contactInfo.facebook!,
            color: const Color(0xFF1877F2),
            onTap: () => _openFacebook(center.contactInfo.facebook!),
          ),

        // Website
        if (center.contactInfo.hasWebsite)
          _buildContactItem(
            icon: Icons.language,
            label: 'Website',
            value: center.contactInfo.website!,
            color: Colors.orange,
            onTap: () => _openWebsite(center.contactInfo.website!),
          ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _getDirections(),
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareCenter(),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _saveToBookmarks(),
            icon: const Icon(Icons.bookmark_add),
            label: const Text('Save to Bookmarks'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Action methods
  Future<void> _makePhoneCall(String phone) async {
    final Uri phoneUrl = Uri.parse('tel:$phone');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUrl = Uri.parse('mailto:$email');
    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    }
  }

  Future<void> _openFacebook(String facebook) async {
    // Handle both full URLs and usernames
    String url = facebook;
    if (!facebook.startsWith('http')) {
      url = 'https://facebook.com/$facebook';
    }

    final Uri facebookUrl = Uri.parse(url);
    if (await canLaunchUrl(facebookUrl)) {
      await launchUrl(facebookUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWebsite(String website) async {
    String url = website;
    if (!website.startsWith('http')) {
      url = 'https://$website';
    }

    final Uri websiteUrl = Uri.parse(url);
    if (await canLaunchUrl(websiteUrl)) {
      await launchUrl(websiteUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _getDirections() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${center.position.latitude},${center.position.longitude}';
    final Uri directionsUrl = Uri.parse(url);
    if (await canLaunchUrl(directionsUrl)) {
      await launchUrl(directionsUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _shareCenter() {
    // TODO: Implement sharing functionality
    // You can use the share_plus package for this
  }

  void _saveToBookmarks() {
    // TODO: Implement bookmark functionality
  }
}
