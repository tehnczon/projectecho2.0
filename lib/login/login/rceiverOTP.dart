import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/login/signup/termsCondition.dart';
import 'package:projecho/main/mainPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';

/// Enhanced OTP Screen with secure phone storage and proper user flow
class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final VoidCallback? onResendSuccess;
  final VoidCallback? onVerificationSuccess;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.onResendSuccess,
    this.onVerificationSuccess,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _otpController = TextEditingController();
  late AnimationController _timerController;
  late AnimationController _shakeController;
  Timer? _resendTimerInstance;

  // State
  String _currentOTP = '';
  bool _isLoading = false;
  bool _autoVerifying = false;
  int _resendTimer = 60;
  int _attemptCount = 0;
  String? _currentVerificationId;

  // Constants
  static const int _maxAttempts = 5;
  static const int _resendCooldown = 60;
  static const int _otpLength = 6;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _initializeControllers();
    _startResendTimer();
  }

  void _initializeControllers() {
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _resendCooldown),
    )..forward();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timerController.dispose();
    _shakeController.dispose();
    _resendTimerInstance?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimerInstance?.cancel();
    _resendTimerInstance = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    // Validate OTP length
    if (_currentOTP.length != _otpLength) {
      _showError('Please enter the complete $_otpLength-digit code');
      _shakeAnimation();
      return;
    }

    // Check attempt limit
    if (_attemptCount >= _maxAttempts) {
      _showError('Too many attempts. Please request a new code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _attemptCount++;
    });

    HapticFeedback.mediumImpact();

    try {
      // Create credential
      final credential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId!,
        smsCode: _currentOTP,
      );

      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception("Authentication failed - no user returned");
      }

      final uid = user.uid;
      final phoneNumber = user.phoneNumber!;

      // Check if user already exists (returning user)
      final userDoc = await _firestore.collection('user').doc(uid).get();
      final userExists = userDoc.exists;

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Call success callback
      widget.onVerificationSuccess?.call();

      // Navigate based on user status
      if (userExists) {
        // Existing user - go to main page
        _navigateToMainPage();
      } else {
        // New user - go to onboarding (DON'T create Firestore doc yet)
        // Pass both uid and phoneNumber to onboarding
        _navigateToOnboarding(uid, phoneNumber);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _handleAuthError(e);
      _shakeAnimation();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      print('❌ Unexpected error during OTP verification: $e');
      _showError('Something went wrong. Please try again.');
      _shakeAnimation();
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String errorMessage = 'Verification failed';

    switch (e.code) {
      case 'invalid-verification-code':
        errorMessage = 'Invalid code. Please check and try again.';
        break;
      case 'session-expired':
        errorMessage = 'Code expired. Please request a new one.';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many attempts. Please try again later.';
        break;
      case 'network-request-failed':
        errorMessage = 'Network error. Check your connection.';
        break;
      default:
        errorMessage = e.message ?? errorMessage;
    }

    _showError(errorMessage);
    print('❌ Firebase Auth error: ${e.code} - ${e.message}');
  }

  /// Encrypt phone number and return encrypted version
  /// This should be called when creating the user document (after onboarding)
  Future<String?> encryptPhoneNumber(String phoneNumber) async {
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
        print(
          '⚠️ Encryption function returned ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('⚠️ Failed to encrypt phone number: $e');
      return null;
    }
  }

  Future<void> _resendOTP() async {
    if (_isLoading || _resendTimer > 0) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification
          if (!mounted) return;
          setState(() => _autoVerifying = true);

          try {
            await _auth.signInWithCredential(credential);
            _showSuccess('Phone verified automatically!');
            widget.onVerificationSuccess?.call();
            _navigateToMainPage();
          } catch (e) {
            print('Auto-verification failed: $e');
            setState(() => _autoVerifying = false);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _isLoading = false);

          String errorMessage = 'Failed to send code';
          if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later.';
          } else if (e.code == 'quota-exceeded') {
            errorMessage = 'SMS quota exceeded. Please try again later.';
          } else if (e.message != null) {
            errorMessage = e.message!;
          }

          _showError(errorMessage);
          print('Resend failed: ${e.code} - ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          setState(() {
            _currentVerificationId = verificationId;
            _isLoading = false;
            _resendTimer = _resendCooldown;
            _attemptCount = 0; // Reset attempts on new code
            _currentOTP = '';
          });

          _otpController.clear();
          _timerController.reset();
          _timerController.forward();
          _startResendTimer();

          _showSuccess('New verification code sent!');
          widget.onResendSuccess?.call();
          print('✅ New verification ID: $verificationId');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!mounted) return;
          setState(() => _currentVerificationId = verificationId);
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Failed to resend code. Please try again.');
      print('❌ Resend error: $e');
    }
  }

  void _shakeAnimation() {
    _shakeController.forward(from: 0);
  }

  void _navigateToMainPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  }

  void _navigateToOnboarding(String uid, String phoneNumber) {
    // Pass phoneNumber to onboarding so it can be encrypted and stored
    // ONLY after the user completes registration (after userType for InfoSeeker,
    // after mainplhivform for PLHIV)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder:
            (_) => TermsAndConditionsPage(
              uid: uid,
              phoneNumber: phoneNumber, // Add this parameter
            ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Phone Verification',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon with animation
              Center(
                child: Container(
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
                  child: Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                    size: 50,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Verification Code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Enter the $_otpLength-digit code sent to',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

              const SizedBox(height: 4),

              // Phone number
              Text(
                widget.phoneNumber,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

              const SizedBox(height: 40),

              // OTP Input with shake animation
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = sin(_shakeController.value * pi * 3) * 5;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: PinCodeTextField(
                  length: _otpLength,
                  appContext: context,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.scale,
                  autoFocus: true,
                  enableActiveFill: true,
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 56,
                    fieldWidth: 50,
                    activeFillColor: AppColors.primary.withOpacity(0.1),
                    selectedFillColor: AppColors.primary.withOpacity(0.05),
                    inactiveFillColor: AppColors.surface,
                    errorBorderColor: AppColors.error,
                    activeColor: AppColors.primary,
                    selectedColor: AppColors.primary,
                    inactiveColor: AppColors.divider,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  onChanged: (value) {
                    setState(() => _currentOTP = value);
                  },
                  onCompleted: (value) {
                    if (!_isLoading) {
                      _verifyOTP();
                    }
                  },
                  beforeTextPaste: (text) {
                    // Allow pasting only numbers
                    return text?.contains(RegExp(r'^[0-9]+$')) ?? false;
                  },
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

              const SizedBox(height: 24),

              // Attempt counter (show after 2 attempts)
              if (_attemptCount >= 2)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Attempts: $_attemptCount/$_maxAttempts',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 24),

              // Verify Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        _currentOTP.length == _otpLength && !_isLoading
                            ? [AppColors.primary, AppColors.primaryLight]
                            : [AppColors.divider, AppColors.divider],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow:
                      _currentOTP.length == _otpLength && !_isLoading
                          ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ]
                          : [],
                ),
                child: ElevatedButton(
                  onPressed:
                      _currentOTP.length == _otpLength && !_isLoading
                          ? _verifyOTP
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: Colors.transparent,
                  ),
                  child:
                      _isLoading || _autoVerifying
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _autoVerifying
                                    ? 'Auto-verifying...'
                                    : 'Verifying...',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                          : Text(
                            'Verify Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  _currentOTP.length == _otpLength
                                      ? Colors.white
                                      : AppColors.textSecondary,
                            ),
                          ),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

              const SizedBox(height: 32),

              // Resend Section
              Center(
                child:
                    _resendTimer > 0
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Resend code in $_resendTimer seconds',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                        : TextButton.icon(
                          onPressed: _isLoading ? null : _resendOTP,
                          icon: Icon(
                            Icons.refresh_rounded,
                            size: 20,
                            color:
                                _isLoading
                                    ? AppColors.textSecondary
                                    : AppColors.primary,
                          ),
                          label: Text(
                            'Resend Code',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color:
                                  _isLoading
                                      ? AppColors.textSecondary
                                      : AppColors.primary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
              ).animate().fadeIn(duration: 800.ms, delay: 500.ms),

              const SizedBox(height: 24),

              // Help text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Didn\'t receive the code?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check your SMS inbox or wait for the timer to resend',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
