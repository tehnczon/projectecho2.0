import 'package:flutter/material.dart';

class MapSearchBar extends StatelessWidget {
  final Function(String) onSearch;
  final VoidCallback onFilterTap;

  const MapSearchBar({
    Key? key,
    required this.onSearch,
    required this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onSearch,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search HIV centers...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(Icons.search, color: Colors.grey[600]),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.filter_list_rounded, color: Colors.grey[600]),
                onPressed: onFilterTap,
                tooltip: 'Filter',
              ),
              Icon(Icons.mic, color: Colors.grey[600]),
              const SizedBox(width: 12),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
