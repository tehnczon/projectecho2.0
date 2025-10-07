import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projecho/main/registration_data.dart';

class AnalyticsHistoryService {
  static Future<void> generateDailySnapshot() async {
    final firestore = FirebaseFirestore.instance;
    final today = DateTime.now();
    final docId =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final analyticSnapshot = await firestore.collection('analyticData').get();

    final users =
        analyticSnapshot.docs
            .map((doc) => RegistrationData.fromFirestore(doc.data(), doc.id))
            .toList();

    // Initialize counters
    final Map<String, int> ageRangeCount = {};
    final Map<String, int> genderIdentityCount = {};
    final Map<String, int> nationalityCount = {};
    final Map<String, int> sexAtBirthCount = {};
    final Map<String, int> cityCount = {};
    final Map<String, int> barangayCount = {};
    final Map<String, int> educationLevelCount = {};
    final Map<String, int> civilStatusCount = {};
    final Map<bool, int> isStudyingCount = {true: 0, false: 0};
    final Map<bool, int> livingWithPartnerCount = {true: 0, false: 0};
    final Map<bool, int> isPregnantCount = {true: 0, false: 0};
    final Map<bool, int> motherHadHIVCount = {true: 0, false: 0};
    final Map<bool, int> diagnosedSTICount = {true: 0, false: 0};
    final Map<bool, int> hasHepatitisCount = {true: 0, false: 0};
    final Map<bool, int> hasTuberculosisCount = {true: 0, false: 0};
    final Map<bool, int> isOFWCount = {true: 0, false: 0};
    final Map<String, int> unprotectedSexWithCount = {};
    final Map<bool, int> hasMultiplePartnerRiskCount = {true: 0, false: 0};
    int msmCount = 0;
    int mswCount = 0;
    int wswCount = 0;
    int youthCount = 0;
    int plhivCount = 0;

    // Loop through users and compute counts
    for (var user in users) {
      // Demographics
      if (user.ageRange != null) {
        ageRangeCount[user.ageRange!] =
            (ageRangeCount[user.ageRange!] ?? 0) + 1;
      }
      if (user.genderIdentity != null) {
        genderIdentityCount[user.genderIdentity!] =
            (genderIdentityCount[user.genderIdentity!] ?? 0) + 1;
      }
      if (user.nationality != null) {
        nationalityCount[user.nationality!] =
            (nationalityCount[user.nationality!] ?? 0) + 1;
      }
      if (user.sexAssignedAtBirth != null) {
        sexAtBirthCount[user.sexAssignedAtBirth!] =
            (sexAtBirthCount[user.sexAssignedAtBirth!] ?? 0) + 1;
      }
      if (user.city != null) {
        cityCount[user.city!] = (cityCount[user.city!] ?? 0) + 1;
      }
      if (user.barangay != null) {
        barangayCount[user.barangay!] =
            (barangayCount[user.barangay!] ?? 0) + 1;
      }
      if (user.educationLevel != null) {
        educationLevelCount[user.educationLevel!] =
            (educationLevelCount[user.educationLevel!] ?? 0) + 1;
      }
      if (user.civilStatus != null) {
        civilStatusCount[user.civilStatus!] =
            (civilStatusCount[user.civilStatus!] ?? 0) + 1;
      }

      // Booleans
      isStudyingCount[user.isStudying ?? false] =
          (isStudyingCount[user.isStudying ?? false] ?? 0) + 1;
      livingWithPartnerCount[user.livingWithPartner ?? false] =
          (livingWithPartnerCount[user.livingWithPartner ?? false] ?? 0) + 1;
      isPregnantCount[user.isPregnant ?? false] =
          (isPregnantCount[user.isPregnant ?? false] ?? 0) + 1;
      motherHadHIVCount[user.motherHadHIV ?? false] =
          (motherHadHIVCount[user.motherHadHIV ?? false] ?? 0) + 1;
      diagnosedSTICount[user.diagnosedSTI ?? false] =
          (diagnosedSTICount[user.diagnosedSTI ?? false] ?? 0) + 1;
      hasHepatitisCount[user.hasHepatitis ?? false] =
          (hasHepatitisCount[user.hasHepatitis ?? false] ?? 0) + 1;
      hasTuberculosisCount[user.hasTuberculosis ?? false] =
          (hasTuberculosisCount[user.hasTuberculosis ?? false] ?? 0) + 1;
      isOFWCount[user.isOFW ?? false] =
          (isOFWCount[user.isOFW ?? false] ?? 0) + 1;

      // Sexual Health & Analytics
      unprotectedSexWithCount[user.unprotectedSexWith ?? 'Unknown'] =
          (unprotectedSexWithCount[user.unprotectedSexWith ?? 'Unknown'] ?? 0) +
          1;
      hasMultiplePartnerRiskCount[user.hasMultiplePartnerRisk] =
          (hasMultiplePartnerRiskCount[user.hasMultiplePartnerRisk] ?? 0) + 1;
      if (user.isMSM) msmCount++;
      if (user.isMSW) mswCount++;
      if (user.isWSW) wswCount++;
      if (user.isYouth) youthCount++;
      if (user.userType == 'PLHIV') plhivCount++;
    }

    // Save snapshot
    await firestore.collection('analyticsHistory').doc(docId).set({
      'totalUsers': users.length,
      'msmCount': msmCount,
      'mswCount': mswCount,
      'wswCount': wswCount,
      'youthCount': youthCount,
      'plhivCount': plhivCount,
      'lastUpdated': FieldValue.serverTimestamp(),
      'ageRangeCount': ageRangeCount,
      'genderIdentityCount': genderIdentityCount,
      'nationalityCount': nationalityCount,
      'sexAtBirthCount': sexAtBirthCount,
      'cityCount': cityCount,
      'barangayCount': barangayCount,
      'educationLevelCount': educationLevelCount,
      'civilStatusCount': civilStatusCount,
      'isStudyingCount': isStudyingCount,
      'livingWithPartnerCount': livingWithPartnerCount,
      'isPregnantCount': isPregnantCount,
      'motherHadHIVCount': motherHadHIVCount,
      'diagnosedSTICount': diagnosedSTICount,
      'hasHepatitisCount': hasHepatitisCount,
      'hasTuberculosisCount': hasTuberculosisCount,
      'isOFWCount': isOFWCount,
      'unprotectedSexWithCount': unprotectedSexWithCount,
      'hasMultiplePartnerRiskCount': hasMultiplePartnerRiskCount,
      'users': users.map((u) => u.toJson()).toList(), // optional full snapshot
    }, SetOptions(merge: true));

    print('✅ Analytics history snapshot saved for $docId');
  }
}
