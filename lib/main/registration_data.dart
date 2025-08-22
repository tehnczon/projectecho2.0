// lib/main/registration_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/phone_number_utils.dart';

class RegistrationData {
  // Core Registration
  String? phoneNumber;
  bool? acceptedTerms;

  // UIC Fields (for local generation only)
  String? motherFirstName;
  String? fatherFirstName;
  int? birthOrder;
  DateTime? birthDate;
  String? generatedUIC;

  // Demographics - Step 1
  String? sexAssignedAtBirth;
  String? ageRange; // Computed from birthDate
  String? genderIdentity;
  String? nationality;

  // Education & Status - Step 2
  String? educationLevel;
  String? civilStatus;
  bool? isStudying;
  bool? livingWithPartner;

  // Health & Pregnancy - Step 3
  bool? isPregnant;
  bool? motherHadHIV;
  bool? diagnosedSTI;
  bool? hasHepatitis;
  bool? hasTuberculosis;

  // Sexual Practices - Step 4
  String?
  unprotectedSexWith; // Values: Male, Female, Both, Never, Prefer not to say

  // Work Status - Step 5
  bool? isOFW;

  // Location
  String? city;
  String? barangay;

  // User Type
  String? userType; // "PLHIV" or "Health Information Seeker"

  // PLHIV-specific Fields
  int? yearDiagnosed;
  String? confirmatoryCode;
  String? treatmentHub;

  RegistrationData({
    this.phoneNumber,
    this.acceptedTerms,
    this.motherFirstName,
    this.fatherFirstName,
    this.birthOrder,
    this.birthDate,
    this.generatedUIC,
    this.sexAssignedAtBirth,
    this.ageRange,
    this.genderIdentity,
    this.nationality,
    this.educationLevel,
    this.civilStatus,
    this.isStudying,
    this.livingWithPartner,
    this.isPregnant,
    this.motherHadHIV,
    this.diagnosedSTI,
    this.hasHepatitis,
    this.hasTuberculosis,
    this.unprotectedSexWith,
    this.isOFW,
    this.city,
    this.barangay,
    this.userType,
    this.yearDiagnosed,
    this.confirmatoryCode,
    this.treatmentHub,
  });

  // Helper method to compute age range from birth date
  void computeAgeRange() {
    if (birthDate != null) {
      final now = DateTime.now();
      int age = now.year - birthDate!.year;
      if (now.month < birthDate!.month ||
          (now.month == birthDate!.month && now.day < birthDate!.day)) {
        age--;
      }

      if (age < 18) {
        ageRange = 'Under 18';
      } else if (age <= 24) {
        ageRange = '18-24';
      } else if (age <= 34) {
        ageRange = '25-34';
      } else if (age <= 44) {
        ageRange = '35-44';
      } else {
        ageRange = '45+';
      }
    }
  }

  // Convert user type to role for Firestore
  String get role {
    switch (userType) {
      case 'PLHIV':
        return 'plhiv';
      case 'Health Information Seeker':
        return 'infoSeeker';
      default:
        return 'infoSeeker';
    }
  }

  // Get cleaned phone number for document ID using PhoneNumberUtils
  String? get cleanedPhoneNumber {
    if (phoneNumber == null) return null;
    try {
      return PhoneNumberUtils.cleanForDocumentId(phoneNumber!);
    } catch (e) {
      print('Error cleaning phone number: $e');
      return null;
    }
  }

  // Check if user is MSM (Men who have Sex with Men)
  bool get isMSM {
    return sexAssignedAtBirth == 'Male' &&
        (unprotectedSexWith == 'Male' || unprotectedSexWith == 'Both');
  }

  // Check if user is youth (18-24)
  bool get isYouth {
    return ageRange == '18-24';
  }

