// lib/data/datasources/hiv_center_data.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/hiv_center.dart';
import '../../models/service_type.dart';
import '../../models/center_category.dart';
import '../../models/contact_info.dart';
import '../../models/operating_hours.dart';
import '../../models/time_range.dart';

class HIVCenterData {
  static List<HIVCenter> getAllCenters() {
    return [
      // MULTI-SERVICE CENTERS
      HIVCenter(
        id: 'rhwc_davao',
        name: 'Reproductive Health & Wellness Center Davao (RHWC Davao)',
        position: const LatLng(7.068752634153147, 125.61663351395941),
        category: CenterCategory.multi,
        services: const [
          ServiceType.treatment,
          ServiceType.prep,
          ServiceType.testing,
          ServiceType.laboratory,
        ],
        operatingHours: OperatingHours(
          schedule: {
            'Monday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 15, minute: 0),
            ),
            'Tuesday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 15, minute: 0),
            ),
            'Wednesday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 15, minute: 0),
            ),
            'Thursday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 15, minute: 0),
            ),
            'Friday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 15, minute: 0),
            ),
            'Saturday': null,
            'Sunday': null,
          },
        ),
        contactInfo: const ContactInfo(
          phone: '(082) 222 4187',
          address:
              '3J98+GM2, Emilio Jacinto St, Poblacion District, Davao City, Davao del Sur',
        ),
        description:
            'Comprehensive HIV center offering all services: Treatment Hub, PrEP, Testing, and Laboratory',
        serviceDetails: const {
          ServiceType.treatment: [
            'HIV Treatment',
            'ARV Therapy',
            'Counseling',
            'Case Management',
          ],
          ServiceType.prep: [
            'Pre-exposure prophylaxis',
            'Risk Assessment',
            'PrEP Monitoring',
          ],
          ServiceType.testing: [
            'HIV Testing',
            'Self-Test Kits',
            'Rapid Testing',
            'Confirmatory Testing',
          ],
          ServiceType.laboratory: [
            'CD4 Count',
            'Viral Load Testing',
            'Drug Resistance Testing',
          ],
        },
        photos: const [
          'https://www.davaocity.gov.ph/wp-content/uploads/2022/12/viber_image_2022-12-06_08-17-03-004-scaled.jpg',
          'https://streetviewpixels-pa.googleapis.com/v1/thumbnail?output=thumbnail&cb_client=maps_sv.tactile.gps&panoid=aMeveCJ3Es-JJeTMNVoMqw&w=1177&h=580&thumb=2&yaw=244.38109&pitch=0',
        ],
      ),

      HIVCenter(
        id: 'drmc_redstar',
        name: 'Davao Regional Medical Center (DRMC-REDSTAR)',
        position: const LatLng(7.421615617505603, 125.82785338552642),
        category: CenterCategory.multi,
        services: const [
          ServiceType.treatment,
          ServiceType.prep,
          ServiceType.testing,
        ],
        operatingHours: OperatingHours(
          schedule: {
            'Monday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 17, minute: 0),
            ),
            'Tuesday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 17, minute: 0),
            ),
            'Wednesday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 17, minute: 0),
            ),
            'Thursday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 17, minute: 0),
            ),
            'Friday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 17, minute: 0),
            ),
            'Saturday': null,
            'Sunday': null,
          },
        ),
        contactInfo: const ContactInfo(
          phone: '0991 145 8211',
          address:
              '2nd Floor, Davao Regional Medical Center, OPD Building, Tagum, Davao del Norte',
        ),
        description:
            'Regional medical center with Treatment Hub, PrEP, and Testing services',
        serviceDetails: const {
          ServiceType.treatment: [
            'HIV Treatment',
            'ARV Therapy',
            'Emergency Care',
            'Inpatient Services',
          ],
          ServiceType.prep: ['Pre-exposure prophylaxis', 'Risk Counseling'],
          ServiceType.testing: [
            'HIV Testing',
            'Rapid Testing',
            '24/7 Emergency Testing',
          ],
        },
        photos: const [
          'https://streetviewpixels-pa.googleapis.com/v1/thumbnail?panoid=-TgvBB7ILylaIVoahbmVng&cb_client=maps_sv.tactile.gps&w=203&h=100&yaw=117.57874&pitch=0&thumbfov=100',
        ],
      ),

      HIVCenter(
        id: 'jefferyi_by_loveyourself',
        name: 'Jefferyi By LoveYourself',
        position: const LatLng(7.082876566740306, 125.61383319025228),
        category: CenterCategory.multi,
        services: const [ServiceType.prep, ServiceType.testing],
        operatingHours: OperatingHours(
          schedule: {
            'Monday': null,
            'Tuesday': null,
            'Wednesday': const TimeRange(
              start: TimeOfDay(hour: 12, minute: 0),
              end: TimeOfDay(hour: 18, minute: 0),
            ),
            'Thursday': const TimeRange(
              start: TimeOfDay(hour: 12, minute: 0),
              end: TimeOfDay(hour: 18, minute: 0),
            ),
            'Friday': const TimeRange(
              start: TimeOfDay(hour: 12, minute: 0),
              end: TimeOfDay(hour: 18, minute: 0),
            ),
            'Saturday': const TimeRange(
              start: TimeOfDay(hour: 12, minute: 0),
              end: TimeOfDay(hour: 18, minute: 0),
            ),
            'Sunday': const TimeRange(
              start: TimeOfDay(hour: 12, minute: 0),
              end: TimeOfDay(hour: 18, minute: 0),
            ),
          },
        ),
        contactInfo: const ContactInfo(
          phone: '0918 919 2399',
          address: 'Loyola St, Poblacion District, Davao City, Davao del Sur',
        ),
        description:
            'Free HIV Testing, Anti-Retroviral Treatment, PrEP, PEP and other related services.',
        serviceDetails: const {
          ServiceType.prep: [
            'PrEP Services',
            'Community Support',
            'LGBTQ+ Friendly',
          ],
          ServiceType.testing: [
            'HIV Testing',
            'Anonymous Testing',
            'Community Outreach',
          ],
        },
        photos: const [
          'https://lh3.googleusercontent.com/gps-cs-s/AC9h4np3-lyQvkwkY8D700Ph-C8Cyu8TxXnRhap55qP2IJoyOZvetD3ulhzhh2C6SsyjxTLagtpe8TskLyN-mRApceLb33xSf3zOAoR9jJAUhlZDqQS-lO6bB-soXZ3fhK0KN9sA_yT6=w203-h152-k-no',
          'https://lh3.googleusercontent.com/gps-cs-s/AC9h4nqtJe2p06DwLb3O609cNXWiB-eiydDyWUNMfW1za7y4sVYSwTXA9lb6E0M5bYUAKcFyk7J9QQ50JrQFb8oraBd0flfeHXxqxwF4Y80NiqqZibxfa5_3h1rnvySSqf98gBKqG7e9=w203-h152-k-no',
        ],
      ),

      HIVCenter(
        id: 'mati_city_health',
        name: 'Mati City Health Office',
        position: const LatLng(6.958550539870867, 126.20859197426022),
        category: CenterCategory.multi,
        services: const [ServiceType.prep, ServiceType.testing],
        operatingHours: OperatingHours(
          schedule: {
            'Monday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 17, minute: 0),
            ),
            'Tuesday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 17, minute: 0),
            ),
            'Wednesday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 17, minute: 0),
            ),
            'Thursday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 17, minute: 0),
            ),
            'Friday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 17, minute: 0),
            ),
            'Saturday': null,
            'Sunday': null,
          },
        ),
        contactInfo: const ContactInfo(
          phone: '0981 339 1408',
          address: 'Madang Barangay Central, Mati, Philippines',
        ),
        description: 'City health office with PrEP and HIV Testing services',
        serviceDetails: const {
          ServiceType.prep: ['PrEP Services', 'Public Health Programs'],
          ServiceType.testing: ['HIV Testing', 'Health Screening'],
        },
        photos: const [
          'https://streetviewpixels-pa.googleapis.com/v1/thumbnail?panoid=0XSyAXyu0Kqjv12yf9njIA&cb_client=search.gws-prod.gps&w=408&h=240&yaw=298.89655&pitch=0&thumbfov=100',
          'https://scontent.fdvo8-1.fna.fbcdn.net/v/t39.30808-6/482033591_2527759504233323_4325949883873195887_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=cc71e4&_nc_ohc=Jk2hFVYXEtsQ7kNvwFqtnAT&_nc_oc=Adm7ZWrwocfo9Qtl0fFJKg4BoHhEc8uISGWbZhu8pNoFUp2lzSHcwU92waf6HCAcSC0&_nc_zt=23&_nc_ht=scontent.fdvo8-1.fna&_nc_gid=CBv73EJo6HydwPUyUs2rqQ&oh=00_AfX8VdCDqispk8nAZT1GXcuzEIcnBoTuden6DFiZEGQphg&oe=689A7157',
        ],
      ),

      HIVCenter(
        id: 'fpop_davao',
        name: 'FPOP Davao',
        position: const LatLng(7.075297514436193, 125.61246618683586),
        category: CenterCategory.multi,
        services: const [ServiceType.prep, ServiceType.testing],
        contactInfo: const ContactInfo(
          phone: '0975 635 9974',
          address:
              'COPE building, Door 7 J.P. Laurel Ave, Poblacion District, Davao City, Davao del Sur',
        ),
        description:
            'Family Planning Organization offering PrEP and Testing services',
        serviceDetails: const {
          ServiceType.prep: ['PrEP Services', 'Family Planning Integration'],
          ServiceType.testing: ['HIV Testing', 'Reproductive Health Services'],
        },
        hours: 'Mon-Sat 9AM-6PM',
        photos: const [
          'https://lh3.googleusercontent.com/gps-cs-s/AC9h4nq2VvO7mvXaaKCnrG-dy-bn3oW_ZFC6k85LcpkZHv6oKH8E-l7U9GPXdTA_5cpaSFTDkCIWidrx0DcXqDUzSjQHC0Fedro1qX7_SeYLlXACMUrF4SC2XOkohfq-o59XtXO55Yl1iQ=w408-h306-k-no',
        ],
      ),

      // SINGLE SERVICE CENTERS - Treatment Hubs
      HIVCenter(
        id: 'spmc_hact',
        name: 'Southern Philippines Medical Center (SPMC-HACT)',
        position: const LatLng(7.09855368510992, 125.61971888002385),
        category: CenterCategory.single,
        services: const [ServiceType.treatment],
        contactInfo: const ContactInfo(
          phone: '0955 514 5191',
          address: '2nd Fl SPMC Main Building Dumanlas Street Davao City.',
        ),
        description:
            'Major medical center with HIV/AIDS Care and Treatment program',
        serviceDetails: const {
          ServiceType.treatment: [
            'HIV/AIDS Treatment',
            'HACT Program',
            'Emergency Care',
            'Inpatient Services',
          ],
        },
        hours: 'Open 24 hours',
        photos: const [
          'https://lh3.googleusercontent.com/gps-cs-s/AC9h4no1j9b8BficpSUr2Hu6fZnWiXUlNYM4I15p1C_YhLrGNpPKUQsNuO_E7dDaU6CBQE-OCPbojO_GIpvanDSltDQRgXSfKdjZ-HxwOkRaXO1xNJcmbdV6Uwf5gohapMg7-jp7ZemQ=w408-h281-k-no',
        ],
      ),

      HIVCenter(
        id: 'digos_rhwc',
        name: 'Reproductive Health & Wellness Center Digos',
        position: const LatLng(6.744915434218531, 125.3640776224826),
        category: CenterCategory.multi,
        services: const [
          ServiceType.treatment,
          ServiceType.prep,
          ServiceType.testing,
        ],
        operatingHours: OperatingHours(
          schedule: {
            'Monday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 14, minute: 0),
            ),
            'Tuesday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 14, minute: 0),
            ),
            'Wednesday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 14, minute: 0),
            ),
            'Thursday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 14, minute: 0),
            ),
            'Friday': const TimeRange(
              start: TimeOfDay(hour: 8, minute: 0),
              end: TimeOfDay(hour: 14, minute: 0),
            ),
            'Saturday': null,
            'Sunday': null,
          },
        ),
        contactInfo: const ContactInfo(
          phone: '0909 733 9297',
          address:
              'lapu lapu bataan street barangay zone 3, brgy digos city, Digos, Philippines',
        ),
        description:
            'Comprehensive HIV center offering all services: Treatment Hub, PrEP, and Testing',
        serviceDetails: const {
          ServiceType.treatment: [
            'HIV Treatment',
            'ARV Therapy',
            'Counseling',
            'Case Management',
          ],
          ServiceType.prep: [
            'Pre-exposure prophylaxis',
            'Risk Assessment',
            'PrEP Monitoring',
          ],
          ServiceType.testing: [
            'HIV Testing',
            'Self-Test Kits',
            'Rapid Testing',
            'Confirmatory Testing',
          ],
        },
        photos: const [
          'https://scontent.fdvo5-1.fna.fbcdn.net/v/t39.30808-6/481670986_952325677061679_7041732160477496237_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=6ee11a&_nc_ohc=rfRzQA_Nd6kQ7kNvwHxT5uc&_nc_oc=AdlqVmF8msUHxgBlrICZ2l6YL__5aTS1FYF3GeG9OAVD6eUZRPOZ0FqrcXl_bBnv8fE&_nc_zt=23&_nc_ht=scontent.fdvo5-1.fna&_nc_gid=Lk5RZWC0jvJ8P76DEim_Yw&oh=00_AfUJ3kDgSAB1ddW53IPnSB5q6FOsJW8H44nIeU7RxXabNQ&oe=6899E7EF',
        ],
      ),

      // SINGLE SERVICE CENTERS - Testing Sites
      HIVCenter(
        id: 'higala_community',
        name: 'Higala Community Center',
        position: const LatLng(7.082852946701398, 125.61379204505347),
        category: CenterCategory.single,
        services: const [ServiceType.testing],
        operatingHours: OperatingHours(
          schedule: {
            'Monday': const TimeRange(
              start: TimeOfDay(hour: 15, minute: 0),
              end: TimeOfDay(hour: 22, minute: 0),
            ),
            'Tuesday': const TimeRange(
              start: TimeOfDay(hour: 15, minute: 0),
              end: TimeOfDay(hour: 22, minute: 0),
            ),
            'Wednesday': const TimeRange(
              start: TimeOfDay(hour: 15, minute: 0),
              end: TimeOfDay(hour: 22, minute: 0),
            ),
            'Thursday': const TimeRange(
              start: TimeOfDay(hour: 15, minute: 0),
              end: TimeOfDay(hour: 22, minute: 0),
            ),
            'Friday': const TimeRange(
              start: TimeOfDay(hour: 15, minute: 0),
              end: TimeOfDay(hour: 22, minute: 0),
            ),
            'Saturday': const TimeRange(
              start: TimeOfDay(hour: 15, minute: 0),
              end: TimeOfDay(hour: 22, minute: 0),
            ),
            'Sunday': const TimeRange(
              start: TimeOfDay(hour: 15, minute: 0),
              end: TimeOfDay(hour: 22, minute: 0),
            ),
          },
        ),
        contactInfo: const ContactInfo(
          phone: '0948 632 0144',
          address:
              'Door 4 Don Pedro, Carriedo Bldg., Loyola St., Bo Obrero Brgy. 13-B , Davao City, Philippines',
        ),
        description: 'LGBTQ+ friendly community center with HIV testing',
        serviceDetails: const {
          ServiceType.testing: [
            'HIV Testing',
            'LGBTQ+ Support',
            'Safe Space',
            'Anonymous Testing',
          ],
        },
        photos: const [
          'https://streetviewpixels-pa.googleapis.com/v1/thumbnail?panoid=YpH4vR-7SzY21xuRKlMFyQ&cb_client=search.gws-prod.gps&w=408&h=240&yaw=183.12291&pitch=0&thumbfov=100',
        ],
      ),
    ];
  }
}
