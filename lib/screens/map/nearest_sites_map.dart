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
            end: TimeOfDay(hour: 15, minute: 0),
          ),
          'Tuesday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 15, minute: 0),
          ),
          'Wednesday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 15, minute: 0),
          ),
          'Thursday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 15, minute: 0),
          ),
          'Friday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 15, minute: 0),
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
      'id': 'Jefferyi_By_LoveYourself',
      'name': 'Jefferyi By LoveYourself',
      'position': LatLng(7.082876566740306, 125.61383319025228),
      'category': 'multi',
      'services': ['prep', 'testing'],
      'operatingHours': OperatingHours(
        schedule: {
          'Monday': null,
          'Tuesday': null,
          'Wednesday': TimeRange(
            start: TimeOfDay(hour: 12, minute: 0),
            end: TimeOfDay(hour: 18, minute: 0),
          ),
          'Thursday': TimeRange(
            start: TimeOfDay(hour: 12, minute: 0),
            end: TimeOfDay(hour: 18, minute: 0),
          ),
          'Friday': TimeRange(
            start: TimeOfDay(hour: 12, minute: 0),
            end: TimeOfDay(hour: 18, minute: 0),
          ),
          'Saturday': TimeRange(
            start: TimeOfDay(hour: 12, minute: 0),
            end: TimeOfDay(hour: 18, minute: 0),
          ),
          'Sunday': TimeRange(
            start: TimeOfDay(hour: 12, minute: 0),
            end: TimeOfDay(hour: 18, minute: 0),
          ),
        },
      ),
      'phone': '0918 919 2399',
      'address': 'Loyola St, Poblacion District, Davao City, Davao del Sur',
      'description':
          'Free HIV Testing, Anti-Retroviral Treatment, PrEP, PEP and other related services.',
      'serviceDetails': {
        'prep': ['PrEP Services', 'Community Support', 'LGBTQ+ Friendly'],
        'testing': ['HIV Testing', 'Anonymous Testing', 'Community Outreach'],
      },
      'photos': [
        'https://lh3.googleusercontent.com/gps-cs-s/AC9h4np3-lyQvkwkY8D700Ph-C8Cyu8TxXnRhap55qP2IJoyOZvetD3ulhzhh2C6SsyjxTLagtpe8TskLyN-mRApceLb33xSf3zOAoR9jJAUhlZDqQS-lO6bB-soXZ3fhK0KN9sA_yT6=w203-h152-k-no',
        'https://lh3.googleusercontent.com/gps-cs-s/AC9h4nqtJe2p06DwLb3O609cNXWiB-eiydDyWUNMfW1za7y4sVYSwTXA9lb6E0M5bYUAKcFyk7J9QQ50JrQFb8oraBd0flfeHXxqxwF4Y80NiqqZibxfa5_3h1rnvySSqf98gBKqG7e9=w203-h152-k-no',
      ],
    },
    {
      'id': 'mati_city_health',
      'name': 'Mati City Health Office',
      'position': LatLng(6.958550539870867, 126.20859197426022),
      'category': 'multi',
      'services': ['prep', 'testing'],
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
      'phone': '0981 339 1408',
      'address': 'Madang Barangay Central, Mati, Philippines',
      'description': 'City health office with PrEP and HIV Testing services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'Public Health Programs'],
        'testing': ['HIV Testing', 'Health Screening'],
      },
      'photos': [
        'https://streetviewpixels-pa.googleapis.com/v1/thumbnail?panoid=0XSyAXyu0Kqjv12yf9njIA&cb_client=search.gws-prod.gps&w=408&h=240&yaw=298.89655&pitch=0&thumbfov=100',
        'https://scontent.fdvo8-1.fna.fbcdn.net/v/t39.30808-6/482033591_2527759504233323_4325949883873195887_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=cc71e4&_nc_ohc=Jk2hFVYXEtsQ7kNvwFqtnAT&_nc_oc=Adm7ZWrwocfo9Qtl0fFJKg4BoHhEc8uISGWbZhu8pNoFUp2lzSHcwU92waf6HCAcSC0&_nc_zt=23&_nc_ht=scontent.fdvo8-1.fna&_nc_gid=CBv73EJo6HydwPUyUs2rqQ&oh=00_AfX8VdCDqispk8nAZT1GXcuzEIcnBoTuden6DFiZEGQphg&oe=689A7157',
      ],
    },
    {
      'id': 'fpop_davao',
      'name': 'FPOP Davao ',
      'position': LatLng(7.075297514436193, 125.61246618683586),
      'category': 'multi',
      'services': ['prep', 'testing'],
      'hours': 'Mon-Sat 9AM-6PM',
      'phone': '0975 635 9974',
      'address':
          'COPE building, Door 7 J.P. Laurel Ave, Poblacion District, Davao City, Davao del Sur',
      'description':
          'Family Planning Organization offering PrEP and Testing services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'Family Planning Integration'],
        'testing': ['HIV Testing', 'Reproductive Health Services'],
      },
      'photos': [
        'https://lh3.googleusercontent.com/gps-cs-s/AC9h4nq2VvO7mvXaaKCnrG-dy-bn3oW_ZFC6k85LcpkZHv6oKH8E-l7U9GPXdTA_5cpaSFTDkCIWidrx0DcXqDUzSjQHC0Fedro1qX7_SeYLlXACMUrF4SC2XOkohfq-o59XtXO55Yl1iQ=w408-h306-k-no',
        'https://lh3.googleusercontent.com/gps-cs-s/AC9h4noAN7YXKgwfNygcocBKg6gw8_lPL3RqouWdy-aZCq2oWSIi_6R3JPVDNPdhvxcUFJP8obTsbpRwol52hq03QnHjRPAILF-2mumkqC-JACYxLGcob0fkeo6W_0o80jI0xTuJG9GT4PkNHPB5=s1231-k-no',
      ],
    },

    // SINGLE SERVICE CENTERS - Treatment Hubs Only
    {
      'id': 'spmc_hact',
      'name': 'Southern Philippines Medical Center (SPMC-HACT)',
      'position': LatLng(7.09855368510992, 125.61971888002385),
      'category': 'single',
      'services': ['treatment', 'prep', 'laboratory'],
      'hours': 'Open 24 hours',
      'phone': '0955 514 5191',
      'address': '2nd Fl SPMC Main Building Dumanlas Street Davao City.',
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
      'photos': [
        'https://lh3.googleusercontent.com/gps-cs-s/AC9h4no1j9b8BficpSUr2Hu6fZnWiXUlNYM4I15p1C_YhLrGNpPKUQsNuO_E7dDaU6CBQE-OCPbojO_GIpvanDSltDQRgXSfKdjZ-HxwOkRaXO1xNJcmbdV6Uwf5gohapMg7-jp7ZemQ=w408-h281-k-no',
        'https://lh3.googleusercontent.com/gps-cs-s/AC9h4npvlZ-Zt96S-t6W16CPVirR5pj_xzXsEXANJtz5QZEo9vucIdEfcg_Ly3MWWFUX-o9RtPSULrWa-QsJ6V4E5UBq_MBErDKNz1Ggi_t4yG8fMGqOaIws9Ob8S_tcEPrV4i-eEgxTww=w203-h270-k-no',
      ],
    },

    {
      'id': 'digos_rhwc',
      'name': 'Reproductive Health & Wellness Center Digos',
      'position': LatLng(6.744915434218531, 125.3640776224826),
      'category': 'multi',
      'services': ['treatment', 'prep', 'testing'],
      'operatingHours': OperatingHours(
        schedule: {
          'Monday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 14, minute: 0),
          ),
          'Tuesday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 14, minute: 0),
          ),
          'Wednesday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 14, minute: 0),
          ),
          'Thursday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 14, minute: 0),
          ),
          'Friday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 14, minute: 0),
          ),
          'Saturday': null, // Closed
          'Sunday': null, // Closed
        },
      ),
      'phone': '0909 733 9297',
      'address':
          'lapu lapu bataan street barangay zone 3, brgy digos city, Digos, Philippines',
      'description':
          'Comprehensive HIV center offering all services: Treatment Hub, PrEP, and Testing',
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
        'https://scontent.fdvo5-1.fna.fbcdn.net/v/t39.30808-6/481670986_952325677061679_7041732160477496237_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=6ee11a&_nc_ohc=rfRzQA_Nd6kQ7kNvwHxT5uc&_nc_oc=AdlqVmF8msUHxgBlrICZ2l6YL__5aTS1FYF3GeG9OAVD6eUZRPOZ0FqrcXl_bBnv8fE&_nc_zt=23&_nc_ht=scontent.fdvo5-1.fna&_nc_gid=Lk5RZWC0jvJ8P76DEim_Yw&oh=00_AfUJ3kDgSAB1ddW53IPnSB5q6FOsJW8H44nIeU7RxXabNQ&oe=6899E7EF',
        'https://scontent.fdvo5-1.fna.fbcdn.net/v/t39.30808-6/499928536_1007040124923567_3593286081340667861_n.jpg?_nc_cat=111&ccb=1-7&_nc_sid=833d8c&_nc_ohc=gHDduykdNh4Q7kNvwHpOeC9&_nc_oc=AdlJrswBlKoJjgtAUrsuAM990zmUuzbF5lho0zNuNilRN_P8zcVIab8SdvNadQ5WFfk&_nc_zt=23&_nc_ht=scontent.fdvo5-1.fna&_nc_gid=ctfOQDPqQKTidV_DpBO8tg&oh=00_AfVR8IgDEXd_uJz7ZeI4H1Z9Qxs8KIAdrJqtGnIyeLB2iA&oe=6899E57Ar',
      ],
    },
    {
      'id': 'sta_cruz_rhu',
      'name': 'Sta. Cruz Rural Health Unit',
      'position': LatLng(6.834084731444258, 125.41464803344893),
      'category': 'single',
      'services': ['prep'],
      'hours': 'Mon-Fri 8AM-5PM',
      'phone': '0948 297 8080',
      'address': 'Sta. Cruz, Davao del Sur',
      'description': 'Rural health unit with PrEP services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'Primary Healthcare', 'Community Programs'],
      },
      // 'photos': [],
    },
    {
      'id': 'malita_rhu',
      'name': 'Malita Rural Health Unit',
      'position': LatLng(6.41472095790284, 125.61080510541582),
      'category': 'single',
      'services': ['prep'],
      'hours': 'open 24 hours',
      'phone': '0920 988 8883',
      'address': 'Malita, Davao Occidental',
      'description': 'Rural health unit offering PrEP services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'Rural Healthcare'],
      },
      // 'photos': [],
    },
    {
      'id': 'rhwc_tagum',
      'name': 'RHWC Tagum',
      'position': LatLng(7.447544329254662, 125.79509492197683),
      'category': 'single',
      'services': ['prep'],
      'operatingHours': OperatingHours(
        schedule: {
          'Monday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 16, minute: 0),
          ),
          'Tuesday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 16, minute: 0),
          ),
          'Wednesday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 16, minute: 0),
          ),
          'Thursday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 16, minute: 0),
          ),
          'Friday': TimeRange(
            start: TimeOfDay(hour: 8, minute: 0),
            end: TimeOfDay(hour: 16, minute: 0),
          ),
          'Saturday': null, // Closed
          'Sunday': null, // Closed
        },
      ),
      'phone': 'stihivaids.lgutagum@gmail.com',
      'address': 'Tagum City, Davao del Norte',
      'description': 'Reproductive health center with PrEP services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'Reproductive Health'],
      },
      'photos': [
        'https://lh3.googleusercontent.com/gps-cs-s/AC9h4nq6Gy6_xB0SaWmpFT33AM9NLailQVyQ__4bTV-97NpLGnn7sgcO0whYnz9T4cM-xbCguWuyzcXC6wT8nMpTIN4Z_F-N5OQwZWdIU4BRMucywA3h8NiOKMGqY6SHd5CjfxW_gnID=s1360-w1360-h1020',
        'https://scontent.fdvo8-1.fna.fbcdn.net/v/t39.30808-6/498338553_1021037056832263_2660683057686831311_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=833d8c&_nc_ohc=b6_FggnROP8Q7kNvwGu4ysb&_nc_oc=AdlkprVjlg3c3AeObON2VAMr0hcen_FbMvnpiVKRLQCVdVRvg2cLUHOr5HK54AGzMy4&_nc_zt=23&_nc_ht=scontent.fdvo8-1.fna&_nc_gid=h6STEcRcKHg1dCazUDG-eQ&oh=00_AfURKeD4yxSeMAipPaNOQ4KClWYCftC9VZxLOvpeFdLQfg&oe=689A8B3A',
      ],
    },
    {
      'id': 'panabo_hygiene',
      'name': 'Panabo Social Hygiene & Wellness Center',
      'position': LatLng(7.308456, 125.684123),
      'category': 'single',
      'services': ['prep'],
      'hours': 'Open 24 hours',
      'phone': '0848221300',
      'address':
          'Quezon St. City Health Office Compound Brgy. New Pandan, Panabo, Philippines',
      'description': 'Social hygiene center offering PrEP services',
      'serviceDetails': {
        'prep': ['PrEP Services', 'STI Services', 'Wellness Programs'],
      },
      'photos': [],
    },

    // SINGLE SERVICE CENTERS - Testing Sites Only
    {
      'id': 'davao_del_sur_hospital',
      'name': 'Davao del Sur Provincial Hospital - HACT',
      'position': LatLng(6.74373642086624, 125.36124415303766),
      'category': 'single',
      'services': ['testing'],
      'operatingHours': OperatingHours(
        schedule: {
          'Monday': TimeRange(
            start: TimeOfDay(hour: 6, minute: 0),
            end: TimeOfDay(hour: 16, minute: 0),
          ),
          'Tuesday': TimeRange(
            start: TimeOfDay(hour: 9, minute: 0),
            end: TimeOfDay(hour: 16, minute: 0),
          ),
          'Wednesday': TimeRange(
            start: TimeOfDay(hour: 9, minute: 0),
            end: TimeOfDay(hour: 16, minute: 0),
          ),
          'Thursday': TimeRange(
            start: TimeOfDay(hour: 9, minute: 0),
            end: TimeOfDay(hour: 16, minute: 0),
          ),
          'Friday': TimeRange(
            start: TimeOfDay(hour: 9, minute: 0),
            end: TimeOfDay(hour: 16, minute: 0),
          ),
          'Saturday': null, // Closed
          'Sunday': null, // Closed
        },
      ),
      'phone': ['0951 410 8208', 'dsph.hact@gmail.com'],
      'address':
          'DSPH HACT National Hospital Lapu Lapu St. Digos City Davao del Sur , Digos, Philippines',
      'description': 'Provincial hospital HIV testing services',
      'serviceDetails': {
        'testing': ['HIV Testing', 'Provincial Health Services'],
      },
      'photos': [
        'https://scontent.fdvo5-1.fna.fbcdn.net/v/t39.30808-6/469967503_122095147544661639_6801285847419155984_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=cc71e4&_nc_ohc=XukXUx14BN0Q7kNvwHTpHCi&_nc_oc=AdlwbNd9MrFLLR5UMAR1P6HefSEn_RTv91Vp0Kn6koVxIt_4wYo9pvV-xJzQXm2TMzw&_nc_zt=23&_nc_ht=scontent.fdvo5-1.fna&_nc_gid=dKrXXIUIkTqeBWx3hJyObA&oh=00_AfXM8cMcCN-jM1Yoi9nXjqoACNhlZ4YPtlDziK2_o2Kvhw&oe=689A91BF',
        'https://streetviewpixels-pa.googleapis.com/v1/thumbnail?panoid=7tc-mg_cRmM8l2lbdcrDig&cb_client=search.gws-prod.gps&w=408&h=240&yaw=0.22927986&pitch=0&thumbfov=100',
      ],
    },
    {
      'id': 'higala_community',
      'name': 'Higala Community Center',
      'position': LatLng(7.082852946701398, 125.61379204505347),
      'category': 'single',
      'services': ['testing'],
      'operatingHours': OperatingHours(
        schedule: {
          'Monday': TimeRange(
            start: TimeOfDay(hour: 15, minute: 0),
            end: TimeOfDay(hour: 22, minute: 0),
          ),
          'Tuesday': TimeRange(
            start: TimeOfDay(hour: 15, minute: 0),
            end: TimeOfDay(hour: 22, minute: 0),
          ),
          'Wednesday': TimeRange(
            start: TimeOfDay(hour: 15, minute: 0),
            end: TimeOfDay(hour: 22, minute: 0),
          ),
          'Thursday': TimeRange(
            start: TimeOfDay(hour: 15, minute: 0),
            end: TimeOfDay(hour: 22, minute: 0),
          ),
          'Friday': TimeRange(
            start: TimeOfDay(hour: 15, minute: 0),
            end: TimeOfDay(hour: 22, minute: 0),
          ),
          'Saturday': TimeRange(
            start: TimeOfDay(hour: 15, minute: 0),
            end: TimeOfDay(hour: 22, minute: 0),
          ),
          'Sunday': TimeRange(
            start: TimeOfDay(hour: 15, minute: 0),
            end: TimeOfDay(hour: 22, minute: 0),
          ),
        },
      ),
      'phone': '0948 632 0144',
      'address':
          'Door 4 Don Pedro, Carriedo Bldg., Loyola St., Bo Obrero Brgy. 13-B , Davao City, Philippines',
      'description': 'LGBTQ+ friendly community center with HIV testing',
      'serviceDetails': {
        'testing': [
          'HIV Testing',
          'LGBTQ+ Support',
          'Safe Space',
          'Anonymous Testing',
        ],
      },
      'photos': [
        'https://streetviewpixels-pa.googleapis.com/v1/thumbnail?panoid=YpH4vR-7SzY21xuRKlMFyQ&cb_client=search.gws-prod.gps&w=408&h=240&yaw=183.12291&pitch=0&thumbfov=100',
        'https://scontent.fdvo5-1.fna.fbcdn.net/v/t39.30808-6/482027691_498340490000623_8452687627038826527_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=833d8c&_nc_aid=0&_nc_ohc=V82_C1KYZ0IQ7kNvwG5NKXl&_nc_oc=Adm2kF3okArM0ardNf5z9TjIOjJrY_f-H0JNdxDfzvVdHxGQ5c8r2dE5FCTKTvzwUjw&_nc_zt=23&_nc_ht=scontent.fdvo5-1.fna&_nc_gid=LrrCMolFkKjFfm-d7HUk2g&oh=00_AfXcCIeyPx0RxChbuykgTpX3ODBe8XIMNz0R8dtwLZxRTg&oe=689A9903',
      ],
    },

    // SINGLE SERVICE CENTERS - Laboratory Only
    {
      'id': 'davao_doctors_hospital',
      'name': 'Davao Doctors Hospital (ARTU)',
      'position': LatLng(7.070359023666482, 125.60467408187525),
      'category': 'single',
      'services': ['treatment'],
      'hours': 'open 24 hours',
      'phone': '(08) 222 28000',
      'address':
          '118 Elpidio Quirino Ave, Poblacion District, Davao City, 8000 Davao del Sur',
      'description': 'Regional HIV/AIDS laboratory testing facility',
      'serviceDetails': {
        'treatment': [
          'HIV Treatment',
          'ARV Therapy',
          'Counseling',
          'Case Management',
        ],
      },
      'photos': [
        'https://lh3.googleusercontent.com/p/AF1QipOVMr4Vv68D1A5gStPeqCyspLUliTXUdOUZ4LXV=w408-h291-k-no',
        'https://lh3.googleusercontent.com/gps-cs-s/AC9h4npJjCKxsSMvdzfmLTFzujS8c7ST9A7v0vfNGKW4z--zW8v_Qe_J3_Afs4RC2zXufgMXBEPhVXzp_5PrPZpEzOlVPRiwp291R0MhQjZD61W2DsFxkocBo86gma4xVS38s7zJcZ4nfQ=s819-k-no',
      ],
    },
    {
      'id': 'drmc',
      'name': 'DRMC',
      'position': LatLng(7.4223483412456615, 125.82869652866002),
      'category': 'single',
      'services': ['laboratory'],
      'hours': 'Open 24 hours',
      'phone': 'hemu@drmc.doh.gov.ph',
      'address': 'Tagum City, Davao del Norte',
      'description': 'Regional medical center HIV diagnostic services',
      'serviceDetails': {
        'laboratory': [
          'HIV Diagnostics',
          '24/7 Laboratory',
          'Emergency Testing',
        ],
      },
      'photos': [
        'https://scontent.fdvo8-1.fna.fbcdn.net/v/t39.30808-6/486693600_681798800862453_2212917487596536947_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=cc71e4&_nc_ohc=TAP4JAs_zPUQ7kNvwHufL8E&_nc_oc=Adnqk0El9oVnwQ-xD9yGAk6flCHWi_9JgYr5u0gpGf5tsV31iAMWiFVOr7V7k3Fl12M&_nc_zt=23&_nc_ht=scontent.fdvo8-1.fna&_nc_gid=ehdVmvcd0erpCNzlsDwuAg&oh=00_AfVE7hD347huhVfZ5gm4Chps5qj2uIdeHE09I4tfJQ3a-g&oe=689A7776',
        'https://streetviewpixels-pa.googleapis.com/v1/thumbnail?panoid=JddCkGeyGe7beW3cwbnTGA&cb_client=maps_sv.tactile.gps&w=203&h=100&yaw=131.56364&pitch=0&thumbfov=100',
      ],
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
