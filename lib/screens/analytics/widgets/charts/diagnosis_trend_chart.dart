import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DiagnosisTrendChart extends StatelessWidget {
  final Map<int, int> diagnosisTrend;
  final String timeRange;

  const DiagnosisTrendChart({
    Key? key,
    required this.diagnosisTrend,
    required this.timeRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData();

    if (chartData.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      height: 300,
      padding: EdgeInsets.all(20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 20),
          Expanded(child: _buildChart(chartData)),
        ],
      ),
    );
  }

  List<DiagnosisData> _prepareChartData() {
    return diagnosisTrend.entries
        .map((e) => DiagnosisData(e.key.toString(), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.year.compareTo(b.year));
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.trending_up, color: Color(0xFF1877F2), size: 20),
        SizedBox(width: 8),
        Text(
          'Diagnosis Trend',
          style: GoogleFonts.workSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1E21),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<DiagnosisData> chartData) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
        labelStyle: GoogleFonts.workSans(fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(width: 0.5, color: Color(0xFFDADDE1)),
        labelStyle: GoogleFonts.workSans(fontSize: 10),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<DiagnosisData, String>>[
        SplineAreaSeries<DiagnosisData, String>(
          dataSource: chartData,
          xValueMapper: (DiagnosisData data, _) => data.year,
          yValueMapper: (DiagnosisData data, _) => data.count,
          gradient: LinearGradient(
            colors: [
              Color(0xFF1877F2).withOpacity(0.3),
              Color(0xFF1877F2).withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderColor: Color(0xFF1877F2),
          borderWidth: 2,
          markerSettings: MarkerSettings(
            isVisible: true,
            color: Color(0xFF1877F2),
            borderColor: Colors.white,
            borderWidth: 2,
          ),
        ),
      ],
    );
  }
}

class DiagnosisData {
  final String year;
  final double count;
  DiagnosisData(this.year, this.count);
}
