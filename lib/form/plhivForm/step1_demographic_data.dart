import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main/registration_data.dart';
import '../../main/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class Step1DemographicForm extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const Step1DemographicForm({
    Key? key,
    required this.registrationData,
    required this.formKey,
  }) : super(key: key);

  @override
  State<Step1DemographicForm> createState() => _Step1DemographicFormState();
}

class _Step1DemographicFormState extends State<Step1DemographicForm> {
  final TextEditingController _birthOrderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _ageMonthsController = TextEditingController();
  final TextEditingController _currentCityController = TextEditingController();
  final TextEditingController _currentProvinceController =
      TextEditingController();
  final TextEditingController _permanentCityController =
      TextEditingController();
  final TextEditingController _permanentProvinceController =
      TextEditingController();
  final TextEditingController _birthCityController = TextEditingController();
  final TextEditingController _birthProvinceController =
      TextEditingController();
  final TextEditingController _numberOfChildrenController =
      TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _otherNationalityController =
      TextEditingController();

  String? _sexAtBirth;
  String? _selfIdentity;
  String? _nationality;
  String? _educationLevel;
  String? _civilStatus;
  bool? _livingWithPartner;
  bool? _isPregnant;

  final List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to share',
  ];

  final List<String> _educationLevels = [
    'None',
    'Elementary',
    'Highschool',
    'College',
    'Vocational',
    'Post-Graduate',
    'Prefer not to share',
  ];

  final List<String> _civilStatuses = [
    'Single',
    'Married',
    'Separated',
    'Widowed',
    'Prefer not to share',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.registrationData.birthDate != null) {
      final age = _calculateAge(widget.registrationData.birthDate!);
      _ageController.text = age.toString();
    }

    _sexAtBirth = widget.registrationData.sexAssignedAtBirth;
    _selfIdentity = widget.registrationData.genderIdentity;
    _nationality = widget.registrationData.nationality;
    _educationLevel = widget.registrationData.educationLevel;
    _civilStatus = widget.registrationData.civilStatus;
    _livingWithPartner = widget.registrationData.livingWithPartner;
    _isPregnant = widget.registrationData.isPregnant;
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('DEMOGRAPHIC DATA'),
            const SizedBox(height: 20),

            // Parent info & birth order
            const SizedBox(height: 20),

            // 4. Birth Date & Age
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Section title
                  Text(
                    '1. Birth date and Age',
                    style: _labelStyle().copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  // 🔹 Birthdate and Age fields
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).unfocus(); // hide keyboard

                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                _birthDateController.text =
                                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: _textField(
                              _birthDateController,
                              'Birthdate',
                              readOnly: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _textField(
                          _ageController,
                          'Age',
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 🔹 Age in months
                  Text(
                    'Age in months (for less than 1 year old)',
                    style: GoogleFonts.poppins(fontSize: 10),
                  ),
                  const SizedBox(height: 4),

                  TextFormField(
                    controller: _ageMonthsController, // ✅ keep consistent
                    style: GoogleFonts.poppins(fontSize: 12),
                    decoration: _inputDecoration(
                      '00',
                    ).copyWith(hintStyle: const TextStyle(fontSize: 12)),
                    maxLength: 2,
                    buildCounter:
                        (
                          context, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null, // ✅ hide 0/2 counter
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly, // ✅ simpler & exact
                    ],
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Sex at birth
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _radioGroup(
                    '2. Sex (at birth)',
                    ['Male', 'Female'],
                    _sexAtBirth,
                    (val) => setState(() => _sexAtBirth = val),
                  ),

                  DropdownButtonFormField<String>(
                    value: _selfIdentity,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selfIdentity = newValue;
                      });
                    },
                    items:
                        genderOptions
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(
                                  gender,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    dropdownColor: AppColors.surface,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textSecondary,
                    ),
                    decoration: InputDecoration(
                      labelText: "Self-identity",
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                      prefixIcon: Icon(Icons.wc, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Residence
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('3. Current Place of Residence ', style: _labelStyle()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _textField(
                          _currentCityController,
                          'City/Municipality',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textField(
                          _currentProvinceController,
                          'Province',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text('Permanent Residence:', style: _labelStyle()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _textField(
                          _permanentCityController,
                          'City/Municipality',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textField(
                          _permanentProvinceController,
                          'Province',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text('Place of Birth:', style: _labelStyle()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _textField(
                          _birthCityController,
                          'City/Municipality',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textField(_birthProvinceController, 'Province'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Nationality
            // 7. Nationality
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _radioGroup(
                    '4. Nationality ',
                    ['Filipino', 'Other'],
                    _nationality,
                    (val) => setState(() => _nationality = val),
                  ),
                  if (_nationality == 'Other') ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _otherNationalityController,
                      decoration: _inputDecoration('Please specify'),
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _educationLevel,
              onChanged: (String? newValue) {
                setState(() {
                  _educationLevel = newValue;
                });
              },
              items:
                  _educationLevels
                      .map(
                        (level) => DropdownMenuItem(
                          value: level,
                          child: Text(
                            level,

                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              dropdownColor: AppColors.surface,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              decoration: InputDecoration(
                labelText: "5. Highest Educational Attainment",
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,

                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
                prefixIcon: Icon(Icons.school, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 9. Civil Status
            DropdownButtonFormField<String>(
              value: _civilStatus,
              onChanged: (String? newValue) {
                setState(() {
                  _civilStatus = newValue;
                });
              },
              items:
                  _civilStatuses
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                            status,
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              dropdownColor: AppColors.surface,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              decoration: InputDecoration(
                labelText: "6. Civil Status",
                labelStyle: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                prefixIcon: Icon(Icons.people, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 10. Living with Partner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: _radioGroupBool(
                '7. Are you currently living with a partner? ',
                _livingWithPartner,
                (val) => setState(() => _livingWithPartner = val),
              ),
            ),

            const SizedBox(height: 20),

            // 11. Pregnancy (female only)
            if (_sexAtBirth?.toLowerCase() == 'female')
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _radioGroupBool(
                      '8. Are you currently pregnant? (if female only) ',
                      _isPregnant,
                      (val) => setState(() => _isPregnant = val),
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      _numberOfChildrenController,
                      'Number of children',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle() => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
  );

  Widget _textField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    bool readOnly = false,
    Function(String)? onChanged,
    double fontSize = 12,
  }) => TextFormField(
    controller: controller,
    decoration: _inputDecoration(
      hint,
    ).copyWith(hintStyle: const TextStyle(fontSize: 12)),
    keyboardType: keyboardType,
    readOnly: readOnly,

    style: TextStyle(fontSize: fontSize),
    inputFormatters:
        keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
    onChanged: onChanged,
  );

  Widget _initialsField(TextEditingController controller, String label) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'First 2 letters of $label\'s real name',
            style: GoogleFonts.poppins(fontSize: 10),
          ),
          const SizedBox(height: 4),
          TextFormField(
            style: GoogleFonts.poppins(fontSize: 12),
            controller: controller,
            decoration: _inputDecoration(
              'XX',
            ).copyWith(hintStyle: const TextStyle(fontSize: 12)),

            maxLength: 2,

            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => null,

            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
              UpperCaseTextFormatter(),
            ],
          ),
        ],
      );

  Widget _radioGroup(
    String label,
    List<String> options,
    String? groupValue,
    Function(String) onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: _labelStyle()),
      const SizedBox(height: 8),
      Row(
        children:
            options
                .map(
                  (opt) => Expanded(
                    child: RadioListTile<String>(
                      title: Text(opt),
                      value: opt,
                      groupValue: groupValue,
                      onChanged: (val) => onChanged(val!),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                    ),
                  ),
                )
                .toList(),
      ),
    ],
  );

  Widget _radioGroupBool(
    String label,
    bool? groupValue,
    Function(bool) onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: _labelStyle()),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: RadioListTile<bool>(
              title: Text('No'),
              value: false,
              groupValue: groupValue,
              onChanged: (val) => onChanged(val!),
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),
          ),
          Expanded(
            child: RadioListTile<bool>(
              title: Text('Yes'),
              value: true,
              groupValue: groupValue,
              onChanged: (val) => onChanged(val!),
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _dropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: _labelStyle()),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: value,
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
        decoration: _inputDecoration(' $label'),
        dropdownColor: Colors.white,
        style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
      ),
    ],
  );

  Widget _buildChip(String label, bool selected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: GoogleFonts.poppins(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  @override
  void _saveStep1Data() {
    // PII Data (will be hashed when saved to Firestore)

    // Parse birthdate
    if (_birthDateController.text.isNotEmpty) {
      try {
        widget.registrationData.birthDate = DateTime.parse(
          _birthDateController.text,
        );
      } catch (e) {
        print('Error parsing birthdate: $e');
      }
    }

    // Location data (PII)
    widget.registrationData.currentCity = _currentCityController.text.trim();
    widget.registrationData.currentProvince =
        _currentProvinceController.text.trim();
    widget.registrationData.permanentCity =
        _permanentCityController.text.trim();
    widget.registrationData.permanentProvince =
        _permanentProvinceController.text.trim();
    widget.registrationData.birthCity = _birthCityController.text.trim();
    widget.registrationData.birthProvince =
        _birthProvinceController.text.trim();

    // Non-PII Data (safe to store as-is)
    widget.registrationData.sexAssignedAtBirth = _sexAtBirth;
    widget.registrationData.genderIdentity = _selfIdentity;
    widget.registrationData.nationality = _nationality;
    widget.registrationData.otherNationality =
        _otherNationalityController.text.trim();
    widget.registrationData.educationLevel = _educationLevel;
    widget.registrationData.civilStatus = _civilStatus;
    widget.registrationData.livingWithPartner = _livingWithPartner;
    widget.registrationData.isPregnant = _isPregnant;

    if (_numberOfChildrenController.text.isNotEmpty) {
      widget.registrationData.numberOfChildren = int.tryParse(
        _numberOfChildrenController.text,
      );
    }

    // Compute age range from birthdate
    widget.registrationData.computeAgeRange();

    // Set city/barangay for analytics (use current location primarily)
    widget.registrationData.city =
        widget.registrationData.currentCity ??
        widget.registrationData.permanentCity;

    print('✅ Step 1 data saved to model');
  }

  // Call this method before moving to next step
  // Update your widget's dispose or when moving forward:

  @override
  void dispose() {
    _saveStep1Data(); // Save data before disposing

    _birthOrderController.dispose();
    _ageController.dispose();
    _ageMonthsController.dispose();
    _currentCityController.dispose();
    _currentProvinceController.dispose();
    _permanentCityController.dispose();
    _permanentProvinceController.dispose();
    _birthCityController.dispose();
    _birthProvinceController.dispose();
    _numberOfChildrenController.dispose();
    super.dispose();
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => TextEditingValue(
    text: newValue.text.toUpperCase(),
    selection: newValue.selection,
  );
}
