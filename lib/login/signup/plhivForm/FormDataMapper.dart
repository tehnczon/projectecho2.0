import 'package:flutter/material.dart';
import 'package:projecho/main/registration_data.dart';

/// Maps form data from Step forms to RegistrationData model
class FormDataMapper {
  /// Extract data from Step 1 form controllers
  static void mapStep1Data(
    RegistrationData regData,
    Map<String, TextEditingController> controllers,
    Map<String, dynamic> state,
  ) {
    // PII Data

    regData.birthOrder = int.tryParse(controllers['birthOrder']?.text ?? '');

    // Parse birthdate
    if (controllers['birthDate']?.text.isNotEmpty ?? false) {
      try {
        regData.birthDate = DateTime.parse(controllers['birthDate']!.text);
      } catch (e) {
        print('Error parsing birthdate: $e');
      }
    }

    // Location data
    regData.currentCity = controllers['currentCity']?.text.trim();
    regData.currentProvince = controllers['currentProvince']?.text.trim();
    regData.permanentCity = controllers['permanentCity']?.text.trim();
    regData.permanentProvince = controllers['permanentProvince']?.text.trim();
    regData.birthCity = controllers['birthCity']?.text.trim();
    regData.birthProvince = controllers['birthProvince']?.text.trim();

    // Non-PII Data
    regData.sexAssignedAtBirth = state['sexAtBirth'];
    regData.genderIdentity = state['selfIdentity'];
    regData.customGender = state['customGender'];
    regData.nationality = state['nationality'];
    regData.otherNationality = controllers['otherNationality']?.text.trim();
    regData.educationLevel = state['educationLevel'];
    regData.civilStatus = state['civilStatus'];
    regData.livingWithPartner = state['livingWithPartner'];
    regData.isPregnant = state['isPregnant'];
    regData.numberOfChildren = int.tryParse(
      controllers['numberOfChildren']?.text ?? '',
    );

    // Compute age range from birthdate
    regData.computeAgeRange();
  }

  /// Extract data from Step 2 form controllers
  static void mapStep2Data(
    RegistrationData regData,
    Map<String, TextEditingController> controllers,
    Map<String, dynamic> state,
  ) {
    regData.currentOccupation = controllers['currentOccupation']?.text.trim();
    regData.previousOccupation = controllers['previousOccupation']?.text.trim();
    regData.isStudying = state['currentlyInSchool'];
    regData.schoolLevel = state['schoolLevel'];
    regData.isOFW = state['workedOverseas'];
    regData.ofwReturnYear = int.tryParse(controllers['returnYear']?.text ?? '');
    regData.ofwBasedLocation = state['basedLocation'];
    regData.ofwLastCountry = controllers['countryWorked']?.text.trim();
  }

  /// Extract data from Step 3 form controllers
  static void mapStep3Data(
    RegistrationData regData,
    Map<String, TextEditingController> controllers,
    Map<String, dynamic> state,
  ) {
    regData.motherHadHIV = state['motherHadHIV'];
    regData.ageAtFirstSex = int.tryParse(
      controllers['ageFirstSex']?.text ?? '',
    );
    regData.ageAtFirstDrugUse = int.tryParse(
      controllers['ageFirstDrug']?.text ?? '',
    );
    regData.femalePartnerCount = int.tryParse(
      controllers['femalePartners']?.text ?? '',
    );
    regData.malePartnerCount = int.tryParse(
      controllers['malePartners']?.text ?? '',
    );
    regData.yearLastSexFemale = int.tryParse(
      controllers['yearLastSexFemale']?.text ?? '',
    );
    regData.yearLastSexMale = int.tryParse(
      controllers['yearLastSexMale']?.text ?? '',
    );

    // Exposure history map
    if (state['exposureHistory'] != null) {
      regData.exposureHistory = Map<String, String?>.from(
        state['exposureHistory'],
      );
    }

    // Compute unprotected sex classification
    regData.computeUnprotectedSexWith();

    // Check for STI from exposure history
    if (regData.exposureHistory['sti'] == 'within12' ||
        regData.exposureHistory['sti'] == 'moreThan12') {
      regData.diagnosedSTI = true;
    }
  }

  /// Extract data from Step 4 form controllers
  static void mapStep4Data(
    RegistrationData regData,
    Map<String, dynamic> state,
  ) {
    regData.hasTuberculosis = state['currentTBPatient'] ?? false;
    regData.hasHepatitisB = state['withHepatitisB'] ?? false;
    regData.hasHepatitisC = state['withHepatitisC'] ?? false;
    regData.cbsReactive = state['cbsReactive'] ?? false;
    regData.takingPreP = state['takingPreP'] ?? false;

    // Pregnancy can also be updated here if changed
    if (state['currentlyPregnant'] != null) {
      regData.isPregnant = state['currentlyPregnant'];
    }
  }

