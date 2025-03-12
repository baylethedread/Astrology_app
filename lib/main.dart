import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Added for consistent typography
import 'package:astrology_ui/screens/sign_in_screen.dart';
import 'package:astrology_ui/screens/sign_up_screen.dart';
import 'package:astrology_ui/screens/welcome_screen.dart';
import 'package:astrology_ui/screens/home_screen.dart';
import 'package:astrology_ui/screens/profile_setup_screen.dart';
import 'package:astrology_ui/wrapper.dart'; // Import the Wrapper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
      debugShowCheckedModeBanner: false,
      title: 'StellarPath',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        // Added textTheme to apply Google Fonts globally
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.black87,
          ),
          bodySmall: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        // Ensure icons and other UI elements adapt to the light theme
        iconTheme: const IconThemeData(color: Colors.black54),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          iconTheme: const IconThemeData(color: Colors.black54),
        ),
        cardTheme: CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.blue[50],
        ),
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
        // Added textTheme for dark mode
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white70,
          ),
          bodySmall: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
        // Ensure icons and other UI elements adapt to the dark theme
        iconTheme: const IconThemeData(color: Colors.white54),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1B1D3C),
          elevation: 2,
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white54),
        ),
        cardTheme: CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: const Color(0xFF1B1D3C),
        ),
      ),
      themeMode: _themeMode,
      home: Wrapper(toggleTheme: toggleTheme), // Use Wrapper as the home screen
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/profileSetup': (context) => ProfileSetupScreen(),
        '/home': (context) => HomeScreen(toggleTheme: toggleTheme),
      },
    );
  }
}