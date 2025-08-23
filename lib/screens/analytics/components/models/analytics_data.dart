class AnalyticsData {
  // Core metrics
  final int totalRespondents;
  final int totalPLHIV;
  final int msmCount;
  final int youthCount; // 18-24
  final Map<String, int> ageDistribution;
  final Map<String, int> genderBreakdown;
  final Map<String, int> cityDistribution;
  final Map<String, int> treatmentHubs;
  final Map<int, int> diagnosisTrend;
  final Map<String, int> educationLevels;
  final Map<String, int> riskFactors;

  // Health metrics
  final Map<String, int> coinfections; // STI, TB, Hepatitis
  final double avgYearsSinceDiagnosis;

  // MSM specific
  final List<CityData> topMSMCities;
  final Map<String, int> msmAgeBreakdown;

  AnalyticsData({
    required this.totalRespondents,
    required this.totalPLHIV,
    required this.msmCount,
    required this.youthCount,
    required this.ageDistribution,
    required this.genderBreakdown,
    required this.cityDistribution,
    required this.treatmentHubs,
    required this.diagnosisTrend,
    required this.educationLevels,
    required this.riskFactors,
    required this.coinfections,
    required this.avgYearsSinceDiagnosis,
    required this.topMSMCities,
    required this.msmAgeBreakdown,
  });
}

class CityData {
  final String city;
  final int count;
  final double percentage;

  CityData({required this.city, required this.count, required this.percentage});
}

// lib/models/personal_insights.dart
class PersonalInsights {
  final String supportiveMessage;
  final String treatmentHub;
  final int yearDiagnosed;
  final String ageRange;
  final List<String> healthTips;
  final String nextSteps;

  PersonalInsights({
    required this.supportiveMessage,
    required this.treatmentHub,
    required this.yearDiagnosed,
    required this.ageRange,
    required this.healthTips,
    required this.nextSteps,
  });
}