  /// Extract data from Step 5 form controllers
  static void mapStep5Data(
    RegistrationData regData,
    Map<String, TextEditingController> controllers,
    Map<String, dynamic> state,
  ) {
    regData.everTestedForHIV = state['everTestedForHIV'];
    regData.lastTestMonth = int.tryParse(controllers['testMonth']?.text ?? '');
    regData.lastTestYear = int.tryParse(controllers['testYear']?.text ?? '');
    regData.testFacility = controllers['testFacility']?.text.trim();
    regData.testCity = controllers['testCity']?.text.trim();
    regData.testResult = state['testResult'];
  }
}

/// Enhanced form submission handler with data mapping
class FormSubmissionHandler {
  /// Submit all form data with proper mapping
  static Future<bool> submitAllData(
    RegistrationData regData,
    BuildContext context,
  ) async {
    try {
      // Show loading dialog
      _showLoadingDialog(context);

      // Step 1: Save analytics data (non-PII)
      print('ðŸ“Š Saving analytics data...');
      bool analyticsSuccess = await regData.saveToAnalyticData();

      if (!analyticsSuccess) {
        throw Exception('Failed to save analytics data');
      }

      // Step 3: Save user profile
      print('ðŸ‘¤ Saving user profile...');
      bool userSuccess = await regData.saveToUser();

      if (!userSuccess) {
        throw Exception('Failed to save user profile');
      }

      // Step 4: Save to profiles collection
      print('ðŸ“ Saving profile details...');
      bool profileSuccess = await regData.saveToProfiles();

      if (!profileSuccess) {
        throw Exception('Failed to save profile details');
      }

      // Step 5: Save demographics (optional)
      print('ðŸ“ Saving demographics...');
      await regData.saveToUserDemographic();

      print('âœ… All data saved successfully!');
      return true;
    } catch (e) {
      print('âŒ Error during form submission: $e');
      return false;
    }
  }

  /// Show loading dialog
  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving your data securely...'),
                ],
              ),
            ),
          ),
    );
  }

  /// Validate all steps data completeness
  static Map<String, bool> validateAllSteps(RegistrationData regData) {
    return {
      'step1': _validateStep1(regData),
      'step2': _validateStep2(regData),
      'step3': _validateStep3(regData),
      'step4': _validateStep4(regData),
      'step5': _validateStep5(regData),
    };
  }

  static bool _validateStep1(RegistrationData regData) {
    // Optional validation - all fields are optional
    // But we can check if at least basic info is provided
    return regData.sexAssignedAtBirth != null || regData.birthDate != null;
  }

  static bool _validateStep2(RegistrationData regData) {
    // All optional
    return true;
  }

  static bool _validateStep3(RegistrationData regData) {
    // All optional
    return true;
  }

  static bool _validateStep4(RegistrationData regData) {
    // All optional
    return true;
  }

  static bool _validateStep5(RegistrationData regData) {
    // All optional
    return true;
  }
}

/// Helper extension for form state management
extension RegistrationDataFormHelper on RegistrationData {
  /// Update city/barangay from location data
  void updateLocationFromForm() {
    // Use current city as primary location
    this.city = this.currentCity ?? this.permanentCity;
    // Note: barangay needs to be added to forms if needed
  }

  /// Get completion percentage
  double getCompletionPercentage() {
    int totalFields = 0;
    int filledFields = 0;

    // Count all optional fields
    final fields = [
      birthOrder,
      birthDate,
      sexAssignedAtBirth,
      genderIdentity,
      nationality,
      educationLevel,
      civilStatus,
      livingWithPartner,
      isPregnant,
      currentOccupation,
      isStudying,
      isOFW,
      motherHadHIV,
      ageAtFirstSex,
      femalePartnerCount,
      malePartnerCount,
      hasTuberculosis,
      hasHepatitisB,
      diagnosedSTI,
      everTestedForHIV,
    ];

    totalFields = fields.length;
    filledFields = fields.where((f) => f != null && f != false).length;

    return (filledFields / totalFields * 100).clamp(0.0, 100.0);
  }

  /// Check if minimum required data is provided
  bool hasMinimumData() {
    // At minimum, we need user type and age range
    return userType != null && (ageRange != null || birthDate != null);
  }
}
