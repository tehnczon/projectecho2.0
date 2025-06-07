import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projecho/introduction_animation/userlogin/otp.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted = '';
    for (int i = 0; i < digitsOnly.length && i < 10; i++) {
      if (i == 3 || i == 6) formatted += ' ';
      formatted += digitsOnly[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class EnterNumberPage extends StatefulWidget {
  const EnterNumberPage({super.key});

  @override
  _EnterNumberPageState createState() => _EnterNumberPageState();
}

class _EnterNumberPageState extends State<EnterNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _submitNumber() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();

      setState(() {
        _isLoading = true;
      });

      final phoneNumber = '+63${_phoneController.text.replaceAll(RegExp(r'\D'), '')}';

      _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android only: auto sign in without user input
          await _auth.signInWithCredential(credential);
          setState(() {
            _isLoading = false;
          });
          // TODO: Navigate to home screen after auto verification
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: phoneNumber,
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto retrieval timeout callback (can be left empty or used to notify user)
        },
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please enter your phone number to register',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                autofocus: true,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 27,
                ),
                inputFormatters: [PhoneNumberInputFormatter()],
                decoration: const InputDecoration(
                  prefixText: '+63 ',
                  prefixStyle: TextStyle(
                    color: Color.fromARGB(255, 131, 131, 131),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  hintText: '*** *** ****',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 27,
                  ),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                  if (digits.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (digits.length != 10) {
                    return 'Enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Your mobile number should be in this format:',
                style: TextStyle(color: Colors.grey),
              ),
              const Text(
                '09123456789',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitNumber,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Send OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}