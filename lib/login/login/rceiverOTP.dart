import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/login/signup/terms_and_condition.dart';
import 'package:projecho/main/registration_data.dart';
import 'package:projecho/utils/phone_number_utils.dart'; // ✅ ADD THIS IMPORT

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with TickerProviderStateMixin {
  String currentOTP = '';
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late AnimationController _timerController;
  int _resendTimer = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..forward();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _verifyOTP() async {
    if (currentOTP.length != 6) {
      _showErrorSnackBar('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: currentOTP,
      );
      await _auth.signInWithCredential(credential);

      // 🔧 FIX: Use cleaned phone number for Firestore lookup
      final String cleanedPhone = PhoneNumberUtils.cleanForDocumentId(
        widget.phoneNumber,
      );

      print('📱 Original phone: ${widget.phoneNumber}');
      print('📱 Cleaned phone for lookup: $cleanedPhone');

      final firestore = FirebaseFirestore.instance;
      final userDoc =
          await firestore.collection('users').doc(cleanedPhone).get();

      print('📱 Document exists: ${userDoc.exists}');
      if (userDoc.exists) {
        print('📱 User data: ${userDoc.data()}');
      }

      setState(() => _isLoading = false);

      if (userDoc.exists) {
        // ✅ User already registered - go to home
        print('✅ Existing user found - navigating to home');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // ✅ New user - start registration flow
        print('✅ New user - starting registration flow');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => TermsAndConditionsPage(
                  registrationData: RegistrationData(
                    phoneNumber: widget.phoneNumber,
                  ),
                ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      _showErrorSnackBar('Verification failed: ${e.message}');
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ General Error: $e');
      _showErrorSnackBar('Something went wrong. Please try again.');
    }
  }

  void _resendOTP() async {
    try {
      setState(() => _isLoading = true);

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          _showErrorSnackBar('Failed to resend code: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isLoading = false);
          _showSuccessSnackBar('New verification code sent!');
          // You might want to update the verificationId here
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // This callback is triggered when SMS auto-retrieval times out
          print('Auto-retrieval timeout for verification ID: $verificationId');
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: null, // You can store and use resend token
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to resend code. Please try again.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
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
        title: Text(
          'Phone Verification',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
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
            Center(
              child: Text(
                'Verification Code',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Enter the 6-digit code sent to',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

            Center(
              child: Text(
                widget.phoneNumber,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 40),

            // OTP Input
            PinCodeTextField(
              length: 6,
              appContext: context,
              keyboardType: TextInputType.number,
              animationType: AnimationType.scale,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(12),
                fieldHeight: 56,
                fieldWidth: 50,
                activeFillColor: AppColors.primary.withOpacity(0.1),
                selectedFillColor: AppColors.primary.withOpacity(0.05),
                inactiveFillColor: AppColors.surface,
                activeColor: AppColors.primary,
                selectedColor: AppColors.primary,
                inactiveColor: AppColors.divider,
              ),
              animationDuration: const Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              enableActiveFill: true,
              onChanged: (value) {
                setState(() => currentOTP = value);
              },
              onCompleted: (value) {
                _verifyOTP();
              },
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

            const SizedBox(height: 32),

            // Verify Button
            Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          currentOTP.length == 6
                              ? [AppColors.primary, AppColors.primaryLight]
                              : [AppColors.divider, AppColors.divider],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow:
                        currentOTP.length == 6
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
                        currentOTP.length == 6 && !_isLoading
                            ? _verifyOTP
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color:
                                    currentOTP.length == 6
                                        ? Colors.white
                                        : AppColors.textSecondary,
                              ),
                            ),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 500.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Resend Timer/Button
            Center(
              child:
                  _resendTimer > 0
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
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
                        onPressed:
                            _isLoading
                                ? null
                                : () {
                                  setState(() => _resendTimer = 60);
                                  _startResendTimer();
                                  _resendOTP();
                                },
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text('Resend Code'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
            ).animate().fadeIn(duration: 800.ms, delay: 700.ms),

            const SizedBox(height: 32),

            // Debug info (remove in production)
            // if (true) // Set to false in production
            //   Container(
            //     padding: EdgeInsets.all(12),
            //     decoration: BoxDecoration(
            //       color: Colors.grey.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Debug Info:',
            //           style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //             fontSize: 12,
            //           ),
            //         ),
            //         SizedBox(height: 4),
            //         Text(
            //           'Original: ${widget.phoneNumber}',
            //           style: TextStyle(fontSize: 11),
            //         ),
            //         Text(
            //           'Cleaned: ${PhoneNumberUtils.cleanForDocumentId(widget.phoneNumber)}',
            //           style: TextStyle(fontSize: 11),
            //         ),
            //       ],
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
