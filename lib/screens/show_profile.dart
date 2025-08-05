import 'package:flutter/material.dart';

class ShowProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ShowProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  State<ShowProfilePage> createState() => _ShowProfilePageState();
}

class _ShowProfilePageState extends State<ShowProfilePage> {
  bool showSensitive = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.userData;

    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Regular Data
          profileItem("Age Range", data['ageRange']),
          profileItem("Barangay", data['barangay']),
          profileItem("Birth Date", data['birthDate']),
          profileItem("City", data['city']),
          profileItem("Civil Status", data['civilStatus']),
          profileItem("Education Level", data['educationLevel']),
          profileItem("Gender Identity", data['genderIdentity']),
          profileItem("Nationality", data['nationality']),
          profileItem("Phone Number", data['phoneNumber']),
          profileItem("Sex Assigned at Birth", data['sexAssignedAtBirth']),
          profileItem("Treatment Hub", data['treatmentHub']),
          profileItem("User Type", data['userType']),
          if (data['yearDiagnosed'] != null)
            profileItem("Year Diagnosed", data['yearDiagnosed'].toString()),
          if (data['hasHepatitis'] != null)
            profileItem("Has Hepatitis", data['hasHepatitis'].toString()),
          if (data['hasTuberculosis'] != null)
            profileItem("Has Tuberculosis", data['hasTuberculosis'].toString()),
          if (data['isOFW'] != null)
            profileItem("Is OFW", data['isOFW'].toString()),
          if (data['isStudying'] != null)
            profileItem("Is Studying", data['isStudying'].toString()),
          if (data['livingWithPartner'] != null)
            profileItem(
              "Living with Partner",
              data['livingWithPartner'].toString(),
            ),
          if (data['diagnosedSTI'] != null)
            profileItem("Diagnosed STI", data['diagnosedSTI'].toString()),
          profileItem("Unprotected Sex With", data['unprotectedSexWith']),

          const SizedBox(height: 20),
          const Divider(),

          // Toggle Sensitive Button
          TextButton(
            onPressed: () {
              setState(() {
                showSensitive = !showSensitive;
              });
            },
            child: Text(
              showSensitive ? "Hide Sensitive Data" : "Show Sensitive Data",
            ),
          ),

          // Sensitive Data (conditionally shown)
          if (showSensitive) ...[
            profileItem("Confirmatory Code", data['confirmatoryCode']),
            profileItem("Generated UIC", data['generatedUIC']),
            if (data['acceptedTerms'] != null)
              profileItem("Accepted Terms", data['acceptedTerms'].toString()),
            profileItem("Father First Name", data['fatherFirstName']),
            profileItem("Mother First Name", data['motherFirstName']),
            if (data['birthOrder'] != null)
              profileItem("Birth Order", data['birthOrder'].toString()),
            if (data['isPregnant'] != null)
              profileItem("Is Pregnant", data['isPregnant'].toString()),
            if (data['motherHadHIV'] != null)
              profileItem("Mother Had HIV", data['motherHadHIV'].toString()),
          ],
        ],
      ),
    );
  }

  // Only show if value is NOT null and not an empty string
  Widget profileItem(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty)
      return SizedBox.shrink();

    return ListTile(title: Text(label), subtitle: Text(value.toString()));
  }
}
