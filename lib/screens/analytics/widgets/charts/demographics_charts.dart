import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DemographicsCharts extends StatelessWidget {
  final Map<String, int> ageDistribution;
  final Map<String, int> genderBreakdown;

  const DemographicsCharts({
    Key? key,
    required this.ageDistribution,
    required this.genderBreakdown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildAgeChart()),
        SizedBox(width: 16),
        Expanded(child: _buildGenderChart()),
      ],
    );
  }

  Widget _buildAgeChart() {
    final ageData =
        ageDistribution.entries
            .map((e) => ChartData(e.key, e.value.toDouble()))
            .toList();

    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(
            'Age Distribution',
            Icons.pie_chart_outline,
            Color(0xFF9C27B0),
          ),
          SizedBox(height: 10),
          Expanded(
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: GoogleFonts.workSans(fontSize: 9),
              ),
              series: <CircularSeries>[
                DoughnutSeries<ChartData, String>(
                  dataSource: ageData,
                  xValueMapper: (ChartData data, _) => data.category,
                  yValueMapper: (ChartData data, _) => data.value,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: GoogleFonts.workSans(fontSize: 8),
                  ),
                  enableTooltip: true,
                  innerRadius: '60%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChart() {
    final genderData =
        genderBreakdown.entries
            .map((e) => ChartData(e.key, e.value.toDouble()))
            .toList();

    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(
            'Gender Distribution',
            Icons.donut_small,
            Color(0xFF42B883),
          ),
          SizedBox(height: 10),
          Expanded(
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: GoogleFonts.workSans(fontSize: 9),
              ),
              series: <CircularSeries>[
                PieSeries<ChartData, String>(
                  dataSource: genderData,
                  xValueMapper: (ChartData data, _) => data.category,
                  yValueMapper: (ChartData data, _) => data.value,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: GoogleFonts.workSans(fontSize: 8),
                  ),
                  enableTooltip: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildChartHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.workSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1E21),
          ),
        ),
      ],
    );
  }
}

class ChartData {
  final String category;
  final double value;
  ChartData(this.category, this.value);
}
