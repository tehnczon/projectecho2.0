// lib/screens/map/map_screen_v2.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/location_provider.dart';
import 'center_details_sheet.dart';
import '../../models/service_type.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().initialize();
      context.read<LocationProvider>().requestLocationAndGetPosition();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map
          FadeTransition(
            opacity: _fadeAnimation,
            child: Consumer<MapProvider>(
              builder: (context, mapProvider, _) {
                return GoogleMap(
                  onMapCreated: mapProvider.setMapController,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(7.0731, 125.6128),
                    zoom: 11.0,
                  ),
                  markers: mapProvider.markers,
                  polylines: mapProvider.polylines,
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  onTap: (_) {
                    mapProvider.clearSelection();
                    _collapseSearch();
                  },
                );
              },
            ),
          ),

          // Search + Filters
          SafeArea(
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGlassSearchBar(theme),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child:
                          _isSearchExpanded
                              ? const SizedBox.shrink()
                              : Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _buildFilterChips(theme),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // My Location Button
          Positioned(
            bottom: 100,
            right: 16,
            child: _buildLocationButton(theme),
          ),

          // Details Sheet
          Consumer<MapProvider>(
            builder: (context, mapProvider, _) {
              if (!mapProvider.hasSelectedCenter) {
                return const SizedBox.shrink();
              }
              return CenterDetailsSheet(
                center: mapProvider.selectedCenter!,
                onClose: () {
                  mapProvider.clearSelection();
                  _collapseSearch();
                },
              );
            },
          ),

          // Loading Overlay
          Consumer<MapProvider>(
            builder: (context, provider, _) {
              if (!provider.isLoading) return const SizedBox.shrink();
              return _buildLoadingOverlay(theme);
            },
          ),
        ],
      ),
    );
  }

  // Modern Glass Search Bar
  Widget _buildGlassSearchBar(ThemeData theme) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(32),
        color: Colors.white.withOpacity(0.85),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onTap: () => setState(() => _isSearchExpanded = true),
                onChanged: context.read<MapProvider>().searchCenters,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: "Search HIV centers",
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_isSearchExpanded)
              IconButton(
                icon: const Icon(Icons.close),
                color: theme.primaryColor,
                onPressed: _collapseSearch,
              ),
          ],
        ),
      ),
    );
  }

  // Filter Chips Row
  Widget _buildFilterChips(ThemeData theme) {
    final mapProvider = context.watch<MapProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All Centers',
            icon: Icons.apps,
            isSelected:
                mapProvider.showTreatmentHubs &&
                mapProvider.showPrepSites &&
                mapProvider.showTestingSites &&
                mapProvider.showLaboratory &&
                mapProvider.showMultiService,
            color: Colors.grey[700]!,
            onTap: () {
              final allSelected =
                  mapProvider.showTreatmentHubs &&
                  mapProvider.showPrepSites &&
                  mapProvider.showTestingSites &&
                  mapProvider.showLaboratory &&
                  mapProvider.showMultiService;
              mapProvider.updateFilters(
                showTreatmentHubs: !allSelected,
                showPrepSites: !allSelected,
                showTestingSites: !allSelected,
                showLaboratory: !allSelected,
                showMultiService: !allSelected,
              );
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Multi-Service',
            icon: Icons.auto_awesome,
            isSelected: mapProvider.showMultiService,
            color: Colors.purple,
            onTap:
                () => mapProvider.updateFilters(
                  showMultiService: !mapProvider.showMultiService,
                ),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Treatment',
            icon: ServiceType.treatment.icon,
            isSelected: mapProvider.showTreatmentHubs,
            color: ServiceType.treatment.color,
            onTap:
                () => mapProvider.updateFilters(
                  showTreatmentHubs: !mapProvider.showTreatmentHubs,
                ),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'PrEP',
            icon: ServiceType.prep.icon,
            isSelected: mapProvider.showPrepSites,
            color: ServiceType.prep.color,
            onTap:
                () => mapProvider.updateFilters(
                  showPrepSites: !mapProvider.showPrepSites,
                ),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Testing',
            icon: ServiceType.testing.icon,
            isSelected: mapProvider.showTestingSites,
            color: ServiceType.testing.color,
            onTap:
                () => mapProvider.updateFilters(
                  showTestingSites: !mapProvider.showTestingSites,
                ),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Laboratory',
            icon: ServiceType.laboratory.icon,
            isSelected: mapProvider.showLaboratory,
            color: ServiceType.laboratory.color,
            onTap:
                () => mapProvider.updateFilters(
                  showLaboratory: !mapProvider.showLaboratory,
                ),
          ),
        ],
      ),
    );
  }

  // My Location Button
  Widget _buildLocationButton(ThemeData theme) {
    return Consumer2<MapProvider, LocationProvider>(
      builder: (context, mapProvider, locationProvider, _) {
        return FloatingActionButton(
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: () async {
            if (locationProvider.hasLocation &&
                mapProvider.mapController != null) {
              final pos = locationProvider.currentPosition!;
              mapProvider.mapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(pos.latitude, pos.longitude),
                    zoom: 15.0,
                  ),
                ),
              );
            } else {
              await locationProvider.requestLocationAndGetPosition();
            }
          },
          child:
              locationProvider.isLoading
                  ? CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.primaryColor,
                    ),
                  )
                  : Icon(Icons.my_location, color: theme.primaryColor),
        );
      },
    );
  }

  // Loading Overlay
  Widget _buildLoadingOverlay(ThemeData theme) {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loading HIV Centers...',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _collapseSearch() {
    setState(() {
      _isSearchExpanded = false;
      _searchController.clear();
    });
    _searchFocusNode.unfocus();
    context.read<MapProvider>().searchCenters('');
  }
}

// Chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color; // This can be ignored for sky blue override
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color skyBlue = const Color(0xFF40C4FF); // Sky blue color

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? skyBlue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
