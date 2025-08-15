import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecho/login/signup/wlcmPrjecho.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/main/registration_data.dart';
import 'package:projecho/plhiv_form/step1_age_identity.dart';
import 'package:projecho/plhiv_form/step2_education_status.dart';
import 'package:projecho/plhiv_form/step3_health_pregnancy.dart';
import 'package:projecho/plhiv_form/step4_sexual_practices.dart';
import 'package:projecho/plhiv_form/step5_work_status.dart';
import 'package:projecho/plhiv_form/step6_confirmation.dart';

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
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < stepTitles.length - 1) {
        setState(() => _currentStep++);
        _progressController.forward(from: 0);
        HapticFeedback.lightImpact();
      } else {
        _submitForm();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _progressController.forward(from: 0);
      HapticFeedback.lightImpact();
    }
  }

  Widget _buildModernTimeline() {
    return Container(
      height: 120, // Increased from 100 to 120
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
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ), // Reduced vertical padding from 20 to 16
        itemCount: stepTitles.length,
        itemBuilder: (context, index) {
          final isActive = index == _currentStep;
          final isPassed = index < _currentStep;

          return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // Added to minimize space
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 44 : 32, // Slightly reduced from 48:36
                      height: isActive ? 44 : 32, // Slightly reduced from 48:36
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
                        size: isActive ? 20 : 16, // Reduced from 24:18
                      ),
                    ),

                    const SizedBox(height: 6), // Reduced from 8

                    Flexible(
                      // Wrapped in Flexible to prevent overflow
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
      child: Row(
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
      child: content,
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
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStep,
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
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _nextStep,
              icon: Icon(
                _currentStep == stepTitles.length - 1
                    ? Icons.check_circle
                    : Icons.arrow_forward,
                size: 20,
              ),
              label: Text(
                _currentStep == stepTitles.length - 1 ? "Complete" : "Continue",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    // Implementation remains the same as original
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final Map<String, dynamic> data = widget.registrationData.toJson();

      await FirebaseFirestore.instance
          .collection('plhiv_profiles')
          .doc(widget.registrationData.phoneNumber)
          .set(data);

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profiling completed successfully!")),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          onPressed: () => Navigator.pop(context),
        ),
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
    );
  }
}
