import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:astrology_ui/screens/sign_in_screen.dart';
import 'package:astrology_ui/screens/sign_up_screen.dart';
import 'package:astrology_ui/screens/welcome_screen.dart';
import 'package:astrology_ui/screens/home_screen.dart';
import 'package:astrology_ui/screens/profile_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
  } catch (e) {
    print("Error initializing Firebase: $e");
    return;
  }

  // Check if the user is signed in and if profile setup is complete
  String initialRoute = await getInitialRoute();

  runApp(MyApp(initialRoute: initialRoute));
}

Future<String> getInitialRoute() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (userDoc.exists && userDoc['profileComplete'] == true) {
      return '/home';
    } else {
      return '/profileSetup';
    }
  }

  return '/';
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

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
      debugShowCheckedModeBanner: false,
      title: 'StellarPath',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.deepPurpleAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          background: Color(0xFF090A1A),
          surface: Color(0xFF1B1D3C),
          secondary: Colors.purpleAccent,
          onPrimary: Colors.white,
          onBackground: Colors.white70,
          onSurface: Colors.white,
        ),
      ),
      themeMode: _themeMode,
      initialRoute: widget.initialRoute,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => WelcomeScreen(toggleTheme: toggleTheme));
          case '/signin':
            return MaterialPageRoute(builder: (context) => const SignInScreen());
          case '/signup':
            return MaterialPageRoute(builder: (context) => const SignUpScreen());
          case '/profileSetup':
            return MaterialPageRoute(builder: (context) => ProfileSetupScreen());
          case '/home':
            return MaterialPageRoute(builder: (context) => HomeScreen(toggleTheme: toggleTheme));
          default:
            return null;
        }
      },
    );
  }
}
