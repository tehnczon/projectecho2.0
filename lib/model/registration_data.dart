class RegistrationData {
  String? phoneNumber;
  bool? acceptedTerms;

  // UIC fields
  String? motherFirstName;
  String? fatherFirstName;
  int? birthOrder;
  DateTime? birthDate;
  String? generatedUIC; // auto-generated username

  // Identity fields
  String? sexAssignedAtBirth;
  String? genderIdentity;
  String? nationality;

  // Location
  String? city;
  String? barangay;

  // User type
  String? userType; // "PLHIV" or "Info Seeker"

  // PLHIV Profiling
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
    this.genderIdentity,
    this.nationality,
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
    String? genderIdentity,
    String? nationality,
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
      genderIdentity: genderIdentity ?? this.genderIdentity,
      nationality: nationality ?? this.nationality,
      city: city ?? this.city,
      barangay: barangay ?? this.barangay,
      userType: userType ?? this.userType,
      yearDiagnosed: yearDiagnosed ?? this.yearDiagnosed,
      confirmatoryCode: confirmatoryCode ?? this.confirmatoryCode,
      treatmentHub: treatmentHub ?? this.treatmentHub,
    );
  }
}