  // ANALYTICS-READY Firestore conversion - FLATTENED structure
  Map<String, dynamic> toFirestore() {
    // Ensure age range is computed before saving
    computeAgeRange();

    final cleanedPhone = cleanedPhoneNumber;
    if (cleanedPhone == null) {
      throw ArgumentError(
        'Phone number is required and must be valid Philippine mobile number',
      );
    }

    Map<String, dynamic> data = {
      // ==================== CORE IDENTIFICATION ====================
      'phoneNumber': phoneNumber,
      'cleanedPhone': cleanedPhone, // Used as document ID
      'role': role, // Computed from userType
      'userType': userType,
      'acceptedTerms': acceptedTerms ?? false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'isActive': true,

      // ==================== UIC DATA ====================
      'generatedUIC': generatedUIC,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'ageRange': ageRange,

      // ==================== DEMOGRAPHICS (FLATTENED) ====================
      'sexAssignedAtBirth': sexAssignedAtBirth,
      'genderIdentity': genderIdentity,
      'nationality': nationality,

      // ==================== EDUCATION & SOCIAL ====================
      'educationLevel': educationLevel,
      'civilStatus': civilStatus,
      'isStudying': isStudying ?? false,
      'livingWithPartner': livingWithPartner ?? false,

      // ==================== HEALTH INFORMATION ====================
      'isPregnant': isPregnant ?? false,
      'motherHadHIV': motherHadHIV ?? false,
      'diagnosedSTI': diagnosedSTI ?? false,
      'hasHepatitis': hasHepatitis ?? false,
      'hasTuberculosis': hasTuberculosis ?? false,
      'unprotectedSexWith': unprotectedSexWith,

      // ==================== LOCATION & WORK ====================
      'city': city,
      'barangay': barangay,
      'isOFW': isOFW ?? false,

      // ==================== PRE-COMPUTED ANALYTICS ====================
      'isMSM': isMSM,
      'isYouth': isYouth,
    };

    // Add PLHIV-specific data if applicable
    if (userType == 'PLHIV') {
      data.addAll({
        'yearDiagnosed': yearDiagnosed,
        'confirmatoryCode': confirmatoryCode,
        'treatmentHub': treatmentHub,
        'verifiedPLHIV':
            confirmatoryCode != null && confirmatoryCode!.isNotEmpty,
      });
    }

    return data;
  }

