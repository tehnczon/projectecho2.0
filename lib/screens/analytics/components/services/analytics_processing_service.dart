import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AnalyticsProcessingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Process and update analytics summary (call this after saving individual data)
  static Future<void> updateAnalyticsSummary() async {
    try {
      // Call cloud function to process analytics
      await _functions.httpsCallable('processAnalytics').call();
    } catch (e) {
      print('Failed to update analytics summary: $e');
      // Fallback to client-side processing for development
      await _processAnalyticsClientSide();
    }
  }

  // Client-side processing (for development/fallback)
  static Future<void> _processAnalyticsClientSide() async {
    try {
      // Get all users from users collection
      final usersSnapshot = await _firestore.collection('user').get();
      final allUsers = usersSnapshot.docs.map((doc) => doc.data()).toList();
      final totalUsers = allUsers.length;

      // Count user types from users collection
      int plhivCountFromUsers = 0;
      int infoSeekerCountFromUsers = 0;
      int researcherCountFromUsers = 0;
      Map<String, int> userRoleDistribution = {};

      for (var user in allUsers) {
        String role = (user['role'] ?? 'Unknown').toString().toLowerCase();

        // Count by role
        String roleKey = user['role'] ?? 'Unknown';
        userRoleDistribution[roleKey] =
            (userRoleDistribution[roleKey] ?? 0) + 1;

        if (role == 'plhiv') {
          plhivCountFromUsers++;
        } else if (role == 'infoseeker' ||
            role == 'health information seeker') {
          infoSeekerCountFromUsers++;
        } else if (role == 'researcher') {
          researcherCountFromUsers++;
        }
      }

      // Get all analytic data records
      final snapshot = await _firestore.collection('analyticData').get();
      final records = snapshot.docs.map((doc) => doc.data()).toList();

      if (records.isEmpty) {
        // Even if no analytics data, save total users count
        await _firestore.collection('analytics_summary').doc('current').set({
          'totalUsers': totalUsers,
          'totalPLHIV': plhivCountFromUsers,
          'totalInfoSeekers': infoSeekerCountFromUsers,
          'totalResearchers': researcherCountFromUsers,
          'userRoleDistribution': userRoleDistribution,
          'totalRecords': 0,
          'lastUpdated': FieldValue.serverTimestamp(),
          'message': 'No analytics data available yet',
        }, SetOptions(merge: true));
        return;
      }

      // Process the data (pass user counts)
      final summary = _calculateSummary(
        records,
        totalUsers,
        plhivCountFromUsers,
        infoSeekerCountFromUsers,
        researcherCountFromUsers,
        userRoleDistribution,
      );

      // Save to analytics_summary collection
      await _firestore.collection('analytics_summary').doc('current').set({
        ...summary,
        'lastUpdated': FieldValue.serverTimestamp(),
        'totalRecords': records.length,
      }, SetOptions(merge: true));

      // Save to analytics_history for trend tracking
      await _firestore.collection('analytics_history').add({
        ...summary,
        'timestamp': FieldValue.serverTimestamp(),
        'totalRecords': records.length,
      });

      print('âœ… Analytics summary updated successfully');
      print(
        'ðŸ“Š Total Users: $totalUsers (PLHIV: $plhivCountFromUsers, InfoSeekers: $infoSeekerCountFromUsers, Researchers: $researcherCountFromUsers) | Analytics Records: ${records.length}',
      );
    } catch (e) {
      print('âŒ Error processing analytics: $e');
    }
  }

  static Map<String, dynamic> _calculateSummary(
    List<Map<String, dynamic>> records,
    int totalUsers, // From users collection
    int plhivCountFromUsers, // PLHIV count from users collection
    int infoSeekerCountFromUsers, // InfoSeeker count from users collection
    int researcherCountFromUsers, // Researcher count from users collection
    Map<String, int> userRoleDistribution, // All roles distribution
  ) {
    // Basic distributions
    Map<String, int> ageDistribution = {};
    Map<String, int> genderBreakdown = {};
    Map<String, int> cityDistribution = {};
    Map<String, Map<String, int>> barangayByCity = {};
    Map<String, int> educationLevels = {};
    Map<String, int> civilStatusDist = {};
    Map<String, int> treatmentHubs = {};
    Map<String, int> unprotectedSexTypes = {};
    Map<String, int> roles = {};
    Map<String, int> sexAtBirth = {};
    Map<String, int> coinfections = {};
    Map<String, int> riskFactors = {};

    // Counters (from analytics data only - for detailed breakdown)
    int analyticsRecordCount = records.length; // People with analytics data
    int plhivWithAnalytics = 0; // PLHIV who filled analytics
    int infoSeekerWithAnalytics = 0; // InfoSeekers who filled analytics
    int msmCount = 0;
    int mswCount = 0;
    int wswCount = 0;
    int ofwCount = 0;
    int studyingCount = 0;
    int youthCount = 0;
    int stiCount = 0;
    int hepatitisCount = 0;
    int tbCount = 0;
    int multiplePartnerRisk = 0;
    int pregnantCount = 0;
    int livingWithPartnerCount = 0;
    int activeCount = 0;

    // Cross-tabulation tracking
    Map<String, Map<String, dynamic>> crossTabData = {};

    // MSM by age groups
    Map<String, List<Map<String, dynamic>>> msmByAge = {};
    Map<String, List<Map<String, dynamic>>> mswByAge = {};
    Map<String, List<Map<String, dynamic>>> wswByAge = {};

    // City + Age + Risk behavior
    Map<String, Map<String, List<Map<String, dynamic>>>> cityAgeUsers = {};

    // Gender + Health
    Map<String, List<Map<String, dynamic>>> genderUsers = {};

    // Education + Risk
    Map<String, List<Map<String, dynamic>>> educationUsers = {};

    for (var record in records) {
      // --- User Type Classification (from analytics data for cross-referencing)
      String userType = record['userType'] ?? record['role'] ?? 'Unknown';
      String userTypeLower = userType.toLowerCase();

      if (userTypeLower == 'plhiv') {
        plhivWithAnalytics++;
      } else if (userTypeLower == 'health information seeker' ||
          userTypeLower == 'infoseeker') {
        infoSeekerWithAnalytics++;
      }

      // --- Age distribution
      String ageRange = record['ageRange'] ?? 'Unknown';
      ageDistribution[ageRange] = (ageDistribution[ageRange] ?? 0) + 1;
      if (ageRange == '18-24') youthCount++;

      // --- Gender identity
      String gender = record['genderIdentity'] ?? 'Unknown';
      genderBreakdown[gender] = (genderBreakdown[gender] ?? 0) + 1;

      // Track for cross-tab
      if (!genderUsers.containsKey(gender)) {
        genderUsers[gender] = [];
      }
      genderUsers[gender]!.add(record);

      // --- Sex assigned at birth
      String sab = record['sexAssignedAtBirth'] ?? 'Unknown';
      sexAtBirth[sab] = (sexAtBirth[sab] ?? 0) + 1;

      // --- City and Barangay distribution
      String city = record['city'] ?? record['location']?['city'] ?? 'Unknown';
      String barangay =
          record['barangay'] ?? record['location']?['barangay'] ?? 'Unknown';

      cityDistribution[city] = (cityDistribution[city] ?? 0) + 1;

      if (!barangayByCity.containsKey(city)) {
        barangayByCity[city] = {};
      }
      barangayByCity[city]![barangay] =
          (barangayByCity[city]![barangay] ?? 0) + 1;

      // Track city-age combinations
      if (!cityAgeUsers.containsKey(city)) {
        cityAgeUsers[city] = {};
      }
      if (!cityAgeUsers[city]!.containsKey(ageRange)) {
        cityAgeUsers[city]![ageRange] = [];
      }
      cityAgeUsers[city]![ageRange]!.add(record);

      // --- Education levels
      String education = record['educationLevel'] ?? 'Unknown';
      educationLevels[education] = (educationLevels[education] ?? 0) + 1;

      // Track for cross-tab
      if (!educationUsers.containsKey(education)) {
        educationUsers[education] = [];
      }
      educationUsers[education]!.add(record);

      // --- Civil status
      String civilStatus = record['civilStatus'] ?? 'Unknown';
      civilStatusDist[civilStatus] = (civilStatusDist[civilStatus] ?? 0) + 1;

      // --- Treatment hub (for PLHIV)
      String hub = record['treatmentHub'] ?? 'N/A';
      if (hub != 'N/A') {
        treatmentHubs[hub] = (treatmentHubs[hub] ?? 0) + 1;
      }

      // --- Unprotected sex type
      String unprotected = record['unprotectedSexWith'] ?? 'Unknown';
      unprotectedSexTypes[unprotected] =
          (unprotectedSexTypes[unprotected] ?? 0) + 1;

      // --- Role / user type
      String role = record['role'] ?? 'Unknown';
      roles[role] = (roles[role] ?? 0) + 1;

      // --- Sexual behavior flags
      bool isMSM = record['isMSM'] == true;
      bool isMSW = record['isMSW'] == true;
      bool isWSW = record['isWSW'] == true;

      if (isMSM) {
        msmCount++;
        if (!msmByAge.containsKey(ageRange)) {
          msmByAge[ageRange] = [];
        }
        msmByAge[ageRange]!.add(record);
      }
      if (isMSW) {
        mswCount++;
        if (!mswByAge.containsKey(ageRange)) {
          mswByAge[ageRange] = [];
        }
        mswByAge[ageRange]!.add(record);
      }
      if (isWSW) {
        wswCount++;
        if (!wswByAge.containsKey(ageRange)) {
          wswByAge[ageRange] = [];
        }
        wswByAge[ageRange]!.add(record);
      }

      // --- Other flags
      if (record['isOFW'] == true) ofwCount++;
      if (record['isStudying'] == true) studyingCount++;
      if (record['isPregnant'] == true) pregnantCount++;
      if (record['livingWithPartner'] == true) livingWithPartnerCount++;
      if (record['isActive'] == true) activeCount++;

      // --- Health conditions
      bool hasSTI = record['diagnosedSTI'] == true;
      if (hasSTI) {
        stiCount++;
        coinfections['STI'] = (coinfections['STI'] ?? 0) + 1;
      }
      if (record['hasHepatitis'] == true) {
        hepatitisCount++;
        coinfections['Hepatitis'] = (coinfections['Hepatitis'] ?? 0) + 1;
      }
      if (record['hasTuberculosis'] == true) {
        tbCount++;
        coinfections['Tuberculosis'] = (coinfections['Tuberculosis'] ?? 0) + 1;
      }

      // --- Risk factors
      if (record['hasMultiplePartnerRisk'] == true) {
        multiplePartnerRisk++;
        riskFactors['Multiple Partners'] =
            (riskFactors['Multiple Partners'] ?? 0) + 1;
      }
      if (record['motherHadHIV'] == true) {
        riskFactors['Mother had HIV'] =
            (riskFactors['Mother had HIV'] ?? 0) + 1;
      }
      if (unprotected != 'Never' && unprotected != 'Unknown') {
        riskFactors['Unprotected Sex'] =
            (riskFactors['Unprotected Sex'] ?? 0) + 1;
      }
    }

    // ============================================
    // CROSS-TABULATION ANALYSIS
    // ============================================

    // 1. MSM users aged 18-24 with STI
    final msm1824 = msmByAge['18-24'] ?? [];
    final msm1824STI = msm1824.where((r) => r['diagnosedSTI'] == true).length;
    crossTabData['msm_18_24_sti'] = {
      'total': msm1824.length,
      'positive': msm1824STI,
      'percentage':
          msm1824.isNotEmpty
              ? (msm1824STI / msm1824.length * 100).toStringAsFixed(1)
              : '0.0',
    };

    // 2. Gender Ã— STI diagnosis
    Map<String, dynamic> genderSTI = {};
    genderUsers.forEach((gender, users) {
      final withSTI = users.where((r) => r['diagnosedSTI'] == true).length;
      genderSTI[gender] = {
        'total': users.length,
        'positive': withSTI,
        'percentage':
            users.isNotEmpty
                ? (withSTI / users.length * 100).toStringAsFixed(1)
                : '0.0',
      };
    });
    crossTabData['gender_sti'] = genderSTI;

    // 3. Education Ã— Risk Factors
    Map<String, dynamic> educationRisk = {};
    educationUsers.forEach((education, users) {
      final multiplePartners =
          users.where((r) => r['hasMultiplePartnerRisk'] == true).length;
      final unprotected =
          users
              .where(
                (r) =>
                    r['unprotectedSexWith'] != null &&
                    r['unprotectedSexWith'] != 'Never' &&
                    r['unprotectedSexWith'] != 'Prefer not to say',
              )
              .length;

      educationRisk[education] = {
        'total': users.length,
        'multiplePartners': multiplePartners,
        'unprotectedSex': unprotected,
        'multiplePartnersPercentage':
            users.isNotEmpty
                ? (multiplePartners / users.length * 100).toStringAsFixed(1)
                : '0.0',
        'unprotectedSexPercentage':
            users.isNotEmpty
                ? (unprotected / users.length * 100).toStringAsFixed(1)
                : '0.0',
      };
    });
    crossTabData['education_risk'] = educationRisk;

    // 4. City Ã— Age Ã— High-risk behavior
    Map<String, dynamic> cityAgeRisk = {};
    cityAgeUsers.forEach((city, ageGroups) {
      cityAgeRisk[city] = {};
      ageGroups.forEach((age, users) {
        final unprotectedMultiple =
            users
                .where(
                  (r) =>
                      r['unprotectedSexWith'] == 'Both' ||
                      r['hasMultiplePartnerRisk'] == true,
                )
                .length;

        cityAgeRisk[city][age] = {
          'total': users.length,
          'unprotectedMultiple': unprotectedMultiple,
          'percentage':
              users.isNotEmpty
                  ? (unprotectedMultiple / users.length * 100).toStringAsFixed(
                    1,
                  )
                  : '0.0',
        };
      });
    });
    crossTabData['city_age_risk'] = cityAgeRisk;

    // 5. MSM vs MSW vs WSW health outcomes
    final msmAll = records.where((r) => r['isMSM'] == true).toList();
    final mswAll = records.where((r) => r['isMSW'] == true).toList();
    final wswAll = records.where((r) => r['isWSW'] == true).toList();

    Map<String, dynamic> sexualBehaviorHealth = {
      'MSM': {
        'count': msmAll.length,
        'stiCount': msmAll.where((r) => r['diagnosedSTI'] == true).length,
        'hepatitisCount': msmAll.where((r) => r['hasHepatitis'] == true).length,
        'stiRate':
            msmAll.isNotEmpty
                ? (msmAll.where((r) => r['diagnosedSTI'] == true).length /
                        msmAll.length *
                        100)
                    .toStringAsFixed(1)
                : '0.0',
        'hepatitisRate':
            msmAll.isNotEmpty
                ? (msmAll.where((r) => r['hasHepatitis'] == true).length /
                        msmAll.length *
                        100)
                    .toStringAsFixed(1)
                : '0.0',
      },
      'MSW': {
        'count': mswAll.length,
        'stiCount': mswAll.where((r) => r['diagnosedSTI'] == true).length,
        'hepatitisCount': mswAll.where((r) => r['hasHepatitis'] == true).length,
        'stiRate':
            mswAll.isNotEmpty
                ? (mswAll.where((r) => r['diagnosedSTI'] == true).length /
                        mswAll.length *
                        100)
                    .toStringAsFixed(1)
                : '0.0',
        'hepatitisRate':
            mswAll.isNotEmpty
                ? (mswAll.where((r) => r['hasHepatitis'] == true).length /
                        mswAll.length *
                        100)
                    .toStringAsFixed(1)
                : '0.0',
      },
      'WSW': {
        'count': wswAll.length,
        'stiCount': wswAll.where((r) => r['diagnosedSTI'] == true).length,
        'hepatitisCount': wswAll.where((r) => r['hasHepatitis'] == true).length,
        'stiRate':
            wswAll.isNotEmpty
                ? (wswAll.where((r) => r['diagnosedSTI'] == true).length /
                        wswAll.length *
                        100)
                    .toStringAsFixed(1)
                : '0.0',
        'hepatitisRate':
            wswAll.isNotEmpty
                ? (wswAll.where((r) => r['hasHepatitis'] == true).length /
                        wswAll.length *
                        100)
                    .toStringAsFixed(1)
                : '0.0',
      },
    };
    crossTabData['sexual_behavior_health'] = sexualBehaviorHealth;

    // 6. Civil Status Ã— Pregnancy
    Map<String, dynamic> civilStatusPregnancy = {};
    civilStatusDist.keys.forEach((status) {
      final statusUsers =
          records.where((r) => r['civilStatus'] == status).toList();
      final pregnantCount =
          statusUsers.where((r) => r['isPregnant'] == true).length;
      civilStatusPregnancy[status] = {
        'total': statusUsers.length,
        'pregnant': pregnantCount,
        'percentage':
            statusUsers.isNotEmpty
                ? (pregnantCount / statusUsers.length * 100).toStringAsFixed(1)
                : '0.0',
      };
    });
    crossTabData['civil_status_pregnancy'] = civilStatusPregnancy;

    // ============================================
    // PERCENTAGES (Based on TOTAL USERS from users collection)
    // ============================================
    Map<String, dynamic> percentages = {
      // User type percentages (from users collection)
      'plhivPercentage':
          totalUsers > 0
              ? (plhivCountFromUsers / totalUsers * 100).toStringAsFixed(1)
              : '0.0',
      'infoSeekerPercentage':
          totalUsers > 0
              ? (infoSeekerCountFromUsers / totalUsers * 100).toStringAsFixed(1)
              : '0.0',
      'researcherPercentage':
          totalUsers > 0
              ? (researcherCountFromUsers / totalUsers * 100).toStringAsFixed(1)
              : '0.0',

      // Analytics data percentages (from analytics records)
      'youthPercentage':
          analyticsRecordCount > 0
              ? (youthCount / analyticsRecordCount * 100).toStringAsFixed(1)
              : '0.0',
      'stiPercentage':
          analyticsRecordCount > 0
              ? (stiCount / analyticsRecordCount * 100).toStringAsFixed(1)
              : '0.0',
      'hepatitisPercentage':
          analyticsRecordCount > 0
              ? (hepatitisCount / analyticsRecordCount * 100).toStringAsFixed(1)
              : '0.0',
      'tbPercentage':
          analyticsRecordCount > 0
              ? (tbCount / analyticsRecordCount * 100).toStringAsFixed(1)
              : '0.0',
      'pregnantPercentage':
          analyticsRecordCount > 0
              ? (pregnantCount / analyticsRecordCount * 100).toStringAsFixed(1)
              : '0.0',
      'msmPercentage':
          analyticsRecordCount > 0
              ? (msmCount / analyticsRecordCount * 100).toStringAsFixed(1)
              : '0.0',
      'multiplePartnerRiskPercentage':
          analyticsRecordCount > 0
              ? (multiplePartnerRisk / analyticsRecordCount * 100)
                  .toStringAsFixed(1)
              : '0.0',
      'analyticsCompletionPercentage':
          totalUsers > 0
              ? (analyticsRecordCount / totalUsers * 100).toStringAsFixed(1)
              : '0.0',
    };

    return {
      // Overview - User counts from users collection
      'totalUsers': totalUsers, // From users collection
      'totalPLHIV': plhivCountFromUsers, // From users collection role field
      'totalInfoSeekers':
          infoSeekerCountFromUsers, // From users collection role field
      'totalResearchers':
          researcherCountFromUsers, // From users collection role field
      'userRoleDistribution':
          userRoleDistribution, // All roles from users collection
      // Analytics data tracking
      'totalWithAnalytics':
          analyticsRecordCount, // From analyticData collection
      'plhivWithAnalytics': plhivWithAnalytics, // PLHIV who completed analytics
      'infoSeekersWithAnalytics':
          infoSeekerWithAnalytics, // InfoSeekers who completed analytics
      'activeCount': activeCount,

      // Demographics
      'ageDistribution': ageDistribution,
      'genderBreakdown': genderBreakdown,
      'sexAtBirth': sexAtBirth,
      'cityDistribution': cityDistribution,
      'barangayDistribution': barangayByCity,
      'educationLevels': educationLevels,
      'civilStatusDistribution': civilStatusDist,

      // Health Status
      'healthConditions': {
        'stiCount': stiCount,
        'hepatitisCount': hepatitisCount,
        'tbCount': tbCount,
        'pregnantCount': pregnantCount,
      },

      // Risk Factors
      'riskFactorStats': {
        'msmCount': msmCount,
        'mswCount': mswCount,
        'wswCount': wswCount,
        'multiplePartnerRisk': multiplePartnerRisk,
        'youthCount': youthCount,
        'ofwCount': ofwCount,
      },

      // Additional Breakdowns
      'treatmentHubs': treatmentHubs,
      'unprotectedSexTypes': unprotectedSexTypes,
      'roles': roles,
      'coinfections': coinfections,
      'riskFactors': riskFactors,

      // Counts (for backward compatibility)
      'msmCount': msmCount,
      'mswCount': mswCount,
      'wswCount': wswCount,
      'ofwCount': ofwCount,
      'studyingCount': studyingCount,
      'pregnantCount': pregnantCount,
      'livingWithPartnerCount': livingWithPartnerCount,
      'youthCount': youthCount,
      'stiCount': stiCount,
      'hepatitisCount': hepatitisCount,
      'tbCount': tbCount,
      'multiplePartnerRisk': multiplePartnerRisk,

      // Cross-tabulation Data
      'crossTabs': crossTabData,

      // Percentages (now correctly based on total users!)
      'percentages': percentages,

      // Metadata
      'processedAt': DateTime.now().toIso8601String(),
    };
  }

  // Get analytics summary for dashboard
  static Future<Map<String, dynamic>?> getAnalyticsSummary() async {
    try {
      final doc =
          await _firestore.collection('analytics_summary').doc('current').get();

      // If no summary exists, try to generate one
      if (!doc.exists) {
        print('No analytics summary found, generating...');
        await _processAnalyticsClientSide();
        // Try to get it again
        final newDoc =
            await _firestore
                .collection('analytics_summary')
                .doc('current')
                .get();
        return newDoc.exists ? newDoc.data() : null;
      }

      return doc.data();
    } catch (e) {
      print('Error getting analytics summary: $e');
      return null;
    }
  }

  // Get analytics history for trends
  static Future<List<Map<String, dynamic>>> getAnalyticsHistory({
    int limit = 12,
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection('analytics_history')
              .orderBy('timestamp', descending: true)
              .limit(limit)
              .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print('Error getting analytics history: $e');
      return [];
    }
  }

  // Get filtered analytics (for dashboard filters)
  static Future<Map<String, dynamic>?> getFilteredAnalytics({
    String? riskFactor,
    String? ageGroup,
    String? location,
  }) async {
    try {
      // Get all users from users collection
      final usersSnapshot = await _firestore.collection('users').get();
      final allUsers = usersSnapshot.docs.map((doc) => doc.data()).toList();
      final totalUsers = allUsers.length;

      // Count user types from users collection
      int plhivCountFromUsers = 0;
      int infoSeekerCountFromUsers = 0;
      int researcherCountFromUsers = 0;
      Map<String, int> userRoleDistribution = {};

      for (var user in allUsers) {
        String role = (user['role'] ?? 'Unknown').toString().toLowerCase();

        String roleKey = user['role'] ?? 'Unknown';
        userRoleDistribution[roleKey] =
            (userRoleDistribution[roleKey] ?? 0) + 1;

        if (role == 'plhiv') {
          plhivCountFromUsers++;
        } else if (role == 'infoseeker' ||
            role == 'health information seeker') {
          infoSeekerCountFromUsers++;
        } else if (role == 'researcher') {
          researcherCountFromUsers++;
        }
      }

      Query query = _firestore.collection('analyticData');

      // Apply filters
      if (riskFactor != null && riskFactor != 'all') {
        switch (riskFactor.toLowerCase()) {
          case 'msm':
            query = query.where('isMSM', isEqualTo: true);
            break;
          case 'wsm':
            query = query.where('isMSW', isEqualTo: true);
            break;
          case 'multiple':
            query = query.where('hasMultiplePartnerRisk', isEqualTo: true);
            break;
        }
      }

      if (ageGroup != null && ageGroup != 'all') {
        query = query.where('ageRange', isEqualTo: ageGroup);
      }

      if (location != null && location != 'all') {
        query = query.where('city', isEqualTo: location);
      }

      final snapshot = await query.get();
      final records =
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

      if (records.isEmpty) {
        return null;
      }

      return _calculateSummary(
        records,
        totalUsers,
        plhivCountFromUsers,
        infoSeekerCountFromUsers,
        researcherCountFromUsers,
        userRoleDistribution,
      );
    } catch (e) {
      print('Error getting filtered analytics: $e');
      return null;
    }
  }

  // Query specific cross-tab data
  static Future<Map<String, dynamic>?> getCustomQuery({
    required String populationGroup, // "MSM", "WSM", "PLHIV"
    required String ageRange,
    required String healthOutcome, // "STI", "Hepatitis", "Risk Behavior"
  }) async {
    try {
      Query query = _firestore.collection('analyticData');

      // Apply population group filter
      switch (populationGroup.toUpperCase()) {
        case 'MSM':
          query = query.where('isMSM', isEqualTo: true);
          break;
        case 'WSM':
          query = query.where('isMSW', isEqualTo: true);
          break;
        case 'PLHIV':
          query = query.where('userType', isEqualTo: 'PLHIV');
          break;
      }

      // Apply age filter
      query = query.where('ageRange', isEqualTo: ageRange);

      final snapshot = await query.get();
      final users =
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

      if (users.isEmpty) {
        return {
          'total': 0,
          'outcome': 0,
          'percentage': '0.0',
          'message': 'No data available for this combination',
        };
      }

      int outcomeCount = 0;
      switch (healthOutcome) {
        case 'STI':
          outcomeCount = users.where((u) => u['diagnosedSTI'] == true).length;
          break;
        case 'Hepatitis':
          outcomeCount = users.where((u) => u['hasHepatitis'] == true).length;
          break;
        case 'Risk Behavior':
          outcomeCount =
              users
                  .where(
                    (u) =>
                        u['hasMultiplePartnerRisk'] == true ||
                        (u['unprotectedSexWith'] != 'Never' &&
                            u['unprotectedSexWith'] != null),
                  )
                  .length;
          break;
      }

      return {
        'populationGroup': populationGroup,
        'ageRange': ageRange,
        'healthOutcome': healthOutcome,
        'total': users.length,
        'outcome': outcomeCount,
        'percentage': (outcomeCount / users.length * 100).toStringAsFixed(1),
      };
    } catch (e) {
      print('Error executing custom query: $e');
      return null;
    }
  }
}
