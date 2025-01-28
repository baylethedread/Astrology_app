import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'package:astrology_ui/screens/welcome_screen.dart'; // Import your WelcomeScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth Navigation',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      // Define named routes
      initialRoute: '/', // Set the initial route to the Welcome Screen
      routes: {
        '/': (context) => const WelcomeScreen(), // Welcome screen route
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}
