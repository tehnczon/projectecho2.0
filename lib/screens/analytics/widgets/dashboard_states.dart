import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardStates {
  static Widget loading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1877F2)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading analytics...',
            style: GoogleFonts.workSans(fontSize: 14, color: Color(0xFF65676B)),
          ),
        ],
      ),
    );
  }

  static Widget error(String error, {required VoidCallback onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          ),
          SizedBox(height: 20),
          Text(
            'Error Loading Data',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1E21),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: GoogleFonts.workSans(
                fontSize: 14,
                color: Color(0xFF65676B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1877F2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget empty({required VoidCallback onRefresh}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1877F2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Color(0xFF1877F2),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No Analytics Data',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1E21),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Data will appear here once participants submit their information',
              style: GoogleFonts.workSans(
                fontSize: 14,
                color: Color(0xFF65676B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF42B883),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget accessDenied(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.block, size: 48, color: Colors.red[400]),
          ),
          SizedBox(height: 20),
          Text(
            'Access Denied',
            style: GoogleFonts.workSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1E21),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You need researcher privileges to access this dashboard.',
            style: GoogleFonts.workSans(fontSize: 14, color: Color(0xFF65676B)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1877F2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
