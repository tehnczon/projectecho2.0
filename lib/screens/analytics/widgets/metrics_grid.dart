import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projecho/screens/analytics/components/models/analytics_data.dart';

class MetricsGrid extends StatelessWidget {
  final AnalyticsData data;

  const MetricsGrid({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final metrics = _buildMetricsList();

    return Container(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemCount: metrics.length,
        itemBuilder: (context, index) => MetricCard(metric: metrics[index]),
      ),
    );
  }

  List<MetricData> _buildMetricsList() {
    return [
      MetricData(
        title: 'Total PLHIV',
        value: data.totalPLHIV.toString(),
        change: '+12%',
        icon: Icons.people_outline,
        color: Color(0xFF1877F2),
      ),
      MetricData(
        title: 'MSM Count',
        value: data.msmCount.toString(),
        percentage:
            data.totalPLHIV > 0
                ? '${((data.msmCount / data.totalPLHIV) * 100).toStringAsFixed(1)}%'
                : '0%',
        icon: Icons.trending_up,
        color: Color(0xFF42B883),
      ),
      MetricData(
        title: 'Youth (18-24)',
        value: data.youthCount.toString(),
        percentage:
            data.totalPLHIV > 0
                ? '${((data.youthCount / data.totalPLHIV) * 100).toStringAsFixed(1)}%'
                : '0%',
        icon: Icons.person_outline,
        color: Color(0xFF9C27B0),
      ),
      MetricData(
        title: 'Avg Years Since Diagnosis',
        value: data.avgYearsSinceDiagnosis.toStringAsFixed(1),
        subtitle: 'years',
        icon: Icons.schedule,
        color: Color(0xFFFFA726),
      ),
    ];
  }
}

class MetricCard extends StatelessWidget {
  final MetricData metric;

  const MetricCard({Key? key, required this.metric}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildHeader(), _buildContent()],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: metric.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(metric.icon, color: metric.color, size: 20),
        ),
        if (metric.change != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Color(0xFF42B883).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              metric.change!,
              style: GoogleFonts.workSans(
                fontSize: 10,
                color: Color(0xFF42B883),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          metric.value,
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1E21),
          ),
        ),
        if (metric.percentage != null)
          Text(
            metric.percentage!,
            style: GoogleFonts.workSans(fontSize: 11, color: Color(0xFF65676B)),
          ),
        Text(
          metric.title,
          style: GoogleFonts.workSans(fontSize: 11, color: Color(0xFF65676B)),
        ),
      ],
    );
  }
}

class MetricData {
  final String title;
  final String value;
  final String? change;
  final String? percentage;
  final String? subtitle;
  final IconData icon;
  final Color color;

  MetricData({
    required this.title,
    required this.value,
    this.change,
    this.percentage,
    this.subtitle,
    required this.icon,
    required this.color,
  });
}
