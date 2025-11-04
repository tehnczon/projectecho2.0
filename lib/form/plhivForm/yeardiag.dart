import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/main/registration_data.dart';
import 'package:projecho/login/registration_flow_manager.dart';

class YearDiagPage extends StatefulWidget {
  final RegistrationData registrationData;

  const YearDiagPage({super.key, required this.registrationData});

  @override
  State<YearDiagPage> createState() => _YearDiagPageState();
}

class _YearDiagPageState extends State<YearDiagPage> {
  int? selectedYear;
  bool preferNotToShare = false;

  List<int> _generateYearList() {
    final currentYear = DateTime.now().year;
    return List.generate(31, (index) => currentYear - index);
  }

  void _handlePreferNotToShare(bool? value) {
    HapticFeedback.mediumImpact();
    setState(() {
      preferNotToShare = value ?? false;
      if (preferNotToShare) {
        selectedYear = null; // Clear year selection
      }
    });
  }

  void _handleYearSelection(int? year) {
    if (year == null) return;

    HapticFeedback.lightImpact();
    setState(() {
      selectedYear = year;
      preferNotToShare = false; // Uncheck prefer not to share
    });
  }

  void _onSubmit() {
    if (selectedYear != null || preferNotToShare) {
      HapticFeedback.mediumImpact();

      widget.registrationData.yearDiagnosed =
          preferNotToShare ? null : selectedYear;

      RegistrationFlowManager.navigateToNextStep(
        context: context,
        currentStep: 'yearDiag',
        registrationData: widget.registrationData,
      );
    } else {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Please select a year or choose 'Prefer not to share'",
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final yearList = _generateYearList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "When were you diagnosed with HIV?",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Optional - You're in control",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            // Supportive message card
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.05),
                        AppColors.secondary.withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Why we ask (optional)",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Sharing this helps us understand your journey and provide personalized support. However, your comfort matters most - you can skip this if you prefer.",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            // Prefer not to share checkbox
            Container(
              decoration: BoxDecoration(
                color:
                    preferNotToShare
                        ? AppColors.primary.withOpacity(0.05)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                value: preferNotToShare,
                onChanged: _handlePreferNotToShare,
                title: Text(
                  "Prefer not to share",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        preferNotToShare
                            ? AppColors.primary
                            : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  "Skip this question and continue",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        preferNotToShare
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.divider.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color:
                        preferNotToShare
                            ? AppColors.primary
                            : AppColors.textLight,
                    size: 20,
                  ),
                ),
                activeColor: AppColors.primary,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Divider with "OR"
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.divider)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "OR",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.divider)),
              ],
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 24),

            // Dropdown Label
            Text(
              "Select year of diagnosis:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 450.ms),

            const SizedBox(height: 12),

            // Year Dropdown
            // Year Input Field
            TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: InputDecoration(
                labelText: "Enter year of diagnosis",
                labelStyle: TextStyle(color: AppColors.textSecondary),

                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.primary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
                hintText: "e.g. 2018",
                hintStyle: TextStyle(color: AppColors.textSecondary),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() => selectedYear = null);
                } else {
                  final year = int.tryParse(value);
                  if (year != null &&
                      year >= 1900 &&
                      year <= DateTime.now().year) {
                    setState(() {
                      selectedYear = year;
                      preferNotToShare = false;
                    });
                  }
                }
              },
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Info about selection
            if (selectedYear != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You were diagnosed in $selectedYear. This helps us provide relevant support.",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            // Continue button
            SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        (selectedYear != null || preferNotToShare)
                            ? _onSubmit
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (selectedYear != null || preferNotToShare)
                              ? AppColors.primary
                              : AppColors.divider,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation:
                          (selectedYear != null || preferNotToShare) ? 4 : 0,
                      shadowColor: AppColors.primary.withOpacity(0.3),
                      disabledBackgroundColor: AppColors.divider,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Encouragement message
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: AppColors.success, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          preferNotToShare
                              ? "That's completely okay! You can still access all features. Your privacy matters. 💚"
                              : "Your courage in sharing helps create better support for everyone. You're not alone. 💚",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 1000.ms, delay: 600.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            // Privacy reminder
          ],
        ),
      ),
    );
  }
}
