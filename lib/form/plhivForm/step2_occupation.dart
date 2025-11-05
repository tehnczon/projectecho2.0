import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main/registration_data.dart';
import '../../main/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class Step2OccupationForm extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const Step2OccupationForm({
    Key? key,
    required this.registrationData,
    required this.formKey,
  }) : super(key: key);

  @override
  State<Step2OccupationForm> createState() => _Step2OccupationFormState();
}

class _Step2OccupationFormState extends State<Step2OccupationForm> {
  final TextEditingController _currentOccupationController =
      TextEditingController();
  final TextEditingController _previousOccupationController =
      TextEditingController();
  final TextEditingController _returnYearController = TextEditingController();
  final TextEditingController _countryWorkedController =
      TextEditingController();

  bool? _currentlyInSchool;
  String? _schoolLevel;
  bool? _workedOverseas;
  String? _basedLocation;

  final List<String> _schoolLevels = [
    'High school',
    'Vocational',
    'College',
    'Post-graduate',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    _currentlyInSchool = widget.registrationData.isStudying;
    _workedOverseas = widget.registrationData.isOFW;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('OCCUPATION'),
            const SizedBox(height: 20),

            // 12. Current Occupation
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
                  Text(
                    '8. Current Occupation (please specify main source of income):',
                    style: _labelStyle(),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _currentOccupationController,
                    style: GoogleFonts.poppins(fontSize: 12),
                    decoration: _inputDecoration(
                      'e.g., Teacher, Engineer, Self-employed',
                    ).copyWith(hintStyle: const TextStyle(fontSize: 10)),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'If no current work, please specify previous occupation:',
                    style: GoogleFonts.poppins(fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _previousOccupationController,
                    style: GoogleFonts.poppins(fontSize: 12),
                    decoration: _inputDecoration(
                      'Previous occupation',
                    ).copyWith(hintStyle: const TextStyle(fontSize: 10)),
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 13. Currently in School
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
                  Text('9. Currently in school? ', style: _labelStyle()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text(
                            'No',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          value: false,
                          groupValue: _currentlyInSchool,
                          onChanged: (value) {
                            setState(() {
                              _currentlyInSchool = value;
                              if (value == false) _schoolLevel = null;
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text(
                            'Yes',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          value: true,
                          groupValue: _currentlyInSchool,
                          onChanged:
                              (value) =>
                                  setState(() => _currentlyInSchool = value),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  // School Level (if yes)
                  if (_currentlyInSchool == true) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Please indicate level:',
                      style: GoogleFonts.poppins(fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _schoolLevel,
                      onChanged: (String? newValue) {
                        setState(() {
                          _schoolLevel = newValue;
                        });
                      },
                      items:
                          _schoolLevels
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
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.textSecondary,
                      ),
                      decoration: InputDecoration(
                        labelText: "School level",
                        labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                        prefixIcon: Icon(
                          Icons.school_outlined,
                          color: AppColors.primary,
                        ),
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 14. Worked Overseas
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
                  Text(
                    '10. Did you work overseas/abroad in the past 5 years?',
                    style: _labelStyle(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text(
                            'No',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          value: false,
                          groupValue: _workedOverseas,
                          onChanged: (value) {
                            setState(() {
                              _workedOverseas = value;
                              if (value == false) {
                                _returnYearController.clear();
                                _basedLocation = null;
                                _countryWorkedController.clear();
                              }
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text(
                            'Yes',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          value: true,
                          groupValue: _workedOverseas,
                          onChanged:
                              (value) =>
                                  setState(() => _workedOverseas = value),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  // Overseas Work Details (if yes)
                  if (_workedOverseas == true) ...[
                    const SizedBox(height: 16),
                    Text(
                      'If yes, when did you return from your last contract?',
                      style: GoogleFonts.poppins(fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _returnYearController,
                      style: GoogleFonts.poppins(fontSize: 12),
                      decoration: _inputDecoration(
                        'Year (e.g., 2023)',
                      ).copyWith(hintStyle: const TextStyle(fontSize: 10)),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Where were you based?',
                      style: GoogleFonts.poppins(fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                              'On a ship',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            value: 'On a ship',
                            groupValue: _basedLocation,
                            onChanged:
                                (value) =>
                                    setState(() => _basedLocation = value),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                              'Land',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            value: 'Land',
                            groupValue: _basedLocation,
                            onChanged:
                                (value) =>
                                    setState(() => _basedLocation = value),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'What country did you last work in?',
                      style: GoogleFonts.poppins(fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _countryWorkedController,
                      style: GoogleFonts.poppins(fontSize: 12),
                      decoration: _inputDecoration(
                        'Country name',
                      ).copyWith(hintStyle: const TextStyle(fontSize: 10)),
                    ),
                  ],
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

  @override
  void _saveStep2Data() {
    widget.registrationData.currentOccupation =
        _currentOccupationController.text.trim();
    widget.registrationData.previousOccupation =
        _previousOccupationController.text.trim();
    widget.registrationData.isStudying = _currentlyInSchool;
    widget.registrationData.schoolLevel = _schoolLevel;
    widget.registrationData.isOFW = _workedOverseas;

    if (_returnYearController.text.isNotEmpty) {
      widget.registrationData.ofwReturnYear = int.tryParse(
        _returnYearController.text,
      );
    }

    widget.registrationData.ofwBasedLocation = _basedLocation;
    widget.registrationData.ofwLastCountry =
        _countryWorkedController.text.trim();

    print('✅ Step 2 data saved to model');
  }

  void dispose() {
    _currentOccupationController.dispose();
    _previousOccupationController.dispose();
    _returnYearController.dispose();
    _countryWorkedController.dispose();
    super.dispose();
  }
}
