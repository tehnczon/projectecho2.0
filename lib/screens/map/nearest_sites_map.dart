import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  String? selectedCenterId;
  Map<String, dynamic> selectedCenterInfo = {};
  Position? currentPosition;
  bool isLoadingRoute = false;

  // Filter states
  bool showTreatmentHubs = true;
  bool showPrepSites = true;
  bool showTestingSites = true;
  bool showLaboratory = true;

  // Davao City center coordinates
  final LatLng centerLocation = LatLng(7.0731, 125.6128);

  // Updated HIV centers data with more accurate coordinates
  final List<Map<String, dynamic>> allCenters = [
    // HIV TREATMENT HUBS (Green markers with location pin icon)
    {
      'id': 'drmc_redstar_treatment',
      'name': 'Davao Regional Medical Center (DRMC-REDSTAR)',
      'type': 'HIV TREATMENT HUBS',
      'position': LatLng(7.421515540973429, 125.8278497274706),
      'color': Colors.green,
      'category': 'treatment',
      'hours': 'Open 24 hours',
      'phone': '+63-82-227-2731',
      'address': 'Tagum City, Davao del Norte',
      'description':
          'Regional medical center providing comprehensive HIV treatment services',
      'services': ['HIV Treatment', 'ARV Therapy', 'Counseling', 'Laboratory'],
      'photos': [
        'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=DRMC+Main+Building',
        'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Treatment+Ward',
        'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Laboratory',
      ],
    },
    {
      'id': 'reproductive_health_wellness',
      'name': 'Reproductive Health & Wellness Center Davao',
      'type': 'HIV TREATMENT HUBS',
      'position': LatLng(
        7.068761605356898,
        125.61663268661627,
      ), // Adjusted for better spacing
      'color': Colors.green,
      'category': 'treatment',
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-82-300-1234',
      'address': 'Davao City',
      'description': 'Specialized reproductive health and wellness services',
      'services': ['HIV Treatment', 'Reproductive Health', 'STI Treatment'],
      'photos': [
        'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Wellness+Center',
        'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Consultation+Room',
      ],
    },
    {
      'id': 'spmc_hact_treatment',
      'name': 'Southern Philippines Medical Center (SPMC-HACT)',
      'type': 'HIV TREATMENT HUBS',
      'position': LatLng(
        7.0983965060891325,
        125.61984174431115,
      ), // SPMC actual location in Bajada
      'color': Colors.green,
      'category': 'treatment',
      'hours': 'Open 24 hours',
      'phone': '+63-82-221-8000',
      'address': 'J.P. Laurel Ave, Bajada, Davao City',
      'description':
          'Major medical center with HIV/AIDS Care and Treatment program',
      'services': [
        'HIV/AIDS Treatment',
        'HACT Program',
        'Emergency Care',
        'Laboratory',
      ],
      'photos': [
        'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=SPMC+Hospital',
        'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=HACT+Department',
        'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Emergency+Room',
        'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Pharmacy',
      ],
    },
    {
      'id': 'davao_doctors_hospital',
      'name': 'Davao Doctors Hospital (DDH-ARTU)',
      'type': 'HIV TREATMENT HUBS',
      'position': LatLng(
        7.070318293540201,
        125.60471615948111,
      ), // E. Quirino Ave location
      'color': Colors.green,
      'category': 'treatment',
      'hours': 'Open 24 hours',
      'phone': '+63-82-222-8000',
      'address': 'E. Quirino Ave, Davao City',
      'description': 'Private hospital with Anti-Retroviral Treatment Unit',
      'services': ['ARV Treatment', 'Private Healthcare', 'Laboratory'],
      'photos': [
        'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=DDH+Building',
        'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=ARTU+Ward',
      ],
    },

    // HIV PREP SITES (Blue dots)
    // {
    //   'id': 'bhwc_davao_prep',
    //   'name': 'RHWC Davao',
    //   'type': 'HIV PREP SITES',
    //   'position': LatLng(7.072345, 125.612789), // Slightly offset from center
    //   'color': Colors.blue,
    //   'category': 'prep',
    //   'hours': 'Mon-Fri 8AM-5PM',
    //   'phone': '+63-82-298-7000',
    //   'address': 'Davao City',
    //   'description':
    //       'Behavioral Health and Wellness Center offering PrEP services',
    //   'services': ['PrEP', 'Counseling', 'Risk Assessment'],
    //   'photos': [
    //     'https://via.placeholder.com/300x200/2196F3/FFFFFF?text=BHWC+Clinic',
    //     'https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Counseling+Room',
    //     'https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Waiting+Area',
    //   ],
    // },
    {
      'id': 'drmc_redstar_prep',
      'name': 'DRMC-REDSTAR PrEP',
      'type': 'HIV PREP SITES',
      'position': LatLng(7.421515540973429, 125.8278497274706),
      'color': Colors.blue,
      'category': 'prep',
      'hours': 'Open 24 hours',
      'phone': '+63-82-227-2731',
      'address': 'Tagum City, Davao del Norte',
      'description':
          'Pre-exposure prophylaxis services at regional medical center',
      'services': ['PrEP', 'HIV Prevention', 'Counseling'],
    },
    {
      'id': 'olympus_community_prep',
      'name': 'Olympus Community Center',
      'type': 'HIV PREP SITES',
      'position': LatLng(7.076543, 125.609876), // Downtown area
      'color': Colors.blue,
      'category': 'prep',
      'hours': 'Daily 9AM-6PM',
      'phone': '+63-82-305-6789',
      'address': 'Downtown Davao City',
      'description': 'Community-based HIV prevention and PrEP services',
      'services': ['PrEP', 'Community Support', 'LGBTQ+ Services'],
    },
    {
      'id': 'digos_social_hygiene',
      'name': 'Digos Social Hygiene Clinic',
      'type': 'HIV PREP SITES',
      'position': LatLng(6.748901, 125.357234), // Digos City coordinates
      'color': Colors.blue,
      'category': 'prep',
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-82-553-1234',
      'address': 'Digos City, Davao del Sur',
      'description': 'Social hygiene and HIV prevention services in Digos',
      'services': ['PrEP', 'STI Prevention', 'Health Education'],
    },
    {
      'id': 'sta_cruz_rural',
      'name': 'Sta. Cruz Rural Health Unit',
      'type': 'HIV PREP SITES',
      'position': LatLng(6.879012, 125.408567), // Sta. Cruz, Davao del Sur
      'color': Colors.blue,
      'category': 'prep',
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-82-540-5678',
      'address': 'Sta. Cruz, Davao del Sur',
      'description': 'Rural health unit providing HIV prevention services',
      'services': ['PrEP', 'Primary Healthcare', 'Community Outreach'],
    },
    {
      'id': 'mati_city_health_prep',
      'name': 'Mati City Health Office',
      'type': 'HIV PREP SITES',
      'position': LatLng(6.955789, 126.216734), // Mati City coordinates
      'color': Colors.blue,
      'category': 'prep',
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-87-388-1234',
      'address': 'Mati City, Davao Oriental',
      'description': 'City health office with HIV prevention programs',
      'services': ['PrEP', 'Public Health Services', 'HIV Education'],
    },
    {
      'id': 'malita_rural',
      'name': 'Malita Rural Health Unit',
      'type': 'HIV PREP SITES',
      'position': LatLng(6.405234, 125.611789), // Malita, Davao Occidental
      'color': Colors.blue,
      'category': 'prep',
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-82-517-8901',
      'address': 'Malita, Davao Occidental',
      'description': 'Rural health services including HIV prevention',
      'services': ['PrEP', 'Rural Healthcare', 'Community Programs'],
    },
    {
      'id': 'panabo_social',
      'name': 'Panabo Social Hygiene & Wellness Center',
      'type': 'HIV PREP SITES',
      'position': LatLng(7.308456, 125.684123), // Panabo City coordinates
      'color': Colors.blue,
      'category': 'prep',
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-84-823-4567',
      'address': 'Panabo City, Davao del Norte',
      'description': 'Social hygiene and wellness services in Panabo',
      'services': ['PrEP', 'STI Services', 'Wellness Programs'],
    },
    {
      'id': 'fpop_davao_prep',
      'name': 'FPOP Davao (Davao City & DavOr)',
      'type': 'HIV PREP SITES',
      'position': LatLng(7.088901, 125.627345), // Matina area
      'color': Colors.blue,
      'category': 'prep',
      'hours': 'Mon-Sat 9AM-6PM',
      'phone': '+63-82-297-1234',
      'address': 'Matina, Davao City',
      'description': 'Family Planning Organization of the Philippines - Davao',
      'services': ['PrEP', 'Family Planning', 'Reproductive Health'],
    },

    // HIVST SITES (Red dots)
    {
      'id': 'bhwc_davao_hivst',
      'name': 'BHWC Davao Testing',
      'type': 'HIVST SITES',
      'position': LatLng(
        7.073456,
        125.613901,
      ), // Slightly different from PrEP site
      'color': Colors.red,
      'category': 'testing',
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-82-298-7000',
      'address': 'Davao City',
      'description': 'HIV self-testing services and counseling',
      'services': ['HIV Testing', 'Self-Test Kits', 'Counseling'],
    },
    {
      'id': 'drmc_redstar_hivst',
      'name': 'DRMC-REDSTAR Testing',
      'type': 'HIVST SITES',
      'position': LatLng(7.069789, 125.617678), // Near treatment center
      'color': Colors.red,
      'category': 'testing',
      'hours': 'Open 24 hours',
      'phone': '+63-82-227-2731',
      'address': 'Tagum City, Davao del Norte',
      'description': 'HIV self-testing kits and support services',
      'services': ['HIV Testing', 'Rapid Testing', '24/7 Services'],
    },
    {
      'id': 'olympus_community_hivst',
      'name': 'Olympus Community Testing',
      'type': 'HIVST SITES',
      'position': LatLng(7.077098, 125.610431), // Near PrEP site
      'color': Colors.red,
      'category': 'testing',
      'hours': 'Daily 9AM-6PM',
      'phone': '+63-82-305-6789',
      'address': 'Downtown Davao City',
      'description': 'Community-based HIV self-testing programs',
      'services': ['HIV Testing', 'Community Support', 'Anonymous Testing'],
    },
    {
      'id': 'spmc_hact_hivst',
      'name': 'SPMC-HACT Testing',
      'type': 'HIVST SITES',
      'position': LatLng(7.127511, 125.646994), // At SPMC
      'color': Colors.red,
      'category': 'testing',
      'hours': 'Open 24 hours',
      'phone': '+63-82-221-8000',
      'address': 'J.P. Laurel Ave, Bajada, Davao City',
      'description': 'Hospital-based HIV self-testing services',
      'services': ['HIV Testing', 'Laboratory Services', 'Emergency Testing'],
    },
    {
      'id': 'mati_city_health_hivst',
      'name': 'Mati City Health Testing',
      'type': 'HIVST SITES',
      'position': LatLng(6.956344, 126.217289), // Mati City
      'color': Colors.red,
      'category': 'testing',
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-87-388-1234',
      'address': 'Mati City, Davao Oriental',
      'description': 'HIV self-testing services at city health office',
      'services': ['HIV Testing', 'Health Screening', 'Counseling'],
    },
    {
      'id': 'higala_community',
      'name': 'Higala Community Center',
      'type': 'HIVST SITES',
      'position': LatLng(7.083567, 125.621234), // Central Davao
      'color': Colors.red,
      'category': 'testing',
      'hours': 'Mon-Sat 10AM-7PM',
      'phone': '+63-82-306-7890',
      'address': 'Central Davao City',
      'description': 'LGBTQ+ friendly community center with HIV testing',
      'services': ['HIV Testing', 'LGBTQ+ Support', 'Safe Space'],
    },
    {
      'id': 'fpop_davao_hivst',
      'name': 'FPOP Davao Testing',
      'type': 'HIVST SITES',
      'position': LatLng(7.089456, 125.627900), // Matina
      'color': Colors.red,
      'category': 'testing',
      'hours': 'Mon-Sat 9AM-6PM',
      'phone': '+63-82-297-1234',
      'address': 'Matina, Davao City',
      'description': 'HIV self-testing and family planning services',
      'services': ['HIV Testing', 'Family Planning', 'Health Education'],
    },

    // RHIVDA SITES (Orange dots)
    {
      'id': 'spmc_hiv_lab',
      'name': 'SPMC HIV LAB',
      'type': 'RHIVDA SITE',
      'position': LatLng(7.128066, 125.647549), // SPMC Laboratory
      'color': Colors.orange,
      'category': 'laboratory',
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-82-221-8000',
      'address': 'J.P. Laurel Ave, Bajada, Davao City',
      'description': 'Regional HIV/AIDS laboratory testing facility',
      'services': ['CD4 Count', 'Viral Load Testing', 'Confirmatory Testing'],
    },
    {
      'id': 'bhwc_davao_rhivda',
      'name': 'BHWC DAVAO Lab',
      'type': 'RHIVDA SITE',
      'position': LatLng(
        7.074567,
        125.615012,
      ), // Different from other BHWC sites
      'color': Colors.orange,
      'category': 'laboratory',
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-82-298-7000',
      'address': 'Davao City',
      'description': 'Regional HIV voluntary counseling and testing',
      'services': ['Laboratory Testing', 'VCT Services', 'Result Counseling'],
    },
    {
      'id': 'drmc_rhivda',
      'name': 'DRMC Laboratory',
      'type': 'RHIVDA SITE',
      'position': LatLng(7.070345, 125.618234), // DRMC Lab location
      'color': Colors.orange,
      'category': 'laboratory',
      'hours': 'Open 24 hours',
      'phone': '+63-82-227-2731',
      'address': 'Tagum City, Davao del Norte',
      'description': 'Regional medical center HIV diagnostic services',
      'services': ['HIV Diagnostics', '24/7 Laboratory', 'Emergency Testing'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          currentPosition = position;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _makePhoneCall() async {
    String phoneNumber = selectedCenterInfo['phone'] ?? '+63-82-221-8000';
    final Uri phoneUrl = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch phone dialer')));
    }
  }

  void _bookmarkLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedCenterInfo['name']} saved to bookmarks!'),
        action: SnackBarAction(
          label: 'VIEW',
          onPressed: () {
            // Navigate to bookmarks page
          },
        ),
      ),
    );
  }

  Future<void> _launchGoogleMapsDirections(LatLng destination) async {
    String googleMapsUrl;

    if (currentPosition != null) {
      googleMapsUrl =
          'https://www.google.com/maps/dir/${currentPosition!.latitude},${currentPosition!.longitude}/${destination.latitude},${destination.longitude}';
    } else {
      googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=${destination.latitude},${destination.longitude}';
    }

    final Uri url = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: destination, zoom: 16.0),
          ),
        );
      }
    }
  }

  Future<void> _showRouteOnMap(LatLng destination) async {
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission required for directions')),
      );
      return;
    }

    setState(() {
      isLoadingRoute = true;
    });

    try {
      // Create a simple polyline for demonstration
      // In a real app, you'd use Google Directions API
      List<LatLng> routePoints = [
        LatLng(currentPosition!.latitude, currentPosition!.longitude),
        destination,
      ];

      Polyline route = Polyline(
        polylineId: PolylineId('route'),
        points: routePoints,
        color: Colors.blue,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      );

      setState(() {
        polylines = {route};
        isLoadingRoute = false;
      });

      // Animate camera to show the entire route
      if (mapController != null) {
        LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(
            [
              currentPosition!.latitude,
              destination.latitude,
            ].reduce((a, b) => a < b ? a : b),
            [
              currentPosition!.longitude,
              destination.longitude,
            ].reduce((a, b) => a < b ? a : b),
          ),
          northeast: LatLng(
            [
              currentPosition!.latitude,
              destination.latitude,
            ].reduce((a, b) => a > b ? a : b),
            [
              currentPosition!.longitude,
              destination.longitude,
            ].reduce((a, b) => a > b ? a : b),
          ),
        );

        mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100.0),
        );
      }
    } catch (e) {
      setState(() {
        isLoadingRoute = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading route: $e')));
    }
  }

  void _createMarkers() {
    markers =
        allCenters
            .where((center) {
              // Filter markers based on selected categories
              if (center['category'] == 'treatment' && !showTreatmentHubs) {
                return false;
              }
              if (center['category'] == 'prep' && !showPrepSites) return false;
              if (center['category'] == 'testing' && !showTestingSites) {
                return false;
              }
              if (center['category'] == 'laboratory' && !showLaboratory) {
                return false;
              }
              return true;
            })
            .map((center) {
              return Marker(
                markerId: MarkerId(center['id']),
                position: center['position'],
                infoWindow: InfoWindow(),
                icon:
                    center['category'] == 'treatment'
                        ? BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        )
                        : center['color'] == Colors.blue
                        ? BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue,
                        )
                        : center['color'] == Colors.red
                        ? BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        )
                        : BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueOrange,
                        ),
                onTap: () {
                  setState(() {
                    selectedCenterId = center['id'];
                    selectedCenterInfo = center;
                  });

                  // Animate to selected marker
                  if (mapController != null) {
                    mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: center['position'], zoom: 15.0),
                      ),
                    );
                  }
                },
              );
            })
            .toSet();
  }

  void _searchCenters(String query) {
    if (query.isEmpty) {
      _createMarkers();
      return;
    }

    setState(() {
      markers =
          allCenters
              .where((center) {
                final nameMatch = center['name']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase());
                final typeMatch = center['type']
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase());
                final addressMatch = (center['address'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase());
                final servicesMatch = (center['services'] ?? [])
                    .join(' ')
                    .toLowerCase()
                    .contains(query.toLowerCase());

                return nameMatch || typeMatch || addressMatch || servicesMatch;
              })
              .map((center) {
                return Marker(
                  markerId: MarkerId(center['id']),
                  position: center['position'],
                  infoWindow: InfoWindow(
                    title: center['name'],
                    snippet: center['type'],
                  ),
                  icon:
                      center['category'] == 'treatment'
                          ? BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen,
                          )
                          : center['color'] == Colors.blue
                          ? BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue,
                          )
                          : center['color'] == Colors.red
                          ? BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed,
                          )
                          : BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueOrange,
                          ),
                  onTap: () {
                    setState(() {
                      selectedCenterId = center['id'];
                      selectedCenterInfo = center;
                    });
                  },
                );
              })
              .toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              // Optionally set custom map style here
            },
            initialCameraPosition: CameraPosition(
              target: centerLocation,
              zoom: 11.0,
            ),
            markers: markers,
            polylines: polylines,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            onTap: (LatLng position) {
              setState(() {
                selectedCenterId = null;
                selectedCenterInfo = {};
                polylines.clear();
              });
            },
          ),

          // Search Bar
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _searchCenters,
                decoration: InputDecoration(
                  hintText: 'Search HIV centers...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.filter_list, color: Colors.grey),
                        onPressed: _showFilterDialog,
                      ),
                      Icon(Icons.mic, color: Colors.grey),
                      SizedBox(width: 8),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // HIV Program Header & Legend
          Positioned(
            top: 120,
            left: 16,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.medical_services,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HIV PROGRAM',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            'Davao Region',
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.red[300],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Legend with active filter indicators
                  _buildLegendItem(
                    'HIV TREATMENT HUBS',
                    Colors.green,
                    Icons.location_on,
                    showTreatmentHubs,
                  ),
                  SizedBox(height: 4),
                  _buildLegendItem(
                    'HIV PREP SITES',
                    Colors.blue,
                    Icons.circle,
                    showPrepSites,
                  ),
                  SizedBox(height: 4),
                  _buildLegendItem(
                    'HIVST SITES',
                    Colors.red,
                    Icons.circle,
                    showTestingSites,
                  ),
                  SizedBox(height: 4),
                  _buildLegendItem(
                    'RHIVDA SITE',
                    Colors.orange,
                    Icons.circle,
                    showLaboratory,
                  ),
                ],
              ),
            ),
          ),

          // My Location Button
          Positioned(
            bottom: selectedCenterInfo.isNotEmpty ? 320 : 100,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () async {
                if (currentPosition != null && mapController != null) {
                  mapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          currentPosition!.latitude,
                          currentPosition!.longitude,
                        ),
                        zoom: 15.0,
                      ),
                    ),
                  );
                } else {
                  await _getCurrentLocation();
                }
              },
              child: Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          // Bottom Sheet with Place Details
          if (selectedCenterInfo.isNotEmpty)
            DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.25,
              maxChildSize: 0.8,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Place name and actions
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedCenterInfo['name'] ?? '',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          setState(() {
                                            selectedCenterId = null;
                                            selectedCenterInfo = {};
                                            polylines.clear();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 8),

                              // Category badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedCenterInfo['color']
                                      ?.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        selectedCenterInfo['color'] ??
                                        Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  selectedCenterInfo['type'] ?? '',
                                  style: TextStyle(
                                    color: selectedCenterInfo['color'],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              SizedBox(height: 12),

                              // Hours and address (no rating)
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color:
                                        selectedCenterInfo['hours']?.contains(
                                                  '24 hours',
                                                ) ==
                                                true
                                            ? Colors.green
                                            : Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    selectedCenterInfo['hours'] ??
                                        'Hours not available',
                                    style: TextStyle(
                                      color:
                                          selectedCenterInfo['hours']?.contains(
                                                    '24 hours',
                                                  ) ==
                                                  true
                                              ? Colors.green
                                              : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              if (selectedCenterInfo['address'] != null) ...[
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        selectedCenterInfo['address'],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              if (selectedCenterInfo['phone'] != null) ...[
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      selectedCenterInfo['phone'],
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              SizedBox(height: 8),

                              // Description
                              Text(
                                selectedCenterInfo['description'] ?? '',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),

                              // Services offered
                              if (selectedCenterInfo['services'] != null &&
                                  selectedCenterInfo['services']
                                      .isNotEmpty) ...[
                                SizedBox(height: 16),
                                Text(
                                  'Services Offered',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      (selectedCenterInfo['services'] as List)
                                          .map(
                                            (service) => Chip(
                                              label: Text(
                                                service,
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              backgroundColor:
                                                  selectedCenterInfo['color']
                                                      ?.withOpacity(0.1),
                                              labelStyle: TextStyle(
                                                color:
                                                    selectedCenterInfo['color'],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],

                              SizedBox(height: 20),

                              // Photos section
                              if (selectedCenterInfo['photos'] != null &&
                                  selectedCenterInfo['photos'].isNotEmpty) ...[
                                Text(
                                  'Photos',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        selectedCenterInfo['photos'].length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: 160,
                                        margin: EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.network(
                                                selectedCenterInfo['photos'][index],
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Container(
                                                    color:
                                                        selectedCenterInfo['color']
                                                            ?.withOpacity(0.1),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.local_hospital,
                                                          size: 40,
                                                          color:
                                                              selectedCenterInfo['color'],
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          'Medical\nFacility',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color:
                                                                selectedCenterInfo['color'],
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                loadingBuilder: (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  );
                                                },
                                              ),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.6),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${index + 1}/${selectedCenterInfo['photos'].length}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],

                              // Action buttons
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed:
                                              isLoadingRoute
                                                  ? null
                                                  : () async {
                                                    await _launchGoogleMapsDirections(
                                                      selectedCenterInfo['position'],
                                                    );
                                                  },
                                          icon:
                                              isLoadingRoute
                                                  ? SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  )
                                                  : Icon(Icons.directions),
                                          label: Text('Directions'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            await _showRouteOnMap(
                                              selectedCenterInfo['position'],
                                            );
                                          },
                                          icon: Icon(Icons.route),
                                          label: Text('Show Route'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _makePhoneCall();
                                          },
                                          icon: Icon(Icons.phone),
                                          label: Text('Call'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _bookmarkLocation();
                                          },
                                          icon: Icon(Icons.bookmark_border),
                                          label: Text('Save'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Distance information if available
                              if (currentPosition != null) ...[
                                SizedBox(height: 16),
                                FutureBuilder<double>(
                                  future: _calculateDistance(
                                    selectedCenterInfo['position'],
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.straighten,
                                              size: 16,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Distance: ${snapshot.data!.toStringAsFixed(1)} km from your location',
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color,
    IconData icon,
    bool isActive,
  ) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: icon == Icons.location_on ? 14 : 10),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
              decoration: isActive ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }

  Future<double> _calculateDistance(LatLng destination) async {
    if (currentPosition == null) return 0.0;

    return Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          destination.latitude,
          destination.longitude,
        ) /
        1000; // Convert to kilometers
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Filter HIV Centers'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text('HIV Treatment Hubs'),
                    subtitle: Text('Comprehensive treatment centers'),
                    value: showTreatmentHubs,
                    onChanged: (value) {
                      setDialogState(() {
                        showTreatmentHubs = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  CheckboxListTile(
                    title: Text('HIV PrEP Sites'),
                    subtitle: Text('Pre-exposure prophylaxis'),
                    value: showPrepSites,
                    onChanged: (value) {
                      setDialogState(() {
                        showPrepSites = value!;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                  CheckboxListTile(
                    title: Text('HIVST Sites'),
                    subtitle: Text('HIV self-testing locations'),
                    value: showTestingSites,
                    onChanged: (value) {
                      setDialogState(() {
                        showTestingSites = value!;
                      });
                    },
                    activeColor: Colors.red,
                  ),
                  CheckboxListTile(
                    title: Text('RHIVDA Sites'),
                    subtitle: Text('Laboratory services'),
                    value: showLaboratory,
                    onChanged: (value) {
                      setDialogState(() {
                        showLaboratory = value!;
                      });
                    },
                    activeColor: Colors.orange,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _createMarkers();
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
