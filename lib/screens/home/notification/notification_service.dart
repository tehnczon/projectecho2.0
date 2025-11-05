import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ✅ Check if exact alarm permission is granted (Android 12+)
  Future<bool> hasExactAlarmPermission() async {
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      final canSchedule = await androidPlugin.canScheduleExactNotifications();
      print('📋 Can schedule exact notifications: $canSchedule');
      return canSchedule ?? false;
    }
    return true; // iOS or older Android versions
  }

  // ✅ Request exact alarm permission (Android 12+)
  Future<void> requestExactAlarmPermission() async {
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      final bool? granted = await androidPlugin.requestExactAlarmsPermission();
      print(
        granted == true
            ? '✅ Exact alarm permission granted'
            : '❌ Exact alarm permission denied or unavailable',
      );
    }
  }

  // ✅ Initialize notification service
  Future<void> initialize() async {
    if (_initialized) {
      print('ℹ️ Notification service already initialized');
      return;
    }

    print('🚀 Initializing notification service...');

    // Initialize time zones
    tz.initializeTimeZones();
    // ✅ Set to Philippines timezone (adjust if needed)
    tz.setLocalLocation(tz.getLocation('Asia/Manila'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // ✅ Request permission for exact alarms (Android 12+)
    await requestExactAlarmPermission();

    _initialized = true;
    print('✅ Notification service initialized');
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('👆 Notification tapped: ${response.payload}');
    // You can add navigation logic here based on payload
  }

  // Request notification permissions (iOS & Android 13+)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    // For Android 13+
    final androidPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      print('📱 Android notification permission: $granted');
    }

    // For iOS
    final iosPlugin =
        _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    final iosResult = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return iosResult ?? true;
  }

  // ✅ Schedule daily medication reminder (AT medication time, not before)
  Future<bool> scheduleMedicationReminder(String medicationTime) async {
    if (!_initialized) await initialize();

    try {
      // Check permission first
      final hasPermission = await hasExactAlarmPermission();
      if (!hasPermission) {
        print('❌ No exact alarm permission. Requesting...');
        await requestExactAlarmPermission();
        return false;
      }

      // Cancel existing reminder first
      await _notifications.cancel(0);
      print('🗑️ Cancelled existing medication reminder');

      // Parse time (format: "HH:mm AM/PM" or "HH:mm")
      final timeParts = _parseTime(medicationTime);
      if (timeParts == null) {
        print('❌ Invalid time format: $medicationTime');
        return false;
      }

      print('🕐 Parsed time: ${timeParts['hour']}:${timeParts['minute']}');

      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        timeParts['hour']!,
        timeParts['minute']!,
      );

      print('⏰ Current time: $now');
      print('📅 Target time today: $scheduledTime');

      // If the time has passed today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
        print('➡️ Time passed, scheduling for tomorrow: $scheduledTime');
      }

      await _notifications.zonedSchedule(
        0, // ID for medication reminder
        '💊 Medication Reminder',
        'Time to take your medication!',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel',
            'Medication Reminders',
            channelDescription: 'Daily medication reminders',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            sound: RawResourceAndroidNotificationSound('notification_sound'),
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(sound: 'notification_sound.aiff'),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );

      // Verify it was scheduled
      final pending = await _notifications.pendingNotificationRequests();
      print(
        '✅ Medication reminder scheduled! Total pending: ${pending.length}',
      );
      print('📍 Scheduled for: ${scheduledTime.toString()}');

      return true;
    } catch (e) {
      print('❌ Error scheduling medication reminder: $e');
      return false;
    }
  }

  // ✅ Parse time string to hour and minute
  Map<String, int>? _parseTime(String timeStr) {
    try {
      // Remove spaces and convert to uppercase
      timeStr = timeStr.trim().toUpperCase();

      // Check if AM/PM format
      bool isPM = timeStr.contains('PM');
      bool isAM = timeStr.contains('AM');

      // Remove AM/PM
      timeStr = timeStr.replaceAll(RegExp(r'[AP]M'), '').trim();

      // Split by colon
      final parts = timeStr.split(':');
      if (parts.length != 2) {
        print('❌ Invalid format - expected HH:MM');
        return null;
      }

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      // Validate ranges
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        print('❌ Invalid time values: $hour:$minute');
        return null;
      }

      // Convert to 24-hour format if AM/PM is present
      if (isPM && hour != 12) {
        hour += 12;
      } else if (isAM && hour == 12) {
        hour = 0;
      }

      return {'hour': hour, 'minute': minute};
    } catch (e) {
      print('❌ Error parsing time: $e');
      return null;
    }
  }

  // Cancel medication reminder
  Future<void> cancelMedicationReminder() async {
    await _notifications.cancel(0);
    print('✅ Medication reminder cancelled');
  }

  // Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Show low inventory notification
  Future<void> showLowInventoryNotification(
    int currentInventory,
    int threshold,
  ) async {
    if (!_initialized) await initialize();

    await _notifications.show(
      1, // Notification ID for low inventory
      '⚠️ Low Medication Supply',
      'You have $currentInventory pills remaining (below threshold of $threshold). Please refill soon.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'inventory_channel',
          'Inventory Alerts',
          channelDescription: 'Alerts for low medication inventory',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFFFF9800),
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    print('✅ Low inventory notification shown');
  }

  // Show missed dose notification
  Future<void> showMissedDoseNotification(int consecutiveDays) async {
    if (!_initialized) await initialize();

    await _notifications.show(
      2, // Notification ID for missed doses
      '⚠️ Missed Medication',
      'You haven\'t taken your medication for $consecutiveDays consecutive days. Please remember to take it!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'missed_dose_channel',
          'Missed Dose Alerts',
          channelDescription: 'Alerts for missed medication doses',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFFF44336),
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    print('✅ Missed dose notification shown');
  }

  // Check for LTF (Lost to Follow-up) - 90 days without medication
  static Future<void> checkLostToFollowUp() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final firestore = FirebaseFirestore.instance;
      final medDoc =
          await firestore.collection('medicalTracker').doc(user.uid).get();

      if (!medDoc.exists) return;

      final data = medDoc.data()!;
      final lastTakenDate = data['lastTakenDate'] as Timestamp?;

      if (lastTakenDate == null) return;

      final daysSinceLastTaken =
          DateTime.now().difference(lastTakenDate.toDate()).inDays;

      // Check if 90 days (3 months) have passed
      if (daysSinceLastTaken >= 90) {
        final prefs = await SharedPreferences.getInstance();
        final alreadyReported =
            prefs.getBool('ltf_reported_${user.uid}') ?? false;

        if (!alreadyReported) {
          // Get user details
          final profileDoc =
              await firestore.collection('profiles').doc(user.uid).get();

          if (profileDoc.exists) {
            final profileData = profileDoc.data()!;
            final generatedUIC = profileData['generatedUIC'] ?? '';

            // Get treatment hub
            String treatmentHub = '';
            final roleDataDoc =
                await firestore
                    .collection('profiles')
                    .doc(user.uid)
                    .collection('roleData')
                    .doc('plhiv')
                    .get();

            if (roleDataDoc.exists) {
              treatmentHub = roleDataDoc.data()?['treatmentHub'] ?? '';
            }

            // Send LTF alert to admin
            await firestore.collection('adminAlerts').add({
              'type': 'lostToFollowUp',
              'uid': user.uid,
              'generatedUIC': generatedUIC,
              'treatmentHub': treatmentHub,
              'daysSinceLastTaken': daysSinceLastTaken,
              'lastTakenDate': lastTakenDate,
              'message':
                  'Patient $generatedUIC has not taken medication for $daysSinceLastTaken days (LTF)',
              'status': 'pending',
              'priority': 'high',
              'timestamp': FieldValue.serverTimestamp(),
            });

            // Mark as reported locally
            await prefs.setBool('ltf_reported_${user.uid}', true);

            print('✅ LTF alert sent to admin for UIC: $generatedUIC');

            // Show local notification
            final notificationService = NotificationService();
            await notificationService._notifications.show(
              3, // Notification ID for LTF
              '⚠️ Important Health Notice',
              'It\'s been $daysSinceLastTaken days since your last medication. Please contact your healthcare provider.',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'ltf_channel',
                  'Lost to Follow-up Alerts',
                  channelDescription:
                      'Critical alerts for extended medication absence',
                  importance: Importance.max,
                  priority: Priority.max,
                  color: Color(0xFFD32F2F),
                  icon: '@mipmap/ic_launcher',
                ),
                iOS: DarwinNotificationDetails(),
              ),
            );
          }
        }
      } else {
        // Reset LTF flag if user has taken medication again
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('ltf_reported_${user.uid}');
      }
    } catch (e) {
      print('❌ Error checking LTF: $e');
    }
  }

  // Get pending notifications count for badge
  Future<int> getPendingNotificationsCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 0;

      final firestore = FirebaseFirestore.instance;

      // Count unread center alerts
      final alertsSnapshot =
          await firestore
              .collection('centerAlerts')
              .where('uid', isEqualTo: user.uid)
              .where('status', isEqualTo: 'pending')
              .where('read', isEqualTo: false)
              .get();

      return alertsSnapshot.docs.length;
    } catch (e) {
      print('❌ Error getting notification count: $e');
      return 0;
    }
  }
}
