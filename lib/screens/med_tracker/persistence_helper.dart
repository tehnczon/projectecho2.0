import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Helper class to handle offline medication logs
class OfflinePersistenceHelper {
  static const String _pendingLogsKey = 'pending_medication_logs';

  /// Save medication log locally when offline
  static Future<void> savePendingLog({
    required String uid,
    required DateTime takenDate,
    required int inventoryBefore,
    required int inventoryAfter,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingLogs = await getPendingLogs();

      pendingLogs.add({
        'uid': uid,
        'takenDate': takenDate.toIso8601String(),
        'inventoryBefore': inventoryBefore,
        'inventoryAfter': inventoryAfter,
        'savedAt': DateTime.now().toIso8601String(),
      });

      await prefs.setString(_pendingLogsKey, jsonEncode(pendingLogs));
      print('✅ Saved medication log offline');
    } catch (e) {
      print('❌ Error saving offline log: $e');
    }
  }

  /// Get all pending logs
  static Future<List<Map<String, dynamic>>> getPendingLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_pendingLogsKey);

      if (logsJson == null || logsJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(logsJson);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print('❌ Error getting pending logs: $e');
      return [];
    }
  }

  /// Check if there are pending logs to sync
  static Future<bool> hasPendingLogs() async {
    final logs = await getPendingLogs();
    return logs.isNotEmpty;
  }

  /// Clear all pending logs after successful sync
  static Future<void> clearPendingLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingLogsKey);
      print('✅ Cleared pending logs');
    } catch (e) {
      print('❌ Error clearing pending logs: $e');
    }
  }

  /// Get count of pending logs
  static Future<int> getPendingLogsCount() async {
    final logs = await getPendingLogs();
    return logs.length;
  }
}
