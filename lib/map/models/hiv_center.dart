import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'service_type.dart';
import 'center_category.dart';
import 'contact_info.dart';
import 'operating_hours.dart';

class HIVCenter {
  final String id;
  final String name;
  final LatLng position;
  final CenterCategory category;
  final List<ServiceType> services;
  final OperatingHours? operatingHours;
  final ContactInfo contactInfo;
  final String? description;
  final List<String> photos;
  final Map<ServiceType, List<String>> serviceDetails;
  final String? hours; // Legacy field for centers without operatingHours

  const HIVCenter({
    required this.id,
    required this.name,
    required this.position,
    required this.category,
    required this.services,
    this.operatingHours,
    required this.contactInfo,
    this.description,
    this.photos = const [],
    this.serviceDetails = const {},
    this.hours,
  });

  // Convenience getters
  bool get isMultiService => category == CenterCategory.multi;
  bool get hasTreatment => services.contains(ServiceType.treatment);
  bool get hasPrep => services.contains(ServiceType.prep);
  bool get hasTesting => services.contains(ServiceType.testing);
  bool get hasLaboratory => services.contains(ServiceType.laboratory);

  ServiceType get primaryService =>
      services.isNotEmpty ? services.first : ServiceType.testing;

  String get displayHours {
    if (operatingHours != null) {
      return operatingHours!.getCurrentStatus();
    }
    return hours ?? 'Hours not available';
  }

  bool get isOpenNow {
    return operatingHours?.isOpenNow() ?? false;
  }

  // Factory constructor from Map (for easy migration from existing data)
  factory HIVCenter.fromMap(Map<String, dynamic> map) {
    return HIVCenter(
      id: map['id'] as String,
      name: map['name'] as String,
      position: map['position'] as LatLng,
      category:
          map['category'] == 'multi'
              ? CenterCategory.multi
              : CenterCategory.single,
      services:
          (map['services'] as List<dynamic>)
              .map((s) => ServiceType.fromKey(s as String))
              .where((s) => s != null)
              .cast<ServiceType>()
              .toList(),
      operatingHours: map['operatingHours'] as OperatingHours?,
      contactInfo: ContactInfo.fromMap(map),
      description: map['description'] as String?,
      photos: List<String>.from(map['photos'] ?? []),
      serviceDetails: _parseServiceDetails(map['serviceDetails']),
      hours: map['hours'] as String?,
    );
  }

  static Map<ServiceType, List<String>> _parseServiceDetails(
    dynamic serviceDetails,
  ) {
    if (serviceDetails == null) return {};

    final result = <ServiceType, List<String>>{};
    (serviceDetails as Map<String, dynamic>).forEach((key, value) {
      final serviceType = ServiceType.fromKey(key);
      if (serviceType != null && value is List) {
        result[serviceType] = List<String>.from(value);
      }
    });
    return result;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'category': category == CenterCategory.multi ? 'multi' : 'single',
      'services': services.map((s) => s.key).toList(),
      'operatingHours': operatingHours?.toMap(),
      'phone': contactInfo.phone,
      'address': contactInfo.address,
      'email': contactInfo.email,
      'description': description,
      'photos': photos,
      'serviceDetails': _serviceDetailsToMap(),
      'hours': hours,
    };
  }

  Map<String, dynamic> _serviceDetailsToMap() {
    final result = <String, dynamic>{};
    serviceDetails.forEach((serviceType, details) {
      result[serviceType.key] = details;
    });
    return result;
  }

  // Search functionality
  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();

    // Search in name
    if (name.toLowerCase().contains(lowerQuery)) return true;

    // Search in address
    if (contactInfo.address.toLowerCase().contains(lowerQuery)) return true;

    // Search in description
    if (description?.toLowerCase().contains(lowerQuery) == true) return true;

    // Search in service details
    for (final details in serviceDetails.values) {
      for (final detail in details) {
        if (detail.toLowerCase().contains(lowerQuery)) return true;
      }
    }

    return false;
  }

  // Filter functionality
  bool matchesFilter({
    bool showTreatment = true,
    bool showPrep = true,
    bool showTesting = true,
    bool showLaboratory = true,
    bool showMultiService = true,
  }) {
    if (isMultiService && !showMultiService) return false;

    if (!isMultiService) {
      final primaryService =
          services.isNotEmpty ? services.first : ServiceType.testing;
      switch (primaryService) {
        case ServiceType.treatment:
          return showTreatment;
        case ServiceType.prep:
          return showPrep;
        case ServiceType.testing:
          return showTesting;
        case ServiceType.laboratory:
          return showLaboratory;
      }
    }

    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HIVCenter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'HIVCenter(id: $id, name: $name, category: $category)';
}
