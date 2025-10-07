import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:projecho/screens/analytics/components/providers/researcher_analytics_provider.dart';
import 'package:projecho/screens/analytics/widgets/dashboard_app_bar.dart';
import 'package:projecho/screens/analytics/widgets/filter_controls.dart';
import 'package:projecho/screens/analytics/widgets/welcome_card.dart';
import 'package:projecho/screens/analytics/widgets/metrics_grid.dart';
import 'package:projecho/screens/analytics/widgets/charts_section.dart';
import 'package:projecho/screens/analytics/widgets/dashboard_states.dart';

class ResearcherDashboard extends StatefulWidget {
  @override
  _ResearcherDashboardState createState() => _ResearcherDashboardState();
}

class _ResearcherDashboardState extends State<ResearcherDashboard> {
  String _selectedTimeRange = '1 Year';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    Future.microtask(() {
      final provider = Provider.of<ResearcherAnalyticsProvider>(
        context,
        listen: false,
      );
      provider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      body: Consumer<ResearcherAnalyticsProvider>(
        builder: (context, provider, child) {
          return _buildDashboardContent(provider);
        },
      ),
    );
  }

  Widget _buildDashboardContent(ResearcherAnalyticsProvider provider) {
    // Handle different states
    if (provider.userRole != 'researcher' && provider.userRole != 'admin') {
      return DashboardStates.accessDenied(context);
    }

    if (provider.isLoading) {
      return DashboardStates.loading();
    }

    if (provider.errorMessage != null) {
      return DashboardStates.error(
        provider.errorMessage!,
        onRetry: () => provider.fetchData(),
      );
    }

    final data = provider.analyticsData;
    if (data == null) {
      return DashboardStates.empty(
        onRefresh: () => provider.refreshAnalytics(),
      );
    }

    return CustomScrollView(
      slivers: [
        DashboardAppBar(
          provider: provider,
          onExport: () => _showExportOptions(context, provider),
          onRefresh: () => provider.refreshAnalytics(),
        ),
        SliverToBoxAdapter(
          child: FilterControls(
            selectedTimeRange: _selectedTimeRange,
            selectedFilter: _selectedFilter,
            onTimeRangeChanged: _onTimeRangeChanged,
            onFilterChanged: _onFilterChanged,
          ),
        ),
        SliverToBoxAdapter(child: WelcomeCard()),
        SliverToBoxAdapter(child: MetricsGrid(data: data)),
        SliverToBoxAdapter(
          child: ChartsSection(
            data: data,
            timeRange: _selectedTimeRange,
            filter: _selectedFilter,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  void _onTimeRangeChanged(String? value) {
    if (value != null) {
      setState(() => _selectedTimeRange = value);
      _applyFilters();
    }
  }

  void _onFilterChanged(String? value) {
    if (value != null) {
      setState(() => _selectedFilter = value);
      _applyFilters();
    }
  }

  void _applyFilters() {
    final provider = Provider.of<ResearcherAnalyticsProvider>(
      context,
      listen: false,
    );

    // Apply time range filter
    DateTime startDate;
    final now = DateTime.now();

    switch (_selectedTimeRange) {
      case '1 Month':
        startDate = now.subtract(Duration(days: 30));
        break;
      case '3 Months':
        startDate = now.subtract(Duration(days: 90));
        break;
      case '6 Months':
        startDate = now.subtract(Duration(days: 180));
        break;
      case '1 Year':
        startDate = now.subtract(Duration(days: 365));
        break;
      default:
        startDate = DateTime(2020); // All time
    }

    provider.updateDateRange(startDate, now);
  }

  void _showExportOptions(
    BuildContext context,
    ResearcherAnalyticsProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildExportModal(context, provider),
    );
  }

  Widget _buildExportModal(
    BuildContext context,
    ResearcherAnalyticsProvider provider,
  ) {
    return Container(
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
          _buildExportOption(
            icon: Icons.picture_as_pdf,
            color: Colors.red,
            title: 'Export as PDF',
            subtitle: 'Comprehensive report',
            onTap: () async {
              Navigator.pop(context);
              await _handleExport(
                context,
                () => provider.exportToPDF(),
                'PDF exported successfully',
              );
            },
          ),
          _buildExportOption(
            icon: Icons.table_chart,
            color: Colors.green,
            title: 'Export as CSV',
            subtitle: 'Raw data for analysis',
            onTap: () async {
              Navigator.pop(context);
              await _handleExport(
                context,
                () => provider.exportToCSV(),
                'CSV exported successfully',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: GoogleFonts.workSans()),
      subtitle: Text(subtitle, style: GoogleFonts.workSans(fontSize: 12)),
      onTap: onTap,
    );
  }

  Future<void> _handleExport(
    BuildContext context,
    Future<dynamic> Function() exportFunction,
    String successMessage,
  ) async {
    try {
      await exportFunction();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Color(0xFF42B883),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
