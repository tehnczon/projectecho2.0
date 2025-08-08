import 'package:flutter/material.dart';

enum ServiceType {
  treatment(
    'HIV Treatment Hub',
    'treatment',
    Color(0xFF4CAF50),
    Icons.local_hospital,
  ),
  prep('HIV PrEP Site', 'prep', Color(0xFF2196F3), Icons.shield),
  testing('HIVST Site', 'testing', Color(0xFFF44336), Icons.biotech),
  laboratory('RHIVDA Site', 'laboratory', Color(0xFFFF9800), Icons.science);

  const ServiceType(this.label, this.key, this.color, this.icon);

  final String label;
  final String key;
  final Color color;
  final IconData icon;

  static ServiceType? fromKey(String key) {
    for (ServiceType type in ServiceType.values) {
      if (type.key == key) return type;
    }
    return null;
  }
}
