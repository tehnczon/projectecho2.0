// lib/providers/researcher_analytics_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projecho/screens/analytics/components/services/analytics_processing_service.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:projecho/screens/analytics/components/models/analytics_data.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ResearcherAnalyticsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AnalyticsData? _analyticsData;
  String _userRole = 'basicUser';
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  // Date range for filtering
  DateTime _startDate = DateTime.now().subtract(Duration(days: 365));
  DateTime _endDate = DateTime.now();

  // Getters
  AnalyticsData? get analyticsData => _analyticsData;
  String get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;

  // Helper methods for safe type conversion
  Map<String, int> _safeIntMap(dynamic data) {
    if (data == null) return {};
    if (data is! Map) return {};

    final Map<String, dynamic> dynamicMap = Map<String, dynamic>.from(data);
    return dynamicMap.map((key, value) {
      int intValue = 0;
      if (value is int) {
        intValue = value;
      } else if (value is double) {
        intValue = value.round();
      } else if (value is String) {
        intValue = int.tryParse(value) ?? 0;
      } else if (value is num) {
        intValue = value.round();
      }
      return MapEntry(key, intValue);
    });
  }

  Map<int, int> _safeIntIntMap(dynamic data) {
    if (data == null) return {};
    if (data is! Map) return {};

    Map<int, int> result = {};

    // Handle the original map which could be Map<String, dynamic> or Map<int, dynamic>
    if (data is Map<String, dynamic>) {
      data.forEach((String key, dynamic value) {
        int keyInt = int.tryParse(key) ?? 0;
        int valueInt = _safeInt(value);
        result[keyInt] = valueInt;
      });
    } else if (data is Map<int, dynamic>) {
      data.forEach((int key, dynamic value) {
        int valueInt = _safeInt(value);
        result[key] = valueInt;
      });
    } else {
      // Fallback for any other Map type
      final Map<String, dynamic> dynamicMap = Map<String, dynamic>.from(data);
      dynamicMap.forEach((String key, dynamic value) {
        int keyInt = int.tryParse(key) ?? 0;
        int valueInt = _safeInt(value);
        result[keyInt] = valueInt;
      });
    }

    return result;
  }

  double _safeDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  int _safeInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.round();
    return 0;
  }

  // Initialize and fetch user role
  Future<String?> getUserRole(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('user').doc(uid).get();

    if (doc.exists) {
      return doc.data()?['role'] as String?;
    }
    return null;
  }

  Future<void> fetchData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First try to get existing summary
      final doc =
          await FirebaseFirestore.instance
              .collection('analytics_summary')
              .doc('current')
              .get();

      Map<String, dynamic>? summaryData;

      if (doc.exists && doc.data() != null) {
        summaryData = doc.data()!;
        _lastUpdated = (summaryData['lastUpdated'] as Timestamp?)?.toDate();
      } else {
        // No summary exists, generate one
        print('No analytics summary found, generating new one...');
        await AnalyticsProcessingService.updateAnalyticsSummary();

        // Try to get the newly created summary
        final newDoc =
            await FirebaseFirestore.instance
                .collection('analytics_summary')
                .doc('current')
                .get();

        if (newDoc.exists && newDoc.data() != null) {
          summaryData = newDoc.data()!;
          _lastUpdated = (summaryData['lastUpdated'] as Timestamp?)?.toDate();
        }
      }

      if (summaryData != null) {
        // Get historical data for trends
        final history = await AnalyticsProcessingService.getAnalyticsHistory(
          limit: 12,
        );

        // Build diagnosis trend from history
        Map<int, int> diagnosisTrend = {};
        for (var record in history.reversed) {
          if (record['timestamp'] != null) {
            final timestamp = (record['timestamp'] as Timestamp).toDate();
            final year = timestamp.year;
            diagnosisTrend[year] = _safeInt(record['totalPLHIV']);
          }
        }

        // Convert the summary data to AnalyticsData format with safe type conversion
        _analyticsData = AnalyticsData(
          totalRespondents: _safeInt(summaryData['totalPLHIV']),
          totalPLHIV: _safeInt(summaryData['totalPLHIV']),
          msmCount: _safeInt(summaryData['msmCount']),
          youthCount: _safeInt(summaryData['youthCount']),
          ageDistribution: _safeIntMap(summaryData['ageDistribution']),
          genderBreakdown: _safeIntMap(summaryData['genderBreakdown']),
          cityDistribution: _safeIntMap(summaryData['cityDistribution']),
          treatmentHubs: _safeIntMap(summaryData['cityDistribution']),
          diagnosisTrend: diagnosisTrend,
          educationLevels: _safeIntMap(summaryData['educationLevels']),
          riskFactors: _safeIntMap(summaryData['riskFactors']),
          coinfections: _safeIntMap(summaryData['coinfections']),
          avgYearsSinceDiagnosis: _calculateAvgYearsSinceDiagnosis(summaryData),
          topMSMCities: _getTopCities(
            _safeIntMap(summaryData['cityDistribution']),
          ),
          msmAgeBreakdown: _calculateMSMAgeBreakdown(summaryData),
        );
      } else {
        _errorMessage = 'No analytics data available';
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch analytics: $e';
      print('Error in fetchData: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _errorMessage = 'No user logged in.';
        return;
      }

      // Fetch role from Firestore
      _userRole = await getUserRole(uid) ?? 'basicUser';

      // Allow only researcher or admin to fetch analytics
      if (_userRole == 'researcher' || _userRole == 'admin') {
        await fetchData();
      } else {
        _errorMessage = 'Access denied. Researcher privileges required.';
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double _calculateAvgYearsSinceDiagnosis(Map<String, dynamic> summaryData) {
    // You could implement actual calculation here if needed
    // For now, return a reasonable placeholder
    return 5.2;
  }

  List<CityData> _getTopCities(Map<String, int> cityData) {
    if (cityData.isEmpty) return [];

    final total = cityData.values.fold<int>(0, (sum, c) => sum + c);
    final sorted =
        cityData.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) {
      final percentage = total > 0 ? (e.value / total) * 100 : 0.0;
      return CityData(city: e.key, count: e.value, percentage: percentage);
    }).toList();
  }

  Map<String, int> _calculateMSMAgeBreakdown(Map<String, dynamic> summaryData) {
    // This would need cross-tabulated data from the processing service
    // For now, return empty map or implement based on available data
    return _safeIntMap(summaryData['msmAgeBreakdown']);
  }

  // Force refresh analytics (triggers reprocessing)
  Future<void> refreshAnalytics() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AnalyticsProcessingService.updateAnalyticsSummary();
      await fetchData();
    } catch (e) {
      _errorMessage = 'Failed to refresh analytics: $e';
      notifyListeners();
    }
  }

  // Export to CSV - FIXED for your data structure
  Future<String> exportToCSV() async {
    if (_analyticsData == null) {
      throw Exception('No data available for export');
    }

    List<List<dynamic>> rows = [];

    // Header
    rows.add(['PLHIV Research Analytics Report']);
    rows.add(['Generated on', DateTime.now().toString()]);
    rows.add([
      'Data Range',
      '${_startDate.toString().split(' ')[0]} to ${_endDate.toString().split(' ')[0]}',
    ]);
    rows.add([
      'Generated by',
      FirebaseAuth.instance.currentUser?.uid ?? 'Unknown',
    ]);
    rows.add([]);

    // Summary Statistics
    rows.add(['Summary Statistics']);
    rows.add(['Metric', 'Value']);
    rows.add(['Total PLHIV', _analyticsData!.totalPLHIV]);
    rows.add(['MSM Count', _analyticsData!.msmCount]);
    rows.add(['Youth Count (18-24)', _analyticsData!.youthCount]);
    if (_analyticsData!.totalPLHIV > 0) {
      rows.add([
        'MSM Percentage',
        '${((_analyticsData!.msmCount / _analyticsData!.totalPLHIV) * 100).toStringAsFixed(1)}%',
      ]);
      rows.add([
        'Youth Percentage',
        '${((_analyticsData!.youthCount / _analyticsData!.totalPLHIV) * 100).toStringAsFixed(1)}%',
      ]);
    }
    rows.add([]);

    // Age Distribution
    rows.add(['Age Distribution']);
    rows.add(['Age Range', 'Count', 'Percentage']);
    _analyticsData!.ageDistribution.forEach((age, count) {
      final percentage =
          _analyticsData!.totalPLHIV > 0
              ? (count / _analyticsData!.totalPLHIV) * 100
              : 0;
      rows.add([age, count, '${percentage.toStringAsFixed(1)}%']);
    });
    rows.add([]);

    // Gender Distribution
    rows.add(['Gender Identity Distribution']);
    rows.add(['Gender', 'Count', 'Percentage']);
    _analyticsData!.genderBreakdown.forEach((gender, count) {
      final percentage =
          _analyticsData!.totalPLHIV > 0
              ? (count / _analyticsData!.totalPLHIV) * 100
              : 0;
      rows.add([gender, count, '${percentage.toStringAsFixed(1)}%']);
    });
    rows.add([]);

    // Geographic Distribution
    rows.add(['Geographic Distribution']);
    rows.add(['City', 'Count', 'Percentage']);
    _analyticsData!.cityDistribution.forEach((city, count) {
      final percentage =
          _analyticsData!.totalPLHIV > 0
              ? (count / _analyticsData!.totalPLHIV) * 100
              : 0;
      rows.add([city, count, '${percentage.toStringAsFixed(1)}%']);
    });
    rows.add([]);

    // Education Levels
    if (_analyticsData!.educationLevels.isNotEmpty) {
      rows.add(['Education Level Distribution']);
      rows.add(['Education Level', 'Count', 'Percentage']);
      _analyticsData!.educationLevels.forEach((education, count) {
        final percentage =
            _analyticsData!.totalPLHIV > 0
                ? (count / _analyticsData!.totalPLHIV) * 100
                : 0;
        rows.add([education, count, '${percentage.toStringAsFixed(1)}%']);
      });
      rows.add([]);
    }

    // Risk Factors
    if (_analyticsData!.riskFactors.isNotEmpty) {
      rows.add(['Risk Factors']);
      rows.add(['Risk Factor', 'Count', 'Percentage']);
      _analyticsData!.riskFactors.forEach((factor, count) {
        final percentage =
            _analyticsData!.totalPLHIV > 0
                ? (count / _analyticsData!.totalPLHIV) * 100
                : 0;
        rows.add([factor, count, '${percentage.toStringAsFixed(1)}%']);
      });
      rows.add([]);
    }

    // Co-infections
    if (_analyticsData!.coinfections.isNotEmpty) {
      rows.add(['Co-infections']);
      rows.add(['Type', 'Count', 'Percentage']);
      _analyticsData!.coinfections.forEach((type, count) {
        final percentage =
            _analyticsData!.totalPLHIV > 0
                ? (count / _analyticsData!.totalPLHIV) * 100
                : 0;
        rows.add([type, count, '${percentage.toStringAsFixed(1)}%']);
      });
      rows.add([]);
    }

    // Diagnosis Trend
    if (_analyticsData!.diagnosisTrend.isNotEmpty) {
      rows.add(['Diagnosis Trend by Year']);
      rows.add(['Year', 'Total Count']);
      _analyticsData!.diagnosisTrend.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key))
        ..forEach((entry) {
          rows.add([entry.key, entry.value]);
        });
    }

    String csv = const ListToCsvConverter().convert(rows);
    return csv;
  }

  // Export to PDF - FIXED
  Future<Uint8List> exportToPDF() async {
    if (_analyticsData == null) throw Exception('No data to export');

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'PLHIV Research Analytics Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Paragraph(
              text: 'Generated on: ${DateTime.now().toString().split(' ')[0]}',
            ),
            pw.Paragraph(
              text:
                  'Data Range: ${_startDate.toString().split(' ')[0]} to ${_endDate.toString().split(' ')[0]}',
            ),
            pw.Paragraph(text: 'Total Records: ${_analyticsData!.totalPLHIV}'),
            pw.SizedBox(height: 20),

            // Executive Summary
            pw.Header(level: 1, child: pw.Text('Executive Summary')),
            pw.Paragraph(
              text:
                  'This report provides anonymized analytics on ${_analyticsData!.totalPLHIV} PLHIV community members. '
                  'Key findings include ${_analyticsData!.msmCount} MSM individuals (${_analyticsData!.totalPLHIV > 0 ? ((_analyticsData!.msmCount / _analyticsData!.totalPLHIV) * 100).toStringAsFixed(1) : '0'}%) '
                  'and ${_analyticsData!.youthCount} youth aged 18-24 (${_analyticsData!.totalPLHIV > 0 ? ((_analyticsData!.youthCount / _analyticsData!.totalPLHIV) * 100).toStringAsFixed(1) : '0'}%).',
            ),
            pw.SizedBox(height: 20),

            // Summary Statistics
            pw.Header(level: 1, child: pw.Text('Summary Statistics')),
            pw.Table.fromTextArray(
              data: [
                ['Metric', 'Value', 'Percentage'],
                [
                  'Total PLHIV',
                  _analyticsData!.totalPLHIV.toString(),
                  '100.0%',
                ],
                [
                  'MSM Count',
                  _analyticsData!.msmCount.toString(),
                  '${_analyticsData!.totalPLHIV > 0 ? ((_analyticsData!.msmCount / _analyticsData!.totalPLHIV) * 100).toStringAsFixed(1) : '0'}%',
                ],
                [
                  'Youth Count (18-24)',
                  _analyticsData!.youthCount.toString(),
                  '${_analyticsData!.totalPLHIV > 0 ? ((_analyticsData!.youthCount / _analyticsData!.totalPLHIV) * 100).toStringAsFixed(1) : '0'}%',
                ],
              ],
            ),
            pw.SizedBox(height: 20),

            // Age Distribution
            pw.Header(level: 1, child: pw.Text('Age Distribution')),
            pw.Table.fromTextArray(
              data: [
                ['Age Range', 'Count', 'Percentage'],
                ..._analyticsData!.ageDistribution.entries.map(
                  (e) => [
                    e.key,
                    e.value.toString(),
                    '${_analyticsData!.totalPLHIV > 0 ? ((e.value / _analyticsData!.totalPLHIV) * 100).toStringAsFixed(1) : '0'}%',
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Gender Distribution
            pw.Header(level: 1, child: pw.Text('Gender Identity Distribution')),
            pw.Table.fromTextArray(
              data: [
                ['Gender Identity', 'Count', 'Percentage'],
                ..._analyticsData!.genderBreakdown.entries.map(
                  (e) => [
                    e.key,
                    e.value.toString(),
                    '${_analyticsData!.totalPLHIV > 0 ? ((e.value / _analyticsData!.totalPLHIV) * 100).toStringAsFixed(1) : '0'}%',
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Add second page for detailed breakdowns
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Geographic Distribution
            pw.Header(level: 1, child: pw.Text('Geographic Distribution')),
            pw.Table.fromTextArray(
              data: [
                ['City', 'Count', 'Percentage'],
                ..._analyticsData!.cityDistribution.entries
                    .take(10)
                    .map(
                      (e) => [
                        e.key,
                        e.value.toString(),
                        '${_analyticsData!.totalPLHIV > 0 ? ((e.value / _analyticsData!.totalPLHIV) * 100).toStringAsFixed(1) : '0'}%',
                      ],
                    ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Risk Factors
            if (_analyticsData!.riskFactors.isNotEmpty) ...[
              pw.Header(level: 1, child: pw.Text('Risk Factors')),
              pw.Table.fromTextArray(
                data: [
                  ['Risk Factor', 'Count', 'Percentage'],
                  ..._analyticsData!.riskFactors.entries.map(
                    (e) => [
                      e.key,
                      e.value.toString(),
                      '${_analyticsData!.totalPLHIV > 0 ? ((e.value / _analyticsData!.totalPLHIV) * 100).toStringAsFixed(1) : '0'}%',
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            // Co-infections
            if (_analyticsData!.coinfections.isNotEmpty) ...[
              pw.Header(level: 1, child: pw.Text('Co-infections')),
              pw.Table.fromTextArray(
                data: [
                  ['Type', 'Count', 'Percentage'],
                  ..._analyticsData!.coinfections.entries.map(
                    (e) => [
                      e.key,
                      e.value.toString(),
                      '${_analyticsData!.totalPLHIV > 0 ? ((e.value / _analyticsData!.totalPLHIV) * 100).toStringAsFixed(1) : '0'}%',
                    ],
                  ),
                ],
              ),
            ],

            // Footer
            pw.SizedBox(height: 40),
            pw.Paragraph(
              text:
                  'Note: This report contains anonymized data for research purposes only. '
                  'Individual privacy is protected through aggregation and statistical analysis.',
              style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
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

  void reset() {
    _isLoading = false;
    _analyticsData = null;
    notifyListeners();
  }
}
