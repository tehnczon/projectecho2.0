// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/hiv_center.dart';
import '../models/service_type.dart';
import '../models/center_category.dart';
import '../models/contact_info.dart';
import '../models/operating_hours.dart';
import '../models/time_range.dart';

class FirestoreService {
  static FirestoreService? _instance;
  static FirestoreService get instance => _instance ??= FirestoreService._();
  FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'centers'; // Your Firestore collection name

  /// Stream of HIV Centers from Firestore
  Stream<List<HIVCenter>> getCentersStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return _parseHIVCenter(doc.id, doc.data());
                } catch (e) {
                  print('Error parsing center ${doc.id}: $e');
                  return null;
                }
              })
              .where((center) => center != null)
              .cast<HIVCenter>()
              .toList();
        });
  }

  /// Get all HIV Centers from Firestore (one-time fetch)
  Future<List<HIVCenter>> getAllCenters() async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .get();

      return snapshot.docs
          .map((doc) {
            try {
              return _parseHIVCenter(doc.id, doc.data());
            } catch (e) {
              print('Error parsing center ${doc.id}: $e');
              return null;
            }
          })
          .where((center) => center != null)
          .cast<HIVCenter>()
          .toList();
    } catch (e) {
      print('Error fetching centers from Firestore: $e');
      return [];
    }
  }

  /// Get a single center by ID
  Future<HIVCenter?> getCenterById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) return null;

      return _parseHIVCenter(doc.id, doc.data()!);
    } catch (e) {
      print('Error fetching center $id: $e');
      return null;
    }
  }

  /// Parse Firestore document to HIVCenter model
  HIVCenter _parseHIVCenter(String id, Map<String, dynamic> data) {
    // Parse position
    final position = _parsePosition(data);

    // Parse services
    final services = _parseServices(data['services']);

    // Parse category
    final category = _parseCategory(data['category']);

    // Parse contact info
    final contactInfo = _parseContactInfo(data);

    // Parse operating hours
    final operatingHours = _parseOperatingHours(data['operatingHours']);

    // Parse service details
    final serviceDetails = _parseServiceDetails(data['serviceDetails']);

    // Parse photos
    final photos = _parsePhotos(data['photos']);

    return HIVCenter(
      id: id,
      name: data['name'] ?? 'Unknown Center',
      position: position,
      category: category,
      services: services,
      operatingHours: operatingHours,
      contactInfo: contactInfo,
      description: data['description'],
      photos: photos,
      serviceDetails: serviceDetails,
      hours: data['hours'] ?? data['quickHours'],
    );
  }

  /// Parse position from Firestore data
  LatLng _parsePosition(Map<String, dynamic> data) {
    // Handle both nested position object and direct lat/lng fields
    if (data['position'] != null && data['position'] is Map) {
      final pos = data['position'] as Map<String, dynamic>;
      return LatLng(
        (pos['latitude'] ?? pos['lat'] ?? 0.0).toDouble(),
        (pos['longitude'] ?? pos['lng'] ?? 0.0).toDouble(),
      );
    } else if (data['lat'] != null && data['lng'] != null) {
      return LatLng(
        (data['lat'] ?? 0.0).toDouble(),
        (data['lng'] ?? 0.0).toDouble(),
      );
    }

    // Default to Davao City center if no position found
    return const LatLng(7.0731, 125.6128);
  }

  /// Parse services list
  List<ServiceType> _parseServices(dynamic servicesData) {
    if (servicesData == null) return [ServiceType.testing];

    if (servicesData is List) {
      return servicesData
          .map((s) => ServiceType.fromKey(s.toString()))
          .where((s) => s != null)
          .cast<ServiceType>()
          .toList();
    }

    return [ServiceType.testing];
  }

  /// Parse category
  CenterCategory _parseCategory(dynamic categoryData) {
    if (categoryData == null) return CenterCategory.single;

    final categoryStr = categoryData.toString().toLowerCase();
    return categoryStr == 'multi'
        ? CenterCategory.multi
        : CenterCategory.single;
  }

  /// Parse contact info
  ContactInfo _parseContactInfo(Map<String, dynamic> data) {
    // Handle both nested contactInfo object and direct fields
    if (data['contactInfo'] != null && data['contactInfo'] is Map) {
      final contact = data['contactInfo'] as Map<String, dynamic>;
      return ContactInfo(
        phone: contact['phone']?.toString(),
        email: contact['email']?.toString(),
        facebook: contact['facebook']?.toString(),
        website: contact['website']?.toString(),
        address:
            contact['address']?.toString() ?? data['address']?.toString() ?? '',
      );
    }

    // Fallback to direct fields
    return ContactInfo(
      phone: data['phone']?.toString(),
      email: data['email']?.toString(),
      facebook: data['facebook']?.toString(),
      website: data['website']?.toString(),
      address: data['address']?.toString() ?? '',
    );
  }

  /// Parse operating hours
  OperatingHours? _parseOperatingHours(dynamic hoursData) {
    if (hoursData == null || hoursData is! Map) return null;

    final schedule = <String, TimeRange?>{};
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    for (final day in days) {
      final dayKey = day.toLowerCase();
      if (hoursData[dayKey] != null && hoursData[dayKey] is Map) {
        final dayData = hoursData[dayKey] as Map<String, dynamic>;

        if (dayData['isOpen'] == true &&
            dayData['openTime'] != null &&
            dayData['closeTime'] != null) {
          final openTime = _parseTimeString(dayData['openTime'].toString());
          final closeTime = _parseTimeString(dayData['closeTime'].toString());

          if (openTime != null && closeTime != null) {
            schedule[day] = TimeRange(start: openTime, end: closeTime);
          } else {
            schedule[day] = null;
          }
        } else {
          schedule[day] = null;
        }
      } else {
        schedule[day] = null;
      }
    }

    return OperatingHours(schedule: schedule);
  }

  /// Parse time string (HH:mm) to TimeOfDay
  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Error parsing time string: $timeStr');
      return null;
    }
  }

  /// Parse service details
  Map<ServiceType, List<String>> _parseServiceDetails(dynamic detailsData) {
    if (detailsData == null || detailsData is! Map) return {};

    final result = <ServiceType, List<String>>{};

    detailsData.forEach((key, value) {
      final serviceType = ServiceType.fromKey(key.toString());
      if (serviceType != null && value is List) {
        result[serviceType] = value.map((v) => v.toString()).toList();
      }
    });

    return result;
  }

  /// Parse photos list
  List<String> _parsePhotos(dynamic photosData) {
    if (photosData == null) return [];

    if (photosData is List) {
      return photosData.map((p) => p.toString()).toList();
    }

    return [];
  }

  /// Add or update a center in Firestore
  Future<void> saveCenter(HIVCenter center) async {
    try {
      final data = _centerToFirestore(center);
      await _firestore
          .collection(_collection)
          .doc(center.id)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error saving center: $e');
      throw e;
    }
  }

  /// Convert HIVCenter to Firestore document
  Map<String, dynamic> _centerToFirestore(HIVCenter center) {
    return {
      'name': center.name,
      'position': {
        'latitude': center.position.latitude,
        'longitude': center.position.longitude,
      },
      'lat': center.position.latitude,
      'lng': center.position.longitude,
      'category': center.category == CenterCategory.multi ? 'multi' : 'single',
      'services': center.services.map((s) => s.key).toList(),
      'contactInfo': {
        'phone': center.contactInfo.phone,
        'email': center.contactInfo.email,
        'facebook': center.contactInfo.facebook,
        'website': center.contactInfo.website,
        'address': center.contactInfo.address,
      },
      'address': center.contactInfo.address,
      'phone': center.contactInfo.phone,
      'description': center.description,
      'photos': center.photos,
      'serviceDetails': _serviceDetailsToMap(center.serviceDetails),
      'hours': center.hours,
      'quickHours': center.hours,
      'operatingHours':
          center.operatingHours != null
              ? _operatingHoursToMap(center.operatingHours!)
              : null,
      'isActive': true,
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert service details to map
  Map<String, dynamic> _serviceDetailsToMap(
    Map<ServiceType, List<String>> details,
  ) {
    final result = <String, dynamic>{};
    details.forEach((serviceType, detailsList) {
      result[serviceType.key] = detailsList;
    });
    return result;
  }

  /// Convert operating hours to Firestore format
  Map<String, dynamic> _operatingHoursToMap(OperatingHours hours) {
    final result = <String, dynamic>{};

    hours.schedule.forEach((day, timeRange) {
      final dayKey = day.toLowerCase();
      if (timeRange != null) {
        result[dayKey] = {
          'isOpen': true,
          'openTime':
              '${timeRange.start.hour.toString().padLeft(2, '0')}:${timeRange.start.minute.toString().padLeft(2, '0')}',
          'closeTime':
              '${timeRange.end.hour.toString().padLeft(2, '0')}:${timeRange.end.minute.toString().padLeft(2, '0')}',
        };
      } else {
        result[dayKey] = {'isOpen': false};
      }
    });

    return result;
  }

  /// Delete a center
  Future<void> deleteCenter(String centerId) async {
    try {
      // Soft delete by setting isActive to false
      await _firestore.collection(_collection).doc(centerId).update({
        'isActive': false,
        'status': 'inactive',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error deleting center: $e');
      throw e;
    }
  }

  /// Listen to real-time updates for a specific center
  Stream<HIVCenter?> getCenterStream(String centerId) {
    return _firestore.collection(_collection).doc(centerId).snapshots().map((
      doc,
    ) {
      if (!doc.exists || doc.data() == null) return null;

      try {
        return _parseHIVCenter(doc.id, doc.data()!);
      } catch (e) {
        print('Error parsing center stream: $e');
        return null;
      }
    });
  }
}
