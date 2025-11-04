import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecho/screens/analytics/components/services/analytics_processing_service.dart';

class RegistrationData {
  // ============================================
  // PERSONAL IDENTIFIABLE INFORMATION (PII)
  // Stored as plaintext locally, hashed in Firestore
  // ============================================
  String uid;

  // Step 1: Demographic Data (PII)
  String? philhealthNumber;
  String? firstName;
  String? middleName;
  String? lastName;
  String? suffix;
  String? motherFirstName;
  String? fatherFirstName;
  int? birthOrder;
  DateTime? birthDate;
  String? currentCity;
  String? currentProvince;
  String? permanentCity;
  String? permanentProvince;
  String? birthCity;
  String? birthProvince;

  // ============================================
  // NON-PII DATA (Safe to store as-is)
  // ============================================

  // User metadata
  String? generatedUIC;
  String? userType;
  int? yearDiagnosed;
  String? treatmentHub;

  // Step 1: Demographic Data (Non-PII)
  String? sexAssignedAtBirth;
  String? ageRange;
  String? genderIdentity;
  String? customGender;
  String? nationality;
  String? otherNationality;
  String? educationLevel;
  String? civilStatus;
  bool? livingWithPartner;
  bool? isPregnant;
  int? numberOfChildren;

  // Step 2: Occupation
  String? currentOccupation;
  String? previousOccupation;
  bool? isStudying;
  String? schoolLevel;
  bool? isOFW;
  int? ofwReturnYear;
  String? ofwBasedLocation; // "On a ship" or "Land"
  String? ofwLastCountry;

  // Step 3: History of Exposure
  bool? motherHadHIV;
  int? ageAtFirstSex;
  int? ageAtFirstDrugUse;
  int? femalePartnerCount;
  int? malePartnerCount;
  int? yearLastSexFemale;
  int? yearLastSexMale;

  // Exposure history (no/within12/moreThan12)
  Map<String, String?> exposureHistory = {
    'sexFemaleNoCondom': null,
    'sexMaleNoCondom': null,
    'sexWithHIVPerson': null,
    'payingForSex': null,
    'acceptingPayment': null,
    'injectedDrugs': null,
    'bloodTransfusion': null,
    'occupationalExposure': null,
    'gotTattoo': null,
    'sti': null,
  };

  // Step 4: Medical History
  bool? hasTuberculosis;
  bool? hasHepatitisB;
  bool? hasHepatitisC;
  bool? cbsReactive;
  bool? takingPreP;
  bool? diagnosedSTI;

  // Step 5: Previous HIV Test
  bool? everTestedForHIV;
  int? lastTestMonth;
  int? lastTestYear;
  String? testFacility;
  String? testCity;
  String?
  testResult; // Positive/Negative/Indeterminate/Was not able to get result

  // Computed fields
  String? unprotectedSexWith;
  List<String> hivRelation = [];
  String? city;
  String? barangay;

  RegistrationData({
    required this.uid,
    this.philhealthNumber,
    this.firstName,
    this.middleName,
    this.lastName,
    this.suffix,
    this.motherFirstName,
    this.fatherFirstName,
    this.birthOrder,
    this.birthDate,
    this.currentCity,
    this.currentProvince,
    this.permanentCity,
    this.permanentProvince,
    this.birthCity,
    this.birthProvince,
    this.generatedUIC,
    this.userType,
    this.yearDiagnosed,
    this.treatmentHub,
    this.sexAssignedAtBirth,
    this.ageRange,
    this.genderIdentity,
    this.customGender,
    this.nationality,
    this.otherNationality,
    this.educationLevel,
    this.civilStatus,
    this.livingWithPartner,
    this.isPregnant,
    this.numberOfChildren,
    this.currentOccupation,
    this.previousOccupation,
    this.isStudying,
    this.schoolLevel,
    this.isOFW,
    this.ofwReturnYear,
    this.ofwBasedLocation,
    this.ofwLastCountry,
    this.motherHadHIV,
    this.ageAtFirstSex,
    this.ageAtFirstDrugUse,
    this.femalePartnerCount,
    this.malePartnerCount,
    this.yearLastSexFemale,
    this.yearLastSexMale,
    this.hasTuberculosis,
    this.hasHepatitisB,
    this.hasHepatitisC,
    this.cbsReactive,
    this.takingPreP,
    this.diagnosedSTI,
    this.everTestedForHIV,
    this.lastTestMonth,
    this.lastTestYear,
    this.testFacility,
    this.testCity,
    this.testResult,
    this.city,
    this.barangay,
  });

