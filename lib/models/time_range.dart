import 'package:flutter/material.dart';

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRange({required this.start, required this.end});

  bool isTimeInRange(TimeOfDay time) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return timeMinutes >= startMinutes && timeMinutes < endMinutes;
  }

  factory TimeRange.fromMap(Map<String, dynamic> map) {
    return TimeRange(
      start: TimeOfDay(
        hour: map['start_hour'] as int,
        minute: map['start_minute'] as int,
      ),
      end: TimeOfDay(
        hour: map['end_hour'] as int,
        minute: map['end_minute'] as int,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start_hour': start.hour,
      'start_minute': start.minute,
      'end_hour': end.hour,
      'end_minute': end.minute,
    };
  }

  @override
  String toString() {
    return '${formatTimeOfDay(start)} - ${formatTimeOfDay(end)}';
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hourStr = hour == 0 ? '12' : hour.toString();
    final minuteStr = time.minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }
}
