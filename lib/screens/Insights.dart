import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

// Data Models
class DashboardData {
  final int totalRespondents;
  final int totalPLHIV;
  final int msmCount;
  final Map<String, int> ageDistribution;
  final Map<String, int> genderBreakdown;
  final List<CityMSMData> topMSMCities;
  final Map<String, int> treatmentHubs;
  final Map<String, int> medicationAdherence;
  final Map<String, int> viralLoadStatus;
  final Map<int, int> diagnosisTrend;

  DashboardData({
    required this.totalRespondents,
    required this.totalPLHIV,
    required this.msmCount,
    required this.ageDistribution,
    required this.genderBreakdown,
    required this.topMSMCities,
    required this.treatmentHubs,
    required this.medicationAdherence,
    required this.viralLoadStatus,
    required this.diagnosisTrend,
  });
}

class CityMSMData {
  final String city;
  final int count;
  CityMSMData(this.city, this.count);
}

// Analytics Provider
class AnalyticsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DashboardData? _dashboardData;
  bool _isLoading = false;

  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('profiles').get();
      final profiles = snapshot.docs.map((doc) => doc.data()).toList();

      // Process analytics
      _dashboardData = _processAnalytics(profiles);
    } catch (e) {
      print('Error fetching data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  DashboardData _processAnalytics(List<Map<String, dynamic>> profiles) {
    // Total respondents
    int totalRespondents = profiles.length;

    // Total PLHIV (those with yearDiagnosed)
    int totalPLHIV = profiles.where((p) => p['yearDiagnosed'] != null).length;

    // MSM Count
    int msmCount =
        profiles.where((p) {
          return p['sexAssignedAtBirth'] == 'Male' &&
              (p['unprotectedSexWith'] == 'Male' ||
                  p['unprotectedSexWith'] == 'Both');
        }).length;

    // Age Distribution
    Map<String, int> ageDistribution = {
      '18-24': 0,
      '25-34': 0,
      '35-44': 0,
      '45-54': 0,
      '55+': 0,
    };

    for (var profile in profiles) {
      int? age = profile['age'];
      if (age != null) {
        if (age >= 18 && age <= 24)
          ageDistribution['18-24'] = ageDistribution['18-24']! + 1;
        else if (age >= 25 && age <= 34)
          ageDistribution['25-34'] = ageDistribution['25-34']! + 1;
        else if (age >= 35 && age <= 44)
          ageDistribution['35-44'] = ageDistribution['35-44']! + 1;
        else if (age >= 45 && age <= 54)
          ageDistribution['45-54'] = ageDistribution['45-54']! + 1;
        else if (age >= 55)
          ageDistribution['55+'] = ageDistribution['55+']! + 1;
      }
    }

    // Gender Breakdown
    Map<String, int> genderBreakdown = {};
    for (var profile in profiles) {
      String? gender = profile['genderIdentity'];
      if (gender != null) {
        genderBreakdown[gender] = (genderBreakdown[gender] ?? 0) + 1;
      }
    }

    // Top 5 MSM Cities
    Map<String, int> msmCityCount = {};
    for (var profile in profiles) {
      bool isMSM =
          profile['sexAssignedAtBirth'] == 'Male' &&
          (profile['unprotectedSexWith'] == 'Male' ||
              profile['unprotectedSexWith'] == 'Both');
      if (isMSM &&
          profile['yearDiagnosed'] != null &&
          profile['city'] != null) {
        String city = profile['city'];
        msmCityCount[city] = (msmCityCount[city] ?? 0) + 1;
      }
    }
    var sortedCities =
        msmCityCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    List<CityMSMData> topMSMCities =
        sortedCities.take(5).map((e) => CityMSMData(e.key, e.value)).toList();

    // Treatment Hub Usage
    Map<String, int> treatmentHubs = {};
    for (var profile in profiles) {
      String? hub = profile['treatmentHub'];
      if (hub != null) {
        treatmentHubs[hub] = (treatmentHubs[hub] ?? 0) + 1;
      }
    }

    // Medication Adherence
    Map<String, int> medicationAdherence = {
      'Always': 0,
      'Sometimes': 0,
      'Never': 0,
    };
    for (var profile in profiles) {
      String? adherence = profile['medicationAdherence'];
      if (adherence != null && medicationAdherence.containsKey(adherence)) {
        medicationAdherence[adherence] = medicationAdherence[adherence]! + 1;
      }
    }

    // Viral Load Status
    Map<String, int> viralLoadStatus = {
      'Undetectable': 0,
      'Detectable': 0,
      'Unknown': 0,
    };
    for (var profile in profiles) {
      String? status = profile['viralLoadStatus'];
      if (status != null && viralLoadStatus.containsKey(status)) {
        viralLoadStatus[status] = viralLoadStatus[status]! + 1;
      }
    }

    // Diagnosis Trend
    Map<int, int> diagnosisTrend = {};
    for (var profile in profiles) {
      int? year = profile['yearDiagnosed'];
      if (year != null) {
        diagnosisTrend[year] = (diagnosisTrend[year] ?? 0) + 1;
      }
    }

    return DashboardData(
      totalRespondents: totalRespondents,
      totalPLHIV: totalPLHIV,
      msmCount: msmCount,
      ageDistribution: ageDistribution,
      genderBreakdown: genderBreakdown,
      topMSMCities: topMSMCities,
      treatmentHubs: treatmentHubs,
      medicationAdherence: medicationAdherence,
      viralLoadStatus: viralLoadStatus,
      diagnosisTrend: diagnosisTrend,
    );
  }
}

