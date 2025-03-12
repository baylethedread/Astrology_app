import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompatibilityTestScreen extends StatefulWidget {
  @override
  _CompatibilityTestScreenState createState() => _CompatibilityTestScreenState();
}

class _CompatibilityTestScreenState extends State<CompatibilityTestScreen> {
  String? selectedSign1;
  String? selectedSign2;
  Map<String, dynamic>? compatibilityResult;

  // List of zodiac signs
  final List<String> zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  // Predefined compatibility data (example pairs)
  final Map<String, Map<String, dynamic>> compatibilityData = {
    'Aries-Leo': {'percentage': 80, 'description': 'Great match! Both are fire signs with high energy.'},
    'Aries-Cancer': {'percentage': 40, 'description': 'Challenging but possible with effort.'},
    // Add more pairs as needed or use a default for undefined pairs
  };

  // Function to calculate compatibility
  void calculateCompatibility() {
    if (selectedSign1 == null || selectedSign2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select both zodiac signs.")),
      );
      return;
    }
    String key = getCompatibilityKey(selectedSign1!, selectedSign2!);
    setState(() {
      compatibilityResult = compatibilityData[key] ?? {
        'percentage': 50,
        'description': 'Average compatibility. A balanced relationship is possible.'
      };
    });
  }

  // Helper function to generate a unique key for compatibility lookup
  String getCompatibilityKey(String sign1, String sign2) {
    List<String> signs = [sign1, sign2]..sort();
    return signs.join('-');
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Compatibility Test",
          style: GoogleFonts.playfairDisplay(), // Consistent typography
        ),
        backgroundColor: isDarkMode ? Colors.blueGrey : Colors.blue, // Theme-based color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions for the user
              Text(
                "Select your zodiac sign and your partner's to check compatibility.",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              SizedBox(height: 20),
              // Form for zodiac sign selection
              Form(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedSign1,
                      decoration: InputDecoration(
                        labelText: "Your Zodiac Sign",
                        border: OutlineInputBorder(),
                      ),
                      items: zodiacSigns.map((sign) => DropdownMenuItem(
                        value: sign,
                        child: Text(sign),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSign1 = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedSign2,
                      decoration: InputDecoration(
                        labelText: "Partner's Zodiac Sign",
                        border: OutlineInputBorder(),
                      ),
                      items: zodiacSigns.map((sign) => DropdownMenuItem(
                        value: sign,
                        child: Text(sign),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSign2 = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Button to calculate compatibility
              ElevatedButton(
                onPressed: calculateCompatibility,
                child: Text("Calculate Compatibility"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
              SizedBox(height: 20),
              // Display compatibility result if available
              if (compatibilityResult != null)
                Card(
                  color: isDarkMode ? Colors.grey[800] : Colors.blue[50],
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite, color: Colors.red),
                            SizedBox(width: 10),
                            Text(
                              "${compatibilityResult!['percentage']}%",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Text(
                          compatibilityResult!['description'],
                          style: GoogleFonts.poppins(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}