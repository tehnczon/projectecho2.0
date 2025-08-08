// lib/screens/map/map_screen.dart - COMPLETE WORKING VERSION
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/map/center_details_sheet.dart'; // ADD THIS IMPORT

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize the existing providers from main.dart
      context.read<MapProvider>().initialize();
      context.read<LocationProvider>().requestLocationAndGetPosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          Consumer<MapProvider>(
            builder: (context, mapProvider, _) {
              return GoogleMap(
                onMapCreated: mapProvider.setMapController,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(7.0731, 125.6128), // Davao City
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
          ),

          // Search Bar
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: context.read<MapProvider>().searchCenters,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search HIV centers...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(Icons.search, color: Colors.grey[600]),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.filter_list_rounded,
                          color: Colors.grey[600],
                        ),
                        onPressed: () => _showFilterDialog(context),
                        tooltip: 'Filter',
                      ),
                      Icon(Icons.mic, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // My Location Button
          Positioned(
            bottom: 100,
            right: 16,
            child: Consumer2<MapProvider, LocationProvider>(
              builder: (context, mapProvider, locationProvider, _) {
                return Material(
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
                              target: LatLng(
                                position.latitude,
                                position.longitude,
                              ),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(
                                Icons.my_location_rounded,
                                color: Colors.blueAccent,
                                size: 26,
                              ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Sheet - NOW PROPERLY IMPORTED
          Consumer<MapProvider>(
            builder: (context, mapProvider, _) {
              if (!mapProvider.hasSelectedCenter) {
                return const SizedBox.shrink();
              }

              return CenterDetailsSheet(
                center: mapProvider.selectedCenter!,
                onClose: mapProvider.clearSelection,
              );
            },
          ),

          // Loading overlay
          Consumer<MapProvider>(
            builder: (context, provider, _) {
              if (!provider.isLoading) return const SizedBox.shrink();

              return Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),

          // Debug info (you can remove this later)
          // Positioned(
          //   bottom: 200,
          //   left: 16,
          //   child: Consumer<MapProvider>(
          //     builder: (context, provider, _) {
          //       return Container(
          //         padding: const EdgeInsets.all(8),
          //         color: Colors.black87,
          //         child: Text(
          //           'Centers: ${provider.allCenters.length}\n'
          //           'Markers: ${provider.markers.length}\n'
          //           'Selected: ${provider.selectedCenter?.name ?? "None"}',
          //           style: const TextStyle(color: Colors.white, fontSize: 12),
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => FilterDialog());
  }
}

// REAL FILTER DIALOG - ADD THIS TO THE SAME FILE
class FilterDialog extends StatefulWidget {
  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late bool _showTreatmentHubs;
  late bool _showPrepSites;
  late bool _showTestingSites;
  late bool _showLaboratory;
  late bool _showMultiService;

  @override
  void initState() {
    super.initState();
    final mapProvider = context.read<MapProvider>();
    _showTreatmentHubs = mapProvider.showTreatmentHubs;
    _showPrepSites = mapProvider.showPrepSites;
    _showTestingSites = mapProvider.showTestingSites;
    _showLaboratory = mapProvider.showLaboratory;
    _showMultiService = mapProvider.showMultiService;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter HIV Centers'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Multi-Service Centers'),
              subtitle: const Text('Centers offering multiple services'),
              value: _showMultiService,
              onChanged: (value) => setState(() => _showMultiService = value!),
              activeColor: Colors.purple,
            ),
            const Divider(),
            CheckboxListTile(
              title: const Text('HIV Treatment Hubs'),
              subtitle: const Text('Comprehensive treatment centers'),
              value: _showTreatmentHubs,
              onChanged: (value) => setState(() => _showTreatmentHubs = value!),
              activeColor: Colors.green,
            ),
            CheckboxListTile(
              title: const Text('HIV PrEP Sites'),
              subtitle: const Text('Pre-exposure prophylaxis'),
              value: _showPrepSites,
              onChanged: (value) => setState(() => _showPrepSites = value!),
              activeColor: Colors.blue,
            ),
            CheckboxListTile(
              title: const Text('HIVST Sites'),
              subtitle: const Text('HIV self-testing locations'),
              value: _showTestingSites,
              onChanged: (value) => setState(() => _showTestingSites = value!),
              activeColor: Colors.red,
            ),
            CheckboxListTile(
              title: const Text('RHIVDA Sites'),
              subtitle: const Text('Laboratory services'),
              value: _showLaboratory,
              onChanged: (value) => setState(() => _showLaboratory = value!),
              activeColor: Colors.orange,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _showTreatmentHubs = true;
                  _showPrepSites = true;
                  _showTestingSites = true;
                  _showLaboratory = true;
                  _showMultiService = true;
                });
              },
              child: const Text('Select All'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                context.read<MapProvider>().updateFilters(
                  showTreatmentHubs: _showTreatmentHubs,
                  showPrepSites: _showPrepSites,
                  showTestingSites: _showTestingSites,
                  showLaboratory: _showLaboratory,
                  showMultiService: _showMultiService,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ],
    );
  }
}
