// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'sign_in_screen.dart';  // Ensure you are importing the correct SignInScreen
import 'sign_up_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3A1C71),
              Color(0xFFD76D77),
              Color(0xFFFFAF7B)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.8),
                child: const Icon(
                  Icons.star_rate_rounded,
                  color: Colors.purpleAccent,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "StellarPath",
                style: GoogleFonts.audiowide(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Unlock the secrets of the stars",
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()), // Corrected here
                  );
                },
                child: const Text("Sign In"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                child: const Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