  // For local storage/transfer (keeps original structure for UI)
  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'acceptedTerms': acceptedTerms,
      'motherFirstName': motherFirstName,
      'fatherFirstName': fatherFirstName,
      'birthOrder': birthOrder,
      'birthDate': birthDate?.toIso8601String(),
      'generatedUIC': generatedUIC,
      'sexAssignedAtBirth': sexAssignedAtBirth,
      'ageRange': ageRange,
      'genderIdentity': genderIdentity,
      'nationality': nationality,
      'educationLevel': educationLevel,
      'civilStatus': civilStatus,
      'isStudying': isStudying,
      'livingWithPartner': livingWithPartner,
      'isPregnant': isPregnant,
      'motherHadHIV': motherHadHIV,
      'diagnosedSTI': diagnosedSTI,
      'hasHepatitis': hasHepatitis,
      'hasTuberculosis': hasTuberculosis,
      'unprotectedSexWith': unprotectedSexWith,
      'isOFW': isOFW,
      'city': city,
      'barangay': barangay,
      'userType': userType,
      'yearDiagnosed': yearDiagnosed,
      'confirmatoryCode': confirmatoryCode,
      'treatmentHub': treatmentHub,
    };
  }

  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      phoneNumber: json['phoneNumber'],
      acceptedTerms: json['acceptedTerms'],
      motherFirstName: json['motherFirstName'],
      fatherFirstName: json['fatherFirstName'],
      birthOrder: json['birthOrder'],
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      generatedUIC: json['generatedUIC'],
      sexAssignedAtBirth: json['sexAssignedAtBirth'],
      ageRange: json['ageRange'],
      genderIdentity: json['genderIdentity'],
      nationality: json['nationality'],
      educationLevel: json['educationLevel'],
      civilStatus: json['civilStatus'],
      isStudying: json['isStudying'],
      livingWithPartner: json['livingWithPartner'],
      isPregnant: json['isPregnant'],
      motherHadHIV: json['motherHadHIV'],
      diagnosedSTI: json['diagnosedSTI'],
      hasHepatitis: json['hasHepatitis'],
      hasTuberculosis: json['hasTuberculosis'],
      unprotectedSexWith: json['unprotectedSexWith'],
      isOFW: json['isOFW'],
      city: json['city'],
      barangay: json['barangay'],
      userType: json['userType'],
      yearDiagnosed: json['yearDiagnosed'],
      confirmatoryCode: json['confirmatoryCode'],
      treatmentHub: json['treatmentHub'],
    );
  }

  // Create from Firestore document (handles flattened structure)
  factory RegistrationData.fromFirestore(Map<String, dynamic> data) {
    return RegistrationData(
      phoneNumber: data['phoneNumber'],
      acceptedTerms: data['acceptedTerms'],
      // Note: UIC components not stored in Firestore for privacy
      generatedUIC: data['generatedUIC'],
      birthDate:
          data['birthDate'] != null
              ? (data['birthDate'] as Timestamp).toDate()
              : null,
      sexAssignedAtBirth: data['sexAssignedAtBirth'],
      ageRange: data['ageRange'],
      genderIdentity: data['genderIdentity'],
      nationality: data['nationality'],
      educationLevel: data['educationLevel'],
      civilStatus: data['civilStatus'],
      isStudying: data['isStudying'],
      livingWithPartner: data['livingWithPartner'],
      isPregnant: data['isPregnant'],
      motherHadHIV: data['motherHadHIV'],
      diagnosedSTI: data['diagnosedSTI'],
      hasHepatitis: data['hasHepatitis'],
      hasTuberculosis: data['hasTuberculosis'],
      unprotectedSexWith: data['unprotectedSexWith'],
      isOFW: data['isOFW'],
      city: data['city'],
      barangay: data['barangay'],
      userType: data['userType'],
      yearDiagnosed: data['yearDiagnosed'],
      confirmatoryCode: data['confirmatoryCode'],
      treatmentHub: data['treatmentHub'],
    );
  }

  // Save to Firestore using the cleaned phone as document ID
  Future<bool> saveToFirestore() async {
    try {
      final cleanedPhone = cleanedPhoneNumber;
      if (cleanedPhone == null) {
        throw ArgumentError('Valid Philippine mobile number is required');
      }

      await FirebaseFirestore.instance
          .collection('users') // PRIMARY COLLECTION
          .doc(cleanedPhone)
          .set(toFirestore(), SetOptions(merge: true));

      print('✅ User profile saved to Firestore: $cleanedPhone');
      return true;
    } catch (e) {
      print('❌ Error saving to Firestore: $e');
      return false;
    }
  }

  RegistrationData copyWith({
    String? phoneNumber,
    bool? acceptedTerms,
    String? motherFirstName,
    String? fatherFirstName,
    int? birthOrder,
    DateTime? birthDate,
    String? generatedUIC,
    String? sexAssignedAtBirth,
    String? ageRange,
    String? genderIdentity,
    String? nationality,
    String? educationLevel,
    String? civilStatus,
    bool? isStudying,
    bool? livingWithPartner,
    bool? isPregnant,
    bool? motherHadHIV,
    bool? diagnosedSTI,
    bool? hasHepatitis,
    bool? hasTuberculosis,
    String? unprotectedSexWith,
    bool? isOFW,
    String? city,
    String? barangay,
    String? userType,
    int? yearDiagnosed,
    String? confirmatoryCode,
    String? treatmentHub,
  }) {
    return RegistrationData(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      motherFirstName: motherFirstName ?? this.motherFirstName,
      fatherFirstName: fatherFirstName ?? this.fatherFirstName,
      birthOrder: birthOrder ?? this.birthOrder,
      birthDate: birthDate ?? this.birthDate,
      generatedUIC: generatedUIC ?? this.generatedUIC,
      sexAssignedAtBirth: sexAssignedAtBirth ?? this.sexAssignedAtBirth,
      ageRange: ageRange ?? this.ageRange,
      genderIdentity: genderIdentity ?? this.genderIdentity,
      nationality: nationality ?? this.nationality,
      educationLevel: educationLevel ?? this.educationLevel,
      civilStatus: civilStatus ?? this.civilStatus,
      isStudying: isStudying ?? this.isStudying,
      livingWithPartner: livingWithPartner ?? this.livingWithPartner,
      isPregnant: isPregnant ?? this.isPregnant,
      motherHadHIV: motherHadHIV ?? this.motherHadHIV,
      diagnosedSTI: diagnosedSTI ?? this.diagnosedSTI,
      hasHepatitis: hasHepatitis ?? this.hasHepatitis,
      hasTuberculosis: hasTuberculosis ?? this.hasTuberculosis,
      unprotectedSexWith: unprotectedSexWith ?? this.unprotectedSexWith,
      isOFW: isOFW ?? this.isOFW,
      city: city ?? this.city,
      barangay: barangay ?? this.barangay,
      userType: userType ?? this.userType,
      yearDiagnosed: yearDiagnosed ?? this.yearDiagnosed,
      confirmatoryCode: confirmatoryCode ?? this.confirmatoryCode,
      treatmentHub: treatmentHub ?? this.treatmentHub,
    );
  }
}
