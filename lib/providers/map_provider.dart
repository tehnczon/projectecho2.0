// lib/providers/map_provider.dart - FIRESTORE VERSION
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/hiv_center.dart';
import '../models/service_type.dart';
import '../data/repositories/hiv_center_repository.dart';

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
  String? _errorMessage;

  // Filter states
  bool _showTreatmentHubs = true;
  bool _showPrepSites = true;
  bool _showTestingSites = true;
  bool _showLaboratory = true;
  bool _showMultiService = true;

  // Google Map Controller
  GoogleMapController? _mapController;

  // Stream subscription for real-time updates
  Stream<List<HIVCenter>>? _centersStream;

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
  String? get errorMessage => _errorMessage;

  // Filter getters
  bool get showTreatmentHubs => _showTreatmentHubs;
  bool get showPrepSites => _showPrepSites;
  bool get showTestingSites => _showTestingSites;
  bool get showLaboratory => _showLaboratory;
  bool get showMultiService => _showMultiService;

  GoogleMapController? get mapController => _mapController;

  // Constants
  static const LatLng davaoCityCenter = LatLng(7.0731, 125.6128);

  /// Initialize the provider and load centers from Firestore
  Future<void> initialize() async {
    print('🚀 MapProvider: Starting Firestore initialization...');
    _setLoading(true);
    _errorMessage = null;

    try {
      // Initialize repository first
      await _repository.initialize();

      // Load centers from Firestore
      _allCenters = await _repository.getAllCenters();
      print(
        '📊 MapProvider: Loaded ${_allCenters.length} centers from Firestore',
      );

      // Print first center for debugging
      if (_allCenters.isNotEmpty) {
        final first = _allCenters.first;
        print('📍 First center: ${first.name} at ${first.position}');
        print('🏷️ Category: ${first.category}, Services: ${first.services}');
      }

      await _applyFiltersAndSearch();
      print('✅ MapProvider: Firestore initialization complete');
    } catch (e, stackTrace) {
      print('❌ MapProvider Error: $e');
      print('📜 Stack trace: $stackTrace');
      _errorMessage = 'Failed to load centers: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Initialize with real-time updates
  void initializeWithStream() {
    print('🚀 MapProvider: Starting real-time Firestore stream...');
    _setLoading(true);
    _errorMessage = null;

    // Listen to real-time updates
    _centersStream = _repository.getCentersStream();
    _centersStream!.listen(
      (centers) async {
        print('📊 MapProvider: Received ${centers.length} centers from stream');
        _allCenters = centers;

        if (_allCenters.isNotEmpty) {
          final first = _allCenters.first;
          print('📍 Stream update - First center: ${first.name}');
        }

        await _applyFiltersAndSearch();
        _setLoading(false);
      },
      onError: (error) {
        print('❌ MapProvider Stream Error: $error');
        _errorMessage = 'Failed to load centers: $error';
        _setLoading(false);
      },
    );
  }

  /// Refresh data from Firestore
  Future<void> refresh() async {
    print('🔄 MapProvider: Refreshing data from Firestore...');
    _errorMessage = null;

    try {
      await _repository.refresh();
      _allCenters = await _repository.getAllCenters();
      print('📊 MapProvider: Refreshed ${_allCenters.length} centers');
      await _applyFiltersAndSearch();
    } catch (e) {
      print('❌ MapProvider Refresh Error: $e');
      _errorMessage = 'Failed to refresh centers: $e';
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
  Future<void> selectCenter(String centerId) async {
    print('🎯 MapProvider: Selecting center $centerId');

    try {
      // First check in current centers
      HIVCenter? center = _allCenters.firstWhere(
        (c) => c.id == centerId,
        orElse: () => null as dynamic,
      );

      // If not found, fetch from Firestore
      if (center == null) {
        center = await _repository.getCenterById(centerId);
      }

      if (center != null && center != _selectedCenter) {
        _selectedCenter = center;
        _clearRoute();

        // Animate camera to selected center
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: center.position, zoom: 15.0),
            ),
          );
        }

        notifyListeners();
      }
    } catch (e) {
      print('❌ Error selecting center: $e');
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

    // Start with all centers
    List<HIVCenter> filtered = List.from(_allCenters);

    // Apply filters
    filtered =
        filtered.where((center) {
          // Multi-service filter
          if (center.isMultiService && !_showMultiService) return false;

          // Single service filters
          if (!center.isMultiService) {
            final primaryService = center.primaryService;
            switch (primaryService) {
              case ServiceType.treatment:
                if (!_showTreatmentHubs) return false;
                break;
              case ServiceType.prep:
                if (!_showPrepSites) return false;
                break;
              case ServiceType.testing:
                if (!_showTestingSites) return false;
                break;
              case ServiceType.laboratory:
                if (!_showLaboratory) return false;
                break;
            }
          }

          return true;
        }).toList();

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

  /// Save a center to Firestore
  Future<void> saveCenter(HIVCenter center) async {
    try {
      await _repository.saveCenter(center);
      // Refresh the data
      await refresh();
    } catch (e) {
      print('❌ Error saving center: $e');
      _errorMessage = 'Failed to save center: $e';
      notifyListeners();
    }
  }

  /// Delete a center from Firestore
  Future<void> deleteCenter(String centerId) async {
    try {
      await _repository.deleteCenter(centerId);
      // Clear selection if deleted center was selected
      if (_selectedCenter?.id == centerId) {
        clearSelection();
      }
      // Refresh the data
      await refresh();
    } catch (e) {
      print('❌ Error deleting center: $e');
      _errorMessage = 'Failed to delete center: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
