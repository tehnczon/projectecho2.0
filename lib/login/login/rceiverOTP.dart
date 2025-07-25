import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:projecho/login/signup/terms_and_condition.dart';
import 'package:projecho/model/registration_data.dart'; 


class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OTPScreen({super.key, required this.phoneNumber, required this.verificationId});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String currentOTP = '';
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
void _verifyOTP() async {
  if (currentOTP.length != 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: currentOTP,
    );
    await _auth.signInWithCredential(credential);

    setState(() {
      _isLoading = false;
    });

    final registrationData = RegistrationData(phoneNumber: widget.phoneNumber);

    // Navigate to username step after successful verification
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TermsAndConditionsPage(registrationData: registrationData),
        ),
      );
  } on FirebaseAuthException catch (e) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error verifying OTP: ${e.message}')),
    );
  }
}

 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your 6 digit One-Time PIN (OTP)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Sent to ${widget.phoneNumber}',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            PinCodeTextField(
              length: 6,
              appContext: context,
              autoDisposeControllers: false,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.lightBlue.shade50,
                selectedFillColor: Colors.lightBlue.shade100,
                inactiveFillColor: Colors.grey.shade200,
                activeColor: Colors.lightBlue,
                selectedColor: Colors.lightBlueAccent,
                inactiveColor: Colors.grey,
              ),
              animationDuration: const Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              enableActiveFill: true,
              onChanged: (value) {
                setState(() {
                  currentOTP = value;
                });
              },
              onCompleted: (value) {
                // Optional: Auto-verify
              },
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Verify',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              // child: TextButton(
              //   onPressed: resendOTP,
              //   child: const Text(
              //     "Didn't receive the code? Resend",
              //     style: TextStyle(color: Colors.blue),
              //   ),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
