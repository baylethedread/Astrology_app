import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BirthChartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Birth Chart", style: GoogleFonts.playfairDisplay()),
        backgroundColor: isDarkMode ? Colors.blueGrey : Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Full Birth Chart",
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
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
                      "Sun Sign: Leo",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Moon Sign: Pisces",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Rising Sign: Taurus",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    // Add more birth chart details here
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
