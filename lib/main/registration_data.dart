class RegistrationData {
  // Core Registration
  String? phoneNumber;
  bool? acceptedTerms; // Checkbox before proceeding

  // UIC Fields
  String? motherFirstName;
  String? fatherFirstName;
  int? birthOrder;
  DateTime? birthDate;
  String? generatedUIC;

  // Step 1 – Self Identity
  String? sexAssignedAtBirth;
  String? ageRange; // Computed from birthDate
  String? genderIdentity;
  String? nationality;

  // Step 2 – Education & Status
  String? educationLevel;
  String? civilStatus;
  bool? isStudying;
  bool? livingWithPartner;

  // Step 3 – Health & Pregnancy
  bool? isPregnant;
  bool? motherHadHIV;
  bool? diagnosedSTI;
  bool? hasHepatitis;
  bool? hasTuberculosis;

  // Step 4 – Sexual Practices
  String?
  unprotectedSexWith; // Values: Male, Female, Both, Never, Prefer not to say

  // Step 5 – Work Status
  bool? isOFW;

  // Location
  String? city;
  String? barangay;

  // User Type
  String? userType; // "PLHIV" or "Info Seeker"

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
      'role': userType,
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
}
