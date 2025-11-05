import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projecho/main/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:projecho/login/login/inputNum.dart';
import 'package:projecho/main/mainPage.dart';
import 'package:projecho/screens/profile/user_profile.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projecho/screens/med_tracker/medication_provider.dart';
import 'package:projecho/screens/home/articleDetail.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!hasSeenOnboarding) {
      // show onboarding once
      setState(() {
        _currentScreen = onboarding.MyOnboardingScreen();
      });

      await prefs.setBool('hasSeenOnboarding', true);
    } else {
      setState(() {
        _currentScreen = nextScreen;
        _showSplash = false;
      });

      await _checkForIncompleteRegistration();
    }
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
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
        ChangeNotifierProvider(create: (_) => EnhancedAnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => ResearcherAnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => UserRoleProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
      ],
      child: MaterialApp(
        title: 'ProjEcho',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: AppTheme.textTheme,
          platform: TargetPlatform.iOS,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // 🟢 Splash first
            if (_showSplash) {
              return _currentScreen ?? const SizedBox.shrink();
            }

            // 🟡 Registration check
            if (_isCheckingRegistration) {
              return _buildRegistrationCheckScreen();
            }

            // 🔵 Firebase loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // 🟢 User logged in
            if (snapshot.hasData) {
              final user = snapshot.data!;
              print('🟢 Logged in: ${user.uid}');
              // Trigger role check once logged in
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Provider.of<UserRoleProvider>(
                  context,
                  listen: false,
                ).checkUserRole();
              });
              return const MainPage();
            }

            // 🔴 User logged out
            print('🔴 User logged out');
            return const EnterNumberPage();
          },
        ),
        routes: {
          '/onboarding': (context) => onboarding.MyOnboardingScreen(),
          '/enternumber': (context) => EnterNumberPage(),
          '/home': (context) => MainPage(),
          '/profile': (context) => UserProfile(),
        },
        // Handle dynamic routes like article detail
        onGenerateRoute: (settings) {
          // Article Detail Route
          if (settings.name == '/article-detail') {
            final args = settings.arguments as Map<String, dynamic>?;

            if (args != null &&
                args.containsKey('id') &&
                args.containsKey('data')) {
              return MaterialPageRoute(
                builder:
                    (context) => ArticleDetailPage(
                      id: args['id'] as String,
                      data: args['data'] as Map<String, dynamic>,
                    ),
              );
            }

            // If arguments are invalid, return to home
            return MaterialPageRoute(builder: (context) => const MainPage());
          }

          // Default: return null to use routes table
          return null;
        },
      ),
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
