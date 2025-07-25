import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:projecho/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:projecho/login/login/inputNum.dart';
// import 'package:projecho/introduction_animation/userlogin/otp.dart';

import 'package:projecho/mainPage.dart';
import 'package:projecho/screens/Insights.dart';
import 'package:projecho/screens/userProfile.dart';


// Firebase options import, uncomment and update if you have it generated
import 'firebase_options.dart'; // Make sure this file exists — generated by FlutterFire CLI
import 'package:projecho/introduction_animation/onbrdingAnimationScreen.dart';

// Import your OTP related pages (make sure you create these pages)
// import 'package:projecho/pages/userlogin/enternumber.dart';
// import 'package:projecho/pages/userlogin/otp_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase - uncomment and adjust if you have firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      title: 'Flutter UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.iOS,
      ),
      home: MyOnboardingScreen(),

      // Add routes for phone auth flow
      routes: {
        '/enternumber': (context) => EnterNumberPage(),  // You need to create this page
        // '/otp': (context) => OTPScreen(),                 // You need to create this page
        '/home': (context) => MainPage(),
        '/profile': (context) => UserProfile(),
        '/MyAppointments': (context) => Insights(),
        
      },
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
