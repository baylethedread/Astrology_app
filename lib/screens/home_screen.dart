import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'birth_chart_screen.dart'; // Import other screens
import 'compatibility_test_screen.dart'; // Import other screens
import 'chatbot_screen.dart'; // Import other screens
import 'package:astrology_ui/widgets/quick_access_card.dart';  // Adjust the path accordingly

class HomeScreen extends StatelessWidget {
  // Define the functions for navigation
  void navigateToBirthChart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BirthChartScreen()),
    );
  }

  void navigateToCompatibilityTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CompatibilityTestScreen()),
    );
  }

  void navigateToChatbot(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatbotScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("AstroApp", style: GoogleFonts.playfairDisplay()),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to Profile Screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Horoscope
            Card(
              color: isDarkMode ? Colors.grey[800] : Colors.blue[50],
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Horoscope",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "A day filled with opportunities to grow, take a leap of faith!",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Quick Access Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Birth Chart
                QuickAccessCard(
                  title: "Birth Chart",
                  icon: Icons.calendar_today,
                  onTap: () => navigateToBirthChart(context),
                ),
                // Compatibility Test
                QuickAccessCard(
                  title: "Compatibility Test",
                  icon: Icons.favorite,
                  onTap: () => navigateToCompatibilityTest(context),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Personalized Insights
            Text(
              "Your Insights",
              style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Card(
              color: isDarkMode ? Colors.grey[800] : Colors.blue[50],
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Today, your energy is vibrant. Trust your intuition and go for the opportunities that arise.",
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
