import 'package:flutter/material.dart';
import '../../main/registration_data.dart';

class demog1HIVrelationForm extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const demog1HIVrelationForm({
    Key? key,
    required this.registrationData,
    required this.formKey,
  }) : super(key: key);

  @override
  State<demog1HIVrelationForm> createState() => _demog1HIVrelationFormState();
}

class _demog1HIVrelationFormState extends State<demog1HIVrelationForm> {
  final List<String> _options = ['Partner', 'Family Member', 'Friend'];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 1 - HIV Relation",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          ..._options.map((option) {
            return CheckboxListTile(
              title: Text(option),
              value: widget.registrationData.hivRelation.contains(option),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    widget.registrationData.hivRelation.add(option);
                  } else {
                    widget.registrationData.hivRelation.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
