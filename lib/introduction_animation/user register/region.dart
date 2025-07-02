import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:projecho/introduction_animation/user register/auth.dart'; // Adjust path if needed

class RegionPicker extends StatefulWidget {


  final void Function(String region)? onRegionSelected;

  const RegionPicker({Key? key, this.onRegionSelected}) : super(key: key);


  @override
  State<RegionPicker> createState() => _RegionPickerState();
}

class _RegionPickerState extends State<RegionPicker> {
  LatLng? _selectedLatLng;
  String _selectedRegion = '';
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(14.5995, 120.9842); // Default: Manila

  @override
  void initState() {
    super.initState();
    _detectCurrentLocation();
  }

  Future<void> _detectCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_initialPosition, 14),
    );
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        String regionName =
            '${placemark.locality ?? placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.country}';

        setState(() {
          _selectedRegion = regionName;
        });

        _showConfirmationDialog(regionName);
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
  }

  void _showConfirmationDialog(String regionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Location"),
        content: Text("You selected:\n\n$regionName"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // cancel
            child: const Text("Change"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PasswordScreen(selectedRegion: _selectedRegion),
                ),
              );
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Region')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 10,
            ),
            myLocationEnabled: true,
            onTap: (LatLng position) {
              setState(() => _selectedLatLng = position);
              _getAddressFromLatLng(position);
            },
            markers: _selectedLatLng != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLatLng!,
                    ),
                  }
                : {},
          ),
        ],
      ),
    );
  }
}
