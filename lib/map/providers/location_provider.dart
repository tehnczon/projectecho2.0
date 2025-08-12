import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

enum LocationStatus { initial, loading, granted, denied, error }

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  LocationStatus _status = LocationStatus.initial;
  String? _errorMessage;

  // Getters
  Position? get currentPosition => _currentPosition;
  LocationStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get hasLocation => _currentPosition != null;
  bool get isLoading => _status == LocationStatus.loading;

  /// Request location permission and get current position
  Future<void> requestLocationAndGetPosition() async {
    _updateStatus(LocationStatus.loading);

    try {
      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _updateStatus(LocationStatus.denied, 'Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _updateStatus(
          LocationStatus.denied,
          'Location permissions are permanently denied',
        );
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;
      _updateStatus(LocationStatus.granted);
    } catch (e) {
      _updateStatus(LocationStatus.error, e.toString());
    }
  }

  /// Update location status
  void _updateStatus(LocationStatus status, [String? error]) {
    _status = status;
    _errorMessage = error;
    notifyListeners();
  }

  /// Calculate distance to a point
  double? distanceTo(double latitude, double longitude) {
    if (_currentPosition == null) return null;

    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          latitude,
          longitude,
        ) /
        1000; // Convert to kilometers
  }
}
