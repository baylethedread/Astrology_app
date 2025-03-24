import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:astrology_ui/screens/sign_in_screen.dart';
import 'package:astrology_ui/screens/sign_up_screen.dart';
import 'package:astrology_ui/screens/welcome_screen.dart';
import 'package:astrology_ui/screens/home_screen.dart';
import 'package:astrology_ui/screens/horoscope_screen.dart';
import 'package:astrology_ui/screens/profile_setup_screen.dart';
import 'package:astrology_ui/wrapper.dart';
import 'package:astrology_ui/theme/app_theme.dart';
import 'package:astrology_ui/utils/notification_service.dart'; // Import NotificationService

// Define the navigatorKey as a top-level variable
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    await NotificationService().init();
  } catch (e) {
    print('Failed to initialize NotificationService: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'StellarPath',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: Wrapper(toggleTheme: toggleTheme),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/profileSetup': (context) => ProfileSetupScreen(),
        '/home': (context) => HomeScreen(toggleTheme: toggleTheme),
        '/horoscope': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return HoroscopeScreen(
            initialZodiacSign: args?['initialZodiacSign'] as String?,
          );
        },
      },
    );
  }
}