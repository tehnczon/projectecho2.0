import 'package:flutter/material.dart';
import 'package:projecho/login/signup/UIC.dart'; 
import 'package:projecho/model/registration_data.dart'; 

class TermsAndConditionsPage extends StatefulWidget {
  final RegistrationData registrationData;

  const TermsAndConditionsPage({
    super.key,
    required this.registrationData,
  });

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _accepted = false;

  void _onAccept() {
    if (_accepted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UICScreen(registrationData: widget.registrationData),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must accept the terms to continue.')),
      );
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget sectionText(String content) {
    return Text(
      content,
      style: const TextStyle(fontSize: 15, height: 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 243, 237, 237),
        foregroundColor: Colors.black,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Terms and Conditions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle("Acceptance of Terms"),
                  sectionText("By using ECHO, you agree to abide by these terms. If you do not agree, please do not use the app."),
                  sectionTitle("Purpose of the App"),
                  sectionText("ECHO is a support and advocacy platform for people living with HIV (PLHIV)..."),
                  sectionTitle("User Responsibilities"),
                  sectionText("• Provide accurate info during registration\n• Use respectful language\n• Respect others’ privacy..."),
                  sectionTitle("Privacy and Data"),
                  sectionText("• Your personal data is secure\n• You may request deletion anytime..."),
                  sectionTitle("Content Ownership"),
                  sectionText("You retain ownership of what you post..."),
                  sectionTitle("Moderation and Removal"),
                  sectionText("Violating community guidelines may result in removal or bans..."),
                  sectionTitle("Location Sharing (Optional)"),
                  sectionText("Sharing region info is optional and not tied to exact location..."),
                  sectionTitle("Changes to Terms"),
                  sectionText("Using the app after updates means you accept the changes..."),

                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: const Text("accept the Terms and Conditions."),
                    value: _accepted,
                    onChanged: (val) => setState(() => _accepted = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 9, 136, 255),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      "Accept and Continue",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
