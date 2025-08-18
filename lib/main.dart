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
import 'package:projecho/screens/analytics/testing/providers/user_role_provider.dart';
import 'package:projecho/screens/analytics/testing/providers/enhanced_analytics_provider.dart';

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
        home: _currentScreen,
        routes: {
          '/onboarding': (context) => onboarding.MyOnboardingScreen(),
          '/enternumber': (context) => EnterNumberPage(),
          '/home': (context) => MainPage(),
          '/profile': (context) => UserProfile(),
        },
      ),
    );
  }
}
// REMOVE THE UserRoleProvider CLASS FROM HERE - IT'S NOW IN SEPARATE FILE