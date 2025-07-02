import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:im_stepper/stepper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PLHIVProfilingForm extends StatefulWidget {
  const PLHIVProfilingForm({Key? key}) : super(key: key);

  @override
  State<PLHIVProfilingForm> createState() => _PLHIVProfilingFormState();
}

class _PLHIVProfilingFormState extends State<PLHIVProfilingForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  int currentStep = 0;

  void nextStep() {
    if (currentStep < 4) setState(() => currentStep++);
  }

  void previousStep() {
    if (currentStep > 0) setState(() => currentStep--);
  }

  Future<void> submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = _formKey.currentState!.value;
      await FirebaseFirestore.instance.collection('profiles').add(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you! Your profile has been submitted.')),
      );
    }
  }

 
  @override
Widget build(BuildContext context) {
  return Theme(
    data: ThemeData(
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        accentColor: Colors.lightBlueAccent,
        backgroundColor: Colors.white,
      ).copyWith(
        secondary: Colors.lightBlueAccent,
        primary: Colors.blue,
        surface: Colors.white,
        background: Colors.white,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.blue.shade700),
      ),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.blue.shade700),
    ),
    child: Scaffold(
      appBar: AppBar(
        title: const Text('PLHIV Profiling'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD), // light blue
              Color(0xFFFFFFFF), // white
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: IconStepper(
                icons: const [
                  Icon(Icons.person, color: Colors.blue),
                  Icon(Icons.health_and_safety, color: Colors.lightBlue),
                  Icon(Icons.mood, color: Colors.blueAccent),
                  Icon(Icons.shield, color: Colors.lightBlueAccent),
                  Icon(Icons.check_circle, color: Colors.blue),
                ],
                activeStep: currentStep,
                activeStepBorderColor: Colors.blueAccent,
                activeStepColor: Colors.blue,
                lineColor: Colors.lightBlueAccent,
                stepColor: Colors.white,
                enableStepTapping: true,
                onStepReached: (index) => setState(() => currentStep = index),
              ),
            ),
            Expanded(
              child: FormBuilder(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: IndexedStack(
                    key: ValueKey(currentStep),
                    index: currentStep,
                    children: [
                      _buildDemographicsStep(),
                      _buildHealthInfoStep(),
                      _buildWellnessStep(),
                      _buildPracticesStep(),
                      _buildSummaryStep(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentStep > 0)
                    TextButton(
                      onPressed: previousStep,
                      child: const Text('Back'),
                    ),
                  ElevatedButton(
                    onPressed: currentStep == 4 ? submitForm : nextStep,
                    child: Text(currentStep == 4 ? 'Submit' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildDemographicsStep() {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text('Demographics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyan)),
            const SizedBox(height: 16),
           
            const SizedBox(height: 12),
            FormBuilderDropdown(
              name: 'age_group',
              decoration: const InputDecoration(labelText: 'Age Range'),
              items: ['18-24', '25-34', '35-44', '45+']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
            const SizedBox(height: 12),
            FormBuilderDropdown(
              name: 'sex_assigned_at_birth',
              decoration: const InputDecoration(labelText: 'Sex Assigned at Birth'),
              items: ['Male', 'Female'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            ),
            const SizedBox(height: 12),
            FormBuilderDropdown(
              name: 'gender_identity',
              decoration: const InputDecoration(labelText: 'Gender Identity'),
              items: ['Male', 'Female', 'Transgender', 'Non-binary', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
            const SizedBox(height: 12),
            FormBuilderDropdown(
              name: 'employment_status',
              decoration: const InputDecoration(labelText: 'Employment Status'),
              items: ['Employed', 'Unemployed', 'Student', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInfoStep() {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text('Health Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyan)),
            const SizedBox(height: 16),
            FormBuilderDropdown(
              name: 'hiv_status',
              decoration: const InputDecoration(labelText: 'HIV Status'),
              items: ['Positive', 'Negative', 'Prefer not to say']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
            const SizedBox(height: 12),
            FormBuilderTextField(
              name: 'diagnosed_year',
              decoration: const InputDecoration(labelText: 'Year Diagnosed'),
            ),
            const SizedBox(height: 12),
            FormBuilderCheckbox(
              name: 'on_art',
              title: const Text('I am currently taking ART medication'),
            ),
            const SizedBox(height: 12),
            FormBuilderTextField(
              name: 'cd4_count',
              decoration: const InputDecoration(labelText: 'Recent CD4 count (optional)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessStep() {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text('Wellness', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyan)),
            const SizedBox(height: 16),
            FormBuilderSlider(
              name: 'wellness',
              min: 0,
              max: 10,
              initialValue: 5,
              divisions: 10,
              decoration: const InputDecoration(labelText: 'How do you feel today?'),
              activeColor: Colors.cyan,
              inactiveColor: Colors.cyan.shade100,
            ),
            const SizedBox(height: 12),
            FormBuilderCheckbox(
              name: 'access_counseling',
              title: const Text('I have access to counseling support'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticesStep() {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text('Practices', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyan)),
            const SizedBox(height: 16),
            FormBuilderCheckbox(
              name: 'uses_condom',
              title: const Text('I use condoms during sexual activity'),
            ),
            const SizedBox(height: 12),
            FormBuilderCheckbox(
              name: 'aware_u_equals_u',
              title: const Text('I am aware of U=U (Undetectable = Untransmittable)'),
            ),
            const SizedBox(height: 12),
            FormBuilderTextField(
              name: 'info_needs',
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'What information would you like to learn more about?'),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildSummaryStep() {
  final formData = _formKey.currentState?.value ?? {};
  return Card(
    elevation: 6,
    margin: const EdgeInsets.all(24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const Text(
            'Summary Review',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.cyan),
          ),
          const SizedBox(height: 16),

          _buildSummaryItem('Age Range', formData['age_group']),
          _buildSummaryItem('Sex Assigned at Birth', formData['sex_assigned_at_birth']),
          _buildSummaryItem('Gender Identity', formData['gender_identity']),
          _buildSummaryItem('Employment Status', formData['employment_status']),
          const Divider(),

          _buildSummaryItem('HIV Status', formData['hiv_status']),
          _buildSummaryItem('Year Diagnosed', formData['diagnosed_year']),
          _buildSummaryItem('On ART?', formData['on_art'] == true ? 'Yes' : 'No'),
          _buildSummaryItem('CD4 Count', formData['cd4_count']),
          const Divider(),

          _buildSummaryItem('Wellness Score', formData['wellness']?.toString()),
          _buildSummaryItem('Access to Counseling?', formData['access_counseling'] == true ? 'Yes' : 'No'),
          const Divider(),

          _buildSummaryItem('Uses Condom?', formData['uses_condom'] == true ? 'Yes' : 'No'),
          _buildSummaryItem('Aware of U=U?', formData['aware_u_equals_u'] == true ? 'Yes' : 'No'),
          _buildSummaryItem('Info Needs', formData['info_needs']),
        ],
      ),
    ),
  );
}

Widget _buildSummaryItem(String label, dynamic value) {
  if (value == null || value.toString().isEmpty) return SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ),
        Expanded(
          flex: 5,
          child: Chip(
            label: Text(value.toString()),
            backgroundColor: Colors.cyan.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.cyan.shade200),
            ),
          ),
        ),
      ],
    ),
  );
}



}
