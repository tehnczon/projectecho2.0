import 'package:flutter/material.dart';
import '../main/registration_data.dart';

class Step6FinalConfirmation extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const Step6FinalConfirmation({
    Key? key,
    required this.registrationData,
    required this.formKey,
  }) : super(key: key);

  @override
  State<Step6FinalConfirmation> createState() => _Step6FinalConfirmationState();
}

class _Step6FinalConfirmationState extends State<Step6FinalConfirmation> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 6 - Final Confirmation",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text(
              "I understand this information is collected anonymously, and I agree to the terms and privacy policy.",
              style: TextStyle(fontSize: 16),
            ),
            value: _agreed,
            onChanged: (value) {
              setState(() {
                _agreed = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (!_agreed)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                "You must accept to proceed.",
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
