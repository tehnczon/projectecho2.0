import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecho/login/signup/UIC.dart';
import 'package:projecho/main/registration_data.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndConditionsPage extends StatefulWidget {
  final String uid;

  const TermsAndConditionsPage({super.key, required this.uid});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage>
    with SingleTickerProviderStateMixin {
  bool _accepted = false;
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToEnd = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    _tabController.dispose();
    super.dispose();
  }

  void _onAccept() async {
    if (_accepted) {
      HapticFeedback.mediumImpact();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => UICScreen(
                registrationData: RegistrationData(uid: widget.uid),
              ),
        ),
      );
    } else {
      _showErrorSnackBar('Please accept the terms to continue');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
          content,
        ],
      ),
    );
  }

  Widget _buildTermsContent() {
    return Column(
      children: [
        _buildSection(
              'Acceptance of Terms',
              Text(
                '• By accessing and using the Project ECHO mobile application or web platform (the "App"), you agree to be bound by these Terms and Conditions ("Terms") and our Data Privacy Policy. If you do not agree to all of these Terms, you may not use the App.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              Icons.handshake,
            )
            .animate()
            .fadeIn(duration: 600.ms, delay: 100.ms)
            .slideX(begin: -0.1, end: 0),

        _buildSection(
          'Purpose and Disclaimer',
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text:
                      '• Project ECHO is an educational and information-sharing platform. ',
                ),
                const TextSpan(
                  text:
                      'It is not intended to provide and should not be considered a substitute for professional medical advice, diagnosis, or treatment. ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'The App\'s purpose is to empower users with information and resources. Always seek the advice of a qualified healthcare provider with any questions you may have regarding a medical condition. Do not disregard professional medical advice or delay in seeking it because of something you have read on this App.',
                ),
              ],
            ),
          ),
          Icons.info_outline,
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.1, end: 0),

        _buildSection(
          'User Accounts and Unique Identifier Code (UIC)',
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text: '• Account Registration: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'To use the App, you must register for an account using your phone number. You agree to provide accurate and complete information. \n\n',
                ),
                const TextSpan(
                  text: '• Unique Identifier Code (UIC): ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'Upon registration, you will be assigned a Unique Identifier Code (UIC). This code is your primary identifier on the App. It is your responsibility to keep your UIC and password confidential. You are solely responsible for all activities that occur under your account. \n\n',
                ),
                const TextSpan(
                  text: '• Account Deletion: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'You have the right to request deletion of your account and you personal identifier. ',
                ),
              ],
            ),
          ),
          Icons.person,
        ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideX(begin: -0.1, end: 0),

        _buildSection(
          'Prohibited Conduct',
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text:
                      'You agree not to use the App for any unlawful purpose or in any way that could harm the App or its users. This includes, but is not limited to:\n\n ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: '• Impersonating another person or entity. \n\n',
                ),
                const TextSpan(
                  text:
                      '•Uploading or sharing content that is false, misleading, defamatory, obscene, or illegal. \n\n',
                ),
                const TextSpan(
                  text:
                      '• Attempting to gain unauthorized access to the App\'s servers, accounts, or data. \n\n',
                ),
                const TextSpan(
                  text:
                      '• Harassing, threatening, or violating the privacy of other users. \n\n',
                ),
              ],
            ),
          ),
          Icons.block,
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: -0.1, end: 0),

        _buildSection(
              'Intellectual Property',
              Text(
                'All content, features, and functionality of the App, including text, graphics, logos, and software, are the exclusive property of the Project ECHO development team and are protected by intellectual property laws. You may not reproduce, modify, or distribute any part of the App without our explicit permission.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              Icons.copyright,
            )
            .animate()
            .fadeIn(duration: 600.ms, delay: 500.ms)
            .slideX(begin: -0.1, end: 0),

        _buildSection(
              'Limitation of Liability',
              Text(
                'To the fullest extent permitted by law, the Project ECHO development team shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of or inability to use the App, even if we have been advised of the possibility of such damages.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              Icons.warning_amber_outlined,
            )
            .animate()
            .fadeIn(duration: 600.ms, delay: 600.ms)
            .slideX(begin: -0.1, end: 0),

        _buildSection(
              'Governing Law',
              Text(
                'These Terms shall be governed by and construed in accordance with the laws of the Republic of the Philippines. Any legal action or proceeding arising from these Terms shall be brought in the appropriate courts in Davao City, Philippines.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              Icons.gavel,
            )
            .animate()
            .fadeIn(duration: 600.ms, delay: 700.ms)
            .slideX(begin: -0.1, end: 0),

        _buildSection(
              'Contact Information',
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'If you have any questions or concerns about this Data Privacy Policy or our Terms and Conditions, please contact us at: \n\n',
                    ),
                    TextSpan(
                      text: 'Jopeter.babor@acdeducation.com',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () async {
                              final Uri emailUri = Uri(
                                scheme: 'mailto',
                                path: 'Jopeter.babor@acdeducation.com',
                              );
                              if (await canLaunchUrl(emailUri)) {
                                await launchUrl(emailUri);
                              }
                            },
                    ),
                    const TextSpan(text: '\n'),
                    TextSpan(
                      text: 'Maynopas22416@acdeducation.com',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () async {
                              final Uri emailUri = Uri(
                                scheme: 'mailto',
                                path: 'Maynopas22416@acdeducation.com',
                              );
                              if (await canLaunchUrl(emailUri)) {
                                await launchUrl(emailUri);
                              }
                            },
                    ),
                  ],
                ),
              ),
              Icons.contact_mail,
            )
            .animate()
            .fadeIn(duration: 600.ms, delay: 800.ms)
            .slideX(begin: -0.1, end: 0),
      ],
    );
  }

  Widget _buildPrivacyContent() {
    return Column(
      children: [
        _buildSection(
          'Introduction',
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text:
                      'This Privacy Policy for Project ECHO ("the App") outlines how we collect, use, process, and protect your personal and sensitive personal information. We are committed to safeguarding your privacy and ensuring full compliance with ',
                ),
                const TextSpan(
                  text:
                      'Republic Act No. 10173 (Data Privacy Act of 2012) and Republic Act No. 11166 (Philippine HIV and AIDS Policy Act).',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Icons.info_outline,
        ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideX(begin: -0.1, end: 0),

        _buildSection(
          'Information We Collect',
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text:
                      'We collect information to provide you with a secure, personalized, and effective experience. The information we collect falls into the following categories:\n\n',
                ),
                const TextSpan(
                  text: '• Personal Information: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'This includes data you provide directly during registration, such as your phone number. While we use a Unique Identifier Code (UIC) for pseudonymous authentication, your phone number is collected to prevent duplicate accounts and facilitate secure access.\n\n',
                ),
                const TextSpan(
                  text: '• Sensitive Personal Information: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      ' For users who identify as Persons Living with HIV (PLHIV), we may collect health-related data with your explicit consent, such as your date of diagnosis, etc. This data is essential for providing you with personalized health resources.\n\n',
                ),
                const TextSpan(
                  text: '• Usage and Technical Data: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'We automatically collect data about your interaction with the App, including IP addresses, device information (e.g., OS version), and usage patterns. This data helps us improve the App\'s functionality, security, and performance.\n\n',
                ),
                const TextSpan(
                  text: '• Anonymized Public Health Data: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'For reporting purposes, we process your health information into aggregated, anonymized statistics. This data cannot be traced back to any individual and is used to generate insights for public health initiatives.\n\n',
                ),
              ],
            ),
          ),
          Icons.folder_shared,
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.1, end: 0),

        _buildSection(
          'How We Use Your Information',
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text:
                      'We use the collected information for the following purposes:\n\n',
                ),
                const TextSpan(
                  text: '• To Provide Services: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'To enable secure user registration, log-in, and profile management.\n\n',
                ),
                const TextSpan(
                  text: '• For Personalization: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'To deliver a personalized dashboard with relevant health resources, educational content, and support information based on your user type (PLHIV or health information seeker) and health profile.\n\n',
                ),
                const TextSpan(
                  text: '• For Security and Compliance: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'To protect your account, prevent fraud, and ensure strict adherence to the Data Privacy Act of 2012 and the Philippine HIV and AIDS Policy Act.\n\n',
                ),
                const TextSpan(
                  text: '• For Public Health Reporting: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'To generate anonymized, aggregated statistical reports for healthcare providers, NGOs, and policymakers to inform decision-making, program development, and resource allocation.\n\n',
                ),
                const TextSpan(
                  text: '• For App Improvement:  ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
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
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text:
                      'We are committed to the highest standards of data security. We implement robust technical, organizational, and physical security measures to protect your information from unauthorized access, loss, misuse, or alteration. These measures include:\n\n',
                ),
                const TextSpan(
                  text: '• Encryption:  ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'sensitive personal information, is protected with industry-standard encryption, both in transit (while being sent over the network) and at rest (while stored on our servers).\n\n',
                ),
                const TextSpan(
                  text: '• Pseudonymization: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'We use a Unique Identifier Code (UIC) to de-identify your health data, ensuring that your personal identity is not directly linked to your health information within the system.\n\n',
                ),
                const TextSpan(
                  text: '• Access Control: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'Access to your personal and sensitive personal information is strictly limited to authorized personnel on a need-to-know basis.\n\n',
                ),
                const TextSpan(
                  text: '• Anonymization: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
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
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text:
                      'Under the Data Privacy Act of 2012, you have the following rights:\n\n',
                ),
                const TextSpan(
                  text: '• Right to Be Informed:  ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'You have the right to be informed of how your personal data is collected and processed. \n\n',
                ),
                const TextSpan(
                  text: '• Right to Access:  ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'You have the right to request a copy of your personal data held by us.\n\n',
                ),
                const TextSpan(
                  text: '• Right to Object:  ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'You have the right to object to the processing of your personal data.\n\n',
                ),
                const TextSpan(
                  text: '• Right to Erasure or Blocking:  ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'You have the right to request the deletion or removal of your personal data from our system.\n\n',
                ),
                const TextSpan(
                  text: '• Right to Rectification:  ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'You have the right to have inaccurate or incomplete personal data corrected.\n\n',
                ),
                const TextSpan(
                  text: '• Right to Data Portability:  ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'You have the right to obtain and reuse your personal data for your own purposes across different services.',
                ),
              ],
            ),
          ),
          Icons.verified_user,
        ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideX(begin: -0.1, end: 0),
      ],
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
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Terms & Conditions'),
                        Tab(text: 'Privacy Policy'),
                      ],
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicator: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      dividerColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildTermsContent(),
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
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildPrivacyContent(),
                  ),
                ],
              ),
            ),

            // Accept Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() => _accepted = !_accepted);
                      HapticFeedback.lightImpact();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            _accepted
                                ? AppColors.primary.withOpacity(0.05)
                                : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              _accepted ? AppColors.primary : AppColors.divider,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color:
                                  _accepted
                                      ? AppColors.primary
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    _accepted
                                        ? AppColors.primary
                                        : AppColors.divider,
                                width: 2,
                              ),
                            ),
                            child:
                                _accepted
                                    ? Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'I accept the Terms & Conditions and Privacy Policy',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient:
                          _accepted
                              ? LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                              )
                              : null,
                      color: !_accepted ? AppColors.divider : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow:
                          _accepted
                              ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ]
                              : [],
                    ),
                    child: ElevatedButton(
                      onPressed: _accepted ? _onAccept : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Accept and Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color:
                              _accepted
                                  ? Colors.white
                                  : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
