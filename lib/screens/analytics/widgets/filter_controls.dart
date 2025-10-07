import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterControls extends StatelessWidget {
  final String selectedTimeRange;
  final String selectedFilter;
  final ValueChanged<String?> onTimeRangeChanged;
  final ValueChanged<String?> onFilterChanged;

  const FilterControls({
    Key? key,
    required this.selectedTimeRange,
    required this.selectedFilter,
    required this.onTimeRangeChanged,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              value: selectedTimeRange,
              items: ['1 Month', '3 Months', '6 Months', '1 Year', 'All Time'],
              onChanged: onTimeRangeChanged,
              icon: Icons.access_time,
              iconColor: Color(0xFF1877F2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildDropdown(
              value: selectedFilter,
              items: ['All', 'MSM', 'Youth (18-24)', 'High Risk'],
              onChanged: onFilterChanged,
              icon: Icons.filter_list,
              iconColor: Color(0xFF9C27B0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          color: Color(0xFF1C1E21),
                        ),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
          icon: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}
