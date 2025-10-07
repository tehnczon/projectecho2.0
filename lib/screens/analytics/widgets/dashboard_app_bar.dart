import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:projecho/screens/analytics/components/providers/researcher_analytics_provider.dart';

class DashboardAppBar extends StatelessWidget {
  final ResearcherAnalyticsProvider provider;
  final VoidCallback onExport;
  final VoidCallback onRefresh;

  const DashboardAppBar({
    Key? key,
    required this.provider,
    required this.onExport,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1877F2).withOpacity(0.1), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _buildIcon(),
                    SizedBox(width: 12),
                    Expanded(child: _buildTitleSection()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.download_outlined, color: Color(0xFF65676B)),
          onPressed: onExport,
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: Color(0xFF65676B)),
          onPressed: onRefresh,
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1877F2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        FontAwesomeIcons.chartLine,
        color: Color(0xFF1877F2),
        size: 24,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Research Analytics',
          style: GoogleFonts.workSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1E21),
          ),
        ),
        Text(
          'Last updated: ${_formatLastUpdate(provider.lastUpdated)}',
          style: GoogleFonts.workSans(fontSize: 12, color: Color(0xFF65676B)),
        ),
      ],
    );
  }

  String _formatLastUpdate(DateTime? date) {
    if (date == null) return 'Never';
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }
}
