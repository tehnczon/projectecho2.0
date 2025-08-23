// lib/screens/analytics/researcher_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './components/providers/enhanced_analytics_provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;

class ResearcherDashboard extends StatefulWidget {
  @override
  _ResearcherDashboardState createState() => _ResearcherDashboardState();
}

class _ResearcherDashboardState extends State<ResearcherDashboard> {
  late TooltipBehavior _tooltipBehavior;
  String _selectedTimeRange = '1 Year';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);

    // Fetch initial data
    Future.microtask(() {
      final provider = Provider.of<EnhancedAnalyticsProvider>(
        context,
        listen: false,
      );
      provider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5), // Match GeneralBasicDashboard
      body: Consumer<EnhancedAnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.errorMessage != null) {
            return _buildErrorState(provider.errorMessage!);
          }

          final data = provider.analyticsData;
          if (data == null) {
            return _buildEmptyState();
          }

          return CustomScrollView(
            slivers: [
              // Modern App Bar matching GeneralBasicDashboard style
              _buildThemedAppBar(provider),

              // Filter Controls
              SliverToBoxAdapter(child: _buildFilterControls()),

              // Welcome Card for Researchers
              SliverToBoxAdapter(child: _buildWelcomeCard()),

              // Key Metrics Cards
              SliverToBoxAdapter(child: _buildKeyMetricsGrid(data)),

              // Charts Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDiagnosisTrendChart(data),
                      SizedBox(height: 16),
                      _buildDemographicsCharts(data),
                      SizedBox(height: 16),
                      _buildRiskFactorAnalysis(data),
                      SizedBox(height: 16),
                      _buildCoinfectionChart(data),
                      SizedBox(height: 80), // Space for bottom navigation
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemedAppBar(EnhancedAnalyticsProvider provider) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1877F2).withOpacity(0.1), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF1877F2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        FontAwesomeIcons.chartLine,
                        color: Color(0xFF1877F2),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Research Analytics',
                            style: GoogleFonts.workSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1E21),
                            ),
                          ),
                          Text(
                            'Last updated: ${_formatLastUpdate(provider.lastUpdated)}',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: Color(0xFF65676B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.download_outlined, color: Color(0xFF65676B)),
          onPressed: () => _showExportOptions(context, provider),
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Color(0xFF65676B)),
          onPressed: () => provider.fetchData(),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF42B883), Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF42B883).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              FontAwesomeIcons.userDoctor,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Researcher!',
                  style: GoogleFonts.workSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Access comprehensive analytics to support your research and improve community health outcomes.',
                  style: GoogleFonts.workSans(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Time Range Filter
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTimeRange,
                  items:
                      ['1 Month', '3 Months', '6 Months', '1 Year', 'All Time']
                          .map(
                            (range) => DropdownMenuItem(
                              value: range,
                              child: Text(
                                range,
                                style: GoogleFonts.workSans(
                                  fontSize: 14,
                                  color: Color(0xFF1C1E21),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() => _selectedTimeRange = value!);
                    _applyFilters();
                  },
                  icon: Icon(
                    Icons.access_time,
                    color: Color(0xFF1877F2),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Category Filter
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  items:
                      ['All', 'MSM', 'Youth (18-24)', 'New Cases']
                          .map(
                            (filter) => DropdownMenuItem(
                              value: filter,
                              child: Text(
                                filter,
                                style: GoogleFonts.workSans(
                                  fontSize: 14,
                                  color: Color(0xFF1C1E21),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                    _applyFilters();
                  },
                  icon: Icon(
                    Icons.filter_list,
                    color: Color(0xFF9C27B0),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsGrid(analytics) {
    final metrics = [
      {
        'title': 'Total PLHIV',
        'value': analytics.totalPLHIV.toString(),
        'change': '+12%',
        'icon': Icons.people_outline,
        'color': Color(0xFF1877F2),
      },
      {
        'title': 'MSM Count',
        'value': analytics.msmCount.toString(),
        'percentage':
            '${((analytics.msmCount / analytics.totalPLHIV) * 100).toStringAsFixed(1)}%',
        'icon': Icons.trending_up,
        'color': Color(0xFF42B883),
      },
      {
        'title': 'Youth (18-24)',
        'value': analytics.youthCount.toString(),
        'percentage':
            '${((analytics.youthCount / analytics.totalPLHIV) * 100).toStringAsFixed(1)}%',
        'icon': Icons.person_outline,
        'color': Color(0xFF9C27B0),
      },
      {
        'title': 'Avg Years Since Diagnosis',
        'value': analytics.avgYearsSinceDiagnosis.toStringAsFixed(1),
        'subtitle': 'years',
        'icon': Icons.schedule,
        'color': Color(0xFFFFA726),
      },
    ];

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
        itemBuilder: (context, index) {
          final metric = metrics[index];
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (metric['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        metric['icon'] as IconData,
                        color: metric['color'] as Color,
                        size: 20,
                      ),
                    ),
                    if (metric.containsKey('change'))
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF42B883).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          metric['change'] as String,
                          style: GoogleFonts.workSans(
                            fontSize: 10,
                            color: Color(0xFF42B883),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric['value'] as String,
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1E21),
                      ),
                    ),
                    if (metric.containsKey('percentage'))
                      Text(
                        metric['percentage'] as String,
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          color: Color(0xFF65676B),
                        ),
                      ),
                    Text(
                      metric['title'] as String,
                      style: GoogleFonts.workSans(
                        fontSize: 11,
                        color: Color(0xFF65676B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiagnosisTrendChart(analytics) {
    // Prepare data for the chart
    List<DiagnosisData> chartData = [];
    analytics.diagnosisTrend.forEach((year, count) {
      chartData.add(DiagnosisData(year.toString(), count.toDouble()));
    });
    chartData.sort((a, b) => a.year.compareTo(b.year));

    return Container(
      height: 300,
      padding: EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ),
          SizedBox(height: 20),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
                labelStyle: GoogleFonts.workSans(fontSize: 10),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: Color(0xFFDADDE1),
                ),
                labelStyle: GoogleFonts.workSans(fontSize: 10),
              ),
              tooltipBehavior: _tooltipBehavior,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicsCharts(analytics) {
    // Age Distribution Data
    List<AgeData> ageData = [];
    analytics.ageDistribution.forEach((age, count) {
      ageData.add(AgeData(age, count.toDouble()));
    });

    // Gender Distribution Data
    List<GenderData> genderData = [];
    analytics.genderBreakdown.forEach((gender, count) {
      genderData.add(GenderData(gender, count.toDouble()));
    });

    return Row(
      children: [
        // Age Distribution
        Expanded(
          child: Container(
            height: 250,
            padding: EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      color: Color(0xFF9C27B0),
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Age Distribution',
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1E21),
                      ),
                    ),
                  ],
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
                      DoughnutSeries<AgeData, String>(
                        dataSource: ageData,
                        xValueMapper: (AgeData data, _) => data.age,
                        yValueMapper: (AgeData data, _) => data.count,
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
          ),
        ),
        SizedBox(width: 16),
        // Gender Distribution
        Expanded(
          child: Container(
            height: 250,
            padding: EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.donut_small, color: Color(0xFF42B883), size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Gender Distribution',
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1E21),
                      ),
                    ),
                  ],
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
                      PieSeries<GenderData, String>(
                        dataSource: genderData,
                        xValueMapper: (GenderData data, _) => data.gender,
                        yValueMapper: (GenderData data, _) => data.count,
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
          ),
        ),
      ],
    );
  }

  Widget _buildRiskFactorAnalysis(analytics) {
    List<RiskData> riskData = [];
    analytics.riskFactors.forEach((factor, count) {
      riskData.add(RiskData(factor, count.toDouble()));
    });

    return Container(
      height: 300,
      padding: EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: Color(0xFFFFA726),
                size: 20,
              ),
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
          ),
          SizedBox(height: 20),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
                labelStyle: GoogleFonts.workSans(fontSize: 10),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: Color(0xFFDADDE1),
                ),
                labelStyle: GoogleFonts.workSans(fontSize: 10),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries<RiskData, String>>[
                ColumnSeries<RiskData, String>(
                  dataSource: riskData,
                  xValueMapper: (RiskData data, _) => data.factor,
                  yValueMapper: (RiskData data, _) => data.count,
                  color: Color(0xFFFFA726),
                  borderRadius: BorderRadius.circular(4),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: GoogleFonts.workSans(fontSize: 9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinfectionChart(analytics) {
    List<CoinfectionData> coinfectionData = [];
    analytics.coinfections.forEach((type, count) {
      if (count > 0) {
        coinfectionData.add(CoinfectionData(type, count.toDouble()));
      }
    });

    return Container(
      height: 250,
      padding: EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ),
          SizedBox(height: 20),
          Expanded(
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.right,
                textStyle: GoogleFonts.workSans(fontSize: 10),
              ),
              series: <CircularSeries>[
                RadialBarSeries<CoinfectionData, String>(
                  dataSource: coinfectionData,
                  xValueMapper: (CoinfectionData data, _) => data.type,
                  yValueMapper: (CoinfectionData data, _) => data.count,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: GoogleFonts.workSans(fontSize: 9),
                  ),
                  enableTooltip: true,
                  maximumValue:
                      coinfectionData.isNotEmpty
                          ? coinfectionData
                                  .map((e) => e.count)
                                  .reduce((a, b) => a > b ? a : b) +
                              10
                          : 100,
                  trackColor: Color(0xFFF0F2F5),
                  cornerStyle: charts.CornerStyle.bothCurve,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _formatLastUpdate(DateTime? date) {
    if (date == null) return 'Never';
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  void _applyFilters() {
    final provider = Provider.of<EnhancedAnalyticsProvider>(
      context,
      listen: false,
    );
    provider.fetchData();
  }

  void _showExportOptions(
    BuildContext context,
    EnhancedAnalyticsProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color(0xFFDADDE1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Export Analytics',
                  style: GoogleFonts.workSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1E21),
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.picture_as_pdf, color: Colors.red),
                  ),
                  title: Text('Export as PDF', style: GoogleFonts.workSans()),
                  subtitle: Text(
                    'Comprehensive report',
                    style: GoogleFonts.workSans(fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await provider.exportToPDF();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('PDF exported successfully'),
                        backgroundColor: Color(0xFF42B883),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.table_chart, color: Colors.green),
                  ),
                  title: Text('Export as CSV', style: GoogleFonts.workSans()),
                  subtitle: Text(
                    'Raw data for analysis',
                    style: GoogleFonts.workSans(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    final csv = provider.exportToCSV();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('CSV exported successfully'),
                        backgroundColor: Color(0xFF42B883),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1877F2)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading analytics...',
            style: GoogleFonts.workSans(fontSize: 14, color: Color(0xFF65676B)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          ),
          SizedBox(height: 20),
          Text(
            'Error Loading Data',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1E21),
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.workSans(fontSize: 14, color: Color(0xFF65676B)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Provider.of<EnhancedAnalyticsProvider>(
                context,
                listen: false,
              ).fetchData();
            },
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1877F2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1877F2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Color(0xFF1877F2),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No Analytics Data',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1E21),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Data will appear here once available',
            style: GoogleFonts.workSans(fontSize: 14, color: Color(0xFF65676B)),
          ),
        ],
      ),
    );
  }
}

// Data Models for Charts
class DiagnosisData {
  final String year;
  final double count;
  DiagnosisData(this.year, this.count);
}

class AgeData {
  final String age;
  final double count;
  AgeData(this.age, this.count);
}

class GenderData {
  final String gender;
  final double count;
  GenderData(this.gender, this.count);
}

class RiskData {
  final String factor;
  final double count;
  RiskData(this.factor, this.count);
}

class CoinfectionData {
  final String type;
  final double count;
  CoinfectionData(this.type, this.count);
}
