// lib/providers/map_provider.dart - DEBUG VERSION
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/hiv_center.dart';
import '../models/service_type.dart';
import '../data/repositories/hiv_center_repository.dart';

// Extension for firstOrNull
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class MapProvider extends ChangeNotifier {
  final HIVCenterRepository _repository = HIVCenterRepository.instance;

  // Core state
  List<HIVCenter> _allCenters = [];
  List<HIVCenter> _filteredCenters = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  HIVCenter? _selectedCenter;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isLoadingRoute = false;

  // Filter states
  bool _showTreatmentHubs = true;
  bool _showPrepSites = true;
  bool _showTestingSites = true;
  bool _showLaboratory = true;
  bool _showMultiService = true;

  // Google Map Controller
  GoogleMapController? _mapController;

  // Getters
  List<HIVCenter> get allCenters => List.unmodifiable(_allCenters);
  List<HIVCenter> get filteredCenters => List.unmodifiable(_filteredCenters);
  Set<Marker> get markers => Set.unmodifiable(_markers);
  Set<Polyline> get polylines => Set.unmodifiable(_polylines);
  HIVCenter? get selectedCenter => _selectedCenter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingRoute => _isLoadingRoute;
  bool get hasSelectedCenter => _selectedCenter != null;

  // Filter getters
  bool get showTreatmentHubs => _showTreatmentHubs;
  bool get showPrepSites => _showPrepSites;
  bool get showTestingSites => _showTestingSites;
  bool get showLaboratory => _showLaboratory;
  bool get showMultiService => _showMultiService;

  GoogleMapController? get mapController => _mapController;

  // Constants
  static const LatLng davaoCityCenter = LatLng(7.0731, 125.6128);

  /// Initialize the provider and load centers
  Future<void> initialize() async {
    print('🚀 MapProvider: Starting initialization...');
    _setLoading(true);
    try {
      _allCenters = _repository.getAllCenters();
      print('📊 MapProvider: Loaded ${_allCenters.length} centers');

      // Print first center for debugging
      if (_allCenters.isNotEmpty) {
        final first = _allCenters.first;
        print('📍 First center: ${first.name} at ${first.position}');
        print('🏷️ Category: ${first.category}, Services: ${first.services}');
      }

      await _applyFiltersAndSearch();
      print('✅ MapProvider: Initialization complete');
    } catch (e, stackTrace) {
      print('❌ MapProvider Error: $e');
      print('📜 Stack trace: $stackTrace');
    } finally {
      _setLoading(false);
    }
  }

  /// Set Google Map Controller
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    print('🗺️ MapProvider: Map controller set');
  }

  /// Search centers by query
  void searchCenters(String query) {
    if (_searchQuery == query) return;

    _searchQuery = query;
    print('🔍 MapProvider: Searching for "$query"');
    _applyFiltersAndSearch();
  }

  /// Update filter settings
  void updateFilters({
    bool? showTreatmentHubs,
    bool? showPrepSites,
    bool? showTestingSites,
    bool? showLaboratory,
    bool? showMultiService,
  }) {
    bool changed = false;

    if (showTreatmentHubs != null && _showTreatmentHubs != showTreatmentHubs) {
      _showTreatmentHubs = showTreatmentHubs;
      changed = true;
    }
    if (showPrepSites != null && _showPrepSites != showPrepSites) {
      _showPrepSites = showPrepSites;
      changed = true;
    }
    if (showTestingSites != null && _showTestingSites != showTestingSites) {
      _showTestingSites = showTestingSites;
      changed = true;
    }
    if (showLaboratory != null && _showLaboratory != showLaboratory) {
      _showLaboratory = showLaboratory;
      changed = true;
    }
    if (showMultiService != null && _showMultiService != showMultiService) {
      _showMultiService = showMultiService;
      changed = true;
    }

    if (changed) {
      print('🎛️ MapProvider: Filters updated');
      _applyFiltersAndSearch();
    }
  }

  /// Select a center by ID
  void selectCenter(String centerId) {
    print('🎯 MapProvider: Selecting center $centerId');
    // Use where().first instead of firstOrNull for now
    final centerList = _allCenters.where((c) => c.id == centerId).toList();
    final center = centerList.isNotEmpty ? centerList.first : null;

    if (center != _selectedCenter) {
      _selectedCenter = center;
      _clearRoute();

      // Animate camera to selected center
      if (center != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: center.position, zoom: 15.0),
          ),
        );
      }

      notifyListeners();
    }
  }

  /// Clear selection
  void clearSelection() {
    if (_selectedCenter != null) {
      _selectedCenter = null;
      _clearRoute();
      notifyListeners();
    }
  }

  /// Show route to selected center
  Future<void> showRoute(Position currentPosition) async {
    if (_selectedCenter == null) return;

    _setLoadingRoute(true);
    try {
      final route = Polyline(
        polylineId: const PolylineId('route'),
        points: [
          LatLng(currentPosition.latitude, currentPosition.longitude),
          _selectedCenter!.position,
        ],
        color: Colors.blue,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      );

      _polylines = {route};

      if (_mapController != null) {
        final bounds = _calculateBounds(
          LatLng(currentPosition.latitude, currentPosition.longitude),
          _selectedCenter!.position,
        );

        await _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100.0),
        );
      }

      notifyListeners();
    } catch (e) {
      print('❌ Error showing route: $e');
    } finally {
      _setLoadingRoute(false);
    }
  }

  /// Clear route
  void clearRoute() {
    _clearRoute();
  }

  /// Apply filters and search, then update markers
  Future<void> _applyFiltersAndSearch() async {
    print('🔧 MapProvider: Applying filters and search...');

    // Apply filters
    List<HIVCenter> filtered = _repository.filterCenters(
      showTreatmentHubs: _showTreatmentHubs,
      showPrepSites: _showPrepSites,
      showTestingSites: _showTestingSites,
      showLaboratory: _showLaboratory,
      showMultiService: _showMultiService,
    );

    print('📋 After filtering: ${filtered.length} centers');

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where((center) => center.matchesQuery(_searchQuery))
              .toList();
      print('🔍 After search: ${filtered.length} centers');
    }

    _filteredCenters = filtered;
    await _createMarkers();
    notifyListeners();
  }

  /// Create markers for filtered centers
  Future<void> _createMarkers() async {
    print(
      '📍 MapProvider: Creating markers for ${_filteredCenters.length} centers...',
    );
    final Set<Marker> newMarkers = {};

    try {
      for (int i = 0; i < _filteredCenters.length; i++) {
        final center = _filteredCenters[i];
        print('📌 Creating marker $i: ${center.name}');

        final marker = Marker(
          markerId: MarkerId(center.id),
          position: center.position,
          infoWindow: InfoWindow(
            title: center.name,
            snippet:
                center.isMultiService
                    ? 'Multi-Service Center'
                    : center.primaryService.label,
          ),
          icon: _getMarkerIcon(center),
          onTap: () {
            print('👆 Marker tapped: ${center.name}');
            selectCenter(center.id);
          },
        );
        newMarkers.add(marker);
        print('✅ Marker created for ${center.name}');
      }

      _markers = newMarkers;
      print('🎯 MapProvider: ${_markers.length} markers created successfully');
    } catch (e, stackTrace) {
      print('❌ Error creating markers: $e');
      print('📜 Stack trace: $stackTrace');
    }
  }

  /// Get appropriate marker icon for center
  BitmapDescriptor _getMarkerIcon(HIVCenter center) {
    try {
      if (center.isMultiService) {
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        );
      }

      switch (center.primaryService) {
        case ServiceType.treatment:
          return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          );
        case ServiceType.prep:
          return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          );
        case ServiceType.testing:
          return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        case ServiceType.laboratory:
          return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          );
      }
    } catch (e) {
      print('❌ Error getting marker icon for ${center.name}: $e');
      return BitmapDescriptor.defaultMarker; // Fallback
    }
  }

  /// Calculate bounds for two points
  LatLngBounds _calculateBounds(LatLng point1, LatLng point2) {
    return LatLngBounds(
      southwest: LatLng(
        [point1.latitude, point2.latitude].reduce((a, b) => a < b ? a : b),
        [point1.longitude, point2.longitude].reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        [point1.latitude, point2.latitude].reduce((a, b) => a > b ? a : b),
        [point1.longitude, point2.longitude].reduce((a, b) => a > b ? a : b),
      ),
    );
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set route loading state
  void _setLoadingRoute(bool loading) {
    if (_isLoadingRoute != loading) {
      _isLoadingRoute = loading;
      notifyListeners();
    }
  }

  /// Clear route polylines
  void _clearRoute() {
    if (_polylines.isNotEmpty) {
      _polylines = {};
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
