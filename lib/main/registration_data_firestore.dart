// lib/extensions/registration_data_firestore.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecho/main/registration_data.dart'; // Your existing model

extension RegistrationDataFirestore on RegistrationData {
  Map<String, dynamic> toFirestore() {
    final cleanedPhone = phoneNumber?.replaceAll(RegExp(r'[^\d]'), '') ?? '';

    // Determine role based on userType
    final role = userType == 'PLHIV' ? 'plhiv' : 'infoSeeker';

    Map<String, dynamic> firestoreData = {
      'role': role,
      'phoneNumber': phoneNumber,
      'cleanedPhone': cleanedPhone,
      'acceptedTerms': acceptedTerms ?? false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'isActive': true,

      // UIC Data
      'uicData': {
        'motherFirstName': motherFirstName,
        'fatherFirstName': fatherFirstName,
        'birthOrder': birthOrder,
        'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
        'generatedUIC': generatedUIC,
        'ageRange': ageRange,
      },

      // Demographics
      'demographics': {
        'sexAssignedAtBirth': sexAssignedAtBirth,
        'genderIdentity': genderIdentity,
        'nationality': nationality,
        'educationLevel': educationLevel,
        'civilStatus': civilStatus,
        'isStudying': isStudying,
        'livingWithPartner': livingWithPartner,
        'isOFW': isOFW,
      },

      // Location
      'location': {'city': city, 'barangay': barangay},

      // Health Info
      'healthInfo': {
        'isPregnant': isPregnant,
        'motherHadHIV': motherHadHIV,
        'diagnosedSTI': diagnosedSTI,
        'hasHepatitis': hasHepatitis,
        'hasTuberculosis': hasTuberculosis,
        'unprotectedSexWith': unprotectedSexWith,
      },
    };

    // Add PLHIV-specific data if applicable
    if (userType == 'PLHIV') {
      firestoreData['plhivData'] = {
        'yearDiagnosed': yearDiagnosed,
        'confirmatoryCode': confirmatoryCode,
        'treatmentHub': treatmentHub,
        'verifiedPLHIV': false, // Will be set to true after verification
      };
    }

    return firestoreData;
  }

  // Helper to save to Firestore
  Future<bool> saveToFirestore() async {
    try {
      final cleanedPhone = phoneNumber?.replaceAll(RegExp(r'[^\d]'), '') ?? '';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cleanedPhone)
          .set(toFirestore(), SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error saving to Firestore: $e');
      return false;
    }
  }
}
