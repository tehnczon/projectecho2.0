import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/main/registration_data.dart';
import 'package:projecho/login/signup/plhivForm/step1_demographic_data.dart';
import 'package:projecho/login/signup/plhivForm/step2_occupation.dart';
import 'package:projecho/login/signup/plhivForm/Step3_HistoryOfExposureForm.dart';
import 'package:projecho/login/signup/plhivForm/step4_medical_history.dart';
import 'package:projecho/login/signup/plhivForm/step5_hiv_test.dart';
import 'package:projecho/login/signup/plhivForm/step6_confirmation.dart';
import 'package:projecho/login/registration_flow_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/login/signup/plhivForm/FormDataMapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilingeditScreen extends StatefulWidget {
  final RegistrationData registrationData;

  const ProfilingeditScreen({
    super.key,
    required this.registrationData,
    required uid,
  });

  @override
  State<ProfilingeditScreen> createState() => _ProfilingeditScreenState();
}

class _ProfilingeditScreenState extends State<ProfilingeditScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final _formKeys = List.generate(6, (index) => GlobalKey<FormState>());
  late AnimationController _progressController;
  bool _isSubmitting = false;
  String? _submitError;
  String? _userRole;
  bool _hasLoadedRole = false;

  // Track terms agreement state
  bool _isTermsAgreed = false;

  final List<String> stepTitles = [
    "DEMOGRAPHIC DATA",
    "OCCUPATION",
    "HISTORY OF EXPOSURE",
    "MEDICAL HISTORY",
    "PREVIOUS HIV TEST",
    "FINAL CONFIRMATION",
  ];

  final List<IconData> stepIcons = [
    Icons.person_outline,
    Icons.school_outlined,
    Icons.favorite_outline,
    Icons.psychology_outlined,
    Icons.work_outline,
    Icons.check_circle_outline,
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fetchUserRole(); // 👈 detect role
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

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
    // Special validation for final confirmation step
    if (_currentStep == 5) {
      // First validate form fields
      if (!(_formKeys[_currentStep].currentState?.validate() ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Please fill in all required fields')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(8),
          ),
        );
        return false;
      }

      // Then check terms agreement
      if (!_isTermsAgreed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please accept the terms and conditions to proceed',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(8),
            duration: Duration(seconds: 3),
          ),
        );
        return false;
      }

      return true;
    }

    // Regular validation for other steps
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('Please fill in all required fields')),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(8),
        ),
      );
      return false;
    }
  }

  void _nextStep() async {
    if (!_validateCurrentStep()) return;

    final isPlhiv = _userRole == 'plhiv';
    final finalStep =
        isPlhiv ? 4 : 5; // PLHIV stops at Step5, infoSeeker at Step6

    if (_currentStep < finalStep) {
      setState(() => _currentStep++);
      _progressController.forward(from: 0);
      HapticFeedback.lightImpact();
      await _saveProgressLocally();
    } else {
      await _submitForm();
    }
  }

  void _previousStep() async {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _progressController.forward(from: 0);
      HapticFeedback.lightImpact();
      await _saveProgressLocally();
    }
  }

  Widget _buildCompactProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          // Progress indicator
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width:
                        constraints.maxWidth *
                        ((_currentStep + 1) / stepTitles.length),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 12),
          // Step counter
          Text(
            '${_currentStep + 1}/${stepTitles.length}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    if (!_hasLoadedRole) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    Widget content;

    // If user is PLHIV and reached Step 5, we stop at Step5 (no Step6)
    final maxStep = (_userRole == 'plhiv') ? 5 : 6;

    switch (_currentStep) {
      case 0:
        content = Step1DemographicForm(
          registrationData: widget.registrationData,
          formKey: _formKeys[0],
        );
        break;
      case 1:
        content = Step2OccupationForm(
          registrationData: widget.registrationData,
          formKey: _formKeys[1],
        );
        break;
      case 2:
        content = Step3HistoryOfExposureForm(
          registrationData: widget.registrationData,
          formKey: _formKeys[2],
        );
        break;
      case 3:
        content = Step4MedicalHistoryForm(
          registrationData: widget.registrationData,
          formKey: _formKeys[3],
        );
        break;
      case 4:
        content = Step5PreviousHIVTestForm(
          registrationData: widget.registrationData,
          formKey: _formKeys[4],
        );
        break;
      case 5:
        if (_userRole == 'plhiv') {
          // PLHIV skips Step6 entirely; treat Step5 as final
          content = Step5PreviousHIVTestForm(
            registrationData: widget.registrationData,
            formKey: _formKeys[4],
          );
        } else {
          content = Step6FinalConfirmation(
            registrationData: widget.registrationData,
            formKey: _formKeys[5],
            onAgreementChanged: (isAgreed) {
              setState(() => _isTermsAgreed = isAgreed);
            },
          );
        }
        break;
      default:
        content = Container();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(key: ValueKey(_currentStep), child: content),
    );
  }

  Widget _buildCompactNavigationButtons() {
    // Check if we're on the final step and terms not agreed
    final isCompleteButtonDisabled = _currentStep == 5 && !_isTermsAgreed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              IconButton(
                onPressed: _isSubmitting ? null : _previousStep,
                icon: Icon(Icons.arrow_back_ios, size: 18),
                color: AppColors.textSecondary,
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            if (_currentStep > 0) SizedBox(width: 4),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    (_isSubmitting || isCompleteButtonDisabled)
                        ? null
                        : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isSubmitting
                          ? AppColors.primary.withOpacity(0.7)
                          : isCompleteButtonDisabled
                          ? AppColors.divider
                          : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation:
                      (_isSubmitting || isCompleteButtonDisabled) ? 0 : 1,
                  disabledBackgroundColor: AppColors.divider,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSubmitting)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      Icon(
                        _currentStep == stepTitles.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                        size: 18,
                      ),
                    SizedBox(width: 8),
                    Text(
                      _isSubmitting
                          ? "Saving..."
                          : _currentStep == stepTitles.length - 1
                          ? "Complete"
                          : "Continue",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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

  Future<void> _fetchUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('⚠️ No authenticated user found');
        if (mounted) {
          setState(() {
            _hasLoadedRole = true;
            _userRole = null;
          });
        }
        return;
      }

      // Use the uid from widget or current user
      final uid = widget.registrationData.uid;

      print('🔍 Fetching role for uid: $uid');

      // Consistent collection name - use 'users' everywhere
      final doc =
          await FirebaseFirestore.instance
              .collection('user') // Changed from 'user' to 'users'
              .doc(uid)
              .get();

      if (!doc.exists) {
        print('⚠️ User document not found for uid: $uid');
        if (mounted) {
          setState(() {
            _hasLoadedRole = true;
            _userRole = null;
          });
        }
        return;
      }

      final data = doc.data();
      final role = data?['role'] as String?;

      print('✅ User role loaded: $role');

      if (mounted) {
        setState(() {
          _userRole = role;
          _hasLoadedRole = true;
        });

        // Show notice for infoSeeker
        if (_userRole == 'infoSeeker') {
          _showPLHIVNotice();
        }
      }
    } catch (e) {
      print('⚠️ Failed to fetch user role: $e');
      if (mounted) {
        setState(() {
          _hasLoadedRole = true; // Still set to true to stop infinite loading
          _userRole = null;
        });

        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
    );

    try {
      // Get uid from widget
      final uid = widget.registrationData.uid;

      // Save to analyticData (shared behavior)
      await widget.registrationData.saveToAnalyticData();

      // If infoSeeker, update Firestore role to plhiv after completion
      if (_userRole == 'infoSeeker') {
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('user').doc(uid).update({
          // ✅ Now uid is defined!
          'role': 'plhiv',
        });
        print('✅ User role updated from infoSeeker to plhiv');
      }

      Navigator.pop(context); // close loading

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Form saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Move to next step/close page
        RegistrationFlowManager.navigateToNextStep(
          context: context,
          currentStep: 'plhivForm',
          registrationData: widget.registrationData,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _handleSubmissionError(e.toString());
      print('❌ Error submitting form: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Encrypt phone number using cloud function
  Future<String?> _encryptPhoneNumber(String phoneNumber) async {
    try {
      final url = Uri.parse('https://encryptphone-sgjiksmfoa-uc.a.run.app');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phoneNumber': phoneNumber}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final encryptedPhone = data['encrypted'] as String?;
        print('✅ Phone encrypted successfully');
        return encryptedPhone;
      } else {
        print('⚠️ Encryption returned ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ Failed to encrypt phone: $e');
      return null;
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
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 20),
                SizedBox(width: 8),
                Text('Registration Error', style: TextStyle(fontSize: 16)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We couldn\'t complete your registration. Your progress has been saved locally.',
                  style: TextStyle(fontSize: 13),
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
                      Icon(Icons.security, color: AppColors.primary, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your sensitive data is protected and encrypted',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
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
                  _submitForm();
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

  void _showPLHIVNotice() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.health_and_safety, color: AppColors.primary),
                  // SizedBox(width: 8),
                  Text(
                    'PLHIV Form Notice',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
              content: Text(
                'This page is for PLHIV profiling.\n\n'
                'After you agree to the terms and complete this form, '
                'your role will automatically change to PLHIV.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Got it',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
      );
    });
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
                Icon(Icons.info_outline, color: AppColors.primary, size: 24),
                SizedBox(width: 10),
                Text(
                  'Privacy & Information',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Voluntary Section
                  Text(
                    'Fill at your own pace:',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildBullet('All fields are optional'),
                  _buildBullet('You can skip any section'),

                  SizedBox(height: 16),

                  // Personal Data
                  Text(
                    'Your personal data:',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildBullet('Used only for your app profile'),
                  _buildBullet('Kept confidential and secure'),
                  _buildBullet('You can edit anytime'),

                  SizedBox(height: 16),

                  // Research Data
                  Text(
                    'Research use:',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildBullet('Non-identifiable data for health research'),
                  _buildBullet('No personal identifiers shared'),
                  _buildBullet('Helps improve healthcare services'),

                  SizedBox(height: 16),

                  // Privacy Commitment
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your privacy is protected',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Got it!',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isSubmitting) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    'Exit Registration?',
                    style: TextStyle(fontSize: 16),
                  ),
                  content: Text(
                    'Registration in progress. Exit now?',
                    style: TextStyle(fontSize: 13),
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
        await _saveProgressLocally();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          toolbarHeight: 48,
          titleSpacing: 0,
          title: Text(
            "DOH Form A - ${stepTitles[_currentStep]}",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: AppColors.textPrimary,
            ),
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            padding: EdgeInsets.all(8),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.help_outline,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: _isSubmitting ? null : _showHelpDialog,
              padding: EdgeInsets.all(8),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildCompactProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: _buildStepContent(),
              ),
            ),
            _buildCompactNavigationButtons(),
          ],
        ),
      ),
    );
  }
}
