// lib/screens/analytics/researcher_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './testing/providers/enhanced_analytics_provider.dart';
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
      backgroundColor: Color(0xFFF8F9FC),
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
              // Modern App Bar with Actions
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5E72E4), Color(0xFF825EE4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analytics Dashboard',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Last updated: ${_formatLastUpdate(provider.lastUpdated)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.download, color: Colors.white),
                    onPressed: () => _showExportOptions(context, provider),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => provider.fetchData(),
                  ),
                ],
              ),

              // Filter Controls
              SliverToBoxAdapter(child: _buildFilterControls()),

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
                      // SizedBox(height: 16),
                      // _buildTreatmentHubChart(data),
                      SizedBox(height: 16),
                      _buildRiskFactorAnalysis(data),
                      SizedBox(height: 16),
                      _buildCoinfectionChart(data),
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

  Widget _buildFilterControls() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Time Range Filter
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
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
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() => _selectedTimeRange = value!);
                    _applyFilters();
                  },
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
                borderRadius: BorderRadius.circular(8),
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
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                    _applyFilters();
                  },
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
        'icon': Icons.people,
        'color': Color(0xFF5E72E4),
      },
      {
        'title': 'MSM Count',
        'value': analytics.msmCount.toString(),
        'percentage':
            '${((analytics.msmCount / analytics.totalPLHIV) * 100).toStringAsFixed(1)}%',
        'icon': Icons.trending_up,
        'color': Color(0xFF2DCE89),
      },
      {
        'title': 'Youth (18-24)',
        'value': analytics.youthCount.toString(),
        'percentage':
            '${((analytics.youthCount / analytics.totalPLHIV) * 100).toStringAsFixed(1)}%',
        'icon': Icons.person,
        'color': Color(0xFFFB6340),
      },
      {
        'title': 'Avg Years Since Diagnosis',
        'value': analytics.avgYearsSinceDiagnosis.toStringAsFixed(1),
        'subtitle': 'years',
        'icon': Icons.access_time,
        'color': Color(0xFF11CDEF),
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
          childAspectRatio: 1.5,
        ),
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          final metric = metrics[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
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
                    Icon(
                      metric['icon'] as IconData,
                      color: metric['color'] as Color,
                      size: 24,
                    ),
                    if (metric.containsKey('change'))
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF2DCE89).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          metric['change'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Color(0xFF2DCE89),
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
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF32325D),
                      ),
                    ),
                    if (metric.containsKey('percentage'))
                      Text(
                        metric['percentage'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    Text(
                      metric['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diagnosis Trend',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF32325D),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: Colors.grey[300],
                ),
              ),
              tooltipBehavior: _tooltipBehavior,
              series: <CartesianSeries<DiagnosisData, String>>[
                SplineAreaSeries<DiagnosisData, String>(
                  dataSource: chartData,
                  xValueMapper: (DiagnosisData data, _) => data.year,
                  yValueMapper: (DiagnosisData data, _) => data.count,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF5E72E4).withOpacity(0.3),
                      Color(0xFF5E72E4).withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderColor: Color(0xFF5E72E4),
                  borderWidth: 2,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    color: Color(0xFF5E72E4),
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
        // Age Distribution Pie Chart
        Expanded(
          child: Container(
            height: 250,
            padding: EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Age Distribution',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF32325D),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: SfCircularChart(
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      textStyle: GoogleFonts.poppins(fontSize: 10),
                    ),
                    series: <CircularSeries>[
                      DoughnutSeries<AgeData, String>(
                        dataSource: ageData,
                        xValueMapper: (AgeData data, _) => data.age,
                        yValueMapper: (AgeData data, _) => data.count,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                          textStyle: GoogleFonts.poppins(fontSize: 10),
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
        // Gender Distribution Chart
        Expanded(
          child: Container(
            height: 250,
            padding: EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender Distribution',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF32325D),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: SfCircularChart(
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      textStyle: GoogleFonts.poppins(fontSize: 10),
                    ),
                    series: <CircularSeries>[
                      PieSeries<GenderData, String>(
                        dataSource: genderData,
                        xValueMapper: (GenderData data, _) => data.gender,
                        yValueMapper: (GenderData data, _) => data.count,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: GoogleFonts.poppins(fontSize: 10),
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

  // Widget _buildTreatmentHubChart(analytics) {
  //   // Get top 10 treatment hubs
  //   var sortedHubs =
  //       analytics.treatmentHubs.entries.toList()
  //         ..sort((a, b) => b.value.compareTo(a.value));

  //   List<HubData> hubData =
  //       sortedHubs
  //           .take(10)
  //           .map(
  //             (e) => HubData(
  //               e.key.length > 15 ? '${e.key.substring(0, 15)}...' : e.key,
  //               e.value.toDouble(),
  //             ),
  //           )
  //           .toList();

  //   return Container(
  //     height: 350,
  //     padding: EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Top Treatment Hubs',
  //           style: GoogleFonts.poppins(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xFF32325D),
  //           ),
  //         ),
  //         SizedBox(height: 20),
  //         Expanded(
  //           child: SfCartesianChart(
  //             primaryXAxis: CategoryAxis(
  //               majorGridLines: MajorGridLines(width: 0),
  //               labelRotation: -45,
  //             ),
  //             primaryYAxis: NumericAxis(
  //               majorGridLines: MajorGridLines(
  //                 width: 0.5,
  //                 color: Colors.grey[300],
  //               ),
  //             ),
  //             tooltipBehavior: TooltipBehavior(enable: true),
  //             series: <CartesianSeries<HubData, String>>[
  //               SplineAreaSeries<HubData, String>(
  //                 dataSource: hubData, // hubData is List<HubData>
  //                 xValueMapper: (HubData data, _) => data.year,
  //                 yValueMapper: (HubData data, _) => data.count,
  //                 gradient: LinearGradient(
  //                   colors: [
  //                     Color(0xFF5E72E4).withOpacity(0.3),
  //                     Color(0xFF5E72E4).withOpacity(0.1),
  //                   ],
  //                   begin: Alignment.topCenter,
  //                   end: Alignment.bottomCenter,
  //                 ),
  //                 borderColor: Color(0xFF5E72E4),
  //                 borderWidth: 2,
  //                 markerSettings: MarkerSettings(
  //                   isVisible: true,
  //                   color: Color(0xFF5E72E4),
  //                   borderColor: Colors.white,
  //                   borderWidth: 2,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildRiskFactorAnalysis(analytics) {
    List<RiskData> riskData = [];
    analytics.riskFactors.forEach((factor, count) {
      riskData.add(RiskData(factor, count.toDouble()));
    });

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk Factor Analysis',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF32325D),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: Colors.grey[300],
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries<RiskData, String>>[
                SplineAreaSeries<RiskData, String>(
                  dataSource: riskData, // must be List<RiskData>
                  xValueMapper: (RiskData data, _) => data.factor,
                  yValueMapper: (RiskData data, _) => data.count,
                  color: Color(0xFFFB6340),
                  // borderRadius: BorderRadius.circular(4),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: GoogleFonts.poppins(fontSize: 10),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Co-infections',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF32325D),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.right,
                textStyle: GoogleFonts.poppins(fontSize: 12),
              ),
              series: <CircularSeries>[
                RadialBarSeries<CoinfectionData, String>(
                  dataSource: coinfectionData,
                  xValueMapper: (CoinfectionData data, _) => data.type,
                  yValueMapper: (CoinfectionData data, _) => data.count,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: GoogleFonts.poppins(fontSize: 10),
                  ),
                  enableTooltip: true,
                  maximumValue:
                      coinfectionData.isNotEmpty
                          ? coinfectionData
                                  .map((e) => e.count)
                                  .reduce((a, b) => a > b ? a : b) +
                              10
                          : 100,
                  trackColor: const Color.fromARGB(255, 238, 238, 238),
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
    // Implement filter logic
    final provider = Provider.of<EnhancedAnalyticsProvider>(
      context,
      listen: false,
    );
    // Apply time range and category filters
    provider.fetchData();
  }

  void _showExportOptions(
    BuildContext context,
    EnhancedAnalyticsProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Export Analytics',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text('Export as PDF', style: GoogleFonts.poppins()),
                  onTap: () async {
                    Navigator.pop(context);
                    await provider.exportToPDF();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF exported successfully')),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.table_chart, color: Colors.green),
                  title: Text('Export as CSV', style: GoogleFonts.poppins()),
                  onTap: () {
                    Navigator.pop(context);
                    final csv = provider.exportToCSV();
                    // Implement CSV download/share
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('CSV exported successfully')),
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5E72E4)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading analytics...',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
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
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          SizedBox(height: 16),
          Text(
            'Error loading data',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
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
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No data available',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
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

class HubData {
  final String hub;
  final double count;
  HubData(this.hub, this.count);
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
