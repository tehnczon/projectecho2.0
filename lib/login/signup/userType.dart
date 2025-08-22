import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/main/registration_data.dart';
import 'package:projecho/plhiv_form/yeardiag.dart';
import 'package:projecho/login/signup/wlcmPrjecho.dart';

class UserTypeScreen extends StatefulWidget {
  final RegistrationData registrationData;

  const UserTypeScreen({super.key, required this.registrationData});

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen>
    with SingleTickerProviderStateMixin {
  String? selectedType;
  late AnimationController _animationController;
  bool _isLoading = false;

  final List<Map<String, dynamic>> userTypes = [
    {
      'type': 'PLHIV',
      'title': 'Person Living with HIV',
      'subtitle': 'Access specialized support and resources',
      'icon': Icons.favorite,
      'color': AppColors.primary,
      'benefits': [
        'Confidential support groups',
        'Health tracking tools',
        'Treatment resources',
        'Community connection',
      ],
    },
    {
      'type': 'Health Information Seeker',
      'title': 'Health Information Seeker',
      'subtitle': 'Learn and support the community',
      'icon': Icons.school,
      'color': AppColors.secondary,
      'benefits': [
        'Educational resources',
        'Research updates',
        'Community insights',
        'Support guidelines',
      ],
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

  void _handleSelection(String userType) async {
    HapticFeedback.mediumImpact();
    setState(() {
      selectedType = userType;
      widget.registrationData.userType = userType;
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (userType == 'PLHIV') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => YearDiagPage(registrationData: widget.registrationData),
        ),
      );
      setState(() => _isLoading = false);
    } else {
      // Health Information Seeker - save immediately
      try {
        // OLD CODE - REMOVE:
        // await FirebaseFirestore.instance
        //   .collection('users')
        //   .doc(widget.registrationData.phoneNumber)
        //   .set(widget.registrationData.toJson());

        // NEW CODE - USE THIS:
        bool success = await widget.registrationData.saveToFirestore();

        if (success) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
          );
          _showSuccessSnackBar('Profile saved successfully!');
        } else {
          _showErrorSnackBar('Error saving profile. Please try again.');
        }
      } catch (e) {
        _showErrorSnackBar('Error: $e');
      }
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
          children: [
            // Header Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people, color: AppColors.primary, size: 50),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 32),

            // Title
            Text(
              "Let's get to know you!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 12),

            // Subtitle
            Text(
              'Please select your role',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

            const SizedBox(height: 8),

            // Info Card
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.05),
                        AppColors.secondary.withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your participation helps healthcare providers and researchers better understand and support communities affected by HIV.',
                          style: TextStyle(
                            fontSize: 13,
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

            // User Type Cards
            ...userTypes.asMap().entries.map((entry) {
              final index = entry.key;
              final type = entry.value;
              final isSelected = selectedType == type['type'];

              return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: InkWell(
                      onTap:
                          _isLoading
                              ? null
                              : () => _handleSelection(type['type']),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? type['color'].withOpacity(0.1)
                                  : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected ? type['color'] : AppColors.divider,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isSelected
                                      ? type['color'].withOpacity(0.2)
                                      : Colors.black.withOpacity(0.05),
                              blurRadius: isSelected ? 20 : 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: type['color'].withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    type['icon'],
                                    color: type['color'],
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        type['title'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isSelected
                                                  ? type['color']
                                                  : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        type['subtitle'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isLoading && isSelected)
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: type['color'],
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.arrow_forward_ios,
                                    color:
                                        isSelected
                                            ? type['color']
                                            : AppColors.textLight,
                                    size: isSelected ? 24 : 16,
                                  ),
                              ],
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: type['color'].withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'What you\'ll get:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: type['color'],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...(type['benefits'] as List<String>)
                                        .map(
                                          (benefit) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: type['color'],
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    benefit,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          AppColors
                                                              .textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: (400 + index * 200).ms)
                  .slideX(begin: 0.1, end: 0);
            }).toList(),

            const SizedBox(height: 24),

            // Privacy Badge
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 20, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(
                        'Your information is kept confidential \n and secure',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 1000.ms, delay: 800.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ],
        ),
      ),
    );
  }
}
