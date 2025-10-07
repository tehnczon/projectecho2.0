import 'package:projecho/screens/analytics/widgets/charts/demographics_charts.dart';
import 'package:projecho/screens/analytics/widgets/charts/diagnosis_trend_chart.dart';

class ChartDataTransformer {
  static List<DiagnosisData> toDiagnosisData(Map<int, int> trend) {
    return trend.entries
        .map((e) => DiagnosisData(e.key.toString(), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.year.compareTo(b.year));
  }

  static List<ChartData> toChartData(Map<String, int> data) {
    return data.entries
        .map((e) => ChartData(e.key, e.value.toDouble()))
        .toList();
  }

  static Map<String, int> applyTimeFilter(
    Map<String, int> data,
    String timeRange,
  ) {
    // Implementation would depend on your data structure
    // For now, return original data
    return data;
  }

  static Map<String, int> applyCategoryFilter(
    Map<String, int> data,
    String filter,
  ) {
    if (filter == 'All') return data;

    // Apply specific filters based on category
    return data.entries
        .where((e) => _matchesFilter(e.key, filter))
        .fold<Map<String, int>>(
          {},
          (map, entry) => map..[entry.key] = entry.value,
        );
  }

  static bool _matchesFilter(String key, String filter) {
    switch (filter) {
      case 'MSM':
        return key.toLowerCase().contains('msm') ||
            key.toLowerCase().contains('men who have sex with men');
      case 'Youth (18-24)':
        return key.contains('18-24') || key.contains('youth');
      case 'High Risk':
        return key.toLowerCase().contains('high risk') ||
            key.toLowerCase().contains('substance') ||
            key.toLowerCase().contains('injection');
      default:
        return true;
    }
  }
}
