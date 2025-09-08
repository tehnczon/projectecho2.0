import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class Terms extends StatefulWidget {
  const Terms({super.key});

  @override
  State<Terms> createState() => _TermsState();
}

class _TermsState extends State<Terms> {
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
                          'Terms & Conditions',
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.security,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Your privacy is our priority',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          'Acceptance of Terms',
                          Text(
                            '• By accessing and using the Project ECHO mobile application or web platform (the "App"), you agree to be bound by these Terms and Conditions ("Terms") and our Data Privacy Policy. If you do not agree to all of these Terms, you may not use the App.',
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
                                color: const Color.fromARGB(255, 0, 0, 0),
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '• Project ECHO is an educational and information-sharing platform. ',
                                ),
                                TextSpan(
                                  text:
                                      'It is not intended to provide and should not be considered a substitute for professional medical advice, diagnosis, or treatment. ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      'The App\'s purpose is to empower users with information and resources. Always seek the advice of a qualified healthcare provider with any questions you may have regarding a medical condition. Do not disregard professional medical advice or delay in seeking it because of something you have read on this App.',
                                ),
                              ],
                            ),
                          ),
                          Icons.info_outline,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideX(begin: -0.1, end: 0),

                    _buildSection(
                          'User Accounts and Unique Identifier Code (UIC)',
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text: '• Account Registration: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      'To use the App, you must register for an account using your phone number. You agree to provide accurate and complete information. \n\n',
                                ),
                                TextSpan(
                                  text: '• Unique Identifier Code (UIC): ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      'Upon registration, you will be assigned a Unique Identifier Code (UIC). This code is your primary identifier on the App. It is your responsibility to keep your UIC and password confidential. You are solely responsible for all activities that occur under your account. \n\n',
                                ),

                                TextSpan(
                                  text: '• Account Deletion: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      'You have the right to request deletion of your account and you personal identifier. ',
                                ),
                              ],
                            ),
                          ),
                          Icons.person,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 300.ms)
                        .slideX(begin: -0.1, end: 0),

                    _buildSection(
                      'Prohibited Conduct',
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
                                  'You agree not to use the App for any unlawful purpose or in any way that could harm the App or its users. This includes, but is not limited to:\n\n ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            TextSpan(
                              text:
                                  '• Impersonating another person or entity. \n\n',
                            ),
                            TextSpan(
                              text:
                                  '•Uploading or sharing content that is false, misleading, defamatory, obscene, or illegal. \n\n',
                            ),
                            TextSpan(
                              text:
                                  '• Attempting to gain unauthorized access to the App\'s servers, accounts, or data. \n\n',
                            ),
                            TextSpan(
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
                                      'All content, features, and functionality of the App, including text, graphics, logos, and software, are the exclusive property of the Project ECHO development team and are protected by intellectual property laws. You may not reproduce, modify, or distribute any part of the App without our explicit permission.',
                                ),
                              ],
                            ),
                          ),

                          Icons.copyright,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideX(begin: -0.1, end: 0),

                    _buildSection(
                          'Limitation of Liability',
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
                                      'To the fullest extent permitted by law, the Project ECHO development team shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of or inability to use the App, even if we have been advised of the possibility of such damages.',
                                ),
                              ],
                            ),
                          ),

                          Icons.warning_amber_outlined,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideX(begin: -0.1, end: 0),

                    _buildSection(
                          'Governing Law',
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
                                      'These Terms shall be governed by and construed in accordance with the laws of the Republic of the Philippines. Any legal action or proceeding arising from these Terms shall be brought in the appropriate courts in Davao City, Philippines.',
                                ),
                              ],
                            ),
                          ),

                          Icons.gavel,
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideX(begin: -0.1, end: 0),

                    _buildSection(
                          'Contact Information',
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color.fromARGB(255, 0, 0, 0),
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
                                    color:
                                        Colors.blue, // make it look like a link
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () async {
                                          final Uri emailUri = Uri(
                                            scheme: 'mailto',
                                            path:
                                                'Jopeter.babor@acdeducation.com',
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
                                            path:
                                                'Maynopas22416@acdeducation.com',
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
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideX(begin: -0.1, end: 0),

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
