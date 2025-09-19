import 'package:flutter/material.dart';
import '../../main/registration_data.dart';

class Step3HealthPregnancyForm extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const Step3HealthPregnancyForm({
    Key? key,
    required this.registrationData,
    required this.formKey,
  }) : super(key: key);

  @override
  State<Step3HealthPregnancyForm> createState() =>
      _Step3HealthPregnancyFormState();
}

class _Step3HealthPregnancyFormState extends State<Step3HealthPregnancyForm> {
  bool get isFemale =>
      widget.registrationData.sexAssignedAtBirth?.toLowerCase() == "female";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 3 - Health & Pregnancy",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          if (isFemale)
            CheckboxListTile(
              title: const Text("Are you currently pregnant?"),
              value: widget.registrationData.isPregnant ?? false,
              onChanged: (value) {
                setState(() {
                  widget.registrationData.isPregnant = value;
                });
              },
            ),

          CheckboxListTile(
            title: const Text(
              "Did your birth mother have HIV when you were born?",
            ),
            value: widget.registrationData.motherHadHIV ?? false,
            onChanged: (value) {
              setState(() {
                widget.registrationData.motherHadHIV = value;
              });
            },
          ),

          CheckboxListTile(
            title: const Text("Have you ever been diagnosed with an STI?"),
            value: widget.registrationData.diagnosedSTI ?? false,
            onChanged: (value) {
              setState(() {
                widget.registrationData.diagnosedSTI = value;
              });
            },
          ),

          CheckboxListTile(
            title: const Text("With Hepatitis?"),
            value: widget.registrationData.hasHepatitis ?? false,
            onChanged: (value) {
              setState(() {
                widget.registrationData.hasHepatitis = value;
              });
            },
          ),

          CheckboxListTile(
            title: const Text("Current TB patient?"),
            value: widget.registrationData.hasTuberculosis ?? false,
            onChanged: (value) {
              setState(() {
                widget.registrationData.hasTuberculosis = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
