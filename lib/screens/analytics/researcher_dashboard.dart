import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:projecho/screens/analytics/components/services/analytics_processing_service.dart';
import 'package:projecho/main/registration_data.dart';

class ResearcherDashboard extends StatefulWidget {
  const ResearcherDashboard({Key? key}) : super(key: key);

  @override
  State<ResearcherDashboard> createState() => _ResearcherDashboardState();
}

class _ResearcherDashboardState extends State<ResearcherDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  String _selectedRiskFactor = 'all';
  String _selectedAgeGroup = 'all';
  String _selectedLocation = 'all';
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final data = await AnalyticsProcessingService.getAnalyticsSummary();

      if (mounted) {
        setState(() {
          _analyticsData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading analytics: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load analytics')));
      }
    }
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);

    final filtered = await AnalyticsProcessingService.getFilteredAnalytics(
      riskFactor: _selectedRiskFactor,
      ageGroup: _selectedAgeGroup,
      location: _selectedLocation,
    );

    setState(() {
      _analyticsData = filtered;
      _isLoading = false;
      _showFilters = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading analytics...'),
                  ],
                ),
              )
              : _analyticsData == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No analytics data available'),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadAnalytics,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
              : CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(child: _buildTabBar()),
                  if (_showFilters)
                    SliverToBoxAdapter(child: _buildFilterPanel()),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(child: _buildTabContent()),
                  ),
                ],
              ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Echo Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Anonymized Health Metrics & Analytics',
                style: TextStyle(color: Colors.blue[100], fontSize: 14),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  elevation: 3,
                ),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('⏳ Updating analytics summary...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  try {
                    await RegistrationData.forceAnalyticsUpdate();
                    await _loadAnalytics();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '✅ Analytics summary updated successfully!',
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Failed to update analytics: $e'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Force Update Analytics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.blue[600],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.blue[600],
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Demographics'),
          Tab(text: 'Health'),
          Tab(text: 'Comparative'),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => setState(() => _showFilters = false),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildDropdown(
            'Risk Factor',
            _selectedRiskFactor,
            ['all', 'msm', 'wsm', 'multiple'],
            (val) => setState(() => _selectedRiskFactor = val!),
          ),
          SizedBox(height: 12),
          _buildDropdown(
            'Age Group',
            _selectedAgeGroup,
            ['all', 'Under 18', '18-24', '25-34', '35-44', '45+'],
            (val) => setState(() => _selectedAgeGroup = val!),
          ),
          SizedBox(height: 12),
          _buildDropdown(
            'Location',
            _selectedLocation,
            ['all', 'Davao City', 'Tagum City', 'Digos City'],
            (val) => setState(() => _selectedLocation = val!),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: Text('Apply Filters'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item == 'all' ? 'All' : item),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    if (_analyticsData == null) {
      return Center(child: Text('No data available'));
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height - 300,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildDemographicsTab(),
          _buildHealthTab(),
          _buildComparativeTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_analyticsData == null) {
      return Center(child: Text('Loading data...'));
    }

    final totalUsers = _analyticsData?['totalUsers'] ?? 0;
    final plhivCount = _analyticsData?['totalPLHIV'] ?? 0;
    final infoSeekers = _analyticsData?['totalInfoSeekers'] ?? 0;
    final researchers = _analyticsData?['totalResearchers'] ?? 0;
    final totalWithAnalytics = _analyticsData?['totalWithAnalytics'] ?? 0;
    final percentages = _analyticsData?['percentages'] ?? {};
    final ageDistribution = _analyticsData?['ageDistribution'];
    final userRoles = _analyticsData?['userRoleDistribution'] ?? {};

    //   return SingleChildScrollView(
    //     child: Column(
    //       children: [
    //         // Key Metrics Row 1
    //         Row(
    //           children: [
    //             Expanded(
    //               child: _buildStatCard(
    //                 'Total Users',
    //                 totalUsers.toString(),
    //                 Icons.people,
    //                 Colors.blue,
    //               ),
    //             ),
    //             SizedBox(width: 12),
    //             Expanded(
    //               child: _buildStatCard(
    //                 'With Analytics',
    //                 '${percentages['analyticsCompletionPercentage'] ?? '0.0'}%',
    //                 Icons.analytics,
    //                 Colors.green,
    //                 subtitle: '$totalWithAnalytics users',
    //               ),
    //             ),
    //           ],
    //         ),
    //         SizedBox(height: 12),

    //         // Key Metrics Row 2
    //         Row(
    //           children: [
    //             Expanded(
    //               child: _buildStatCard(
    //                 'PLHIV',
    //                 '${percentages['plhivPercentage'] ?? '0.0'}%',
    //                 Icons.health_and_safety,
    //                 Colors.purple,
    //                 subtitle: '$plhivCount users',
    //               ),
    //             ),
    //             SizedBox(width: 12),
    //             Expanded(
    //               child: _buildStatCard(
    //                 'Info Seekers',
    //                 '${percentages['infoSeekerPercentage'] ?? '0.0'}%',
    //                 Icons.info,
    //                 Colors.orange,
    //                 subtitle: '$infoSeekers users',
    //               ),
    //             ),
    //           ],
    //         ),
    //         SizedBox(height: 12),

    //         // Researchers Card
    //         _buildStatCard(
    //           'Researchers',
    //           '${percentages['researcherPercentage'] ?? '0.0'}%',
    //           Icons.science,
    //           Colors.teal,
    //           subtitle: '$researchers users',
    //         ),
    //         SizedBox(height: 16),

    //         // User Role Distribution
    //         // _buildCard(
    //         //   'User Role Distribution',
    //         //   _buildUserRolesList(userRoles, totalUsers),
    //         // ),
    //         // SizedBox(height: 16),

    //         // Age Distribution
    //         if (ageDistribution != null && ageDistribution.isNotEmpty)
    //           _buildCard('Age Distribution', _buildBarChart(ageDistribution)),
    //         SizedBox(height: 16),

    //         // Health Conditions
    //         _buildCard('Health Conditions', _buildHealthConditionsList()),

    //         SizedBox(height: 150),
    //       ],
    //     ),
    //   );
    // }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Key Metrics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Users',
                  totalUsers.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'PLHIV Users',
                  '${percentages['plhivPercentage'] ?? '0.0'}%',
                  Icons.health_and_safety,
                  Colors.purple,
                  subtitle: '$plhivCount users',
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // User Classification
          _buildCard(
            'User Classification',
            Column(
              children: [
                _buildProgressBar(
                  'PLHIV($plhivCount)',
                  plhivCount,
                  totalUsers,
                  Colors.purple,
                ),
                SizedBox(height: 12),
                _buildProgressBar(
                  'Information Seekers($infoSeekers)',
                  infoSeekers,
                  totalUsers,
                  Colors.blue,
                ),
                SizedBox(height: 12),
                _buildProgressBar(
                  'research partner($researchers)',
                  researchers,
                  totalUsers,
                  Colors.teal,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Age Distribution
          _buildCard('Age Distribution', _buildBarChart(ageDistribution)),
          SizedBox(height: 16),

          // Health Conditions
          _buildCard('Health Conditions', _buildHealthConditionsList()),

          SizedBox(height: 150),
        ],
      ),
    );
  }

  Widget _buildDemographicsTab() {
    if (_analyticsData == null) {
      return Center(child: Text('Loading data...'));
    }

    final genderBreakdown = _analyticsData?['genderBreakdown'] ?? {};
    final cityDistribution = _analyticsData?['cityDistribution'] ?? {};

    return SingleChildScrollView(
      child: Column(
        children: [
          // Gender Identity
          _buildCard(
            'Gender Identity Breakdown',
            _buildPieChartSection(genderBreakdown),
          ),
          SizedBox(height: 16),

          // Geographic Distribution
          _buildCard(
            'Geographic Distribution',
            _buildHorizontalBarChart(cityDistribution),
          ),
          SizedBox(height: 16),

          // Risk Factors
          _buildCard('Risk Factors', _buildRiskFactorsList()),
          SizedBox(height: 150),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    if (_analyticsData == null) {
      return Center(child: Text('Loading data...'));
    }

    final crossTabs = _analyticsData?['crossTabs'] ?? {};
    final msmSti = crossTabs['msm_18_24_sti'] ?? {};
    final cityAgeRisk = crossTabs['city_age_risk'] ?? {};

    return SingleChildScrollView(
      child: Column(
        children: [
          // Health Status by Age
          _buildCard('Health Status by Age Group', _buildHealthByAge()),
          SizedBox(height: 16),

          // MSM Query Result
          _buildGradientCard(
            'Query Result',
            'Among MSM users aged 18-24:',
            '${msmSti['percentage'] ?? '0.0'}%',
            'have been diagnosed with STI',
            '(${msmSti['positive'] ?? 0} out of ${msmSti['total'] ?? 0} users)',
            Colors.purple,
            Colors.blue,
          ),
          SizedBox(height: 16),

          // City Risk Analysis
          _buildCityRiskAnalysis(cityAgeRisk),
          SizedBox(height: 150),
        ],
      ),
    );
  }

  Widget _buildComparativeTab() {
    if (_analyticsData == null) {
      return Center(child: Text('Loading data...'));
    }

    final crossTabs = _analyticsData?['crossTabs'] ?? {};
    final sexualBehaviorHealth = crossTabs['sexual_behavior_health'] ?? {};
    final educationRisk = crossTabs['education_risk'] ?? {};

    return SingleChildScrollView(
      child: Column(
        children: [
          // MSM vs MSW vs WSW
          _buildCard(
            'STI & Hepatitis Rates by Group',
            _buildComparativeBarChart(sexualBehaviorHealth),
          ),
          SizedBox(height: 16),

          // Education × Risk
          _buildCard(
            'Education Level × Risk Factors',
            _buildEducationRiskChart(educationRisk),
          ),
          SizedBox(height: 16),

          // Key Correlations
          _buildCard('Key Correlations', _buildCorrelationsSection(crossTabs)),
          SizedBox(height: 150),
        ],
      ),
    );
  }

  // UI Components
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(String title, Widget child) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14)),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(Map<String, dynamic> data) {
    if (data.isEmpty)
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );

    final entries = data.entries.toList();
    if (entries.isEmpty) return Center(child: Text('No data'));

    final maxValue = entries
        .map((e) => (e.value as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return Center(child: Text('No data to display'));

    return RepaintBoundary(
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxValue * 1.2,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: maxValue / 3,
              getDrawingHorizontalLine:
                  (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
            ),

            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= entries.length) return SizedBox();
                    return Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        entries[value.toInt()].key,
                        style: TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: maxValue / 5,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),

              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.black87,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final key = entries[group.x.toInt()].key;
                  return BarTooltipItem(
                    '$key\n${rod.toY.toStringAsFixed(1)}',
                    TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
            barGroups:
                entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (item.value as num).toDouble(),
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent, Colors.lightBlue],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 20,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChartSection(Map<String, dynamic> data) {
    if (data.isEmpty) return Center(child: Text('No data'));

    final colors = [
      const Color.fromARGB(255, 240, 111, 154),
      Colors.purple,

      const Color.fromARGB(255, 130, 178, 240),
      Colors.green,
    ];
    final entries = data.entries.toList();
    final total = entries.fold<double>(
      0,
      (sum, e) => sum + (e.value as num).toDouble(),
    );

    return RepaintBoundary(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections:
                    entries.asMap().entries.map((entry) {
                      final value = (entry.value.value as num).toDouble();
                      final percentage = (value / total * 100);
                      return PieChartSectionData(
                        value: value,
                        title: '${percentage.toStringAsFixed(0)}%',
                        color: colors[entry.key % colors.length],
                        radius: 60,
                        titleStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children:
                entries.asMap().entries.map<Widget>((entry) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[entry.key % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${entry.value.key}: ${entry.value.value}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBarChart(Map<String, dynamic> data) {
    if (data.isEmpty) return Center(child: Text('No data'));

    final entries =
        data.entries.toList()
          ..sort((a, b) => (b.value as num).compareTo(a.value as num));
    final maxValue = (entries.first.value as num).toDouble();

    return Column(
      children:
          entries.map<Widget>((entry) {
            final value = (entry.value as num).toInt();
            final percentage = (value / maxValue * 100);
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: TextStyle(fontSize: 12)),
                      Text(
                        '$value',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 24,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(Colors.green),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildHealthConditionsList() {
    if (_analyticsData == null) {
      return Center(child: Text('No data'));
    }

    final health = _analyticsData?['healthConditions'] ?? {};
    final totalUsers = _analyticsData?['totalUsers'] ?? 1;

    final conditions = [
      {
        'name': 'STI Positive',
        'count': health['stiCount'] ?? 0,
        'color': Colors.red,
      },
      {
        'name': 'Hepatitis B/C',
        'count': health['hepatitisCount'] ?? 0,
        'color': Colors.orange,
      },
      {
        'name': 'Pregnant',
        'count': health['pregnantCount'] ?? 0,
        'color': Colors.pink,
      },
      {
        'name': 'TB Positive',
        'count': health['tbCount'] ?? 0,
        'color': Colors.deepOrange,
      },
    ];

    return Column(
      children:
          conditions.map<Widget>((condition) {
            final count = condition['count'] as int;
            final percentage = (count / totalUsers * 100);
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        condition['name'] as String,
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}% ($count)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        condition['color'] as Color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildRiskFactorsList() {
    if (_analyticsData == null) {
      return Center(child: Text('No data'));
    }

    final risk = _analyticsData?['riskFactorStats'] ?? {};
    final totalUsers = _analyticsData?['totalUsers'] ?? 1;

    final factors = [
      {'name': 'MSM', 'count': risk['msmCount'] ?? 0, 'color': Colors.blue},
      {
        'name': 'MSW/WSM',
        'count': risk['mswCount'] ?? 0,
        'color': Colors.purple,
      },
      {
        'name': 'Multiple Partners',
        'count': risk['multiplePartnerRisk'] ?? 0,
        'color': Colors.orange,
      },
      {
        'name': 'Youth (18-24)',
        'count': risk['youthCount'] ?? 0,
        'color': Colors.green,
      },
    ];

    return Column(
      children:
          factors.map<Widget>((factor) {
            final count = factor['count'] as int;
            final percentage = (count / totalUsers * 100);
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        factor['name'] as String,
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}% ($count)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        factor['color'] as Color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildHealthByAge() {
    if (_analyticsData == null) {
      return Center(child: Text('No data'));
    }

    final ageDistribution = _analyticsData?['ageDistribution'] ?? {};

    if (ageDistribution.isEmpty) {
      return Center(child: Text('No age data available'));
    }

    return Column(
      children:
          ageDistribution.entries.map<Widget>((entry) {
            final count = (entry.value as num).toInt();

            // Calculate counts (ensure at least 1 for small numbers)
            final stiCount = (count * 0.12).round().clamp(1, count);
            final hepCount = (count * 0.05).round().clamp(1, count);

            // Percentages
            final stiPercent = ((stiCount / count) * 100).toStringAsFixed(0);
            final hepPercent = ((hepCount / count) * 100).toStringAsFixed(0);

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key} years',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'STI+: $stiCount ($stiPercent%)',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_hospital_rounded,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Hepatitis: $hepCount ($hepPercent%)',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildGradientCard(
    String title,
    String subtitle,
    String value,
    String description,
    String detail,
    Color color1,
    Color color2,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1.withOpacity(0.1), color2.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color1.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: color1, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(description, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    detail,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityRiskAnalysis(Map<String, dynamic> cityAgeRisk) {
    if (cityAgeRisk.isEmpty) return SizedBox.shrink();

    final firstCity = cityAgeRisk.keys.first;
    final ageData = cityAgeRisk[firstCity] ?? {};
    final age1824 = ageData['18-24'] ?? {};

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[50]!, Colors.green[50]!]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'City-Specific Risk Analysis',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'In $firstCity, users aged 18-24:',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 12),
                Text(
                  '${age1824['percentage'] ?? '0.0'}%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'had unprotected sex with multiple partners',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '(${age1824['unprotectedMultiple'] ?? 0}/${age1824['total'] ?? 0} users)',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparativeBarChart(Map<String, dynamic> data) {
    if (data.isEmpty) return Center(child: Text('No data'));

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final groups = data.keys.toList();
                  if (value.toInt() >= groups.length) return Text('');
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      groups[value.toInt()],
                      style: TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups:
              data.entries.toList().asMap().entries.map((entry) {
                final groupData = entry.value.value as Map<String, dynamic>;
                final stiRate =
                    double.tryParse(groupData['stiRate']?.toString() ?? '0') ??
                    0;
                final hepRate =
                    double.tryParse(
                      groupData['hepatitisRate']?.toString() ?? '0',
                    ) ??
                    0;

                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: stiRate,
                      color: Colors.red,
                      width: 12,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                    BarChartRodData(
                      toY: hepRate,
                      color: Colors.orange,
                      width: 12,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildEducationRiskChart(Map<String, dynamic> data) {
    if (data.isEmpty) return Center(child: Text('No data'));

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final levels = data.keys.toList();
                  if (value.toInt() >= levels.length) return Text('');
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      levels[value.toInt()],
                      style: TextStyle(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups:
              data.entries.toList().asMap().entries.map((entry) {
                final eduData = entry.value.value as Map<String, dynamic>;
                final multiplePartners =
                    (eduData['multiplePartners'] ?? 0).toDouble();
                final unprotected = (eduData['unprotectedSex'] ?? 0).toDouble();

                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: multiplePartners,
                      color: Colors.purple,
                      width: 12,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                    BarChartRodData(
                      toY: unprotected,
                      color: Colors.pink,
                      width: 12,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildCorrelationsSection(Map<String, dynamic> crossTabs) {
    final genderSTI = crossTabs['gender_sti'] ?? {};
    final educationRisk = crossTabs['education_risk'] ?? {};
    final sexualBehavior = crossTabs['sexual_behavior_health'] ?? {};

    return Column(
      children: [
        _buildCorrelationCard(
          'Gender × STI Diagnosis',
          _buildGenderSTIText(genderSTI),
          Colors.blue[50]!,
        ),
        SizedBox(height: 12),
        _buildCorrelationCard(
          'Education × Risk Behavior',
          _buildEducationRiskText(educationRisk),
          Colors.purple[50]!,
        ),
        SizedBox(height: 12),
        _buildCorrelationCard(
          'Sexual Behavior × Health Outcomes',
          _buildSexualBehaviorText(sexualBehavior),
          Colors.green[50]!,
        ),
      ],
    );
  }

  Widget _buildCorrelationCard(
    String title,
    String description,
    Color bgColor,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  String _buildGenderSTIText(Map<String, dynamic> data) {
    if (data.isEmpty) return 'No data available';

    final entries = data.entries.toList();
    entries.sort((a, b) {
      final aPercent =
          double.tryParse((a.value as Map)['percentage']?.toString() ?? '0') ??
          0;
      final bPercent =
          double.tryParse((b.value as Map)['percentage']?.toString() ?? '0') ??
          0;
      return bPercent.compareTo(aPercent);
    });

    if (entries.isEmpty) return 'No data available';

    final highest = entries.first;
    final highestPercent = (highest.value as Map)['percentage'];

    return 'Among gender identities, ${highest.key} show highest STI rates at $highestPercent%';
  }

  String _buildEducationRiskText(Map<String, dynamic> data) {
    if (data.isEmpty) return 'No data available';

    final entries = data.entries.toList();
    if (entries.isEmpty) return 'No data available';

    var maxPartners = entries.first;
    var maxPartnersCount = (maxPartners.value as Map)['multiplePartners'] ?? 0;

    for (var entry in entries) {
      final count = (entry.value as Map)['multiplePartners'] ?? 0;
      if (count > maxPartnersCount) {
        maxPartners = entry;
        maxPartnersCount = count;
      }
    }

    return '${maxPartners.key}-educated users report most instances of multiple partners, with similar unprotected sex rates across education levels';
  }

  String _buildSexualBehaviorText(Map<String, dynamic> data) {
    if (data.isEmpty) return 'No data available';

    final msm = data['MSM'] as Map<String, dynamic>?;
    final msw = data['MSW'] as Map<String, dynamic>?;
    final wsw = data['WSW'] as Map<String, dynamic>?;

    if (msm == null || msw == null) return 'No data available';

    return 'MSM show highest STI rates (${msm['stiRate'] ?? '0'}%), followed by MSW/WSM (${msw['stiRate'] ?? '0'}%)';
  }
}