  // ============================================
  // HASHING UTILITIES
  // ============================================

  /// Hash sensitive data using SHA-256
  static String _hashData(String? data) {
    if (data == null || data.isEmpty) return '';
    var bytes = utf8.encode(data);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Create composite hash for unique identification
  String _createCompositeHash() {
    final components = [
      firstName ?? '',
      middleName ?? '',
      lastName ?? '',
      birthDate?.toIso8601String() ?? '',
      motherFirstName ?? '',
      fatherFirstName ?? '',
    ].join('|');
    return _hashData(components);
  }

  // ============================================
  // COMPUTED PROPERTIES
  // ============================================

  void computeAgeRange() {
    if (birthDate != null) {
      final now = DateTime.now();
      int age = now.year - birthDate!.year;
      if (now.month < birthDate!.month ||
          (now.month == birthDate!.month && now.day < birthDate!.day)) {
        age--;
      }

      if (age < 18)
        ageRange = 'Under 18';
      else if (age <= 24)
        ageRange = '18-24';
      else if (age <= 34)
        ageRange = '25-34';
      else if (age <= 44)
        ageRange = '35-44';
      else
        ageRange = '45+';
    }
  }

  /// Compute unprotected sex classification
  void computeUnprotectedSexWith() {
    int femaleCount = femalePartnerCount ?? 0;
    int maleCount = malePartnerCount ?? 0;

    if (femaleCount > 0 && maleCount > 0) {
      unprotectedSexWith = 'Both';
    } else if (maleCount > 0) {
      unprotectedSexWith = 'Male';
    } else if (femaleCount > 0) {
      unprotectedSexWith = 'Female';
    } else {
      unprotectedSexWith = 'Never';
    }
  }

  String get role {
    switch (userType) {
      case 'PLHIV':
        return 'plhiv';
      case 'Health Information Seeker':
      default:
        return 'infoSeeker';
    }
  }

  bool get isMSM =>
      sexAssignedAtBirth == 'Male' &&
      (unprotectedSexWith == 'Male' || unprotectedSexWith == 'Both');

  bool get isMSW =>
      sexAssignedAtBirth == 'Male' &&
          (unprotectedSexWith == 'Female' || unprotectedSexWith == 'Both') ||
      sexAssignedAtBirth == 'Female' &&
          (unprotectedSexWith == 'Male' || unprotectedSexWith == 'Both');

  bool get isWSW =>
      sexAssignedAtBirth == 'Female' && unprotectedSexWith == 'Female';

  bool get hasMultiplePartnerRisk => unprotectedSexWith == 'Both';

  bool get isYouth => ageRange == '18-24';

  /// Check if user has any STI exposure
  bool get hasSTIExposure {
    return exposureHistory['sti'] == 'within12' ||
        exposureHistory['sti'] == 'moreThan12' ||
        diagnosedSTI == true;
  }

  /// Check for hepatitis (any type)
  bool get hasHepatitis => hasHepatitisB == true || hasHepatitisC == true;

  // ============================================
  // FIRESTORE SAVE METHODS
  // ============================================

  /// Prepare data for analyticData collection (NON-PII ONLY)
  Map<String, dynamic> toFirestore() {
    computeAgeRange();
    computeUnprotectedSexWith();

    Map<String, dynamic> data = {
      'role': role,
      'userType': userType,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'isActive': true,
      'generatedUIC': generatedUIC,

      // Hashed identifier (for deduplication without exposing PII)
      'compositeHash': _createCompositeHash(),

      // Step 1: Demographic (Non-PII)
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'ageRange': ageRange,
      'sexAssignedAtBirth': sexAssignedAtBirth,
      'genderIdentity': genderIdentity,
      'customGender': customGender,
      'nationality': nationality,
      'otherNationality': otherNationality,
      'educationLevel': educationLevel,
      'civilStatus': civilStatus,
      'livingWithPartner': livingWithPartner ?? false,
      'isPregnant': isPregnant ?? false,
      'numberOfChildren': numberOfChildren,

      // Step 2: Occupation
      'currentOccupation': currentOccupation,
      'previousOccupation': previousOccupation,
      'isStudying': isStudying ?? false,
      'schoolLevel': schoolLevel,
      'isOFW': isOFW ?? false,
      'ofwReturnYear': ofwReturnYear,
      'ofwBasedLocation': ofwBasedLocation,
      'ofwLastCountry': ofwLastCountry,

      // Step 3: History of Exposure
      'motherHadHIV': motherHadHIV ?? false,
      'ageAtFirstSex': ageAtFirstSex,
      'ageAtFirstDrugUse': ageAtFirstDrugUse,
      'femalePartnerCount': femalePartnerCount,
      'malePartnerCount': malePartnerCount,
      'yearLastSexFemale': yearLastSexFemale,
      'yearLastSexMale': yearLastSexMale,
      'exposureHistory': exposureHistory,

      // Step 4: Medical History
      'hasTuberculosis': hasTuberculosis ?? false,
      'hasHepatitisB': hasHepatitisB ?? false,
      'hasHepatitisC': hasHepatitisC ?? false,
      'cbsReactive': cbsReactive ?? false,
      'takingPreP': takingPreP ?? false,
      'diagnosedSTI': diagnosedSTI ?? false,

      // Step 5: Previous HIV Test
      'everTestedForHIV': everTestedForHIV ?? false,
      'lastTestMonth': lastTestMonth,
      'lastTestYear': lastTestYear,
      'testResult': testResult,

      // Computed fields
      'unprotectedSexWith': unprotectedSexWith,
      'city': city,
      'barangay': barangay,
      'isMSM': isMSM,
      'isMSW': isMSW,
      'isWSW': isWSW,
      'hasMultiplePartnerRisk': hasMultiplePartnerRisk,
      'isYouth': isYouth,
      'hasSTIExposure': hasSTIExposure,
      'hasHepatitis': hasHepatitis,
    };

    if (userType == 'PLHIV') {
      data.addAll({
        'yearDiagnosed': yearDiagnosed,
        'treatmentHub': treatmentHub,
      });
    }

    return data;
  }

  /// Prepare PII data for secure storage (HASHED)
  Map<String, dynamic> toSecureFirestore() {
    return {
      'uid': uid,
      'compositeHash': _createCompositeHash(),

      // Hashed PII
      'philhealthNumberHash': _hashData(philhealthNumber),
      'firstNameHash': _hashData(firstName),
      'middleNameHash': _hashData(middleName),
      'lastNameHash': _hashData(lastName),
      'suffixHash': _hashData(suffix),
      'motherFirstNameHash': _hashData(motherFirstName),
      'fatherFirstNameHash': _hashData(fatherFirstName),
      'birthOrderHash': _hashData(birthOrder?.toString()),

      // Location hashes
      'currentCityHash': _hashData(currentCity),
      'currentProvinceHash': _hashData(currentProvince),
      'permanentCityHash': _hashData(permanentCity),
      'permanentProvinceHash': _hashData(permanentProvince),
      'birthCityHash': _hashData(birthCity),
      'birthProvinceHash': _hashData(birthProvince),
      'testFacilityHash': _hashData(testFacility),
      'testCityHash': _hashData(testCity),

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ============================================
  // SAVE TO FIRESTORE
  // ============================================

  Future<bool> saveToAnalyticData() async {
    try {
      computeAgeRange();
      computeUnprotectedSexWith();

      final firestore = FirebaseFirestore.instance;

      // Check returning user status
      final userDoc = await firestore.collection('user').doc(uid).get();
      final isReturningUser = userDoc.data()?['isReturningUser'] ?? false;
      final doNotCount = userDoc.data()?['doNotCountInAnalytics'] ?? false;

      if (isReturningUser) {
        print('⚠️ Returning deleted user detected - marking as do not count');
      }

      // Save analytics data (NON-PII)
      await firestore
          .collection('analyticData')
          .doc(uid)
          .set(toFirestore(), SetOptions(merge: true));

      print('✅ Analytics data saved for user: $uid');

      // Schedule analytics update
      await _scheduleAnalyticsUpdate(forceImmediate: !doNotCount);

      return true;
    } catch (e) {
      print('❌ Error saving analytics data: $e');
      return false;
    }
  }

  /// Save hashed PII to secure collection
  Future<bool> saveSecureData() async {
    try {
      final firestore = FirebaseFirestore.instance;

      await firestore
          .collection('secureUserData')
          .doc(uid)
          .set(toSecureFirestore(), SetOptions(merge: true));

      print('✅ Secure hashed data saved for user: $uid');
      return true;
    } catch (e) {
      print('❌ Error saving secure data: $e');
      return false;
    }
  }

  // ============================================
  // ANALYTICS UPDATE SCHEDULING
  // ============================================

  static DateTime? _lastAnalyticsUpdate;
  static Timer? _analyticsTimer;
  static int _pendingUpdates = 0;

  Future<void> _scheduleAnalyticsUpdate({bool forceImmediate = false}) async {
    _analyticsTimer?.cancel();
    _pendingUpdates++;

    final delay = forceImmediate ? Duration(seconds: 2) : Duration(seconds: 30);

    _analyticsTimer = Timer(delay, () async {
      final now = DateTime.now();

      final shouldUpdate =
          _lastAnalyticsUpdate == null ||
          now.difference(_lastAnalyticsUpdate!).inMinutes > 2 ||
          _pendingUpdates >= 5;

      if (shouldUpdate) {
        try {
          print('🔄 Updating analytics summary (pending: $_pendingUpdates)...');
          await AnalyticsProcessingService.updateAnalyticsSummary();
          _lastAnalyticsUpdate = now;
          _pendingUpdates = 0;
          print('✅ Analytics summary updated at ${now.toIso8601String()}');
        } catch (e) {
          print('❌ Failed to update analytics summary: $e');
          _scheduleRetry();
        }
      } else {
        print(
          '⏭️ Analytics update skipped (updated ${now.difference(_lastAnalyticsUpdate!).inMinutes} min ago)',
        );
      }
    });
  }

  static void _scheduleRetry() {
    Timer(Duration(minutes: 1), () async {
      if (_pendingUpdates > 0) {
        try {
          print('🔄 Retrying analytics update...');
          await AnalyticsProcessingService.updateAnalyticsSummary();
          _lastAnalyticsUpdate = DateTime.now();
          _pendingUpdates = 0;
          print('✅ Analytics retry successful');
        } catch (e) {
          print('❌ Analytics retry failed: $e');
        }
      }
    });
  }

  static Future<void> forceAnalyticsUpdate() async {
    _analyticsTimer?.cancel();
    _pendingUpdates = 0;

    try {
      print('⚡ Force updating analytics...');
      await AnalyticsProcessingService.updateAnalyticsSummary();
      _lastAnalyticsUpdate = DateTime.now();
      print('✅ Force update completed');
    } catch (e) {
      print('❌ Force update failed: $e');
      rethrow;
    }
  }

  // ============================================
  // OTHER SAVE METHODS
  // ============================================

  Future<bool> saveToUserDemographic() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final userDoc = await firestore.collection('user').doc(uid).get();
      final isReturningUser = userDoc.data()?['isReturningUser'] ?? false;

      if (isReturningUser) {
        print(
          '⚠️ Returning user - demographic data will not affect total count',
        );
      }

      await firestore.collection('userDemographic').doc(uid).set({
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

      print('✅ User demographic saved to Firestore: $uid');
      await _scheduleAnalyticsUpdate();
      return true;
    } catch (e) {
      print('❌ Error saving to Firestore: $e');
      return false;
    }
  }

  Future<bool> saveToUser() async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(uid).set({
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

  Future<bool> saveToProfiles() async {
    try {
      computeAgeRange();

      String? finalCustomGender =
          (genderIdentity == 'Other') ? customGender : null;

      await FirebaseFirestore.instance.collection('profiles').doc(uid).set({
        'generatedUIC': generatedUIC,
        'ageRange': ageRange,
        'location': {'city': city, 'barangay': barangay},
        'genderIdentity': genderIdentity,
        'customGender': finalCustomGender,
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
          roleData = {'org': null, 'contactInfo': null, 'isValidated': false};
        }

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

  // ============================================
  // SERIALIZATION (Keep existing methods)
  // ============================================

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'philhealthNumber': philhealthNumber,
    'firstName': firstName,
    'middleName': middleName,
    'lastName': lastName,
    'suffix': suffix,
    'motherFirstName': motherFirstName,
    'fatherFirstName': fatherFirstName,
    'birthOrder': birthOrder,
    'birthDate': birthDate?.toIso8601String(),
    'currentCity': currentCity,
    'currentProvince': currentProvince,
    'permanentCity': permanentCity,
    'permanentProvince': permanentProvince,
    'birthCity': birthCity,
    'birthProvince': birthProvince,
    'generatedUIC': generatedUIC,
    'sexAssignedAtBirth': sexAssignedAtBirth,
    'ageRange': ageRange,
    'genderIdentity': genderIdentity,
    'customGender': customGender,
    'nationality': nationality,
    'otherNationality': otherNationality,
    'educationLevel': educationLevel,
    'civilStatus': civilStatus,
    'isStudying': isStudying,
    'livingWithPartner': livingWithPartner,
    'isPregnant': isPregnant,
    'numberOfChildren': numberOfChildren,
    'motherHadHIV': motherHadHIV,
    'diagnosedSTI': diagnosedSTI,
    'hasTuberculosis': hasTuberculosis,
    'hasHepatitisB': hasHepatitisB,
    'hasHepatitisC': hasHepatitisC,
    'isOFW': isOFW,
    'city': city,
    'barangay': barangay,
    'userType': userType,
    'yearDiagnosed': yearDiagnosed,
    'treatmentHub': treatmentHub,
  };

  factory RegistrationData.fromJson(Map<String, dynamic> json) =>
      RegistrationData(
        uid: json['uid'],
        philhealthNumber: json['philhealthNumber'],
        firstName: json['firstName'],
        middleName: json['middleName'],
        lastName: json['lastName'],
        suffix: json['suffix'],
        motherFirstName: json['motherFirstName'],
        fatherFirstName: json['fatherFirstName'],
        birthOrder: json['birthOrder'],
        birthDate:
            json['birthDate'] != null
                ? DateTime.parse(json['birthDate'])
                : null,
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
        hasTuberculosis: json['hasTuberculosis'],
        isOFW: json['isOFW'],
        city: json['city'],
        barangay: json['barangay'],
        userType: json['userType'],
        yearDiagnosed: json['yearDiagnosed'],
        treatmentHub: json['treatmentHub'],
      );
}
