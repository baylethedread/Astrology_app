import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'birth_chart_screen.dart';
import 'compatibility_test_screen.dart';
import 'chatbot_screen.dart';
import 'package:astrology_ui/widgets/quick_access_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) toggleTheme;

  const HomeScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              widget.toggleTheme(!isDarkMode);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                QuickAccessCard(
                  title: "Birth Chart",
                  icon: Icons.calendar_today,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BirthChartScreen()),
                  ),
                ),
                QuickAccessCard(
                  title: "Compatibility Test",
                  icon: Icons.favorite,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CompatibilityTestScreen()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

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
