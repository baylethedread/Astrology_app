import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  final Function(bool) toggleTheme;

  const WelcomeScreen({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
              Color(0xFF0A0F29), // Deep space blue
              Color(0xFF1B1D3C), // Dark purple
              Color(0xFF3D2C8D), // Mystic violet
            ]
                : [
              Color(0xFF3A1C71),
              Color(0xFFD76D77),
              Color(0xFFFFAF7B),
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
                child: Icon(
                  Icons.star_rate_rounded,
                  color: isDarkMode ? Colors.tealAccent : Colors.purpleAccent,
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
                  Navigator.pushNamed(context, '/signin');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.deepPurple : Colors.white,
                  foregroundColor: isDarkMode ? Colors.white : Colors.black,
                ),
                child: const Text("Sign In"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.purpleAccent : Colors.white,
                  foregroundColor: isDarkMode ? Colors.black : Colors.black,
                ),
                child: const Text("Sign Up"),
              ),
              const SizedBox(height: 40),
              // Dark Mode Toggle Button
              IconButton(
                icon: Icon(
                  isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                  color: Colors.white70,
                ),
                onPressed: () {
                  toggleTheme(!isDarkMode);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
