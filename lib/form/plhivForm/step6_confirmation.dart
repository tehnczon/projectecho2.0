import 'package:flutter/material.dart';
import '../../main/registration_data.dart';
import '../../main/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/login/signup/privacyPolicy.dart';
import 'package:projecho/login/signup/terms.dart';

class Step6FinalConfirmation extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;
  // Add callback to expose validation state
  final Function(bool)? onAgreementChanged;

  const Step6FinalConfirmation({
    Key? key,
    required this.registrationData,
    required this.formKey,
    this.onAgreementChanged,
  }) : super(key: key);

  @override
  State<Step6FinalConfirmation> createState() => _Step6FinalConfirmationState();
}

class _Step6FinalConfirmationState extends State<Step6FinalConfirmation> {
  bool _agreed = false;
  bool _showError = false;

  // Getter to check if form is valid
  bool get isAgreed => _agreed;

  // PUBLIC METHOD: Parent widget can call this to validate before proceeding
  bool validateAgreement() {
    if (!_agreed) {
      setState(() {
        _showError = true;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('FINAL CONFIRMATION'),
            const SizedBox(height: 30),

            // Privacy & Terms Section
            Container(
              padding: const EdgeInsets.all(20),
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
                      Icon(
                        Icons.privacy_tip_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Privacy & Data Protection',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildInfoRow(
                    Icons.shield_outlined,
                    'Your data is stored securely',
                  ),

                  const SizedBox(height: 12),

                  _buildInfoRow(
                    Icons.admin_panel_settings_outlined,
                    'Identifiable information will be used only for your personal profile',
                  ),

                  const SizedBox(height: 12),

                  _buildInfoRow(
                    Icons.lock_outline,
                    'Your identity remains confidential',
                  ),

                  const SizedBox(height: 12),

                  _buildInfoRow(
                    Icons.verified_user_outlined,
                    'Non-identifiable data may be used for research purposes only',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Agreement Checkbox with Validation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    _agreed
                        ? AppColors.primary.withOpacity(0.05)
                        : (_showError && !_agreed)
                        ? Colors.red[50]
                        : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      (_showError && !_agreed)
                          ? Colors.red
                          : _agreed
                          ? AppColors.primary
                          : AppColors.divider,
                  width: (_showError && !_agreed) || _agreed ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          'I have read and agree to the ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Terms()),
                            );
                          },
                          child: Text(
                            "Terms ",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          "and ",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Privacypolicy(),
                              ),
                            );
                          },
                          child: Text(
                            "Privacy Policy",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'I understand that this information is collected anonymously and I consent to the terms and privacy policy.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    value: _agreed,
                    onChanged: (value) {
                      setState(() {
                        _agreed = value ?? false;
                        if (_agreed) _showError = false;
                      });

                      // 🔥 Notify parent about agreement change
                      if (widget.onAgreementChanged != null) {
                        widget.onAgreementChanged!(_agreed);
                      }
                    },

                    dense: false,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.primary,
                  ),

                  // Show error only when validation fails and not agreed
                  if (_showError && !_agreed) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You must accept the terms and conditions to proceed',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.red[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Important Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By proceeding, you acknowledge that you have read and understood our privacy policy and consent to data collection.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
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
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
