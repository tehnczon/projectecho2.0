import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecho/login/signup/plhivForm/app_colors.dart';
import 'profile_item.dart';

class SensitiveInfoSection extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? secureUserData;
  final bool showSensitive;
  final bool isAuthenticated;
  final VoidCallback onAuthenticationRequested;
  final VoidCallback onHideRequested;

  const SensitiveInfoSection({
    super.key,
    this.userData,
    this.secureUserData,
    required this.showSensitive,
    required this.isAuthenticated,
    required this.onAuthenticationRequested,
    required this.onHideRequested,
  });

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      return timestamp.toString();
    } catch (e) {
      return '';
    }
  }

  String _formatExposureHistory(Map<String, dynamic>? exposureHistory) {
    if (exposureHistory == null || exposureHistory.isEmpty)
      return 'Not provided';

    final positive =
        exposureHistory.entries
            .where((e) => e.value == 'within12' || e.value == 'moreThan12')
            .map((e) => e.key)
            .toList();

    if (positive.isEmpty) return 'No exposures reported';
    return positive.join(', ');
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.red[700], size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            Icons.lock_outline,
            color: showSensitive ? Colors.red : AppColors.primary,
          ),
          title: Text(
            'Personal Information',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            showSensitive
                ? 'Tap to hide sensitive data'
                : 'Requires biometric authentication',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Icon(
            showSensitive ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[600],
          ),
          onExpansionChanged: (expanding) {
            if (expanding && !isAuthenticated) {
              onAuthenticationRequested();
            } else if (!expanding) {
              onHideRequested();
            }
          },
          children: [
            if (showSensitive && userData != null) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Warning header
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.red[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Confidential Health Information',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This information is encrypted and protected. Do not share screenshots.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.red[600],
                        ),
                      ),

                      // DEMOGRAPHIC DATA
                      _buildSectionHeader(
                        'Demographic Data',
                        Icons.person_outline,
                      ),
                      const Divider(),

                      if (secureUserData != null) ...[
                        ProfileItem(
                          label: "PhilHealth Number",
                          value: secureUserData!['philhealthNumber'],
                          isSensitive: true,
                        ),
                        ProfileItem(
                          label: "Full Name",
                          value:
                              '${secureUserData!['firstName'] ?? ''} ${secureUserData!['middleName'] ?? ''} ${secureUserData!['lastName'] ?? ''} ${secureUserData!['suffix'] ?? ''}'
                                  .trim(),
                          isSensitive: true,
                        ),
                        ProfileItem(
                          label: "Mother's First Name",
                          value: secureUserData!['motherFirstName'],
                          isSensitive: true,
                        ),
                        ProfileItem(
                          label: "Father's First Name",
                          value: secureUserData!['fatherFirstName'],
                          isSensitive: true,
                        ),
                      ],

                      ProfileItem(
                        label: "Birth Date",
                        value: _formatDate(userData!['birthDate']),
                      ),
                      ProfileItem(
                        label: "Age Range",
                        value: userData!['ageRange'],
                      ),
                      ProfileItem(
                        label: "Gender Identity",
                        value: userData!['genderIdentity'],
                      ),

                      // OCCUPATION
                      _buildSectionHeader('Occupation', Icons.work_outline),
                      const Divider(),

                      ProfileItem(
                        label: "Current Occupation",
                        value: userData!['currentOccupation'],
                      ),
                      ProfileItem(
                        label: "Previous Occupation",
                        value: userData!['previousOccupation'],
                      ),

                      // MEDICAL HISTORY
                      _buildSectionHeader(
                        'Medical History',
                        Icons.medical_services_outlined,
                      ),
                      const Divider(),

                      ProfileItem(
                        label: "Current TB Patient",
                        value:
                            userData!['hasTuberculosis'] == true ? 'Yes' : 'No',
                      ),
                      ProfileItem(
                        label: "Hepatitis B",
                        value:
                            userData!['hasHepatitisB'] == true ? 'Yes' : 'No',
                      ),
                      ProfileItem(
                        label: "Hepatitis C",
                        value:
                            userData!['hasHepatitisC'] == true ? 'Yes' : 'No',
                      ),

                      // PLHIV SPECIFIC
                      if (userData!['userType'] == 'PLHIV' ||
                          userData!['role'] == 'plhiv') ...[
                        _buildSectionHeader(
                          'PLHIV Information',
                          Icons.medical_information_outlined,
                        ),
                        const Divider(),

                        if (userData!['yearDiagnosed'] != null)
                          ProfileItem(
                            label: "Year Diagnosed",
                            value: userData!['yearDiagnosed'].toString(),
                          ),
                        ProfileItem(
                          label: "Treatment Hub",
                          value: userData!['treatmentHub'],
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Data Protection Notice
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: Colors.blue[700],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your personal information is encrypted and stored securely.',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (showSensitive && userData == null) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Loading your profile data...',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
