import 'package:flutter/material.dart';
import '../../main/registration_data.dart';
import '../../main/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class Step4MedicalHistoryForm extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const Step4MedicalHistoryForm({
    Key? key,
    required this.registrationData,
    required this.formKey,
  }) : super(key: key);

  @override
  State<Step4MedicalHistoryForm> createState() =>
      _Step4MedicalHistoryFormState();
}

class _Step4MedicalHistoryFormState extends State<Step4MedicalHistoryForm> {
  bool _currentTBPatient = false;
  bool _currentlyPregnant = false;
  bool _withHepatitisB = false;
  bool _withHepatitisC = false;
  bool _cbsReactive = false;
  bool _takingPreP = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    _currentTBPatient = widget.registrationData.hasTuberculosis ?? false;
    _currentlyPregnant = widget.registrationData.isPregnant ?? false;
    _withHepatitisB = widget.registrationData.hasHepatitis ?? false;
  }

  void _saveStep4Data() {
    widget.registrationData.hasTuberculosis = _currentTBPatient;
    widget.registrationData.hasHepatitisB = _withHepatitisB;
    widget.registrationData.hasHepatitisC = _withHepatitisC;
    widget.registrationData.cbsReactive = _cbsReactive;
    widget.registrationData.takingPreP = _takingPreP;
    widget.registrationData.isPregnant = _currentlyPregnant;

    print('✅ Step 4 data saved to model');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('MEDICAL HISTORY'),
            const SizedBox(height: 20),

            // Medical conditions
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
                    '19. Please check all that apply. (optional)',
                    style: _labelStyle(),
                  ),
                  const SizedBox(height: 16),

                  // Row 1
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            'Current TB patient',
                            style: GoogleFonts.poppins(fontSize: 10),
                          ),
                          value: _currentTBPatient,
                          onChanged: (value) {
                            setState(() {
                              _currentTBPatient = value ?? false;
                              _saveStep4Data();
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            'With hepatitis B',
                            style: GoogleFonts.poppins(fontSize: 10),
                          ),
                          value: _withHepatitisB,
                          onChanged: (value) {
                            setState(() {
                              _withHepatitisB = value ?? false;
                              _saveStep4Data();
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            'CBS reactive',
                            style: GoogleFonts.poppins(fontSize: 10),
                          ),
                          value: _cbsReactive,
                          onChanged: (value) {
                            setState(() {
                              _cbsReactive = value ?? false;
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            'Currently pregnant',
                            style: GoogleFonts.poppins(fontSize: 10),
                          ),
                          value: _currentlyPregnant,
                          onChanged: (value) {
                            setState(() {
                              _currentlyPregnant = value ?? false;
                              _saveStep4Data();
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            'With hepatitis C',
                            style: GoogleFonts.poppins(fontSize: 10),
                          ),
                          value: _withHepatitisC,
                          onChanged: (value) {
                            setState(() {
                              _withHepatitisC = value ?? false;
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            'Taking PrEP',
                            style: GoogleFonts.poppins(fontSize: 10),
                          ),
                          value: _takingPreP,
                          onChanged: (value) {
                            setState(() {
                              _takingPreP = value ?? false;
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ],
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
}
