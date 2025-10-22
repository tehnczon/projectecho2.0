import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/main/registration_data.dart';
import 'package:projecho/form/plhivForm/step1_age_identity.dart';
import 'package:projecho/form/plhivForm/step2_education_status.dart';
import 'package:projecho/form/plhivForm/step3_health_pregnancy.dart';
import 'package:projecho/form/plhivForm/step4_sexual_practices.dart';
import 'package:projecho/form/plhivForm/step5_work_status.dart';
import 'package:projecho/form/plhivForm/step6_confirmation.dart';
import 'package:projecho/login/registration_flow_manager.dart';

class PLHIVStepperScreen extends StatefulWidget {
  final RegistrationData registrationData;

  const PLHIVStepperScreen({super.key, required this.registrationData});

  @override
  State<PLHIVStepperScreen> createState() => _PLHIVStepperScreenState();
}

class _PLHIVStepperScreenState extends State<PLHIVStepperScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final _formKeys = List.generate(6, (index) => GlobalKey<FormState>());
  late AnimationController _progressController;
  bool _isSubmitting = false;
  String? _submitError;

  final List<String> stepTitles = [
    "Your Identity",
    "Education & Life",
    "Health Journey",
    "Personal Wellness",
    "Work & Life",
    "Final Review",
  ];

  final List<IconData> stepIcons = [
    Icons.person_outline,
    Icons.school_outlined,
    Icons.favorite_outline,
    Icons.psychology_outlined,
    Icons.work_outline,
    Icons.check_circle_outline,
  ];

  final List<String> encouragingMessages = [
    "Welcome! Your voice matters here. 💙",
    "Every journey is unique and valuable. 🌟",
    "Your health story helps others too. 💚",
    "Thank you for trusting us. 🤝",
    "Almost there! You're doing amazing. 💪",
    "One final step. We're proud of you! 🎉",
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Save initial progress
    _saveProgressLocally();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  // Save progress locally with current step
  Future<void> _saveProgressLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressData = {
        'currentStep': 'plhiv_form_step_$_currentStep',
        'stepNumber': _currentStep,
        'registrationData': widget.registrationData.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString('registration_progress', json.encode(progressData));
    } catch (e) {
      print('Failed to save progress locally: $e');
    }
  }

  Future<void> _clearLocalProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('registration_progress');
    } catch (e) {
      print('Failed to clear local progress: $e');
    }
  }

  bool _validateCurrentStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      return true;
    } else {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Please fill in all required fields'),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return false;
    }
  }

  void _nextStep() async {
    if (!_validateCurrentStep()) return;

    if (_currentStep < stepTitles.length - 1) {
      setState(() => _currentStep++);
      _progressController.forward(from: 0);
      HapticFeedback.lightImpact();

      // Save progress after each step
      await _saveProgressLocally();
    } else {
      // Final step - submit form
      await _submitForm();
    }
  }

  void _previousStep() async {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _progressController.forward(from: 0);
      HapticFeedback.lightImpact();

      // Save progress when going back
      await _saveProgressLocally();
    }
  }

  Widget _buildModernTimeline() {
    return Container(
      height: 120,
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: stepTitles.length,
        itemBuilder: (context, index) {
          final isActive = index == _currentStep;
          final isPassed = index < _currentStep;

          return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 44 : 32,
                      height: isActive ? 44 : 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isActive
                                ? AppColors.primary
                                : isPassed
                                ? AppColors.success
                                : AppColors.divider,
                        boxShadow:
                            isActive
                                ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                                : [],
                      ),
                      child: Icon(
                        isPassed ? Icons.check : stepIcons[index],
                        color: Colors.white,
                        size: isActive ? 20 : 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        stepTitles[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          color:
                              isActive
                                  ? AppColors.primary
                                  : isPassed
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: (index * 100).ms)
              .slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width:
                constraints.maxWidth * ((_currentStep + 1) / stepTitles.length),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEncouragementCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.secondary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  encouragingMessages[_currentStep],
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),

          // Progress indicator
          if (_currentStep > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.timeline, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Step ${_currentStep + 1} of ${stepTitles.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Text(
                  '${((_currentStep + 1) / stepTitles.length * 100).round()}% Complete',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          // Error message display
          if (_submitError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _submitError!,
                      style: TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _submitError = null),
                    child: Text('Dismiss', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStepContent() {
    Widget content;
    switch (_currentStep) {
      case 0:
        content = Step1AgeIdentityForm(
          registrationData: widget.registrationData,
          formKey: _formKeys[0],
        );
        break;
      case 1:
        content = Step2EducationStatusForm(
          registrationData: widget.registrationData,
          formKey: _formKeys[1],
        );
        break;
      case 2:
        content = Step3HealthPregnancyForm(
          registrationData: widget.registrationData,
          formKey: _formKeys[2],
        );
        break;
      case 3:
        content = Step4SexualPracticesForm(
          registrationData: widget.registrationData,
          formKey: _formKeys[3],
        );
        break;
      case 4:
        content = Step5WorkStatusForm(
          registrationData: widget.registrationData,
          formKey: _formKeys[4],
        );
        break;
      case 5:
        content = Step6FinalConfirmation(
          registrationData: widget.registrationData,
          formKey: _formKeys[5],
        );
        break;
      default:
        content = Container();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(key: ValueKey(_currentStep), child: content),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _previousStep,
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  label: const Text("Back"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.divider),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),

            // Next/Submit button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _nextStep,
                icon:
                    _isSubmitting
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Icon(
                          _currentStep == stepTitles.length - 1
                              ? Icons.check_circle
                              : Icons.arrow_forward,
                          size: 20,
                        ),
                label: Text(
                  _isSubmitting
                      ? "Saving..."
                      : _currentStep == stepTitles.length - 1
                      ? "Complete Registration"
                      : "Continue",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isSubmitting
                          ? AppColors.primary.withOpacity(0.7)
                          : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _isSubmitting ? 0 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    // Show submission dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Completing your registration...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This may take a moment',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        // Attempt to save to Firestore
        bool success = await widget.registrationData.saveToAnalyticData();

        if (success) {
          // Clear local progress after successful save
          await _clearLocalProgress();

          Navigator.pop(context); // Close loading dialog

          // Navigate to welcome screen
          RegistrationFlowManager.navigateToNextStep(
            context: context,
            currentStep: 'plhivForm',
            registrationData: widget.registrationData,
          );
          // Show success message

          return;
        } else {
          throw Exception('Save operation returned false');
        }
      } catch (e) {
        retryCount++;
        print('Save attempt $retryCount failed: $e');

        if (retryCount < maxRetries) {
          // Wait before retry with exponential backoff
          await Future.delayed(Duration(seconds: retryCount * 2));
        } else {
          // Max retries reached - show error
          Navigator.pop(context); // Close loading dialog
          _handleSubmissionError(e.toString());
          return;
        }
      }
    }
  }

  void _handleSubmissionError(String error) {
    setState(() {
      _isSubmitting = false;
      _submitError =
          'Failed to complete registration. Please check your connection and try again.';
    });

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 24),
                SizedBox(width: 8),
                Text('Registration Error'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We couldn\'t complete your registration right now. Your progress has been saved.',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can try again or come back later to complete registration.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Try Later',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _submitForm(); // Retry
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text('Retry'),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.help_outline, color: AppColors.primary, size: 24),
                SizedBox(width: 8),
                Text('Need Help?'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Your progress is automatically saved'),
                SizedBox(height: 8),
                Text('• You can go back to previous steps anytime'),
                SizedBox(height: 8),
                Text('• All information is kept confidential'),
                SizedBox(height: 8),
                Text('• Skip optional fields if you prefer'),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Your participation helps improve healthcare for everyone. Thank you! 💚',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Got it!',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isSubmitting) {
          // Show warning about interrupting submission
          final shouldExit = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Exit Registration?'),
                  content: Text(
                    'Your registration is in progress. Exiting now may lose your current progress.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Stay'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Exit',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
          );
          return shouldExit ?? false;
        }

        // Save progress when going back
        await _saveProgressLocally();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text(
            "Health Profile",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          ),
          actions: [
            // Help button
            IconButton(
              icon: Icon(Icons.help_outline, color: AppColors.textSecondary),
              onPressed: _isSubmitting ? null : () => _showHelpDialog(),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildModernTimeline(),
            _buildProgressBar(),
            _buildEncouragementCard(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildStepContent(),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }
}