// Main Dashboard Screen
class PLHIVDashboard extends StatefulWidget {
  @override
  _PLHIVDashboardState createState() => _PLHIVDashboardState();
}

class _PLHIVDashboardState extends State<PLHIVDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<AnalyticsProvider>(
            context,
            listen: false,
          ).fetchDashboardData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'PLHIV Analytics Dashboard',
          style: GoogleFonts.workSans(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF2C3E50)),
            onPressed: () {
              Provider.of<AnalyticsProvider>(
                context,
                listen: false,
              ).fetchDashboardData();
            },
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.dashboardData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No data available', style: GoogleFonts.workSans()),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKeyMetrics(provider.dashboardData!),
                SizedBox(height: 24),
                _buildAgeDistributionChart(provider.dashboardData!),
                SizedBox(height: 24),
                _buildGenderBreakdownChart(provider.dashboardData!),
                SizedBox(height: 24),
                _buildTopMSMCitiesChart(provider.dashboardData!),
                SizedBox(height: 24),
                _buildMedicationAdherenceChart(provider.dashboardData!),
                SizedBox(height: 24),
                _buildViralLoadStatusChart(provider.dashboardData!),
                SizedBox(height: 24),
                _buildDiagnosisTrendChart(provider.dashboardData!),
                SizedBox(height: 24),
                _buildTreatmentHubsList(provider.dashboardData!),
              ],
            ),
          );
        },
      ),
    );
  }

  // Solution 1: Adjust the childAspectRatio
  Widget _buildKeyMetrics(DashboardData data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3, // Changed from 1.5 to 1.3 to give more height
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildMetricCard(
          'Total Respondents',
          data.totalRespondents.toString(),
          Icons.people,
          Color(0xFF3498DB),
        ),
        _buildMetricCard(
          'Total PLHIV',
          data.totalPLHIV.toString(),
          FontAwesomeIcons.ribbon,
          Color(0xFFE74C3C),
        ),
        _buildMetricCard(
          'MSM Count',
          data.msmCount.toString(),
          Icons.male,
          Color(0xFF9B59B6),
        ),
        _buildMetricCard(
          'PLHIV Rate',
          '${((data.totalPLHIV / data.totalRespondents) * 100).toStringAsFixed(1)}%',
          Icons.percent,
          Color(0xFF2ECC71),
        ),
      ],
    );
  }

  // Solution 2: Use Flexible/Expanded widgets in the card
  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(12), // Reduced padding from 16 to 12
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24), // Reduced icon size from 28 to 24
          SizedBox(height: 6), // Reduced spacing from 8 to 6
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 20, // Reduced font size from 24 to 20
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 2), // Reduced spacing from 4 to 2
          Flexible(
            child: Text(
              title,
              style: GoogleFonts.workSans(
                fontSize: 11, // Reduced font size from 12 to 11
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Solution 3: Use dynamic height calculation
  Widget _buildKeyMetricsAlternative(DashboardData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardHeight =
            constraints.maxWidth / 2 / 1.3; // Dynamic height based on width

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildMetricCard(
              'Total Respondents',
              data.totalRespondents.toString(),
              Icons.people,
              Color(0xFF3498DB),
            ),
            _buildMetricCard(
              'Total PLHIV',
              data.totalPLHIV.toString(),
              FontAwesomeIcons.ribbon,
              Color(0xFFE74C3C),
            ),
            _buildMetricCard(
              'MSM Count',
              data.msmCount.toString(),
              Icons.male,
              Color(0xFF9B59B6),
            ),
            _buildMetricCard(
              'PLHIV Rate',
              '${((data.totalPLHIV / data.totalRespondents) * 100).toStringAsFixed(1)}%',
              Icons.percent,
              Color(0xFF2ECC71),
            ),
          ],
        );
      },
    );
  }

  // Solution 4: Use FittedBox to scale content
  Widget _buildMetricCardWithFittedBox(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeDistributionChart(DashboardData data) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Age Distribution',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups:
                    data.ageDistribution.entries.map((entry) {
                      int index = data.ageDistribution.keys.toList().indexOf(
                        entry.key,
                      );
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.toDouble(),
                            color: Color(0xFF3498DB),
                            width: 30,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        List<String> labels =
                            data.ageDistribution.keys.toList();
                        if (value.toInt() < labels.length) {
                          return Text(
                            labels[value.toInt()],
                            style: GoogleFonts.workSans(fontSize: 12),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderBreakdownChart(DashboardData data) {
    List<PieChartSectionData> sections = [];
    List<Color> colors = [
      Color(0xFF3498DB),
      Color(0xFFE74C3C),
      Color(0xFF9B59B6),
      Color(0xFF2ECC71),
      Color(0xFFF39C12),
    ];

    int colorIndex = 0;
    data.genderBreakdown.forEach((gender, count) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: count.toDouble(),
          title: gender,
          radius: 100,
          titleStyle: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender Identity Breakdown',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMSMCitiesChart(DashboardData data) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 5 Cities with MSM PLHIV',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 16),
          ...data.topMSMCities.map(
            (city) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      city.city,
                      style: GoogleFonts.workSans(fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF9B59B6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      city.count.toString(),
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9B59B6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationAdherenceChart(DashboardData data) {
    return Container(
      height: 210,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medication Adherence',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  data.medicationAdherence.entries.map((entry) {
                    int total = data.medicationAdherence.values.reduce(
                      (a, b) => a + b,
                    );
                    double percentage = total > 0 ? (entry.value / total) : 0;
                    Color color =
                        entry.key == 'Always'
                            ? Color(0xFF2ECC71)
                            : entry.key == 'Sometimes'
                            ? Color(0xFFF39C12)
                            : Color(0xFFE74C3C);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularPercentIndicator(
                          radius: 45.0,
                          lineWidth: 8.0,
                          percent: percentage,
                          center: Text(
                            '${(percentage * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          progressColor: color,
                          backgroundColor: color.withOpacity(0.1),
                        ),
                        SizedBox(height: 8),
                        Text(
                          entry.key,
                          style: GoogleFonts.workSans(fontSize: 12),
                        ),
                        Text(
                          '(${entry.value})',
                          style: GoogleFonts.workSans(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViralLoadStatusChart(DashboardData data) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Viral Load Status',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              children:
                  data.viralLoadStatus.entries.map((entry) {
                    int total = data.viralLoadStatus.values.reduce(
                      (a, b) => a + b,
                    );
                    double percentage = total > 0 ? (entry.value / total) : 0;
                    Color color =
                        entry.key == 'Undetectable'
                            ? Color(0xFF2ECC71)
                            : entry.key == 'Detectable'
                            ? Color(0xFFE74C3C)
                            : Color(0xFF95A5A6);

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: GoogleFonts.workSans(fontSize: 14),
                              ),
                              Text(
                                '${entry.value} (${(percentage * 100).toStringAsFixed(1)}%)',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          LinearPercentIndicator(
                            lineHeight: 8.0,
                            percent: percentage,
                            progressColor: color,
                            backgroundColor: color.withOpacity(0.1),
                            padding: EdgeInsets.zero,
                            barRadius: Radius.circular(4),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisTrendChart(DashboardData data) {
    List<int> years = data.diagnosisTrend.keys.toList()..sort();

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Diagnoses Trend',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < years.length) {
                          return Text(
                            years[value.toInt()].toString(),
                            style: GoogleFonts.workSans(fontSize: 10),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        years.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            data.diagnosisTrend[entry.value]?.toDouble() ?? 0,
                          );
                        }).toList(),
                    isCurved: true,
                    color: Color(0xFFE74C3C),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Color(0xFFE74C3C),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Color(0xFFE74C3C).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentHubsList(DashboardData data) {
    var sortedHubs =
        data.treatmentHubs.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Treatment Hub Usage',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 16),
          ...sortedHubs
              .take(10)
              .map(
                (hub) => Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF3498DB).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_hospital,
                        color: Color(0xFF3498DB),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hub.key,
                          style: GoogleFonts.workSans(fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF3498DB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          hub.value.toString(),
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// Deep Dive Analytics Screen
class DeepDiveAnalytics extends StatelessWidget {
  final DashboardData data;

  DeepDiveAnalytics({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Deep Dive Analytics',
          style: GoogleFonts.workSans(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMSMvsNonMSMAdherence(),
            SizedBox(height: 24),
            _buildMSMAgeBreakdown(),
            SizedBox(height: 24),
            _buildLowSupportRegions(),
          ],
        ),
      ),
    );
  }

  Widget _buildMSMvsNonMSMAdherence() {
    // This would need actual MSM vs non-MSM data filtering
    return Container(
      height: 350,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medication Adherence: MSM vs Non-MSM',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.percentPattern(),
              ),
              legend: Legend(isVisible: true, position: LegendPosition.bottom),
              series: <CartesianSeries>[
                ColumnSeries<AdherenceData, String>(
                  dataSource: [
                    AdherenceData('Always', 0.65, 0.70),
                    AdherenceData('Sometimes', 0.25, 0.20),
                    AdherenceData('Never', 0.10, 0.10),
                  ],
                  xValueMapper: (AdherenceData data, _) => data.category,
                  yValueMapper: (AdherenceData data, _) => data.msm,
                  name: 'MSM',
                  color: Color(0xFF9B59B6),
                ),
                ColumnSeries<AdherenceData, String>(
                  dataSource: [
                    AdherenceData('Always', 0.65, 0.70),
                    AdherenceData('Sometimes', 0.25, 0.20),
                    AdherenceData('Never', 0.10, 0.10),
                  ],
                  xValueMapper: (AdherenceData data, _) => data.category,
                  yValueMapper: (AdherenceData data, _) => data.nonMsm,
                  name: 'Non-MSM',
                  color: Color(0xFF3498DB),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMSMAgeBreakdown() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MSM Age Distribution',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: SfCircularChart(
              series: <CircularSeries>[
                DoughnutSeries<AgeData, String>(
                  dataSource: [
                    AgeData('18-24', 25),
                    AgeData('25-34', 40),
                    AgeData('35-44', 20),
                    AgeData('45-54', 10),
                    AgeData('55+', 5),
                  ],
                  xValueMapper: (AgeData data, _) => data.age,
                  yValueMapper: (AgeData data, _) => data.count,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
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

  Widget _buildLowSupportRegions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFE74C3C),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Low Support Regions',
                style: GoogleFonts.workSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Regions with high PLHIV count but low support systems',
            style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          _buildRegionCard('Davao City', 145, 32),
          _buildRegionCard('Cebu City', 98, 28),
          _buildRegionCard('Manila', 234, 45),
          _buildRegionCard('Quezon City', 167, 38),
        ],
      ),
    );
  }

  Widget _buildRegionCard(String region, int plhivCount, int supportPercent) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  region,
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'PLHIV: $plhivCount',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      supportPercent < 40
                          ? Color(0xFFE74C3C).withOpacity(0.1)
                          : Color(0xFFF39C12).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$supportPercent% Support',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color:
                        supportPercent < 40
                            ? Color(0xFFE74C3C)
                            : Color(0xFFF39C12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper Classes
class AdherenceData {
  final String category;
  final double msm;
  final double nonMsm;
  AdherenceData(this.category, this.msm, this.nonMsm);
}

class AgeData {
  final String age;
  final int count;
  AgeData(this.age, this.count);
}

// Main App Entry Point
class PLHIVAnalyticsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PLHIV Analytics',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'WorkSans'),
      home: ChangeNotifierProvider(
        create: (_) => AnalyticsProvider(),
        child: PLHIVDashboard(),
      ),
    );
  }
}
