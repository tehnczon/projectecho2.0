import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecho/login/signup/wlcmPrjecho.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:projecho/models/registration_data.dart';
import 'package:projecho/plhiv_form/step1_age_identity.dart';
import 'package:projecho/plhiv_form/step2_education_status.dart';
import 'package:projecho/plhiv_form/step3_health_pregnancy.dart';
import 'package:projecho/plhiv_form/step4_sexual_practices.dart';
import 'package:projecho/plhiv_form/step5_work_status.dart';
import 'package:projecho/plhiv_form/step6_confirmation.dart';

class PLHIVStepperScreen extends StatefulWidget {
  final RegistrationData registrationData;

  const PLHIVStepperScreen({super.key, required this.registrationData});

  @override
  State<PLHIVStepperScreen> createState() => _PLHIVStepperScreenState();
}

class _PLHIVStepperScreenState extends State<PLHIVStepperScreen> {
  int _currentStep = 0;
  final _formKeys = List.generate(6, (index) => GlobalKey<FormState>());
  final List<String> stepTitles = [
    "Age & Identity",
    "Education & Status",
    "Health & Pregnancy",
    "Sexual Practices",
    "Work Status",
    "Confirmation",
  ];

  List<Widget> get _steps => [
    _buildStep1(),
    _buildStep2(),
    _buildStep3(),
    _buildStep4(),
    _buildStep5(),
    _buildStep6(),
  ];

  void _nextStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < _steps.length - 1) {
        setState(() => _currentStep++);
      } else {
        _submitForm(); // ✅ submit when it's the last step
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Widget _buildTimeline() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stepTitles.length,
        itemBuilder: (context, index) {
          return TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.center,
            isFirst: index == 0,
            isLast: index == stepTitles.length - 1,
            indicatorStyle: IndicatorStyle(
              width: 20,
              color: index == _currentStep ? Colors.red : Colors.grey,
            ),
            beforeLineStyle: LineStyle(
              color: index <= _currentStep ? Colors.red : Colors.grey,
              thickness: 3,
            ),
            endChild: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                stepTitles[index],
                style: TextStyle(
                  fontWeight:
                      index == _currentStep
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep1() {
    return Step1AgeIdentityForm(
      registrationData: widget.registrationData,
      formKey: _formKeys[0],
    );
  }

  Widget _buildStep2() {
    return Step2EducationStatusForm(
      registrationData: widget.registrationData,
      formKey: _formKeys[1],
    );
  }

  Widget _buildStep3() {
    return Step3HealthPregnancyForm(
      registrationData: widget.registrationData,
      formKey: _formKeys[2],
    );
  }

  Widget _buildStep4() {
    return Step4SexualPracticesForm(
      registrationData: widget.registrationData,
      formKey: _formKeys[3],
    );
  }

  Widget _buildStep5() {
    return Step5WorkStatusForm(
      registrationData: widget.registrationData,
      formKey: _formKeys[4],
    );
  }

  Widget _buildStep6() {
    return Step6FinalConfirmation(
      registrationData: widget.registrationData,
      formKey: _formKeys[5],
    );
  }

  void _submitForm() async {
    try {
      // 1. Optional: Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // 2. Convert RegistrationData to Map
      final Map<String, dynamic> data =
          widget.registrationData.toJson(); // assumes toJson() exists

      // 3. Save to Firestore
      await FirebaseFirestore.instance
          .collection('plhiv_profiles')
          .doc(widget.registrationData.phoneNumber) // or use uid
          .set(data);

      // 4. Dismiss loading
      Navigator.pop(context);

      // 5. Navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
      );
      // 6. Optional: Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profiling completed successfully!")),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PLHIV Profiling Form")),
      body: Column(
        children: [
          _buildTimeline(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _steps[_currentStep],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: _previousStep,
                    child: const Text("Back"),
                  ),
                ElevatedButton(
                  onPressed: _nextStep,
                  child: Text(
                    _currentStep == _steps.length - 1 ? "Submit" : "Next",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
