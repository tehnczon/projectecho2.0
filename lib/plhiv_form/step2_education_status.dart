import 'package:flutter/material.dart';
import 'package:projecho/models/registration_data.dart';

class Step2EducationStatusForm extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const Step2EducationStatusForm({
    super.key,
    required this.registrationData,
    required this.formKey,
  });

  @override
  State<Step2EducationStatusForm> createState() =>
      _Step2EducationStatusFormState();
}

class _Step2EducationStatusFormState extends State<Step2EducationStatusForm> {
  final List<String> _educationLevels = [
    'No formal education',
    'Primary',
    'Secondary',
    'College',
    'Postgraduate',
  ];

  final List<String> _civilStatuses = [
    'Single',
    'Married',
    'Separated',
    'Widowed',
    'Domestic Partner',
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Step 2 – Education & Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Highest Educational Attainment',
            ),
            value: widget.registrationData.educationLevel,
            items:
                _educationLevels
                    .map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() => widget.registrationData.educationLevel = value);
            },
            validator:
                (value) =>
                    value == null ? 'Please select education level' : null,
          ),

          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Current Civil Status',
            ),
            value: widget.registrationData.civilStatus,
            items:
                _civilStatuses
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() => widget.registrationData.civilStatus = value);
            },
            validator:
                (value) => value == null ? 'Please select civil status' : null,
          ),

          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text("Are you currently studying?"),
            value: widget.registrationData.isStudying ?? false,
            onChanged: (value) {
              setState(() => widget.registrationData.isStudying = value);
            },
          ),

          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text("Are you currently living with a partner?"),
            value: widget.registrationData.livingWithPartner ?? false,
            onChanged: (value) {
              setState(() => widget.registrationData.livingWithPartner = value);
            },
          ),
        ],
      ),
    );
  }
}
