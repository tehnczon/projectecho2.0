import 'package:flutter/material.dart';
import '../../main/registration_data.dart';

class Step4SexualPracticesForm extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const Step4SexualPracticesForm({
    Key? key,
    required this.registrationData,
    required this.formKey,
  }) : super(key: key);

  @override
  State<Step4SexualPracticesForm> createState() =>
      _Step4SexualPracticesFormState();
}

class _Step4SexualPracticesFormState extends State<Step4SexualPracticesForm> {
  final List<String> options = [
    "Male",
    "Female",
    "Both",
    "Never",
    "Prefer not to say",
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 4 - Sexual Practices",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          const Text(
            "Have you had sex without a condom with:",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),

          ...options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: widget.registrationData.unprotectedSexWith,
              onChanged: (value) {
                setState(() {
                  widget.registrationData.unprotectedSexWith = value;
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
