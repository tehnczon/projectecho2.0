import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../main/registration_data.dart';
import '../../../main/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class Step3HistoryOfExposureForm extends StatefulWidget {
  final RegistrationData registrationData;
  final GlobalKey<FormState> formKey;

  const Step3HistoryOfExposureForm({
    Key? key,
    required this.registrationData,
    required this.formKey,
  }) : super(key: key);

  @override
  State<Step3HistoryOfExposureForm> createState() =>
      _Step3HistoryOfExposureFormState();
}

class _Step3HistoryOfExposureFormState
    extends State<Step3HistoryOfExposureForm> {
  final TextEditingController _ageFirstSexController = TextEditingController();
  final TextEditingController _ageFirstDrugController = TextEditingController();
  final TextEditingController _femalePartnersController =
      TextEditingController();
  final TextEditingController _malePartnersController = TextEditingController();
  final TextEditingController _yearLastSexFemaleController =
      TextEditingController();
  final TextEditingController _yearLastSexMaleController =
      TextEditingController();

  bool? _motherHadHIV;
  bool _ageFirstSexNA = false;
  bool _ageFirstDrugNA = false;

  // Exposure history items
  final Map<String, String?> _exposureHistory = {
    'sexFemaleNoCondom': null,
    'sexMaleNoCondom': null,
    'sexWithHIVPerson': null,
    'payingForSex': null,
    'acceptingPayment': null,
    'injectedDrugs': null,
    'bloodTransfusion': null,
    'occupationalExposure': null,
    'gotTattoo': null,
    'sti': null,
  };

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    _motherHadHIV = widget.registrationData.motherHadHIV;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('HISTORY OF EXPOSURE'),
            const SizedBox(height: 20),

            // Question 15: Mother had HIV
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
                    '11. Did your birth mother have HIV when you were born?',
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
                          groupValue: _motherHadHIV,
                          onChanged:
                              (value) => setState(() => _motherHadHIV = value),
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
                          groupValue: _motherHadHIV,
                          onChanged:
                              (value) => setState(() => _motherHadHIV = value),
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

            // Question 16: Exposure History Table
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
                    '12. Have you ever experienced any of the following? Please check the appropriate column for each item.',
                    style: _labelStyle(),
                  ),
                  const SizedBox(height: 16),

                  // Table Header
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text('', style: _tableHeaderStyle()),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text('No', style: _tableHeaderStyle()),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            'Yes,\nwithin 12\nmonths',
                            style: _tableHeaderStyle(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            'Yes,\nmore than\n12 months',
                            style: _tableHeaderStyle(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(thickness: 2),

                  // Exposure items
                  _buildExposureRow(
                    'Sex with a female with no condom',
                    'sexFemaleNoCondom',
                  ),
                  _buildExposureRow(
                    'Sex with a male with no condom',
                    'sexMaleNoCondom',
                  ),
                  _buildExposureRow(
                    'Sex with someone whom you know has HIV',
                    'sexWithHIVPerson',
                  ),
                  _buildExposureRow('Paying for sex', 'payingForSex'),
                  _buildExposureRow(
                    'Regularly accepting payment for sex',
                    'acceptingPayment',
                  ),
                  _buildExposureRow(
                    'Injected drugs without doctor\'s advice',
                    'injectedDrugs',
                  ),
                  _buildExposureRow(
                    'Received blood transfusion',
                    'bloodTransfusion',
                  ),
                  _buildExposureRow(
                    'Occupational exposure (needlestick/sharps)',
                    'occupationalExposure',
                  ),
                  _buildExposureRow('Gotten a tattoo', 'gotTattoo'),
                  _buildExposureRow(
                    'Sexually transmitted infection (STI / STD)',
                    'sti',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Question 17: Age at first sex and drug use
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
                  Text('13. Age milestones:', style: _labelStyle()),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Age at first sex:',
                              style: GoogleFonts.poppins(fontSize: 9),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _ageFirstSexController,
                              style: GoogleFonts.poppins(fontSize: 12),
                              decoration: _inputDecoration('Age').copyWith(
                                hintStyle: const TextStyle(fontSize: 10),
                              ),
                              keyboardType: TextInputType.number,
                              enabled: !_ageFirstSexNA,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            CheckboxListTile(
                              title: Text(
                                'Not applicable',
                                style: GoogleFonts.poppins(fontSize: 10),
                              ),
                              value: _ageFirstSexNA,
                              onChanged: (value) {
                                setState(() {
                                  _ageFirstSexNA = value ?? false;
                                  if (_ageFirstSexNA)
                                    _ageFirstSexController.clear();
                                });
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Age at first injecting drug use:',
                              style: GoogleFonts.poppins(fontSize: 9),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _ageFirstDrugController,
                              style: GoogleFonts.poppins(fontSize: 12),
                              decoration: _inputDecoration('Age').copyWith(
                                hintStyle: const TextStyle(fontSize: 10),
                              ),
                              keyboardType: TextInputType.number,
                              enabled: !_ageFirstDrugNA,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            CheckboxListTile(
                              title: Text(
                                'Not applicable',
                                style: GoogleFonts.poppins(fontSize: 10),
                              ),
                              value: _ageFirstDrugNA,
                              onChanged: (value) {
                                setState(() {
                                  _ageFirstDrugNA = value ?? false;
                                  if (_ageFirstDrugNA)
                                    _ageFirstDrugController.clear();
                                });
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Question 18: Sexual partners
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
                    '14. If you have ever had sex, please answer this section. If the answer is none, write "0" in the box.',
                    style: _labelStyle(),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'How many FEMALE sex partners have you ever had?',
                    style: GoogleFonts.poppins(fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _femalePartnersController,
                          style: GoogleFonts.poppins(fontSize: 12),
                          decoration: _inputDecoration(
                            'Number (or 0)',
                          ).copyWith(hintStyle: const TextStyle(fontSize: 10)),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _yearLastSexFemaleController,
                              style: GoogleFonts.poppins(fontSize: 12),
                              decoration: _inputDecoration(
                                'Year of last sex with a female:',
                              ).copyWith(
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
                    'How many MALE sex partners have you ever had?',
                    style: GoogleFonts.poppins(fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _malePartnersController,
                          style: GoogleFonts.poppins(fontSize: 12),
                          decoration: _inputDecoration(
                            'Number (or 0)',
                          ).copyWith(hintStyle: const TextStyle(fontSize: 10)),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _yearLastSexMaleController,
                              style: GoogleFonts.poppins(fontSize: 12),
                              decoration: _inputDecoration(
                                'Year of last sex with a male:',
                              ).copyWith(
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
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExposureRow(String label, String key) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(label, style: GoogleFonts.poppins(fontSize: 10)),
              ),
              Expanded(
                flex: 2,
                child: Radio<String>(
                  value: 'no',
                  groupValue: _exposureHistory[key],
                  onChanged:
                      (value) => setState(() => _exposureHistory[key] = value),
                  activeColor: AppColors.primary,
                ),
              ),
              Expanded(
                flex: 2,
                child: Radio<String>(
                  value: 'within12',
                  groupValue: _exposureHistory[key],
                  onChanged:
                      (value) => setState(() => _exposureHistory[key] = value),
                  activeColor: AppColors.primary,
                ),
              ),
              Expanded(
                flex: 2,
                child: Radio<String>(
                  value: 'moreThan12',
                  groupValue: _exposureHistory[key],
                  onChanged:
                      (value) => setState(() => _exposureHistory[key] = value),
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),
      ],
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

  TextStyle _tableHeaderStyle() => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.bold,
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
  void _saveStep3Data() {
    widget.registrationData.motherHadHIV = _motherHadHIV;

    if (_ageFirstSexController.text.isNotEmpty && !_ageFirstSexNA) {
      widget.registrationData.ageAtFirstSex = int.tryParse(
        _ageFirstSexController.text,
      );
    }

    if (_ageFirstDrugController.text.isNotEmpty && !_ageFirstDrugNA) {
      widget.registrationData.ageAtFirstDrugUse = int.tryParse(
        _ageFirstDrugController.text,
      );
    }

    if (_femalePartnersController.text.isNotEmpty) {
      widget.registrationData.femalePartnerCount = int.tryParse(
        _femalePartnersController.text,
      );
    }

    if (_malePartnersController.text.isNotEmpty) {
      widget.registrationData.malePartnerCount = int.tryParse(
        _malePartnersController.text,
      );
    }

    if (_yearLastSexFemaleController.text.isNotEmpty) {
      widget.registrationData.yearLastSexFemale = int.tryParse(
        _yearLastSexFemaleController.text,
      );
    }

    if (_yearLastSexMaleController.text.isNotEmpty) {
      widget.registrationData.yearLastSexMale = int.tryParse(
        _yearLastSexMaleController.text,
      );
    }

    // Save exposure history map
    widget.registrationData.exposureHistory = Map.from(_exposureHistory);

    // Compute unprotected sex classification
    widget.registrationData.computeUnprotectedSexWith();

    // Check for STI from exposure history
    if (widget.registrationData.exposureHistory['sti'] == 'within12' ||
        widget.registrationData.exposureHistory['sti'] == 'moreThan12') {
      widget.registrationData.diagnosedSTI = true;
    }

    print('✅ Step 3 data saved to model');
  }

  void dispose() {
    _ageFirstSexController.dispose();
    _ageFirstDrugController.dispose();
    _femalePartnersController.dispose();
    _malePartnersController.dispose();
    _yearLastSexFemaleController.dispose();
    _yearLastSexMaleController.dispose();
    super.dispose();
  }
}
