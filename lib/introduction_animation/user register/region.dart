import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class RegionPicker extends StatefulWidget {
  final Function(String region) onRegionSelected;
  const RegionPicker({required this.onRegionSelected});

  @override
  _RegionPickerState createState() => _RegionPickerState();
}

class _RegionPickerState extends State<RegionPicker> {
  LatLng? _selectedLatLng;
  String _selectedRegion = '';
  GoogleMapController? _mapController;

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        String regionName = '${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';

        setState(() {
          _selectedRegion = regionName;
        });

        widget.onRegionSelected(regionName);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Your Region')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: LatLng(14.5995, 120.9842), // e.g. Manila
              zoom: 10,
            ),
            onTap: (LatLng position) {
              setState(() => _selectedLatLng = position);
              _getAddressFromLatLng(position);
            },
            markers: _selectedLatLng != null
                ? {
                    Marker(
                      markerId: MarkerId('selected'),
                      position: _selectedLatLng!,
                    ),
                  }
                : {},
          ),
          if (_selectedRegion.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Selected Region: $_selectedRegion'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


