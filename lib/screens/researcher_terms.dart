import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ResearcherApplicationConsentDialog extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const ResearcherApplicationConsentDialog({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<ResearcherApplicationConsentDialog> createState() =>
      _ResearcherApplicationConsentDialogState();
}

class _ResearcherApplicationConsentDialogState
    extends State<ResearcherApplicationConsentDialog> {
  bool _accepted = false;
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToEnd = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 20) {
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

  void _onAccept() {
    if (_accepted) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
      widget.onAccept();
    } else {
      _showErrorSnackBar('Please accept the consent to continue');
    }
  }

  void _onDecline() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    widget.onDecline();
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          content,
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
              padding: const EdgeInsets.all(20),
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
                      Icon(
                        Icons.assignment_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Researcher Application Consent',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Please review before submitting',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSection(
                      'Personal Information Collection',
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'By submitting this application, ',
                            ),
                            const TextSpan(
                              text: 'I consent to the collection ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text:
                                  'of the following personal information for researcher verification purposes:\n\n',
                            ),
                            const TextSpan(text: '• My full legal name\n'),
                            const TextSpan(
                              text: '• My Gmail address for communications\n',
                            ),
                            const TextSpan(
                              text: '• My institutional/center affiliation\n',
                            ),
                            const TextSpan(
                              text: '• My research proposal document (PDF)\n',
                            ),
                            const TextSpan(
                              text: '• Application submission timestamp\n\n',
                            ),
                            const TextSpan(
                              text: 'I understand this information will be ',
                            ),
                            const TextSpan(
                              text: 'stored securely ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text:
                                  'and accessed only by authorized Project ECHO administrators for application review and approval.',
                            ),
                          ],
                        ),
                      ),
                      Icons.person_outline,
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                    _buildSection(
                      'Purpose of Data Collection',
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
                                  'I understand that my personal information is being collected to:\n\n',
                            ),
                            const TextSpan(
                              text:
                                  '• Verify my professional credentials and institutional affiliation\n\n',
                            ),
                            const TextSpan(
                              text:
                                  '• Evaluate my research proposal and intended use of data\n\n',
                            ),
                            const TextSpan(
                              text:
                                  '• Maintain an audit trail of who has accessed research data\n\n',
                            ),
                            const TextSpan(
                              text:
                                  '• Communicate with me regarding my application status\n\n',
                            ),
                            const TextSpan(
                              text:
                                  '• Ensure accountability and ethical use of sensitive health data',
                            ),
                          ],
                        ),
                      ),
                      Icons.info_outline,
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                    _buildSection(
                      'Data Access Commitment',
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'If my application is approved, ',
                            ),
                            const TextSpan(
                              text: 'I commit to the following:\n\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: '• I will '),
                            const TextSpan(
                              text: 'only access anonymized, aggregated data ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: 'for legitimate research purposes\n\n',
                            ),
                            const TextSpan(text: '• I will '),
                            const TextSpan(
                              text: 'NOT attempt to identify ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: 'any individual from the data\n\n',
                            ),
                            const TextSpan(
                              text: '• I will use data in accordance with ',
                            ),
                            const TextSpan(
                              text:
                                  'ethical research standards and data privacy laws\n\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text:
                                  '• I will NOT share, sell, or distribute the data to unauthorized parties\n\n',
                            ),
                            const TextSpan(
                              text:
                                  '• I will properly attribute Project ECHO as the data source in any publications',
                            ),
                          ],
                        ),
                      ),
                      Icons.verified_user,
                    ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                    _buildSection(
                      'Research Proposal Review',
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'I acknowledge that:\n\n'),
                            const TextSpan(
                              text:
                                  '• My uploaded research proposal PDF will be ',
                            ),
                            const TextSpan(
                              text: 'reviewed by administrators ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text:
                                  'to assess the legitimacy and appropriateness of my research\n\n',
                            ),
                            const TextSpan(
                              text:
                                  '• Approval is at the sole discretion of Project ECHO administrators\n\n',
                            ),
                            const TextSpan(
                              text:
                                  '• My application may be approved, pending further review, or rejected\n\n',
                            ),
                            const TextSpan(
                              text:
                                  '• I will be notified of the decision via the email address I provided',
                            ),
                          ],
                        ),
                      ),
                      Icons.description,
                    ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                    _buildSection(
                      'Legal Compliance',
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'I confirm that:\n\n'),
                            const TextSpan(
                              text:
                                  '• I understand my data is processed under ',
                            ),
                            const TextSpan(
                              text:
                                  'Republic Act No. 10173 (Data Privacy Act of 2012) ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: 'and '),
                            const TextSpan(
                              text:
                                  'Republic Act No. 11166 (Philippine HIV and AIDS Policy Act)\n\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text:
                                  '• I have the right to access, correct, or request deletion of my personal data\n\n',
                            ),
                            const TextSpan(
                              text:
                                  '• My researcher access may be suspended or terminated for policy violations\n\n',
                            ),
                            const TextSpan(
                              text:
                                  '• I am solely responsible for my use of the data and any resulting research outputs',
                            ),
                          ],
                        ),
                      ),
                      Icons.gavel,
                    ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

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
                                  'For questions about this application or data privacy:\n\n',
                            ),
                            TextSpan(
                              text: 'projectecho@gmail.com',
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
                                        path: 'projectecho@gmail.com',
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
                    ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

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
                                'Thank you for reviewing the consent terms',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                      ),
                  ],
                ),
              ),
            ),

            // Accept Section
            Container(
              padding: const EdgeInsets.all(20),
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
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            _accepted
                                ? AppColors.primary.withOpacity(0.05)
                                : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              _accepted ? AppColors.primary : AppColors.divider,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color:
                                  _accepted
                                      ? AppColors.primary
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
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
                                      size: 14,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'I have read and consent to the collection and use of my personal information as described above',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _onDecline,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.divider),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Decline',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 50,
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
                            borderRadius: BorderRadius.circular(12),
                            boxShadow:
                                _accepted
                                    ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Accept & Submit',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color:
                                    _accepted
                                        ? Colors.white
                                        : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
