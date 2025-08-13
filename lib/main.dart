// main.dart - Fixed import conflicts
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:projecho/main/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:projecho/login/login/inputNum.dart';
import 'package:projecho/main/mainPage.dart';
import 'package:projecho/screens/profile/userProfile.dart';
import 'package:projecho/screens/analytics/Insights.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

        // Analytics Providers
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),

        // User Role Provider
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
          '/insights': (context) => PLHIVDashboard(),
        },
      ),
    );
  }
}

// User Role Management (same as before)
enum UserRole { regular, researcher, admin }

class UserRoleProvider extends ChangeNotifier {
  UserRole _currentRole = UserRole.regular;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;

  UserRole get currentRole => _currentRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isResearcher =>
      _currentRole == UserRole.researcher || _currentRole == UserRole.admin;
  bool get isAdmin => _currentRole == UserRole.admin;
  Map<String, dynamic>? get userData => _userData;

  Future<void> checkUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _currentRole = UserRole.regular;
        _isAuthenticated = false;
        notifyListeners();
        return;
      }

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        _userData = userDoc.data();
        final roleString = userDoc.data()?['role'] ?? 'regular';

        switch (roleString) {
          case 'researcher':
            _currentRole = UserRole.researcher;
            break;
          case 'admin':
            _currentRole = UserRole.admin;
            break;
          default:
            _currentRole = UserRole.regular;
        }
        _isAuthenticated = true;
      } else {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'phoneNumber': user.phoneNumber,
          'role': 'regular',
          'createdAt': FieldValue.serverTimestamp(),
        });
        _currentRole = UserRole.regular;
        _isAuthenticated = true;
      }

      notifyListeners();
    } catch (e) {
      print('Error checking user role: $e');
      _currentRole = UserRole.regular;
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void logout() {
    _currentRole = UserRole.regular;
    _isAuthenticated = false;
    _userData = null;
    notifyListeners();
  }
}
