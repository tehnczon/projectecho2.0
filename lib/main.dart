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
import 'package:projecho/screens/analytics/components/providers/user_role_provider.dart';
import 'package:projecho/screens/analytics/components/providers/enhanced_analytics_provider.dart';
import 'package:projecho/screens/analytics/components/providers/researcher_analytics_provider.dart';
import 'package:projecho/map/providers/map_provider.dart';
import 'package:projecho/map/providers/location_provider.dart';
import 'package:projecho/map/providers/filter_provider.dart';
import 'package:projecho/login/registration_flow_manager.dart';
import 'main/firebase_options.dart';
import 'package:projecho/onboarding/onbrdingAnimationScreen.dart' as onboarding;
import 'package:projecho/login/animation/appstart.dart' as splash;

class AppTheme {
  AppTheme._();
  static const Color primaryColor = AppColors.primary;
  static const Color secondaryColor = AppColors.secondary;
  static const TextTheme textTheme = TextTheme();
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

    await _checkForIncompleteRegistration();
  }

  Future<void> _checkForIncompleteRegistration() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isCheckingRegistration = true);

    try {
      final resumeScreen = await RegistrationFlowManager.resumeRegistration(
        context,
      );

      if (resumeScreen != null) {
        setState(() {
          _currentScreen = resumeScreen;
        });
      }
    } catch (e) {
      print('Error checking registration progress: $e');
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

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show splash while waiting
        if (_showSplash) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _currentScreen ?? const SizedBox.shrink(),
          );
        }

        // Show registration check screen
        if (_isCheckingRegistration) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _buildRegistrationCheckScreen(),
          );
        }

        // Show loading while Firebase checks auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // 🟢 User logged in - Create fresh providers
        if (snapshot.hasData) {
          final user = snapshot.data!;
          print('🟢 User logged in: ${user.uid}');

          // ✅ Create NEW providers for each user session
          return MultiProvider(
            key: ValueKey(user.uid), // Force rebuild when user changes
            providers: [
              ChangeNotifierProvider(create: (_) => MapProvider()),
              ChangeNotifierProvider(create: (_) => LocationProvider()),
              ChangeNotifierProvider(create: (_) => FilterProvider()),
              ChangeNotifierProvider(
                create: (_) => EnhancedAnalyticsProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => ResearcherAnalyticsProvider(),
              ),
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
              home: const MainPage(),
              routes: {
                '/onboarding': (context) => onboarding.MyOnboardingScreen(),
                '/enternumber': (context) => EnterNumberPage(),
                '/home': (context) => MainPage(),
                '/profile': (context) => UserProfile(),
              },
            ),
          );
        }

        // 🔴 User logged out
        print('🔴 User logged out');

        return MaterialApp(
          title: 'ProjEcho',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: AppTheme.textTheme,
            platform: TargetPlatform.iOS,
          ),
          home: const EnterNumberPage(),
          routes: {
            '/onboarding': (context) => onboarding.MyOnboardingScreen(),
            '/enternumber': (context) => EnterNumberPage(),
          },
        );
      },
    );
  }

  Widget _buildRegistrationCheckScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
