import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/main/registration_data.dart';
import 'package:projecho/login/registration_flow_manager.dart';

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
  bool _showRetryOption = false;
  String? _errorMessage;

  // Enhanced user types with clear descriptions
  final List<Map<String, dynamic>> userTypes = [
    {
      'type': 'PLHIV',
      'title': 'Person Living with HIV',

      'icon': Icons.favorite,
      'color': AppColors.primary,
      'benefits': [
        'DOH HIV testing form profiling',
        'Treatment hub locator',
        'Personalized learnings',
        'Encouragement dashboard',
        'Feed anonymous data for research',
      ],
      'helpText':
          'Get access to specialized resources, connect with treatment hubs, and contribute to research while maintaining complete privacy and anonymity.',
    },
    {
      'type': 'Health Information Seeker',
      'title': 'Health Information Seeker',

      'icon': Icons.school,
      'color': AppColors.secondary,
      'benefits': [
        'Demographic profiling',
        'Treatment hub locator',
        'Personalized learnings',
        'Encouragement dashboard',
      ],
      'helpText':
          'Access educational content, find testing locations, and get reliable information about HIV prevention and care. No personal health disclosure required.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _saveProgressLocally();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveProgressLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressData = {
        'currentStep': 'userType',
        'registrationData': widget.registrationData.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString('registration_progress', json.encode(progressData));
    } catch (e) {
      print('Failed to save progress locally: $e');
    }
  }

  void _handleSelection(String? userType) {
    if (userType == null || _isLoading) return;

    HapticFeedback.mediumImpact();
    setState(() {
      selectedType = userType;
      widget.registrationData.userType = userType;
      _errorMessage = null;
    });
  }

  Future<void> _handleContinue() async {
    if (selectedType == null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _showRetryOption = false;
      _errorMessage = null;
    });

    await _saveProgressLocally();
    await Future.delayed(const Duration(milliseconds: 500));

    if (selectedType == 'PLHIV') {
      await widget.registrationData.saveToProfiles();
      await widget.registrationData.saveToUser();
      _navigateToPLHIVFlow();
    } else {
      await widget.registrationData.saveToProfiles();
      _navigateToDemographic();
    }
  }

  void _navigateToPLHIVFlow() {
    setState(() => _isLoading = false);
    RegistrationFlowManager.navigateToNextStep(
      context: context,
      currentStep: 'userType',
      registrationData: widget.registrationData,
    );
  }

  void _navigateToDemographic() {
    setState(() => _isLoading = false);
    RegistrationFlowManager.navigateToNextStep(
      context: context,
      currentStep: 'userType',
      registrationData: widget.registrationData,
    );
  }

  Map<String, dynamic>? _getSelectedTypeData() {
    return userTypes.firstWhere(
      (type) => type['type'] == selectedType,
      orElse: () => {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedTypeData = _getSelectedTypeData();

    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please wait for the current operation to complete',
              ),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        await _saveProgressLocally();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: _isLoading ? null : () => Navigator.pop(context),
          ),
          title: Text(
            'User Type Selection',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
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
                    'Choose the option that best describes you',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 20),

              // Privacy and Comfort Notice
              Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 20,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your Choice, Your Privacy',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You can choose "Health Information Seeker" for any reason—whether you\'re seeking general knowledge, supporting someone, or simply prefer not to disclose. Both options give you valuable resources, and you can always update your profile later.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 700.ms, delay: 150.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

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

              // Dropdown Label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'I\'m registering as:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 12),

              // Dropdown Field with Enhanced Descriptions
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        selectedType != null
                            ? AppColors.primary.withOpacity(0.5)
                            : AppColors.divider,
                    width: selectedType != null ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          selectedType != null
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: InputBorder.none,
                  ),
                  hint: Text(
                    'Select your role',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
                  dropdownColor: AppColors.surface,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  // Updated dropdown items to include descriptions
                  items:
                      userTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['type'],
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: type['color'].withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  type['icon'],
                                  color: type['color'],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      type['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: _isLoading ? null : _handleSelection,
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

              // Help Text Section (shows when option selected)
              if (selectedType != null && selectedTypeData!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selectedTypeData['color'].withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedTypeData['color'].withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: selectedTypeData['color'],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedTypeData['helpText'],
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
              ],

              // Benefits Section (shows when option selected)
              if (selectedType != null && selectedTypeData!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        selectedTypeData['color'].withOpacity(0.08),
                        selectedTypeData['color'].withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedTypeData['color'].withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: selectedTypeData['color'],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'What you\'ll get:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: selectedTypeData['color'],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...(selectedTypeData['benefits'] as List<String>)
                          .map(
                            (benefit) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: selectedTypeData['color']
                                          .withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: selectedTypeData['color'],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      benefit,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                        height: 1.5,
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
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
              ],

              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      selectedType != null && !_isLoading
                          ? _handleContinue
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedType != null
                            ? AppColors.primary
                            : AppColors.divider,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: selectedType != null ? 4 : 0,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                    disabledBackgroundColor: AppColors.divider,
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock,
                              size: 20,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Complete Privacy Guaranteed',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your information is encrypted, confidential, and never shared. You have full control to update or delete your data anytime.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 1000.ms, delay: 800.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                  ),

              // Loading Status
              if (_isLoading)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedType == 'PLHIV'
                            ? 'Preparing PLHIV registration...'
                            : 'Completing registration...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
