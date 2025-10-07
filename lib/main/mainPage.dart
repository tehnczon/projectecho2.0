// lib/main/mainPage.dart
import 'package:projecho/screens/home/homePage.dart';
import 'package:projecho/screens/analytics/general_basic_dashboard.dart';
import 'package:projecho/screens/analytics/researcher_dashboard.dart';
import 'package:projecho/screens/profile/userProfile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:projecho/screens/analytics/components/providers/user_role_provider.dart';
import 'package:projecho/screens/analytics/components/providers/researcher_analytics_provider.dart';
import 'package:projecho/map/map_screen.dart';

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

  // NEW: Separated initialization method
  void _initializeUserRole() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roleProvider = Provider.of<UserRoleProvider>(
        context,
        listen: false,
      );
      // Only check role if not already initialized
      if (!roleProvider.isInitialized || !roleProvider.isAuthenticated) {
        roleProvider.checkUserRole();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRoleProvider>(
      builder: (context, roleProvider, child) {
        // Show loading state while checking role AND not yet initialized
        if (roleProvider.isLoading || !roleProvider.isInitialized) {
          return _buildLoadingScreen();
        }

        // Build pages based on role
        final List<Widget> pages = [
          HomePage(),
          _buildAnalyticsDashboard(roleProvider),
          UserProfile(),
          MapScreen(),
        ];

        // Build navigation items based on role
        final List<BottomNavigationBarItem> navItems = [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: _getAnalyticsLabel(roleProvider),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Centers',
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

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1877F2)),
            ),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: GoogleFonts.workSans(
                fontSize: 16,
                color: Color(0xFF65676B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsDashboard(UserRoleProvider roleProvider) {
    if (roleProvider.shouldShowResearcherDashboard) {
      return Consumer<ResearcherAnalyticsProvider>(
        builder: (context, researcherProvider, child) {
          // Auto-initialize when dashboard loads
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

  Widget _buildBottomNavBar(List<BottomNavigationBarItem> navItems) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            border: Border(top: BorderSide(color: Color(0xFFDADDE1))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedItemColor: Color(0xFF1877F2),
            unselectedItemColor: Color(0xFF65676B),
            selectedLabelStyle: GoogleFonts.workSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.workSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: navItems,
          ),
        ),
      ),
    );
  }
}
