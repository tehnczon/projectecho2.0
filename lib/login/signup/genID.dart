import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/main/registration_data.dart';
import 'package:projecho/login/registration_flow_manager.dart';

class GenderSelectionScreen extends StatefulWidget {
  final RegistrationData registrationData;

  const GenderSelectionScreen({super.key, required this.registrationData});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? selectedGender;
  String? customGender;
  late AnimationController _animationController;

  final List<String> genderOptions = [
    'Male',
    'Female',
    'Transgender',
    'Other',
    'Prefer not to share',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    HapticFeedback.lightImpact();

    final genderToSave =
        selectedGender == 'Other' ? customGender ?? 'Other' : selectedGender;

    if (genderToSave == null || genderToSave.isEmpty) return;

    widget.registrationData.genderIdentity = selectedGender;
    widget.registrationData.customGender = customGender; // 👈 Add this line

    RegistrationFlowManager.navigateToNextStep(
      context: context,
      currentStep: 'gender',
      registrationData: widget.registrationData,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Header icon
            Center(
              child:
                  Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.accent.withOpacity(0.05),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.diversity_3,
                          color: AppColors.primary,
                          size: 50,
                        ),
                      )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .fadeIn(),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              'Your Gender Identity',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),

            const SizedBox(height: 12),

            // Subtitle info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.favorite, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'We respect all gender identities. Choose the one that best reflects you — your journey matters.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 700.ms, delay: 200.ms),

            const SizedBox(height: 32),

            // Dropdown Selector
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Gender Identity",
                prefixIcon: Icon(
                  Icons.wc,
                  color: AppColors.primary,
                ), // 👈 added icon
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
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
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              dropdownColor: AppColors.surface,
              value: selectedGender,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              items:
                  genderOptions
                      .map(
                        (gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                  if (value != 'Other') customGender = null;
                });
              },
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            // Text field for "Other"
            if (selectedGender == 'Other')
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Please specify",
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged:
                    (value) => setState(() => customGender = value), // 👈 FIXED
              ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 40),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    selectedGender == null
                        ? null
                        : (selectedGender == 'Other' &&
                            (customGender?.isEmpty ?? true))
                        ? null
                        : _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 24),

            // Support message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(0.05),
                    AppColors.primary.withOpacity(0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.support_agent, color: AppColors.success, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your identity is valid and respected here.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 1.seconds, delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
