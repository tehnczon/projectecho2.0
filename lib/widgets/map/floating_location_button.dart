import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/location_provider.dart';

class FloatingLocationButton extends StatelessWidget {
  const FloatingLocationButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<MapProvider, LocationProvider>(
      builder: (context, mapProvider, locationProvider, _) {
        return Positioned(
          bottom: mapProvider.hasSelectedCenter ? 320 : 100,
          right: 16,
          child: Material(
            shape: const CircleBorder(),
            elevation: 4,
            color: Colors.white,
            shadowColor: Colors.black.withOpacity(0.15),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () async {
                if (locationProvider.hasLocation &&
                    mapProvider.mapController != null) {
                  final position = locationProvider.currentPosition!;
                  mapProvider.mapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 15.0,
                      ),
                    ),
                  );
                } else {
                  await locationProvider.requestLocationAndGetPosition();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child:
                    locationProvider.isLoading
                        ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(
                          Icons.my_location_rounded,
                          color: Colors.blueAccent,
                          size: 26,
                        ),
              ),
            ),
          ),
        );
      },
    );
  }
}
