// lib/data/repositories/hiv_center_repository.dart
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/hiv_center.dart';
import '../../models/service_type.dart';

// Import the data source (we'll create this next)
import '../datasources/hiv_center_data.dart';

// Extension for firstOrNull (if not using Dart 2.17+)
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class HIVCenterRepository {
  static HIVCenterRepository? _instance;
  static HIVCenterRepository get instance =>
      _instance ??= HIVCenterRepository._();
  HIVCenterRepository._();

  List<HIVCenter>? _cachedCenters;

  /// Get all HIV centers
  List<HIVCenter> getAllCenters() {
    _cachedCenters ??= HIVCenterData.getAllCenters();
    return List.unmodifiable(_cachedCenters!);
  }

  /// Get center by ID
  HIVCenter? getCenterById(String id) {
    return getAllCenters().where((center) => center.id == id).firstOrNull;
  }

  /// Search centers by query
  List<HIVCenter> searchCenters(String query) {
    if (query.trim().isEmpty) return getAllCenters();

    return getAllCenters()
        .where((center) => center.matchesQuery(query))
        .toList();
  }

  /// Filter centers by criteria
  List<HIVCenter> filterCenters({
    bool showTreatmentHubs = true,
    bool showPrepSites = true,
    bool showTestingSites = true,
    bool showLaboratory = true,
    bool showMultiService = true,
  }) {
    return getAllCenters()
        .where(
          (center) => center.matchesFilter(
            showTreatment: showTreatmentHubs,
            showPrep: showPrepSites,
            showTesting: showTestingSites,
            showLaboratory: showLaboratory,
            showMultiService: showMultiService,
          ),
        )
        .toList();
  }

  /// Get centers by service type
  List<HIVCenter> getCentersByService(ServiceType serviceType) {
    return getAllCenters()
        .where((center) => center.services.contains(serviceType))
        .toList();
  }

  /// Get multi-service centers only
  List<HIVCenter> getMultiServiceCenters() {
    return getAllCenters().where((center) => center.isMultiService).toList();
  }

  /// Get centers currently open
  List<HIVCenter> getOpenCenters() {
    return getAllCenters().where((center) => center.isOpenNow).toList();
  }

  /// Get centers within radius (in kilometers)
  List<HIVCenter> getCentersNearby(LatLng userLocation, double radiusKm) {
    return getAllCenters().where((center) {
      final distance = _calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        center.position.latitude,
        center.position.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  /// Calculate distance between two points in kilometers
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (pi / 180);

  /// Clear cache (useful for testing or data refresh)
  void clearCache() {
    _cachedCenters = null;
  }
}
