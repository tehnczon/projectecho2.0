import 'package:flutter/material.dart';
import 'package:projecho/main/registration_data.dart';

class demog4CivilStatus extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const demog4CivilStatus({
    super.key,
    required this.registrationData,
    required this.formKey,
  });

  @override
  State<demog4CivilStatus> createState() => _demog4CivilStatusState();
}

class _demog4CivilStatusState extends State<demog4CivilStatus> {
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
            'Step 4 – Education & Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }
}
