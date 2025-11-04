import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/form/plhivForm/app_colors.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onSupportTap;
  final VoidCallback onSettingsTap;

  const QuickActionsCard({
    super.key,
    required this.onTermsTap,
    required this.onPrivacyTap,
    required this.onSupportTap,
    required this.onSettingsTap,
  });

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickAction(
            icon: Icons.description_outlined,
            label: 'Terms and Conditions',
            onTap: onTermsTap,
          ),
          _buildQuickAction(
            icon: Icons.lock_outline,
            label: 'Privacy Policy',
            onTap: onPrivacyTap,
          ),
          _buildQuickAction(
            icon: Icons.help_outline,
            label: 'Support',
            onTap: onSupportTap,
          ),
          _buildQuickAction(
            icon: Icons.settings_outlined,
            label: 'Advanced Settings',
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}
