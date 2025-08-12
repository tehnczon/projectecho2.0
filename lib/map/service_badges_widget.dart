import 'package:flutter/material.dart';
import 'models/hiv_center.dart';

class ServiceBadgesWidget extends StatelessWidget {
  final HIVCenter center;

  const ServiceBadgesWidget({Key? key, required this.center}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (center.isMultiService) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Multi-service badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.1),
                  Colors.purple.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.purple.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.purple,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'MULTI-SERVICE CENTER',
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Individual service badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                center.services
                    .map((service) => _buildServiceChip(service))
                    .toList(),
          ),
        ],
      );
    } else {
      // Single service badge
      return _buildServiceChip(center.primaryService, isLarge: true);
    }
  }

  Widget _buildServiceChip(service, {bool isLarge = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 14 : 12,
        vertical: isLarge ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: service.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: service.color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(service.icon, size: isLarge ? 18 : 16, color: service.color),
          SizedBox(width: isLarge ? 8 : 6),
          Text(
            service.label,
            style: TextStyle(
              color: service.color,
              fontWeight: FontWeight.w500,
              fontSize: isLarge ? 14 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
