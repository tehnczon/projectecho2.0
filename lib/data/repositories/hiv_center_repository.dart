// lib/data/repositories/hiv_center_repository.dart - UPDATED WITH FIRESTORE
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/hiv_center.dart';
import '../../models/service_type.dart';
import '../../services/firestore_service.dart';

// Extension for firstOrNull
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class HIVCenterRepository {
  static HIVCenterRepository? _instance;
  static HIVCenterRepository get instance =>
      _instance ??= HIVCenterRepository._();
  HIVCenterRepository._();

  final FirestoreService _firestoreService = FirestoreService.instance;
  List<HIVCenter>? _cachedCenters;
  Stream<List<HIVCenter>>? _centersStream;

  /// Get stream of HIV centers from Firestore
  Stream<List<HIVCenter>> getCentersStream() {
    _centersStream ??= _firestoreService.getCentersStream();
    return _centersStream!;
  }

  /// Get all HIV centers (fetches from Firestore)
  Future<List<HIVCenter>> getAllCenters() async {
    try {
      // Fetch fresh data from Firestore
      _cachedCenters = await _firestoreService.getAllCenters();
      return List.unmodifiable(_cachedCenters!);
    } catch (e) {
      print('Error in repository getAllCenters: $e');
      // Return cached data if available, otherwise empty list
      return _cachedCenters != null ? List.unmodifiable(_cachedCenters!) : [];
    }
  }

  /// Get all centers synchronously from cache
  List<HIVCenter> getCachedCenters() {
    return _cachedCenters != null ? List.unmodifiable(_cachedCenters!) : [];
  }

  /// Initialize and load centers from Firestore
  Future<void> initialize() async {
    try {
      _cachedCenters = await _firestoreService.getAllCenters();
      print(
        'Repository initialized with ${_cachedCenters?.length ?? 0} centers',
      );
    } catch (e) {
      print('Error initializing repository: $e');
    }
  }

  /// Get center by ID (first checks cache, then Firestore)
  Future<HIVCenter?> getCenterById(String id) async {
    // First check cache
    if (_cachedCenters != null) {
      final cached = _cachedCenters!.where((c) => c.id == id).firstOrNull;
      if (cached != null) return cached;
    }

    // If not in cache, fetch from Firestore
    try {
      final center = await _firestoreService.getCenterById(id);

      // Update cache if center found
      if (center != null && _cachedCenters != null) {
        _cachedCenters!.removeWhere((c) => c.id == id);
        _cachedCenters!.add(center);
      }

      return center;
    } catch (e) {
      print('Error fetching center by ID: $e');
      return null;
    }
  }

  /// Search centers by query
  Future<List<HIVCenter>> searchCenters(String query) async {
    if (query.trim().isEmpty) return await getAllCenters();

    final centers = await getAllCenters();
    return centers.where((center) => center.matchesQuery(query)).toList();
  }

  /// Filter centers by criteria
  Future<List<HIVCenter>> filterCenters({
    bool showTreatmentHubs = true,
    bool showPrepSites = true,
    bool showTestingSites = true,
    bool showLaboratory = true,
    bool showMultiService = true,
  }) async {
    final centers = await getAllCenters();
    return centers
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
  Future<List<HIVCenter>> getCentersByService(ServiceType serviceType) async {
    final centers = await getAllCenters();
    return centers
        .where((center) => center.services.contains(serviceType))
        .toList();
  }

  /// Get multi-service centers only
  Future<List<HIVCenter>> getMultiServiceCenters() async {
    final centers = await getAllCenters();
    return centers.where((center) => center.isMultiService).toList();
  }

  /// Get centers currently open
  Future<List<HIVCenter>> getOpenCenters() async {
    final centers = await getAllCenters();
    return centers.where((center) => center.isOpenNow).toList();
  }

  /// Get centers within radius (in kilometers)
  Future<List<HIVCenter>> getCentersNearby(
    LatLng userLocation,
    double radiusKm,
  ) async {
    final centers = await getAllCenters();
    return centers.where((center) {
      final distance = _calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        center.position.latitude,
        center.position.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  /// Save or update a center
  Future<void> saveCenter(HIVCenter center) async {
    try {
      await _firestoreService.saveCenter(center);

      // Update cache
      if (_cachedCenters != null) {
        _cachedCenters!.removeWhere((c) => c.id == center.id);
        _cachedCenters!.add(center);
      }
    } catch (e) {
      print('Error saving center: $e');
      throw e;
    }
  }

  /// Delete a center
  Future<void> deleteCenter(String centerId) async {
    try {
      await _firestoreService.deleteCenter(centerId);

      // Update cache
      if (_cachedCenters != null) {
        _cachedCenters!.removeWhere((c) => c.id == centerId);
      }
    } catch (e) {
      print('Error deleting center: $e');
      throw e;
    }
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

  /// Force refresh from Firestore
  Future<void> refresh() async {
    clearCache();
    await initialize();
  }
}
