// lib/main/registration_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationData {
  // Core Registration
  String uid; // ✅ Use Firebase UID instead of phone

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
  List<String> hivRelation = []; // Multiple selections allowed
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
  String? treatmentHub;

  RegistrationData({
    required this.uid, // ✅ required
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

  // Check if user is MSM (Men who have Sex with Men)
  bool get isMSM {
    return sexAssignedAtBirth == 'Male' &&
        (unprotectedSexWith == 'Male' || unprotectedSexWith == 'Both');
  }

  // Check if user is youth (18-24)
  bool get isYouth {
    return ageRange == '18-24';
  }

  //has multiple partner risk
  bool get hasMultiplePartnerRisk {
    return sexAssignedAtBirth == 'Male' && (unprotectedSexWith == 'Both') ||
        sexAssignedAtBirth == 'Female' && ((unprotectedSexWith == 'Both'));
  }

  //isMSW
  bool get isMSW {
    return sexAssignedAtBirth == 'Male' &&
            (unprotectedSexWith == 'Both' || unprotectedSexWith == 'Female') ||
        sexAssignedAtBirth == 'Female' &&
            ((unprotectedSexWith == 'Both' || unprotectedSexWith == 'Male'));
  }

  //isWSW
  bool get isWSW {
    return sexAssignedAtBirth == 'Female' && (unprotectedSexWith == 'Female');
  }

  //isWSW

  // ANALYTICS-READY Firestore conversion - FLATTENED structure
  Map<String, dynamic> toFirestore() {
    // Ensure age range is computed before saving
    computeAgeRange();

    Map<String, dynamic> data = {
      // ==================== CORE IDENTIFICATION ====================
      'role': role,
      'userType': userType,
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
      'isMSW': isMSW,
      'isWSW': isWSW,
      'hasMultiplePartnerRisk': hasMultiplePartnerRisk,
    };

    // Add PLHIV-specific data if applicable
    if (userType == 'PLHIV') {
      data.addAll({
        'yearDiagnosed': yearDiagnosed,
        'treatmentHub': treatmentHub,
      });
    }
    return data;
  }

  // For local storage/transfer (keeps original structure for UI)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
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
      'treatmentHub': treatmentHub,
    };
  }

  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      uid: json['uid'],
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
      treatmentHub: json['treatmentHub'],
    );
  }

  // Create from Firestore document (handles flattened structure)
  factory RegistrationData.fromFirestore(
    Map<String, dynamic> data,
    String uid,
  ) {
    return RegistrationData(
      uid: uid,
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
      treatmentHub: data['treatmentHub'],
    );
  }

  Future<bool> saveToUserDemographic() async {
    try {
      await FirebaseFirestore.instance
          .collection('userDemographic') // PRIMARY COLLECTION
          .doc(uid) // ✅ UID instead of phone
          .set({
            'ageRange': ageRange,
            'location': {'city': city, 'barangay': barangay},
            'genderIdentity': genderIdentity,
            'hivRelation': hivRelation,
            'civilStatus': civilStatus,
            'isOFW': isOFW,
            'islivingWithPartner': livingWithPartner,
            'isStudying': isStudying,
            'studyingLevel': educationLevel,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      print('✅ User profile saved to Firestore: $uid');
      return true;
    } catch (e) {
      print('❌ Error saving to Firestore: $e');
      return false;
    }
  }

  // Save to Firestore using UID as document ID
  Future<bool> saveToUser() async {
    try {
      await FirebaseFirestore.instance
          .collection('user') // PRIMARY COLLECTION
          .doc(uid) // ✅ UID instead of phone
          .set({
            'role': role,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
            'isActive': true,
          }, SetOptions(merge: true));

      print('✅ User profile saved to Firestore: $uid');
      return true;
    } catch (e) {
      print('❌ Error saving to Firestore: $e');
      return false;
    }
  }

  // Save minimal profile info to "profiles" collection
  Future<bool> saveToProfiles() async {
    try {
      computeAgeRange();

      await FirebaseFirestore.instance.collection('profiles').doc(uid).set({
        'generatedUIC': generatedUIC,
        'ageRange': ageRange,
        'location': {'city': city, 'barangay': barangay},
        'genderIdentity': genderIdentity,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (role != 'infoSeeker') {
        Map<String, dynamic> roleData = {};
        if (role == 'plhiv') {
          roleData = {
            'yearDiagnosed': yearDiagnosed,
            'treatmentHub': treatmentHub,
          };
        } else if (role == 'admin') {
          roleData = {
            'org': null, // Replace with actual org variable if available
            'contactInfo':
                null, // Replace with actual contact info variable if available
            'isValidated':
                false, // Replace with actual validation status if available
          };
        }

        // Save role data in subcollection
        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(uid)
            .collection('roleData')
            .doc(role)
            .set(roleData, SetOptions(merge: true));
      }

      print('✅ Profile saved to Firestore: $uid');
      return true;
    } catch (e) {
      print('❌ Error saving profile to Firestore: $e');
      return false;
    }
  }

  // save to analytic data
  Future<bool> saveToAnalyticData() async {
    try {
      computeAgeRange();

      await FirebaseFirestore.instance.collection('analyticData').doc(uid).set({
        'ageRange': ageRange,
        'location': {'city': city, 'barangay': barangay},
        'civilStatus': civilStatus,
        'diagnosedWithSTI': diagnosedSTI,
        'educationalLevel': educationLevel,
        'sexAtBirth': sexAssignedAtBirth,
        'genderIdentity': genderIdentity,
        'hasHepatitis': hasHepatitis,
        'hasTuberculosis': hasTuberculosis,
        'isMSM': isMSM,
        'isMSW': isMSW,
        'isWSW': isWSW,
        'nationality': nationality,
        'hasMultiplePartnerRisk': hasMultiplePartnerRisk,
        'isOFW': isOFW,
        'isStudying': isStudying,
        'livingWithPartner': livingWithPartner,
        'motherHadHIV': motherHadHIV,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('');
      return true;
    } catch (e) {
      print('');
      return false;
    }
  }

  RegistrationData copyWith({
    String? uid,
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
      uid: uid ?? this.uid,
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
      treatmentHub: treatmentHub ?? this.treatmentHub,
    );
  }
}
