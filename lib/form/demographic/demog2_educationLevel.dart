import 'package:flutter/material.dart';
import 'package:projecho/main/registration_data.dart';

class demog2EducationLevel extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const demog2EducationLevel({
    super.key,
    required this.registrationData,
    required this.formKey,
  });

  @override
  State<demog2EducationLevel> createState() => _demog2EducationLevelState();
}

class _demog2EducationLevelState extends State<demog2EducationLevel> {
  final List<String> _educationLevels = [
    'No formal education',
    'Primary',
    'Secondary',
    'College',
    'Postgraduate',
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
