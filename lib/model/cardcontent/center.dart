import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CenterScreen extends StatefulWidget {
  const CenterScreen({super.key});

  @override
  State<CenterScreen> createState() => _CenterScreenState();
}

class _CenterScreenState extends State<CenterScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;

  final List<Map<String, dynamic>> hivCenters = [
    {
      'name': 'Hope HIV Clinic',
      'location': LatLng(37.4219999, -122.0840575),
    },
    {
      'name': 'City Health Center',
      'location': LatLng(37.427961, -122.088323),
    },
  ];

  Set<Marker> getMarkers() {
    return hivCenters.map((center) {
      return Marker(
        markerId: MarkerId(center['name']),
        position: center['location'],
        infoWindow: InfoWindow(title: center['name']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      );
    }).toSet();
  }

  Future<void> _getCurrentLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied.")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition!, zoom: 14),
    ));
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby HIV Centers"),
        backgroundColor: Colors.redAccent,
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14,
              ),
              myLocationEnabled: true,
              markers: getMarkers(),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
    );
  }
}
