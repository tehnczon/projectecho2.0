import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

/* Removed duplicate MapScreen class definition to resolve duplicate class error. */

// OperatingHours class
class OperatingHours {
  final Map<String, TimeRange?> schedule;

  OperatingHours({required this.schedule});

  bool isOpenNow() {
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final timeRange = schedule[dayName];

    if (timeRange == null) return false;

    final currentTime = TimeOfDay.fromDateTime(now);
    return timeRange.isTimeInRange(currentTime);
  }

  String getCurrentStatus() {
    if (isOpenNow()) {
      final now = DateTime.now();
      final dayName = _getDayName(now.weekday);
      final timeRange = schedule[dayName]!;
      final closingTime = _formatTimeOfDay(timeRange.end);
      return 'Open • Closes at $closingTime';
    } else {
      return getNextOpenTime();
    }
  }

  String getNextOpenTime() {
    final now = DateTime.now();

    // Check rest of today
    final todayName = _getDayName(now.weekday);
    final todayRange = schedule[todayName];
    if (todayRange != null) {
      final currentTime = TimeOfDay.fromDateTime(now);
      if (currentTime.hour < todayRange.start.hour ||
          (currentTime.hour == todayRange.start.hour &&
              currentTime.minute < todayRange.start.minute)) {
        return 'Closed • Opens at ${_formatTimeOfDay(todayRange.start)}';
      }
    }

    // Check next 7 days
    for (int i = 1; i <= 7; i++) {
      final nextDay = now.add(Duration(days: i));
      final dayName = _getDayName(nextDay.weekday);
      final timeRange = schedule[dayName];

      if (timeRange != null) {
        if (i == 1) {
          return 'Closed • Opens tomorrow at ${_formatTimeOfDay(timeRange.start)}';
        } else {
          return 'Closed • Opens $dayName at ${_formatTimeOfDay(timeRange.start)}';
        }
      }
    }

    return 'Closed';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hourStr = hour == 0 ? '12' : hour.toString();
    final minuteStr = time.minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }
}

// TimeRange class
class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRange({required this.start, required this.end});

  bool isTimeInRange(TimeOfDay time) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return timeMinutes >= startMinutes && timeMinutes < endMinutes;
  }
}

// OperatingHoursWidget
class OperatingHoursWidget extends StatelessWidget {
  final OperatingHours operatingHours;

