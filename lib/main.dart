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

// PROVIDERS
import 'package:projecho/screens/analytics/components/providers/user_role_provider.dart';
import 'package:projecho/screens/analytics/components/providers/enhanced_analytics_provider.dart';

// MAP PROVIDERS
import 'package:projecho/map/providers/map_provider.dart';
import 'package:projecho/map/providers/location_provider.dart';
import 'package:projecho/map/providers/filter_provider.dart';

// REGISTRATION FLOW UTILITIES
import 'package:projecho/login/registration_flow_manager.dart';

import 'main/firebase_options.dart';
import 'package:projecho/onboarding/onbrdingAnimationScreen.dart' as onboarding;
import 'package:projecho/login/animation/appstart.dart' as splash;

class AppTheme {
  AppTheme._();

  static const Color primaryColor = AppColors.primary; // ✅ alias
  static const Color secondaryColor = AppColors.secondary;

  static const TextTheme textTheme = TextTheme();

  // ... (your existing textTheme + styles)
}

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
  bool _isCheckingRegistration = false;

  @override
  void initState() {
    super.initState();
    _currentScreen = splash.CustomSplashScreen(
      onInitializationComplete: _onInitializationComplete,
    );
  }

  void _onInitializationComplete(Widget nextScreen) async {
    setState(() {
      _currentScreen = nextScreen;
      _showSplash = false;
    });

    // ✅ CHECK FOR INCOMPLETE REGISTRATION AFTER SPLASH
    await _checkForIncompleteRegistration();
  }

  // 🎯 NEW METHOD: Check for incomplete registration
  Future<void> _checkForIncompleteRegistration() async {
    // Only check if user is authenticated but not yet fully registered
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isCheckingRegistration = true);

    try {
      // Check if there's incomplete registration progress
      final resumeScreen = await RegistrationFlowManager.resumeRegistration(
        context,
      );

      if (resumeScreen != null) {
        // User has incomplete registration - navigate to resume screen
        setState(() {
          _currentScreen = resumeScreen;
        });
      }
    } catch (e) {
      print('❌ Error checking registration progress: $e');
      // If there's an error, clear any corrupted progress
      await RegistrationFlowManager.emergencyReset();
    } finally {
      setState(() => _isCheckingRegistration = false);
    }
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

        // ANALYTICS PROVIDER
        ChangeNotifierProvider(create: (_) => EnhancedAnalyticsProvider()),

        // USER ROLE PROVIDER - Single consolidated version
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
        home:
            _isCheckingRegistration
                ? _buildRegistrationCheckScreen()
                : _currentScreen,
        routes: {
          '/onboarding': (context) => onboarding.MyOnboardingScreen(),
          '/enternumber': (context) => EnterNumberPage(),
          '/home': (context) => MainPage(),
          '/profile': (context) => UserProfile(),
        },
      ),
    );
  }

  // 🎯 NEW METHOD: Show loading screen while checking registration
  Widget _buildRegistrationCheckScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or branding
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.primaryColor.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.health_and_safety,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),

            SizedBox(height: 24),

            // Loading indicator
            CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 2,
            ),

            SizedBox(height: 16),

            Text(
              'Checking registration status...',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            SizedBox(height: 8),

            Text(
              'This will only take a moment',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
