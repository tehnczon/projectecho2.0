import 'package:flutter/material.dart';
import '../models/registration_data.dart';

class Step1AgeIdentityForm extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const Step1AgeIdentityForm({
    Key? key,
    required this.registrationData,
    required this.formKey,
  }) : super(key: key);

  @override
  State<Step1AgeIdentityForm> createState() => _Step1AgeIdentityFormState();
}

class _Step1AgeIdentityFormState extends State<Step1AgeIdentityForm> {
  final List<String> genderOptions = [
    'Male',
    'Female',
    'Transgender',
    'Non-binary',
    'Prefer not to say',
  ];

  final List<String> sexAssignedOptions = [
    'Male',
    'Female',
    'Intersex',
    'Prefer not to say',
  ];

  final List<String> nationalityOptions = [
    'Filipino',
    'Foreigner',
    'Prefer not to say',
  ];

  String? selectedSex;
  String? selectedGender;
  String? selectedNationality;

  @override
  void initState() {
    super.initState();

    // Compute ageRange if birthDate is present
    if (widget.registrationData.birthDate != null) {
      final age = _calculateAge(widget.registrationData.birthDate!);
      final range = _getAgeRange(age);
      widget.registrationData.ageRange = range;
    }

    selectedSex = widget.registrationData.sexAssignedAtBirth;
    selectedGender = widget.registrationData.genderIdentity;
    selectedNationality = widget.registrationData.nationality;
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _getAgeRange(int age) {
    if (age < 18) return 'Under 18';
    if (age <= 24) return '18-24';
    if (age <= 34) return '25-34';
    if (age <= 44) return '35-44';
    return '45+';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            "Step 1 - Self Identity",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),
          const Text("Sex assigned at birth:"),
          DropdownButtonFormField<String>(
            value: selectedSex,
            items:
                sexAssignedOptions
                    .map(
                      (sex) => DropdownMenuItem(value: sex, child: Text(sex)),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                selectedSex = value;
                widget.registrationData.sexAssignedAtBirth = value;
              });
            },
            validator:
                (value) =>
                    value == null
                        ? 'Please select sex assigned at birth'
                        : null,
          ),

          const SizedBox(height: 20),
          const Text("Gender identity:"),
          DropdownButtonFormField<String>(
            value: selectedGender,
            items:
                genderOptions
                    .map(
                      (gender) =>
                          DropdownMenuItem(value: gender, child: Text(gender)),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                selectedGender = value;
                widget.registrationData.genderIdentity = value;
              });
            },
            validator:
                (value) =>
                    value == null ? 'Please select gender identity' : null,
          ),

          const SizedBox(height: 20),
          const Text("Nationality:"),
          DropdownButtonFormField<String>(
            value: selectedNationality,
            items:
                nationalityOptions
                    .map(
                      (nat) => DropdownMenuItem(value: nat, child: Text(nat)),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                selectedNationality = value;
                widget.registrationData.nationality = value;
              });
            },
            validator:
                (value) => value == null ? 'Please select nationality' : null,
          ),

          const SizedBox(height: 20),
          if (widget.registrationData.ageRange != null)
            Text(
              "Age range automatically computed: ${widget.registrationData.ageRange!}",
              style: const TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
