import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecho/screens/analytics/components/services/analytics_processing_service.dart';

class RegistrationData {
  // ... (keep all your existing fields)
  String uid;
  String? motherFirstName;
  String? fatherFirstName;
  int? birthOrder;
  DateTime? birthDate;
  String? generatedUIC;
  String? sexAssignedAtBirth;
  String? ageRange;
  String? genderIdentity;
  String? nationality;
  List<String> hivRelation = [];
  String? educationLevel;
  String? civilStatus;
  bool? isStudying;
  bool? livingWithPartner;
  bool? isPregnant;
  bool? motherHadHIV;
  bool? diagnosedSTI;
  bool? hasHepatitis;
  bool? hasTuberculosis;
  String? unprotectedSexWith;
  bool? isOFW;
  String? city;
  String? barangay;
  String? userType;
  int? yearDiagnosed;
  String? treatmentHub;

  RegistrationData({
    required this.uid,
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

  // ... (keep all your existing methods: computeAgeRange, role, isMSM, etc.)

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

  Map<String, dynamic> toFirestore() {
    computeAgeRange();

    Map<String, dynamic> data = {
      'role': role,
      'userType': userType,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'isActive': true,
      'generatedUIC': generatedUIC,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'ageRange': ageRange,
      'sexAssignedAtBirth': sexAssignedAtBirth,
      'genderIdentity': genderIdentity,
      'nationality': nationality,
      'educationLevel': educationLevel,
      'civilStatus': civilStatus,
      'isStudying': isStudying ?? false,
      'livingWithPartner': livingWithPartner ?? false,
      'isPregnant': isPregnant ?? false,
      'motherHadHIV': motherHadHIV ?? false,
      'diagnosedSTI': diagnosedSTI ?? false,
      'hasHepatitis': hasHepatitis ?? false,
      'hasTuberculosis': hasTuberculosis ?? false,
      'unprotectedSexWith': unprotectedSexWith,
      'city': city,
      'barangay': barangay,
      'isOFW': isOFW ?? false,
      'isMSM': isMSM,
      'isMSW': isMSW,
      'isWSW': isWSW,
      'hasMultiplePartnerRisk': hasMultiplePartnerRisk,
      'isYouth': isYouth,
    };

    if (userType == 'PLHIV') {
      data.addAll({
        'yearDiagnosed': yearDiagnosed,
        'treatmentHub': treatmentHub,
      });
    }

    return data;
  }

  // ============================================
  // IMPROVED: Save to analytic data with deletion check
  // ============================================
  Future<bool> saveToAnalyticData() async {
    try {
      computeAgeRange();

      final firestore = FirebaseFirestore.instance;

      // ✅ CHECK: Is this a returning deleted user?
      final userDoc = await firestore.collection('user').doc(uid).get();
      final isReturningUser = userDoc.data()?['isReturningUser'] ?? false;
      final doNotCount = userDoc.data()?['doNotCountInAnalytics'] ?? false;

      if (isReturningUser) {
        print('⚠️ Returning deleted user detected - marking as do not count');
      }

      // Save to analyticData
      await firestore
          .collection('analyticData')
          .doc(uid)
          .set(toFirestore(), SetOptions(merge: true));

      print('✅ Analytics data saved for user: $uid');

      // ✅ Schedule analytics update (debounced)
      await _scheduleAnalyticsUpdate(forceImmediate: !doNotCount);

      return true;
    } catch (e) {
      print('❌ Error saving analytics data: $e');
      return false;
    }
  }

  // ============================================
  // IMPROVED: Debounced analytics update with deletion awareness
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

      // Update if:
      // 1. Never updated before, OR
      // 2. More than 2 minutes since last update, OR
      // 3. Multiple pending updates (batch efficiency)
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
          // Retry after 1 minute on failure
          _scheduleRetry();
        }
      } else {
        print(
          '⏭️ Analytics update skipped (updated ${now.difference(_lastAnalyticsUpdate!).inMinutes} min ago)',
        );
      }
    });
  }

  // Retry logic for failed updates
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

  // ============================================
  // Force immediate analytics update (for testing/admin)
  // ============================================
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
  // IMPROVED: Save to userDemographic with deletion check
  // ============================================
  Future<bool> saveToUserDemographic() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Check if returning user
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

      // Schedule analytics update
      await _scheduleAnalyticsUpdate();

      return true;
    } catch (e) {
      print('❌ Error saving to Firestore: $e');
      return false;
    }
  }

  // Keep all your other methods unchanged
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

  // Keep your existing toJson, fromJson, fromFirestore, copyWith methods
  Map<String, dynamic> toJson() => {
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

  factory RegistrationData.fromJson(Map<String, dynamic> json) =>
      RegistrationData(
        uid: json['uid'],
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

  factory RegistrationData.fromFirestore(
    Map<String, dynamic> data,
    String uid,
  ) => RegistrationData(
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
    String? treatmentHub,
  }) => RegistrationData(
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
