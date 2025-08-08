import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppConstants {
  // Map constants
  static const LatLng davaoCityCenter = LatLng(7.0731, 125.6128);
  static const double defaultZoom = 11.0;
  static const double selectedZoom = 15.0;

  // Search constants
  static const String searchHint = 'Search HIV centers...';

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration mapAnimationDuration = Duration(milliseconds: 500);

  // Spacing constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border radius
  static const double defaultBorderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 24.0;
}

class AppColors {
  // Service type colors
  static const Color treatmentColor = Color(0xFF4CAF50);
  static const Color prepColor = Color(0xFF2196F3);
  static const Color testingColor = Color(0xFFF44336);
  static const Color laboratoryColor = Color(0xFFFF9800);
  static const Color multiServiceColor = Color(0xFF9C27B0);

  // Status colors
  static const Color openColor = Color(0xFF4CAF50);
  static const Color closedColor = Color(0xFFF44336);
  static const Color loadingColor = Color(0xFF2196F3);

  // Neutral colors
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF616161);
}

// lib/utils/extensions.dart
extension TimeOfDayExtension on TimeOfDay {
  String get formatted {
    final hour = hourOfPeriod;
    final period = this.period == DayPeriod.am ? 'AM' : 'PM';
    final hourStr = hour == 0 ? '12' : hour.toString();
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
