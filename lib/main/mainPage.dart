// lib/main/mainPage.dart
import 'package:flutter_animate/flutter_animate.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:projecho/screens/home/homePage.dart';
import 'package:projecho/screens/analytics/general_basic_dashboard.dart';
import 'package:projecho/screens/analytics/researcher_dashboard.dart';
import 'package:projecho/screens/profile/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:projecho/screens/analytics/components/providers/user_role_provider.dart';
import 'package:projecho/screens/analytics/components/providers/researcher_analytics_provider.dart';
import 'package:projecho/map/map_screen.dart';
import 'package:projecho/screens/med_tracker/drug_cabinet_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeUserRole();
  }

  void _initializeUserRole() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final roleProvider = Provider.of<UserRoleProvider>(
        context,
        listen: false,
      );

      // Always check role when MainPage mounts
      roleProvider.checkUserRole();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRoleProvider>(
      builder: (context, roleProvider, child) {
        // Show loading ONLY while actively loading
        if (roleProvider.isLoading) {
          return _buildLoadingScreen();
        }

        // Build pages based on role
        final List<Widget> pages = [
          HomePage(),
          _buildAnalyticsDashboard(roleProvider),
          if (roleProvider.isPLHIV) const DrugCabinetScreen(),
          MapScreen(),
          UserProfile(),
        ];

        // Build navigation items based on role
        final List<BottomNavigationBarItem> navItems = [
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home_outlined),
                Text('Home', style: GoogleFonts.poppins(fontSize: 8)),
              ],
            ),
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, color: Color(0xFF1877F2)),
                Text(
                  'Home',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1877F2),
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insights_outlined),
                Text(
                  _getAnalyticsLabel(roleProvider),
                  style: GoogleFonts.poppins(fontSize: 8),
                ),
              ],
            ),
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insights, color: Color(0xFF1877F2)),
                Text(
                  _getAnalyticsLabel(roleProvider),
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1877F2),
                  ),
                ),
              ],
            ),
            label: '',
          ),

          // Medication (ONLY for PLHIV) - ADD THIS
          if (roleProvider.isPLHIV)
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.medication_outlined),
                  Text('Meds', style: GoogleFonts.poppins(fontSize: 8)),
                ],
              ),
              activeIcon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.medication, color: Color(0xFF1877F2)),
                  Text(
                    'Meds',
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1877F2),
                    ),
                  ),
                ],
              ),
              label: '',
            ),

          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_outlined),
                Text('Centers', style: GoogleFonts.poppins(fontSize: 8)),
              ],
            ),
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: Color(0xFF1877F2)),
                Text(
                  'Centers',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1877F2),
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline),
                Text('Profile', style: GoogleFonts.poppins(fontSize: 8)),
              ],
            ),
            activeIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, color: Color(0xFF1877F2)),
                Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1877F2),
                  ),
                ),
              ],
            ),
            label: '',
          ),
        ];

        return Container(
          color: Color(0xFFF0F2F5),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            key: _scaffoldKey,
            body: IndexedStack(index: _selectedIndex, children: pages),
            bottomNavigationBar: _buildBottomNavBar(navItems),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(List<BottomNavigationBarItem> navItems) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            // navbar bg
            border: const Border(
              top: BorderSide(
                color: Color.fromARGB(255, 236, 236, 236),
                width: 0.3,
              ),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedItemColor: const Color(0xFF1877F2),
            unselectedItemColor: AppColors.textPrimary,
            selectedLabelStyle: GoogleFonts.workSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.workSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: navItems,
          ),
        ),
      ),
    );
  }
}

Widget _buildLoadingScreen() {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated gradient circle
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.secondary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 2,
              ),
            ),
          ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),

          const SizedBox(height: 40),

          // Title text
        ],
      ),
    ),
  );
}

Widget _buildAnalyticsDashboard(UserRoleProvider roleProvider) {
  if (roleProvider.shouldShowResearcherDashboard) {
    return Consumer<ResearcherAnalyticsProvider>(
      builder: (context, researcherProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!researcherProvider.isLoading &&
              researcherProvider.analyticsData == null) {
            researcherProvider.initialize();
          }
        });

        return ResearcherDashboard();
      },
    );
  } else {
    return GeneralBasicDashboard();
  }
}

String _getAnalyticsLabel(UserRoleProvider roleProvider) {
  if (roleProvider.isResearcher) {
    return 'Analytics';
  } else if (roleProvider.isPLHIV) {
    return 'Insights';
  } else {
    return 'Community';
  }
}
