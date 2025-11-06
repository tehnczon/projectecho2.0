import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/main/app_theme.dart';

class Privacypolicy extends StatefulWidget {
  const Privacypolicy({super.key});

  @override
  State<Privacypolicy> createState() => _PrivacypolicyState();
}

class _PrivacypolicyState extends State<Privacypolicy> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToEnd = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        if (!_hasScrolledToEnd) {
          setState(() => _hasScrolledToEnd = true);
          HapticFeedback.lightImpact();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSection(String title, Widget content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content, // This can now be RichText or Text
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Data Privacy Policy',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),

            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildSection(
                          ' Introduction',
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      'This Privacy Policy for Project ECHO ("the App") outlines how we collect, use, process, and protect your personal and sensitive personal information. We are committed to safeguarding your privacy and ensuring full compliance with ',
                                ),
                                TextSpan(
                                  text:
                                      'Republic Act No. 10173 (Data Privacy Act of 2012) and Republic Act No. 11166 (Philippine HIV and AIDS Policy Act).',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          Icons.info_outline,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 100.ms)
                        .slideX(begin: -0.1, end: 0),

                    _buildSection(
                      'Information We Collect',
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'We collect information to provide you with a secure, personalized, and effective experience. The information we collect falls into the following categories:\n\n',
                            ),
                            TextSpan(
                              text: '• Personal Information: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'This includes data you provide directly during registration, such as your phone number. While we use a Unique Identifier Code (UIC) for pseudonymous authentication, your phone number is collected to prevent duplicate accounts and facilitate secure access.\n\n',
                            ),

                            TextSpan(
                              text: '• Sensitive Personal Information: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  ' For users who identify as Persons Living with HIV (PLHIV), we may collect health-related data with your explicit consent, such as your date of diagnosis, etc. This data is essential for providing you with personalized health resources.\n\n',
                            ),
                            TextSpan(
                              text: '• Usage and Technical Data: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'We automatically collect data about your interaction with the App, including IP addresses, device information (e.g., OS version), and usage patterns. This data helps us improve the App\'s functionality, security, and performance.\n\n',
                            ),
                            TextSpan(
                              text: '• Anonymized Public Health Data: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'For reporting purposes, we process your health information into aggregated, anonymized statistics. This data cannot be traced back to any individual and is used to generate insights for public health initiatives.\n\n',
                            ),
                          ],
                        ),
                      ),
                      Icons.folder_shared,
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.1, end: 0),

                    _buildSection(
                      ' How We Use Your Information',
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'We use the collected information for the following purposes:\n\n',
                            ),
                            TextSpan(
                              text: '• To Provide Services: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'To enable secure user registration, log-in, and profile management.\n\n',
                            ),

                            TextSpan(
                              text: '• For Personalization: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'To deliver a personalized dashboard with relevant health resources, educational content, and support information based on your user type (PLHIV or health information seeker) and health profile.\n\n',
                            ),
                            TextSpan(
                              text: '• For Security and Compliance: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'To protect your account, prevent fraud, and ensure strict adherence to the Data Privacy Act of 2012 and the Philippine HIV and AIDS Policy Act.\n\n',
                            ),
                            TextSpan(
                              text: '• For Public Health Reporting: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'To generate anonymized, aggregated statistical reports for healthcare providers, NGOs, and policymakers to inform decision-making, program development, and resource allocation.\n\n',
                            ),
                            TextSpan(
                              text: '• For App Improvement:  ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'To analyze usage trends, fix bugs, and enhance the overall user experience and performance of the App.\n\n',
                            ),
                          ],
                        ),
                      ),
                      Icons.auto_awesome_motion,
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideX(begin: -0.1, end: 0),

                    _buildSection(
                      'Data Protection and Security',
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'We are committed to the highest standards of data security. We implement robust technical, organizational, and physical security measures to protect your information from unauthorized access, loss, misuse, or alteration. These measures include:\n\n',
                            ),

                            TextSpan(
                              text: '• Encryption:  ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'sensitive personal information, is protected with industry-standard encryption, both in transit (while being sent over the network) and at rest (while stored on our servers).\n\n',
                            ),

                            TextSpan(
                              text: '• Pseudonymization: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'We use a Unique Identifier Code (UIC) to de-identify your health data, ensuring that your personal identity is not directly linked to your health information within the system.\n\n',
                            ),
                            TextSpan(
                              text: '• Access Control: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'Access to your personal and sensitive personal information is strictly limited to authorized personnel on a need-to-know basis.\n\n',
                            ),
                            TextSpan(
                              text: '• Anonymization: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'For all public health reports, your data is completely anonymized and aggregated, ensuring it is impossible to identify any individual.',
                            ),
                          ],
                        ),
                      ),
                      Icons.security,
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: -0.1, end: 0),

                    _buildSection(
                      'Your Privacy Rights',
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'Under the Data Privacy Act of 2012, you have the following rights:\n\n',
                            ),
                            TextSpan(
                              text: '• Right to Be Informed:  ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'You have the right to be informed of how your personal data is collected and processed. \n\n',
                            ),
                            TextSpan(
                              text: '• Right to Access:  ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'You have the right to request a copy of your personal data held by us.\n\n',
                            ),
                            TextSpan(
                              text: '• Right to Object:  ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'You have the right to object to the processing of your personal data.\n\n',
                            ),
                            TextSpan(
                              text: '• Right to Erasure or Blocking:  ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'You have the right to request the deletion or removal of your personal data from our system.\n\n',
                            ),
                            TextSpan(
                              text: '• Right to Rectification:  ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'You have the right to have inaccurate or incomplete personal data corrected.\n\n',
                            ),
                            TextSpan(
                              text: '• Right to Data Portability:  ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'You have the right to obtain and reuse your personal data for your own purposes across different services.',
                            ),
                          ],
                        ),
                      ),

                      Icons.verified_user,
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: -0.1, end: 0),

                    if (_hasScrolledToEnd)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'You\'ve read through our terms. Thank you!',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
