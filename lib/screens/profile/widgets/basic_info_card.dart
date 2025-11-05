import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/form/plhivForm/app_colors.dart';
import 'profile_item.dart';

class BasicInfoCard extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const BasicInfoCard({super.key, this.userData});

  String _formatLocation() {
    if (userData == null) return '';
    final city = userData!['city'] ?? '';
    final barangay = userData!['barangay'] ?? '';

    if (city.isEmpty && barangay.isEmpty) return '';
    if (city.isEmpty) return barangay;
    if (barangay.isEmpty) return city;
    return '$barangay, $city';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (userData != null) ...[
              ProfileItem(label: "Unique ID", value: userData!['generatedUIC']),
              ProfileItem(label: "User Type"),
              ProfileItem(
                label: "Location",
                value:
                    (userData!['location'] is Map &&
                            userData!['location']['city'] != null)
                        ? userData!['location']['city']
                        : _formatLocation(),
              ),
              ProfileItem(
                label: "Gender Identity",
                value: userData!['genderIdentity'],
              ),
            ] else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
