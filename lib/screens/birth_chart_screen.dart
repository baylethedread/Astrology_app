import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BirthChartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Hardcoded birth details (replace with actual data later)
    String birthDate = 'August 1, 1990';
    String birthTime = '12:00 PM';
    String birthPlace = 'New York, NY';

    // Hardcoded planetary positions
    final List<Map<String, String>> planetaryPositions = [
      {'planet': 'Sun', 'sign': 'Leo', 'house': '5th'},
      {'planet': 'Moon', 'sign': 'Pisces', 'house': '12th'},
      {'planet': 'Mercury', 'sign': 'Virgo', 'house': '6th'},
      {'planet': 'Venus', 'sign': 'Libra', 'house': '7th'},
      {'planet': 'Mars', 'sign': 'Aries', 'house': '1st'},
    ];

    // Hardcoded house cusps
    final List<Map<String, String>> houseCusps = [
      {'house': '1st', 'sign': 'Taurus'},
      {'house': '2nd', 'sign': 'Gemini'},
      {'house': '3rd', 'sign': 'Cancer'},
      {'house': '4th', 'sign': 'Leo'},
      {'house': '5th', 'sign': 'Virgo'},
      {'house': '6th', 'sign': 'Libra'},
      {'house': '7th', 'sign': 'Scorpio'},
      {'house': '8th', 'sign': 'Sagittarius'},
      {'house': '9th', 'sign': 'Capricorn'},
      {'house': '10th', 'sign': 'Aquarius'},
      {'house': '11th', 'sign': 'Pisces'},
      {'house': '12th', 'sign': 'Aries'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Natal Birth Chart",
          style: GoogleFonts.playfairDisplay(),
        ),
        backgroundColor: isDarkMode ? Colors.blueGrey : Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Birth Details Section
              Text(
                "Birth Details",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Card(
                color: isDarkMode ? Colors.grey[800] : Colors.blue[50],
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: $birthDate',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      Text(
                        'Time: $birthTime',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      Text(
                        'Place: $birthPlace',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Planetary Positions Section
              ExpansionTile(
                title: Text(
                  'Planetary Positions',
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Planet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sign',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'House',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...planetaryPositions.map((position) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            position['planet']!,
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          Text(
                            position['sign']!,
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          Text(
                            position['house']!,
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
              SizedBox(height: 20),

              // House Cusps Section
              ExpansionTile(
                title: Text(
                  'House Cusps',
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'House',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sign',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...houseCusps.map((cusp) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cusp['house']!,
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          Text(
                            cusp['sign']!,
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}