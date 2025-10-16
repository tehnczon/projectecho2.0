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
      // Get all analytic data records
      final snapshot = await _firestore.collection('analyticData').get();
      final records = snapshot.docs.map((doc) => doc.data()).toList();

      if (records.isEmpty) return;

      // Process the data
      final summary = _calculateSummary(records);

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
    } catch (e) {
      print('Error processing analytics: $e');
    }
  }

  static Map<String, dynamic> _calculateSummary(
    List<Map<String, dynamic>> records,
  ) {
    Map<String, int> ageDistribution = {};
    Map<String, int> genderBreakdown = {};
    Map<String, int> cityDistribution = {};
    Map<String, int> educationLevels = {};
    Map<String, int> civilStatusDist = {};
    Map<String, int> treatmentHubs = {};
    Map<String, int> unprotectedSexTypes = {};
    Map<String, int> roles = {};
    Map<String, int> sexAtBirth = {};
    Map<String, int> coinfections = {};
    Map<String, int> riskFactors = {};

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

    for (var record in records) {
      // --- Age distribution
      String ageRange = record['ageRange'] ?? 'Unknown';
      ageDistribution[ageRange] = (ageDistribution[ageRange] ?? 0) + 1;
      if (ageRange == '18-24') youthCount++;

      // --- Gender identity
      String gender = record['genderIdentity'] ?? 'Unknown';
      genderBreakdown[gender] = (genderBreakdown[gender] ?? 0) + 1;

      // --- Sex assigned at birth
      String sab = record['sexAssignedAtBirth'] ?? 'Unknown';
      sexAtBirth[sab] = (sexAtBirth[sab] ?? 0) + 1;

      // --- City distribution
      String city = record['city'] ?? record['location']?['city'] ?? 'Unknown';
      cityDistribution[city] = (cityDistribution[city] ?? 0) + 1;

      // --- Education levels
      String education =
          record['educationalLevel'] ?? record['educationLevel'] ?? 'Unknown';
      educationLevels[education] = (educationLevels[education] ?? 0) + 1;

      // --- Civil status
      String civilStatus = record['civilStatus'] ?? 'Unknown';
      civilStatusDist[civilStatus] = (civilStatusDist[civilStatus] ?? 0) + 1;

      // --- Treatment hub
      String hub = record['treatmentHub'] ?? 'Unknown';
      treatmentHubs[hub] = (treatmentHubs[hub] ?? 0) + 1;

      // --- Unprotected sex type
      String unprotected = record['unprotectedSexWith'] ?? 'Unknown';
      unprotectedSexTypes[unprotected] =
          (unprotectedSexTypes[unprotected] ?? 0) + 1;

      // --- Role / user type
      String role = record['role'] ?? record['userType'] ?? 'Unknown';
      roles[role] = (roles[role] ?? 0) + 1;

      // --- Flags and risk categories
      if (record['isMSM'] == true) msmCount++;
      if (record['isMSW'] == true) mswCount++;
      if (record['isWSW'] == true) wswCount++;
      if (record['isOFW'] == true) ofwCount++;
      if (record['isStudying'] == true) studyingCount++;
      if (record['isPregnant'] == true) pregnantCount++;
      if (record['livingWithPartner'] == true) livingWithPartnerCount++;
      if (record['isActive'] == true) activeCount++;

      // --- Coinfections
      bool hasSTI =
          record['diagnosedWithSTI'] == true || record['diagnosedSTI'] == true;
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
    }

    return {
      'totalPLHIV': records.length,
      'msmCount': msmCount,
      'mswCount': mswCount,
      'wswCount': wswCount,
      'ofwCount': ofwCount,
      'studyingCount': studyingCount,
      'pregnantCount': pregnantCount,
      'livingWithPartnerCount': livingWithPartnerCount,
      'activeCount': activeCount,
      'youthCount': youthCount,
      'ageDistribution': ageDistribution,
      'genderBreakdown': genderBreakdown,
      'sexAtBirth': sexAtBirth,
      'cityDistribution': cityDistribution,
      'educationLevels': educationLevels,
      'civilStatusDistribution': civilStatusDist,
      'treatmentHubs': treatmentHubs,
      'unprotectedSexTypes': unprotectedSexTypes,
      'roles': roles,
      'coinfections': coinfections,
      'riskFactors': riskFactors,
      'stiCount': stiCount,
      'hepatitisCount': hepatitisCount,
      'tbCount': tbCount,
      'multiplePartnerRisk': multiplePartnerRisk,
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
}
