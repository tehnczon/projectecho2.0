import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/map_provider.dart';

class GoogleMapWidget extends StatelessWidget {
  const GoogleMapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, _) {
        return GoogleMap(
          onMapCreated: mapProvider.setMapController,
          initialCameraPosition: const CameraPosition(
            target: MapProvider.davaoCityCenter,
            zoom: 11.0,
          ),
          markers: mapProvider.markers,
          polylines: mapProvider.polylines,
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          onTap: (_) => mapProvider.clearSelection(),
        );
      },
    );
  }
}
