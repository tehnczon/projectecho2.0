class AnalyticsData {
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

  /// ✅ Safe conversion from Firestore
  factory AnalyticsData.fromFirestore(Map<String, dynamic> data) {
    return AnalyticsData(
      totalRespondents: (data['totalRespondents'] ?? 0) as int,
      totalPLHIV: (data['totalPLHIV'] ?? 0) as int,
      msmCount: (data['msmCount'] ?? 0) as int,
      youthCount: (data['youthCount'] ?? 0) as int,

      ageDistribution: _convertToIntMap(data['ageDistribution']),
      genderBreakdown: _convertToIntMap(data['genderBreakdown']),
      cityDistribution: _convertToIntMap(data['cityDistribution']),
      treatmentHubs: _convertToIntMap(data['treatmentHubs']),
      diagnosisTrend: _convertToIntIntMap(data['diagnosisTrend']),
      educationLevels: _convertToIntMap(data['educationLevels']),
      riskFactors: _convertToIntMap(data['riskFactors']),
      coinfections: _convertToIntMap(data['coinfections']),

      avgYearsSinceDiagnosis: (data['avgYearsSinceDiagnosis'] ?? 0).toDouble(),
      topMSMCities:
          (data['topMSMCities'] as List<dynamic>? ?? [])
              .map((e) => CityData.fromMap(Map<String, dynamic>.from(e)))
              .toList(),
      msmAgeBreakdown: _convertToIntMap(data['msmAgeBreakdown']),
    );
  }

  /// Helper to cast Map<String, dynamic> → Map<String, int>
  static Map<String, int> _convertToIntMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value.map((k, v) => MapEntry(k, (v as num).toInt()));
    }
    return {};
  }

  /// Helper to cast Map<String, dynamic> → Map<int, int>
  static Map<int, int> _convertToIntIntMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value.map(
        (k, v) => MapEntry(int.tryParse(k) ?? 0, (v as num).toInt()),
      );
    }
    return {};
  }
}

class CityData {
  final String city;
  final int count;
  final double percentage;
  CityData({required this.city, required this.count, required this.percentage});
  factory CityData.fromMap(Map<String, dynamic> map) {
    return CityData(
      city: map['city'] ?? '',
      count: (map['count'] as num?)?.toInt() ?? 0,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
