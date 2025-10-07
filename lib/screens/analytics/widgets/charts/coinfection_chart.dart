import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/screens/analytics/widgets/charts/demographics_charts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CoinfectionChart extends StatelessWidget {
  final Map<String, int> coinfections;

  const CoinfectionChart({Key? key, required this.coinfections})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final coinfectionData =
        coinfections.entries
            .where((e) => e.value > 0)
            .map((e) => ChartData(e.key, e.value.toDouble()))
            .toList();

    if (coinfectionData.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      height: 250,
      padding: EdgeInsets.all(20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 20),
          Expanded(child: _buildChart(coinfectionData)),
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

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.health_and_safety_outlined,
          color: Color(0xFF9C27B0),
          size: 20,
        ),
        SizedBox(width: 8),
        Text(
          'Co-infections',
          style: GoogleFonts.workSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1E21),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<ChartData> coinfectionData) {
    final maxValue =
        coinfectionData.isNotEmpty
            ? coinfectionData
                    .map((e) => e.value)
                    .reduce((a, b) => a > b ? a : b) +
                10
            : 100.0;

    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,
        textStyle: GoogleFonts.workSans(fontSize: 10),
      ),
      series: <CircularSeries>[
        RadialBarSeries<ChartData, String>(
          dataSource: coinfectionData,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: GoogleFonts.workSans(fontSize: 9),
          ),
          enableTooltip: true,
          maximumValue: maxValue,
          trackColor: Color(0xFFF0F2F5),
          cornerStyle: CornerStyle.bothCurve,
        ),
      ],
    );
  }
}
