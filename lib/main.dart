import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:projecho/main/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:projecho/login/login/inputNum.dart';
import 'package:projecho/main/mainPage.dart';
import 'package:projecho/screens/profile/userProfile.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ANALYTICS IMPORTS
import 'package:projecho/screens/analytics/testing/providers/enhanced_analytics_provider.dart';
import 'package:projecho/screens/analytics/testing/services/adjusted_role_service.dart';

// MAP PROVIDERS
import 'package:projecho/map/providers/map_provider.dart';
import 'package:projecho/map/providers/location_provider.dart';
import 'package:projecho/map/providers/filter_provider.dart';

import 'main/firebase_options.dart';
import 'package:projecho/onboarding/onbrdingAnimationScreen.dart' as onboarding;
import 'package:projecho/login/animation/appstart.dart' as splash;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _currentScreen;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _currentScreen = splash.CustomSplashScreen(
      onInitializationComplete: _onInitializationComplete,
    );
  }

  void _onInitializationComplete(Widget nextScreen) {
    setState(() {
      _currentScreen = nextScreen;
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness:
            !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MultiProvider(
      providers: [
        // MAP PROVIDERS
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),

        // ANALYTICS PROVIDER - Using the enhanced version
        ChangeNotifierProvider(create: (_) => EnhancedAnalyticsProvider()),

        // USER ROLE PROVIDER - Using your existing structure
        ChangeNotifierProvider(create: (_) => UserRoleProvider()),
      ],
      child: MaterialApp(
        title: 'ProjEcho',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: AppTheme.textTheme,
          platform: TargetPlatform.iOS,
        ),
        home: _currentScreen,
        routes: {
          '/onboarding': (context) => onboarding.MyOnboardingScreen(),
          '/enternumber': (context) => EnterNumberPage(),
          '/home': (context) => MainPage(),
          '/profile': (context) => UserProfile(),
          // Note: Don't route directly to GeneralBasicDashboard
          // Use InsightsDashboard which will route based on role
        },
      ),
    );
  }
}

// Enhanced User Role Management for your structure
class UserRoleProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AdjustedRoleService _roleService = AdjustedRoleService();

  String _currentRole = 'basicUser';
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;
  String? _phoneNumber;

  String get currentRole => _currentRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isResearcher =>
      _currentRole == 'researcher' || _currentRole == 'admin';
  bool get isAdmin => _currentRole == 'admin';
  Map<String, dynamic>? get userData => _userData;
  String? get phoneNumber => _phoneNumber;

  Future<void> checkUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.phoneNumber == null) {
        _currentRole = 'basicUser';
        _isAuthenticated = false;
        notifyListeners();
        return;
      }

      _phoneNumber = user.phoneNumber;
      _isAuthenticated = true;

      // Clean phone number for document ID
      String cleanedPhone = user.phoneNumber!.replaceAll(RegExp(r'[^\d]'), '');

      // Check if super admin first (using UID)
      final adminDoc =
          await _firestore.collection('super_admin').doc(user.uid).get();

      if (adminDoc.exists) {
        _currentRole = 'admin';
        _userData = adminDoc.data();
        notifyListeners();
        return;
      }

      // Check if researcher (using phone number)
      // Try multiple phone formats
      final phoneFormats = [
        user.phoneNumber!, // Original format (+639123456789)
        cleanedPhone, // Cleaned format (639123456789)
        user.phoneNumber!.replaceAll('+63', ''), // Without +63
        user.phoneNumber!.replaceAll('+', ''), // Without +
      ];

      for (String format in phoneFormats) {
        final researcherDoc =
            await _firestore.collection('researchers').doc(format).get();

        if (researcherDoc.exists) {
          _currentRole = 'researcher';
          _userData = researcherDoc.data();
          notifyListeners();
          return;
        }
      }

      // Check users collection for stored role
      final userDoc =
          await _firestore.collection('users').doc(cleanedPhone).get();

      if (userDoc.exists) {
        _userData = userDoc.data();
        _currentRole = userDoc.data()?['role'] ?? 'basicUser';
      } else {
        // Create new user document
        await _firestore.collection('users').doc(cleanedPhone).set({
          'phoneNumber': user.phoneNumber,
          'cleanedPhone': cleanedPhone,
          'role': 'basicUser',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
        _currentRole = 'basicUser';
      }

      notifyListeners();
    } catch (e) {
      print('Error checking user role: $e');
      _currentRole = 'basicUser';
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  // Method to refresh user role
  Future<void> refreshRole() async {
    await checkUserRole();
  }

  // Method to upgrade a user (admin only)
  Future<bool> upgradeUserToResearcher(String phoneNumber) async {
    if (_currentRole != 'admin') return false;

    try {
      return await _roleService.addResearcher(phoneNumber, {
        'addedBy': _auth.currentUser?.uid,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error upgrading user: $e');
      return false;
    }
  }

  void logout() {
    _currentRole = 'basicUser';
    _isAuthenticated = false;
    _userData = null;
    _phoneNumber = null;
    notifyListeners();
  }
}
