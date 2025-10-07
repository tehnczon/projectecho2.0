import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/screens/analytics/widgets/charts/demographics_charts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RiskFactorChart extends StatelessWidget {
  final Map<String, int> riskFactors;

  const RiskFactorChart({Key? key, required this.riskFactors})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final riskData =
        riskFactors.entries
            .map((e) => ChartData(e.key, e.value.toDouble()))
            .toList();

    return Container(
      height: 300,
      padding: EdgeInsets.all(20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 20),
          Expanded(child: _buildChart(riskData)),
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
        Icon(Icons.warning_amber_outlined, color: Color(0xFFFFA726), size: 20),
        SizedBox(width: 8),
        Text(
          'Risk Factor Analysis',
          style: GoogleFonts.workSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1E21),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<ChartData> riskData) {
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
      series: <CartesianSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(
          dataSource: riskData,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          color: Color(0xFFFFA726),
          borderRadius: BorderRadius.circular(4),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: GoogleFonts.workSans(fontSize: 9),
          ),
        ),
      ],
    );
  }
}
