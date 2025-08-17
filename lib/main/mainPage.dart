import 'package:projecho/screens/home/homePage.dart';
import 'package:projecho/screens/analytics/general_basic_dashboard.dart'; // Update this import
import 'package:projecho/screens/profile/userProfile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Add this import
import 'dart:ui';
import 'package:projecho/screens/analytics/testing/models/user_model.dart'; // for ImageFilter.blur

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();

    // Check user role on init
    Future.microtask(() {
      Provider.of<UserRoleProvider>(context, listen: false).checkUserRole();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRoleProvider>(
      builder: (context, roleProvider, child) {
        // Build pages based on role
        _pages = [
          HomePage(),
          InsightsDashboard(), // This will route internally based on role
          UserProfile(),
        ];

        // Add admin panel if user is admin
        if (roleProvider.isAdmin) {
          _pages.add(SuperAdminPanel());
        }

        // Build navigation items
        _navItems = [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];

        // Add admin nav item if user is admin
        if (roleProvider.isAdmin) {
          _navItems.add(
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
          );
        }

        return Container(
          color: Colors.white,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            key: _scaffoldKey,
            body: IndexedStack(index: _selectedIndex, children: _pages),
            bottomNavigationBar: ClipRRect(
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
                    items: _navItems,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
