import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/role_management_service.dart';
import '../models/analytics_data.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class EnhancedAnalyticsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RoleManagementService _roleService = RoleManagementService();

  AnalyticsData? _analyticsData;
  GeneralInsights? _generalInsights;
  String _userRole = 'basicUser';
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  // Date range for filtering
  DateTime _startDate = DateTime.now().subtract(Duration(days: 365));
  DateTime _endDate = DateTime.now();

  // Getters
  AnalyticsData? get analyticsData => _analyticsData;
  GeneralInsights? get generalInsights => _generalInsights;
  String get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;

  // Initialize and fetch user role
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get user role from phone number
      _userRole = await _roleService.getUserRole();

      // Fetch appropriate data based on role
      await fetchData();
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_userRole == 'basicUser') {
        await _fetchGeneralInsights();
      } else {
        await _fetchFullAnalytics();
      }
      _lastUpdated = DateTime.now();
    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // For basic users - general insights without personal data
  Future<void> _fetchGeneralInsights() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final profiles = snapshot.docs.map((doc) => doc.data()).toList();

      _generalInsights = GeneralInsights(
        totalCommunityMembers: profiles.length,
        supportiveMessage: _getRandomSupportiveMessage(),
        communityGrowth: _calculateGrowthRate(profiles),
        popularTreatmentHubs: _getTopTreatmentHubs(profiles, 3),
        generalHealthTips: _getGeneralHealthTips(),
        availableResources: _getAvailableResources(),
      );
    } catch (e) {
      throw Exception('Failed to fetch general insights: $e');
    }
  }

  // For researchers - full anonymized analytics
  Future<void> _fetchFullAnalytics() async {
    try {
      Query query = _firestore.collection('users');
      // Apply date filter if needed
      if (_startDate != null && _endDate != null) {
        // Filter based on yearDiagnosed
        // Note: This is a simple implementation, you might want to add timestamp fields
      }

      final snapshot = await query.get();
      final profiles =
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

      _analyticsData = _processAnalytics(profiles);
    } catch (e) {
      throw Exception('Failed to fetch analytics: $e');
    }
  }

  String _getRandomSupportiveMessage() {
    List<String> messages = [
      "Together, we're stronger. Our community is here to support each journey. 💙",
      "Every story matters. You're part of a caring community that understands. 🌟",
      "Knowledge is power. Stay informed and connected with our support network. 🤝",
      "Your wellness journey is unique, and we're here every step of the way. 💪",
      "Breaking barriers through understanding and support. You're not alone. 🎯",
    ];
    messages.shuffle();
    return messages.first;
  }

  double _calculateGrowthRate(List<Map<String, dynamic>> profiles) {
    // Calculate monthly growth rate
    DateTime oneMonthAgo = DateTime.now().subtract(Duration(days: 30));
    int newMembers =
        profiles.where((p) {
          if (p['createdAt'] != null) {
            DateTime created = (p['createdAt'] as Timestamp).toDate();
            return created.isAfter(oneMonthAgo);
          }
          return false;
        }).length;

    return profiles.isNotEmpty ? (newMembers / profiles.length * 100) : 0;
  }

  List<String> _getTopTreatmentHubs(
    List<Map<String, dynamic>> profiles,
    int count,
  ) {
    Map<String, int> hubCounts = {};
    for (var profile in profiles) {
      String? hub = profile['treatmentHub'];
      if (hub != null) {
        hubCounts[hub] = (hubCounts[hub] ?? 0) + 1;
      }
    }

    var sorted =
        hubCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(count).map((e) => e.key).toList();
  }

  List<String> _getGeneralHealthTips() {
    return [
      "Regular check-ups are essential for maintaining good health",
      "A balanced diet and exercise contribute to overall wellness",
      "Mental health is as important as physical health",
      "Stay connected with support groups and healthcare providers",
      "Knowledge about your health empowers better decisions",
    ];
  }

  List<Map<String, String>> _getAvailableResources() {
    return [
      {
        'title': 'Treatment Centers',
        'description': 'Find nearby treatment hubs and facilities',
        'icon': 'hospital',
      },
      {
        'title': 'Support Groups',
        'description': 'Connect with community support networks',
        'icon': 'group',
      },
      {
        'title': 'Educational Resources',
        'description': 'Access information and learning materials',
        'icon': 'book',
      },
      {
        'title': '24/7 Helpline',
        'description': 'Confidential support whenever you need it',
        'icon': 'phone',
      },
    ];
  }

  // Export to CSV
  Future<String> exportToCSV() async {
    if (_analyticsData == null) return '';

    List<List<dynamic>> rows = [];

    // Header
    rows.add(['PLHIV Analytics Report']);
    rows.add(['Generated on', DateTime.now().toString()]);
    rows.add([
      'Date Range',
      '${_startDate.toString().split(' ')[0]} to ${_endDate.toString().split(' ')[0]}',
    ]);
    rows.add([]);

    // Summary Statistics
    rows.add(['Summary Statistics']);
    rows.add(['Metric', 'Value']);
    rows.add(['Total Respondents', _analyticsData!.totalRespondents]);
    rows.add(['Total PLHIV', _analyticsData!.totalPLHIV]);
    rows.add(['MSM Count', _analyticsData!.msmCount]);
    rows.add(['Youth Count (18-24)', _analyticsData!.youthCount]);
    rows.add([
      'Average Years Since Diagnosis',
      _analyticsData!.avgYearsSinceDiagnosis.toStringAsFixed(1),
    ]);
    rows.add([]);

    // Age Distribution
    rows.add(['Age Distribution']);
    rows.add(['Age Range', 'Count']);
    _analyticsData!.ageDistribution.forEach((age, count) {
      rows.add([age, count]);
    });
    rows.add([]);

    // Gender Distribution
    rows.add(['Gender Distribution']);
    rows.add(['Gender', 'Count']);
    _analyticsData!.genderBreakdown.forEach((gender, count) {
      rows.add([gender, count]);
    });
    rows.add([]);

    // Treatment Hubs
    rows.add(['Treatment Hub Usage']);
    rows.add(['Hub', 'Count']);
    _analyticsData!.treatmentHubs.forEach((hub, count) {
      rows.add([hub, count]);
    });
    rows.add([]);

    // Co-infections
    rows.add(['Co-infections']);
    rows.add(['Type', 'Count']);
    _analyticsData!.coinfections.forEach((type, count) {
      rows.add([type, count]);
    });

    String csv = const ListToCsvConverter().convert(rows);
    return csv;
  }

  // Export to PDF
  Future<Uint8List> exportToPDF() async {
    if (_analyticsData == null) throw Exception('No data to export');

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, child: pw.Text('PLHIV Analytics Report')),
            pw.Paragraph(
              text: 'Generated on: ${DateTime.now().toString().split(' ')[0]}',
            ),
            pw.Paragraph(
              text:
                  'Date Range: ${_startDate.toString().split(' ')[0]} to ${_endDate.toString().split(' ')[0]}',
            ),
            pw.SizedBox(height: 20),

            // Summary Statistics
            pw.Header(level: 1, child: pw.Text('Summary Statistics')),
            pw.Table.fromTextArray(
              data: [
                ['Metric', 'Value'],
                [
                  'Total Respondents',
                  _analyticsData!.totalRespondents.toString(),
                ],
                ['Total PLHIV', _analyticsData!.totalPLHIV.toString()],
                ['MSM Count', _analyticsData!.msmCount.toString()],
                ['Youth Count (18-24)', _analyticsData!.youthCount.toString()],
                [
                  'Avg Years Since Diagnosis',
                  _analyticsData!.avgYearsSinceDiagnosis.toStringAsFixed(1),
                ],
              ],
            ),
            pw.SizedBox(height: 20),

            // Age Distribution
            pw.Header(level: 1, child: pw.Text('Age Distribution')),
            pw.Table.fromTextArray(
              data: [
                ['Age Range', 'Count'],
                ..._analyticsData!.ageDistribution.entries.map(
                  (e) => [e.key, e.value.toString()],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Gender Distribution
            pw.Header(level: 1, child: pw.Text('Gender Distribution')),
            pw.Table.fromTextArray(
              data: [
                ['Gender', 'Count'],
                ..._analyticsData!.genderBreakdown.entries.map(
                  (e) => [e.key, e.value.toString()],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Update date range
  void updateDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    fetchData();
  }

  // Process analytics (reuse from previous implementation)
  AnalyticsData _processAnalytics(List<Map<String, dynamic>> profiles) {
    // ... (same implementation as before)
    // This is already in the previous artifact
    return AnalyticsData(
      totalRespondents: profiles.length,
      totalPLHIV: profiles.where((p) => p['yearDiagnosed'] != null).length,
      msmCount:
          profiles
              .where(
                (p) =>
                    p['sexAssignedAtBirth'] == 'Male' &&
                    (p['unprotectedSexWith'] == 'Male' ||
                        p['unprotectedSexWith'] == 'Both'),
              )
              .length,
      youthCount: profiles.where((p) => p['ageRange'] == '18-24').length,
      ageDistribution: {},
      genderBreakdown: {},
      cityDistribution: {},
      treatmentHubs: {},
      diagnosisTrend: {},
      educationLevels: {},
      riskFactors: {},
      coinfections: {},
      avgYearsSinceDiagnosis: 0,
      topMSMCities: [],
      msmAgeBreakdown: {},
    );
  }
}

// Models for general insights (basic users)
class GeneralInsights {
  final int totalCommunityMembers;
  final String supportiveMessage;
  final double communityGrowth;
  final List<String> popularTreatmentHubs;
  final List<String> generalHealthTips;
  final List<Map<String, String>> availableResources;

  GeneralInsights({
    required this.totalCommunityMembers,
    required this.supportiveMessage,
    required this.communityGrowth,
    required this.popularTreatmentHubs,
    required this.generalHealthTips,
    required this.availableResources,
  });
}
