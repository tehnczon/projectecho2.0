import 'package:flutter/material.dart';
import 'time_range.dart';

class OperatingHours {
  final Map<String, TimeRange?> schedule;

  const OperatingHours({required this.schedule});

  bool isOpenNow() {
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final timeRange = schedule[dayName];

    if (timeRange == null) return false;

    final currentTime = TimeOfDay.fromDateTime(now);
    return timeRange.isTimeInRange(currentTime);
  }

  String getCurrentStatus() {
    if (isOpenNow()) {
      final now = DateTime.now();
      final dayName = _getDayName(now.weekday);
      final timeRange = schedule[dayName]!;
      final closingTime = timeRange.formatTimeOfDay(timeRange.end);
      return 'Open • Closes at $closingTime';
    } else {
      return getNextOpenTime();
    }
  }

  String getNextOpenTime() {
    final now = DateTime.now();

    // Check rest of today
    final todayName = _getDayName(now.weekday);
    final todayRange = schedule[todayName];
    if (todayRange != null) {
      final currentTime = TimeOfDay.fromDateTime(now);
      if (currentTime.hour < todayRange.start.hour ||
          (currentTime.hour == todayRange.start.hour &&
              currentTime.minute < todayRange.start.minute)) {
        return 'Closed • Opens at ${todayRange.formatTimeOfDay(todayRange.start)}';
      }
    }

    // Check next 7 days
    for (int i = 1; i <= 7; i++) {
      final nextDay = now.add(Duration(days: i));
      final dayName = _getDayName(nextDay.weekday);
      final timeRange = schedule[dayName];

      if (timeRange != null) {
        if (i == 1) {
          return 'Closed • Opens tomorrow at ${timeRange.formatTimeOfDay(timeRange.start)}';
        } else {
          return 'Closed • Opens $dayName at ${timeRange.formatTimeOfDay(timeRange.start)}';
        }
      }
    }

    return 'Closed';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  factory OperatingHours.fromMap(Map<String, dynamic> map) {
    final schedule = <String, TimeRange?>{};

    for (String day in [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ]) {
      final dayData = map[day];
      if (dayData != null && dayData is Map<String, dynamic>) {
        schedule[day] = TimeRange.fromMap(dayData);
      } else {
        schedule[day] = null;
      }
    }

    return OperatingHours(schedule: schedule);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    schedule.forEach((day, timeRange) {
      map[day] = timeRange?.toMap();
    });
    return map;
  }
}
