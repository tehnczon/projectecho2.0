import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main/registration_data.dart';
import '../../main/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class Step5PreviousHIVTestForm extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const Step5PreviousHIVTestForm({
    Key? key,
    required this.registrationData,
    required this.formKey,
  }) : super(key: key);

  @override
  State<Step5PreviousHIVTestForm> createState() =>
      _Step5PreviousHIVTestFormState();
}

class _Step5PreviousHIVTestFormState extends State<Step5PreviousHIVTestForm> {
  final TextEditingController _testMonthController = TextEditingController();
  final TextEditingController _testYearController = TextEditingController();
  final TextEditingController _testFacilityController = TextEditingController();
  final TextEditingController _testCityController = TextEditingController();

  bool? _everTestedForHIV;
  String? _testResult;

  final List<String> _testResults = [
    'Positive',
    'Negative',
    'Indeterminate',
    'Was not able to get result',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    // Load any existing data from registrationData if available
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('PREVIOUS HIV TEST'),
            const SizedBox(height: 20),

            // Question 21: Ever tested for HIV
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
                    '21. Have you ever been tested for HIV before? (optional)',
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
                          groupValue: _everTestedForHIV,
                          onChanged: (value) {
                            setState(() {
                              _everTestedForHIV = value;
                              if (value == false) {
                                _testMonthController.clear();
                                _testYearController.clear();
                                _testFacilityController.clear();
                                _testCityController.clear();
                                _testResult = null;
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
                          groupValue: _everTestedForHIV,
                          onChanged:
                              (value) =>
                                  setState(() => _everTestedForHIV = value),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Show additional fields only if tested before
            if (_everTestedForHIV == true)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'If yes, when was the most recent test?',
                      style: GoogleFonts.poppins(fontSize: 10),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Month',
                                style: GoogleFonts.poppins(fontSize: 10),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _testMonthController,
                                style: GoogleFonts.poppins(fontSize: 12),
                                decoration: _inputDecoration(
                                  'MM (1-12)',
                                ).copyWith(
                                  hintStyle: const TextStyle(fontSize: 10),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                  _MonthInputFormatter(),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Year',
                                style: GoogleFonts.poppins(fontSize: 10),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _testYearController,
                                style: GoogleFonts.poppins(fontSize: 12),
                                decoration: _inputDecoration('YYYY').copyWith(
                                  hintStyle: const TextStyle(fontSize: 10),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Which testing facility did you have the test?',
                      style: GoogleFonts.poppins(fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _testFacilityController,
                      style: GoogleFonts.poppins(fontSize: 12),
                      decoration: _inputDecoration(
                        'Facility name',
                      ).copyWith(hintStyle: const TextStyle(fontSize: 10)),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'City/Municipality:',
                      style: GoogleFonts.poppins(fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _testCityController,
                      style: GoogleFonts.poppins(fontSize: 12),
                      decoration: _inputDecoration(
                        'City/Municipality',
                      ).copyWith(hintStyle: const TextStyle(fontSize: 10)),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'What was the result?',
                      style: GoogleFonts.poppins(fontSize: 10),
                    ),
                    const SizedBox(height: 8),

                    ...(_testResults.map((result) {
                      return RadioListTile<String>(
                        title: Text(
                          result,
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        value: result,
                        groupValue: _testResult,
                        onChanged:
                            (value) => setState(() => _testResult = value),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                      );
                    }).toList()),
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
        color: Colors.grey[800],
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
  void _saveStep5Data() {
    widget.registrationData.everTestedForHIV = _everTestedForHIV;

    if (_testMonthController.text.isNotEmpty) {
      widget.registrationData.lastTestMonth = int.tryParse(
        _testMonthController.text,
      );
    }

    if (_testYearController.text.isNotEmpty) {
      widget.registrationData.lastTestYear = int.tryParse(
        _testYearController.text,
      );
    }

    widget.registrationData.testFacility = _testFacilityController.text.trim();
    widget.registrationData.testCity = _testCityController.text.trim();
    widget.registrationData.testResult = _testResult;

    print('✅ Step 5 data saved to model');
  }

  void dispose() {
    _testMonthController.dispose();
    _testYearController.dispose();
    _testFacilityController.dispose();
    _testCityController.dispose();
    super.dispose();
  }
}

// Custom formatter for month input
class _MonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int? value = int.tryParse(newValue.text);
    if (value != null && value > 12) {
      return oldValue;
    }
    return newValue;
  }
}
