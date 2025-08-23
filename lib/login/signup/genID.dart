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
  late AnimationController _animationController;

  final List<Map<String, dynamic>> genderOptions = [
    {
      'value': 'Male',
      'icon': Icons.male,
      'color': AppColors.primary,
      'description': 'Male identity',
    },
    {
      'value': 'Female',
      'icon': Icons.female,
      'color': AppColors.accent,
      'description': 'Female identity',
    },
    {
      'value': 'Transgender',
      'icon': Icons.transgender,
      'color': AppColors.secondary,
      'description': 'Transgender identity',
    },
    {
      'value': 'Other',
      'icon': Icons.people_outline,
      'color': AppColors.warning,
      'description': 'Other identity',
    },
    {
      'value': 'Non-label',
      'icon': Icons.all_inclusive,
      'color': AppColors.primaryLight,
      'description': 'Prefer not to label',
    },
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

  void _handleSelection(String gender) {
    HapticFeedback.lightImpact();
    setState(() => selectedGender = gender);

    // Add slight delay for visual feedback
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.registrationData.genderIdentity = gender;
      RegistrationFlowManager.navigateToNextStep(
        context: context,
        currentStep: 'gender',
        registrationData: widget.registrationData,
      );
    });
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
            // Header with icon
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

            // Subtitle
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
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
                )
                .animate()
                .fadeIn(duration: 700.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            // Gender Options
            ...genderOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedGender == option['value'];

              return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () => _handleSelection(option['value']),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? option['color'].withOpacity(0.1)
                                  : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isSelected
                                    ? option['color']
                                    : AppColors.divider,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: option['color'].withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ]
                                  : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? option['color'].withOpacity(0.2)
                                        : AppColors.divider.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                option['icon'],
                                color:
                                    isSelected
                                        ? option['color']
                                        : AppColors.textSecondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['value'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                      color:
                                          isSelected
                                              ? option['color']
                                              : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option['description'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.arrow_forward_ios,
                              color:
                                  isSelected
                                      ? option['color']
                                      : AppColors.textLight,
                              size: isSelected ? 24 : 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: (300 + index * 100).ms)
                  .slideX(begin: 0.1, end: 0);
            }).toList(),

            const SizedBox(height: 24),

            // Support Message
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
                      Icon(
                        Icons.support_agent,
                        color: AppColors.success,
                        size: 24,
                      ),
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
                )
                .animate()
                .fadeIn(duration: 1.seconds, delay: 800.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
