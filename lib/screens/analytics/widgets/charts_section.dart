import 'package:flutter/material.dart';
import 'package:projecho/screens/analytics/components/models/analytics_data.dart';
import 'package:projecho/screens/analytics/widgets/charts/diagnosis_trend_chart.dart';
import 'package:projecho/screens/analytics/widgets/charts/demographics_charts.dart';
import 'package:projecho/screens/analytics/widgets/charts/risk_factor_chart.dart';
import 'package:projecho/screens/analytics/widgets/charts/coinfection_chart.dart';

class ChartsSection extends StatelessWidget {
  final AnalyticsData data;
  final String timeRange;
  final String filter;

  const ChartsSection({
    Key? key,
    required this.data,
    required this.timeRange,
    required this.filter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          if (data.diagnosisTrend.isNotEmpty) ...[
            DiagnosisTrendChart(
              diagnosisTrend: data.diagnosisTrend,
              timeRange: timeRange,
            ),
            SizedBox(height: 16),
          ],
          DemographicsCharts(
            ageDistribution: data.ageDistribution,
            genderBreakdown: data.genderBreakdown,
          ),
          SizedBox(height: 16),
          if (data.riskFactors.isNotEmpty) ...[
            RiskFactorChart(riskFactors: data.riskFactors),
            SizedBox(height: 16),
          ],
          if (data.coinfections.isNotEmpty) ...[
            CoinfectionChart(coinfections: data.coinfections),
            SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
