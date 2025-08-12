import 'package:flutter/material.dart';
import '../map/models/registration_data.dart';

class Step5WorkStatusForm extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const Step5WorkStatusForm({
    Key? key,
    required this.registrationData,
    required this.formKey,
  }) : super(key: key);

  @override
  State<Step5WorkStatusForm> createState() => _Step5WorkStatusFormState();
}

class _Step5WorkStatusFormState extends State<Step5WorkStatusForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 5 - Work Status",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "Are you an OFW (Overseas Filipino Worker)?",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          RadioListTile<bool>(
            title: const Text("Yes"),
            value: true,
            groupValue: widget.registrationData.isOFW,
            onChanged: (value) {
              setState(() {
                widget.registrationData.isOFW = value;
              });
            },
          ),
          RadioListTile<bool>(
            title: const Text("No"),
            value: false,
            groupValue: widget.registrationData.isOFW,
            onChanged: (value) {
              setState(() {
                widget.registrationData.isOFW = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