  const OperatingHoursWidget({Key? key, required this.operatingHours})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOpen = operatingHours.isOpenNow();
    final status = operatingHours.getCurrentStatus();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current status
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                isOpen
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOpen ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: isOpen ? Colors.green : Colors.red,
              ),
              SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  color: isOpen ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),

        // Weekly schedule
        InkWell(
          onTap: () => _showFullSchedule(context),
          child: Row(
            children: [
              Text(
                'View full schedule',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 12, color: Colors.blue),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullSchedule(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final now = DateTime.now();
        final currentDay = _getDayName(now.weekday);

        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Operating Hours',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ...[
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday',
              ].map((day) {
                final timeRange = operatingHours.schedule[day];
                final isToday = day == currentDay;

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.blue.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (isToday) ...[
                            Container(
                              width: 4,
                              height: 20,
                              color: Colors.blue,
                              margin: EdgeInsets.only(right: 8),
                            ),
                          ],
                          Text(
                            day,
                            style: TextStyle(
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday ? Colors.blue : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        timeRange != null
                            ? '${_formatTimeOfDay(timeRange.start)} - ${_formatTimeOfDay(timeRange.end)}'
                            : 'Closed',
                        style: TextStyle(
                          color: timeRange != null ? Colors.black : Colors.red,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hourStr = hour == 0 ? '12' : hour.toString();
    final minuteStr = time.minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }
}

// Service type class
class ServiceType {
  final String label;
  final Color color;
  final IconData icon;

  ServiceType(this.label, this.color, this.icon);
}

// Main MapScreen widget
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
  bool showMultiService = true;

  // Davao City center coordinates
  final LatLng centerLocation = LatLng(7.0731, 125.6128);

  // Service type definitions
  final Map<String, ServiceType> serviceTypes = {
    'treatment': ServiceType(
      'HIV Treatment Hub',
      Colors.green,
      Icons.local_hospital,
    ),
    'prep': ServiceType('HIV PrEP Site', Colors.blue, Icons.shield),
    'testing': ServiceType('HIVST Site', Colors.red, Icons.biotech),
    'laboratory': ServiceType('RHIVDA Site', Colors.orange, Icons.science),
  };

  // Multi-service centers data based on Excel file
  final List<Map<String, dynamic>> allCenters = [
    // MULTI-SERVICE CENTERS
    {
      'id': 'rhwc_davao',
      'name': 'Reproductive Health & Wellness Center Davao (RHWC Davao)',
      'position': LatLng(7.068752634153147, 125.61663351395941),
      'category': 'multi',
      'services': ['treatment', 'prep', 'testing', 'laboratory'],
      'operatingHours': OperatingHours(
        schedule: {
          'Monday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 17, minute: 0),
          ),
          'Tuesday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 17, minute: 0),
          ),
          'Wednesday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 17, minute: 0),
          ),
          'Thursday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 17, minute: 0),
          ),
          'Friday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 17, minute: 0),
          ),
          'Saturday': null, // Closed
          'Sunday': null, // Closed
        },
      ),
      'phone': '(082) 222 4187',
      'address':
          '3J98+GM2, Emilio Jacinto St, Poblacion District, Davao City, Davao del Sur',
      'description':
          'Comprehensive HIV center offering all services: Treatment Hub, PrEP, Testing, and Laboratory',
      'serviceDetails': {
        'treatment': [
          'HIV Treatment',
          'ARV Therapy',
          'Counseling',
          'Case Management',
        ],
        'prep': [
          'Pre-exposure prophylaxis',
          'Risk Assessment',
          'PrEP Monitoring',
        ],
        'testing': [
          'HIV Testing',
          'Self-Test Kits',
          'Rapid Testing',
          'Confirmatory Testing',
        ],
        'laboratory': [
          'CD4 Count',
          'Viral Load Testing',
          'Drug Resistance Testing',
        ],
      },
      'photos': [
        'https://www.davaocity.gov.ph/wp-content/uploads/2022/12/viber_image_2022-12-06_08-17-03-004-scaled.jpg',
        'https://streetviewpixels-pa.googleapis.com/v1/thumbnail?output=thumbnail&cb_client=maps_sv.tactile.gps&panoid=aMeveCJ3Es-JJeTMNVoMqw&w=1177&h=580&thumb=2&yaw=244.38109&pitch=0',
      ],
    },
    {
      'id': 'drmc_redstar',
      'name': 'Davao Regional Medical Center (DRMC-REDSTAR)',
      'position': LatLng(7.421615617505603, 125.82785338552642),
      'category': 'multi',
      'services': ['treatment', 'prep', 'testing'],
      'operatingHours': OperatingHours(
        schedule: {
          'Monday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 17, minute: 0),
          ),
          'Tuesday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 17, minute: 0),
          ),
          'Wednesday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 17, minute: 0),
          ),
          'Thursday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 17, minute: 0),
          ),
          'Friday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 17, minute: 0),
          ),
          'Saturday': null, // Closed
          'Sunday': null, // Closed
        },
      ),
      'phone': '0991 145 8211',
      'address':
          '2nd Floor, Davao Regional Medical Center, OPD Building, Tagum, Davao del Norte',
      'description':
          'Regional medical center with Treatment Hub, PrEP, and Testing services',
      'serviceDetails': {
        'treatment': [
          'HIV Treatment',
          'ARV Therapy',
          'Emergency Care',
          'Inpatient Services',
        ],
        'prep': ['Pre-exposure prophylaxis', 'Risk Counseling'],
        'testing': ['HIV Testing', 'Rapid Testing', '24/7 Emergency Testing'],
      },
      'photos': [
        'https://streetviewpixels-pa.googleapis.com/v1/thumbnail?panoid=-TgvBB7ILylaIVoahbmVng&cb_client=maps_sv.tactile.gps&w=203&h=100&yaw=117.57874&pitch=0&thumbfov=100',
      ],
    },
    {
      'id': 'olympus_community',
      'name': 'Olympus Community Center',
      'position': LatLng(7.076543, 125.609876),
      'category': 'multi',
      'services': ['prep', 'testing'],
      'hours': 'Daily 9AM-6PM',
      'phone': '+63-82-305-6789',
      'address': 'Downtown Davao City',
      'description':
          'Community-based center offering PrEP and HIV Testing services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'Community Support', 'LGBTQ+ Friendly'],
        'testing': ['HIV Testing', 'Anonymous Testing', 'Community Outreach'],
      },
      'photos': [],
    },
    {
      'id': 'mati_city_health',
      'name': 'Mati City Health Office',
      'position': LatLng(6.955789, 126.216734),
      'category': 'multi',
      'services': ['prep', 'testing'],
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-87-388-1234',
      'address': 'Mati City, Davao Oriental',
      'description': 'City health office with PrEP and HIV Testing services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'Public Health Programs'],
        'testing': ['HIV Testing', 'Health Screening'],
      },
      'photos': [],
    },
    {
      'id': 'fpop_davao',
      'name': 'FPOP Davao (Davao City & Davao Oriental)',
      'position': LatLng(7.088901, 125.627345),
      'category': 'multi',
      'services': ['prep', 'testing'],
      'hours': 'Mon-Sat 9AM-6PM',
      'phone': '+63-82-297-1234',
      'address': 'Matina, Davao City',
      'description':
          'Family Planning Organization offering PrEP and Testing services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'Family Planning Integration'],
        'testing': ['HIV Testing', 'Reproductive Health Services'],
      },
      'photos': [],
    },

    // SINGLE SERVICE CENTERS - Treatment Hubs Only
    {
      'id': 'spmc_hact',
      'name': 'Southern Philippines Medical Center (SPMC-HACT)',
      'position': LatLng(7.126956, 125.646439),
      'category': 'single',
      'services': ['treatment'],
      'hours': 'Open 24 hours',
      'phone': '+63-82-221-8000',
      'address': 'J.P. Laurel Ave, Bajada, Davao City',
      'description':
          'Major medical center with HIV/AIDS Care and Treatment program',
      'serviceDetails': {
        'treatment': [
          'HIV/AIDS Treatment',
          'HACT Program',
          'Emergency Care',
          'Inpatient Services',
        ],
      },
      'photos': [],
    },
    {
      'id': 'ddh_artu',
      'name': 'Davao Doctors Hospital (DDH-ARTU)',
      'position': LatLng(7.081234, 125.613456),
      'category': 'single',
      'services': ['treatment'],
      'hours': 'Open 24 hours',
      'phone': '+63-82-222-8000',
      'address': 'E. Quirino Ave, Davao City',
      'description': 'Private hospital with Anti-Retroviral Treatment Unit',
      'serviceDetails': {
        'treatment': [
          'ARV Treatment',
          'Private Healthcare',
          'Specialized Care',
        ],
      },
      'photos': [],
    },

    // SINGLE SERVICE CENTERS - PrEP Sites Only
    {
      'id': 'digos_hygiene',
      'name': 'Digos Social Hygiene Clinic',
      'position': LatLng(6.748901, 125.357234),
      'category': 'single',
      'services': ['prep'],
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-82-553-1234',
      'address': 'Digos City, Davao del Sur',
      'description': 'Social hygiene clinic offering PrEP services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'STI Prevention', 'Health Education'],
      },
      'photos': [],
    },
    {
      'id': 'sta_cruz_rhu',
      'name': 'Sta. Cruz Rural Health Unit',
      'position': LatLng(6.879012, 125.408567),
      'category': 'single',
      'services': ['prep'],
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-82-540-5678',
      'address': 'Sta. Cruz, Davao del Sur',
      'description': 'Rural health unit with PrEP services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'Primary Healthcare', 'Community Programs'],
      },
      'photos': [],
    },
    {
      'id': 'malita_rhu',
      'name': 'Malita Rural Health Unit',
      'position': LatLng(6.405234, 125.611789),
      'category': 'single',
      'services': ['prep'],
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-82-517-8901',
      'address': 'Malita, Davao Occidental',
      'description': 'Rural health unit offering PrEP services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'Rural Healthcare'],
      },
      'photos': [],
    },
    {
      'id': 'rhwc_tagum',
      'name': 'RHWC Tagum',
      'position': LatLng(7.448456, 125.807789),
      'category': 'single',
      'services': ['prep'],
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-84-655-1234',
      'address': 'Tagum City, Davao del Norte',
      'description': 'Reproductive health center with PrEP services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'Reproductive Health'],
      },
      'photos': [],
    },
    {
      'id': 'panabo_hygiene',
      'name': 'Panabo Social Hygiene & Wellness Center',
      'position': LatLng(7.308456, 125.684123),
      'category': 'single',
      'services': ['prep'],
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-84-823-4567',
      'address': 'Panabo City, Davao del Norte',
      'description': 'Social hygiene center offering PrEP services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'STI Services', 'Wellness Programs'],
      },
      'photos': [],
    },

    // SINGLE SERVICE CENTERS - Testing Sites Only
    {
      'id': 'spmc_hact_testing',
      'name': 'SPMC-HACT Testing',
      'position': LatLng(7.127511, 125.646994),
      'category': 'single',
      'services': ['testing'],
      'hours': 'Open 24 hours',
      'phone': '+63-82-221-8000',
      'address': 'J.P. Laurel Ave, Bajada, Davao City',
      'description': 'Hospital-based HIV testing services',
      'serviceDetails': {
        'testing': ['HIV Testing', 'Laboratory Services', 'Emergency Testing'],
      },
      'photos': [],
    },
    {
      'id': 'davao_del_sur_hospital',
      'name': 'Davao del Sur Provincial Hospital - HACT',
      'position': LatLng(6.768901, 125.327234),
      'category': 'single',
      'services': ['testing'],
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-82-552-1234',
      'address': 'Digos City, Davao del Sur',
      'description': 'Provincial hospital HIV testing services',
      'serviceDetails': {
        'testing': ['HIV Testing', 'Provincial Health Services'],
      },
      'photos': [],
    },
    {
      'id': 'higala_community',
      'name': 'Higala Community Center',
      'position': LatLng(7.083567, 125.621234),
      'category': 'single',
      'services': ['testing'],
      'hours': 'Mon-Sat 10AM-7PM',
      'phone': '+63-82-306-7890',
      'address': 'Central Davao City',
      'description': 'LGBTQ+ friendly community center with HIV testing',
      'serviceDetails': {
        'testing': [
          'HIV Testing',
          'LGBTQ+ Support',
          'Safe Space',
          'Anonymous Testing',
        ],
      },
      'photos': [],
    },

    // SINGLE SERVICE CENTERS - Laboratory Only
    {
      'id': 'spmc_hiv_lab',
      'name': 'SPMC HIV LAB',
      'position': LatLng(7.128066, 125.647549),
      'category': 'single',
      'services': ['laboratory'],
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '+63-82-221-8000',
      'address': 'J.P. Laurel Ave, Bajada, Davao City',
      'description': 'Regional HIV/AIDS laboratory testing facility',
      'serviceDetails': {
        'laboratory': [
          'CD4 Count',
          'Viral Load Testing',
          'Drug Resistance Testing',
          'Confirmatory Testing',
        ],
      },
      'photos': [],
    },
    {
      'id': 'drmc_lab',
      'name': 'DRMC Laboratory',
      'position': LatLng(7.070345, 125.618234),
      'category': 'single',
      'services': ['laboratory'],
      'hours': 'Open 24 hours',
      'phone': '+63-82-227-2731',
      'address': 'Tagum City, Davao del Norte',
      'description': 'Regional medical center HIV diagnostic services',
      'serviceDetails': {
        'laboratory': [
          'HIV Diagnostics',
          '24/7 Laboratory',
          'Emergency Testing',
        ],
      },
      'photos': [],
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
              // Filter based on selected categories and services
              if (center['category'] == 'multi' && !showMultiService)
                return false;

              // For single service centers
              if (center['category'] == 'single') {
                final service = center['services'][0];
                if (service == 'treatment' && !showTreatmentHubs) return false;
                if (service == 'prep' && !showPrepSites) return false;
                if (service == 'testing' && !showTestingSites) return false;
                if (service == 'laboratory' && !showLaboratory) return false;
              }

              return true;
            })
            .map((center) {
              BitmapDescriptor markerIcon;

              // Set marker icon based on category
              if (center['category'] == 'multi') {
                // Purple marker for multi-service centers
                markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet,
                );
              } else {
                // Single service marker colors
                final service = center['services'][0];
                if (service == 'treatment') {
                  markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  );
                } else if (service == 'prep') {
                  markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  );
                } else if (service == 'testing') {
                  markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  );
                } else {
                  markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange,
                  );
                }
              }

              return Marker(
                markerId: MarkerId(center['id']),
                position: center['position'],
                infoWindow: InfoWindow(
                  title: center['name'],
                  snippet:
                      center['category'] == 'multi'
                          ? 'Multi-Service Center'
                          : serviceTypes[center['services'][0]]?.label ?? '',
                ),
                icon: markerIcon,
                onTap: () {
                  setState(() {
                    selectedCenterId = center['id'];
                    selectedCenterInfo = center;
                  });

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
                final addressMatch = (center['address'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase());

                // Search in service details
                bool serviceMatch = false;
                if (center['serviceDetails'] != null) {
                  (center['serviceDetails'] as Map).values.forEach((services) {
                    if ((services as List).any(
                      (s) => s.toString().toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                    )) {
                      serviceMatch = true;
                    }
                  });
                }

                return nameMatch || addressMatch || serviceMatch;
              })
              .map((center) {
                BitmapDescriptor markerIcon;

                if (center['category'] == 'multi') {
                  markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueViolet,
                  );
                } else {
                  final service = center['services'][0];
                  if (service == 'treatment') {
                    markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    );
                  } else if (service == 'prep') {
                    markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    );
                  } else if (service == 'testing') {
                    markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    );
                  } else {
                    markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange,
                    );
                  }
                }

                return Marker(
                  markerId: MarkerId(center['id']),
                  position: center['position'],
                  infoWindow: InfoWindow(
                    title: center['name'],
                    snippet:
                        center['category'] == 'multi'
                            ? 'Multi-Service Center'
                            : serviceTypes[center['services'][0]]?.label ?? '',
                  ),
                  icon: markerIcon,
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
                    'MULTI-SERVICE CENTER',
                    Colors.purple,
                    Icons.stars,
                    showMultiService,
                  ),
                  SizedBox(height: 4),
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
                                        icon: Icon(Icons.share),
                                        onPressed: () {
                                          // Share functionality
                                        },
                                      ),
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

                              // Multi-service badge or single service badge
                              if (selectedCenterInfo['category'] ==
                                  'multi') ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.purple),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.stars,
                                        color: Colors.purple,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'MULTI-SERVICE CENTER',
                                        style: TextStyle(
                                          color: Colors.purple,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                                // Service badges for multi-service centers
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      (selectedCenterInfo['services'] as List)
                                          .map(
                                            (service) => _buildServiceChip(
                                              serviceTypes[service]!.label,
                                              serviceTypes[service]!.color,
                                              serviceTypes[service]!.icon,
                                            ),
                                          )
                                          .toList(),
                                ),
                              ] else ...[
                                // Single service badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        serviceTypes[selectedCenterInfo['services'][0]]!
                                            .color
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          serviceTypes[selectedCenterInfo['services'][0]]!
                                              .color,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    serviceTypes[selectedCenterInfo['services'][0]]!
                                        .label,
                                    style: TextStyle(
                                      color:
                                          serviceTypes[selectedCenterInfo['services'][0]]!
                                              .color,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],

                              SizedBox(height: 12),

                              // Operating hours with new widget
                              if (selectedCenterInfo['operatingHours'] !=
                                  null) ...[
                                OperatingHoursWidget(
                                  operatingHours:
                                      selectedCenterInfo['operatingHours'],
                                ),
                              ] else if (selectedCenterInfo['hours'] !=
                                  null) ...[
                                // Fallback to simple hours display
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
                                            selectedCenterInfo['hours']
                                                        ?.contains(
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
                              ],

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

                              // Service details
                              if (selectedCenterInfo['serviceDetails'] !=
                                  null) ...[
                                SizedBox(height: 16),
                                Text(
                                  'Services Offered',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                ...(selectedCenterInfo['serviceDetails'] as Map)
                                    .entries
                                    .map((entry) {
                                      final serviceType =
                                          serviceTypes[entry.key];
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                serviceType!.icon,
                                                color: serviceType.color,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                serviceType.label,
                                                style: TextStyle(
                                                  color: serviceType.color,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Padding(
                                            padding: EdgeInsets.only(left: 28),
                                            child: Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              children:
                                                  (entry.value as List)
                                                      .map(
                                                        (service) => Chip(
                                                          label: Text(
                                                            service,
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                          backgroundColor:
                                                              serviceType.color
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                          labelStyle: TextStyle(
                                                            color:
                                                                serviceType
                                                                    .color,
                                                          ),
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 0,
                                                              ),
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                        ],
                                      );
                                    })
                                    .toList(),
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
                                                    color: Colors.grey[200],
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.local_hospital,
                                                          size: 40,
                                                          color: Colors.grey,
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          'Medical\nFacility',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: Colors.grey,
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

  Widget _buildServiceChip(String label, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
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
                    title: Text('Multi-Service Centers'),
                    subtitle: Text('Centers offering multiple services'),
                    value: showMultiService,
                    onChanged: (value) {
                      setDialogState(() {
                        showMultiService = value!;
                      });
                    },
                    activeColor: Colors.purple,
                  ),
                  Divider(),
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
