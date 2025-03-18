import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For AnnotatedRegion
import 'package:google_fonts/google_fonts.dart';
import 'package:astrology_ui/theme/app_theme.dart'; // Import the theme file

class CompatibilityTestScreen extends StatefulWidget {
  @override
  _CompatibilityTestScreenState createState() => _CompatibilityTestScreenState();
}

class _CompatibilityTestScreenState extends State<CompatibilityTestScreen> {
  String? _selectedSign1;
  String? _selectedSign2;
  Map<String, dynamic>? _compatibilityResult;

  // List of zodiac signs with updated icons
  final List<Map<String, dynamic>> _zodiacSigns = [
    {'name': 'Aries', 'icon': Icons.local_fire_department},
    {'name': 'Taurus', 'icon': Icons.agriculture},
    {'name': 'Gemini', 'icon': Icons.handshake},
    {'name': 'Cancer', 'icon': Icons.local_hospital},
    {'name': 'Leo', 'icon': Icons.local_dining},
    {'name': 'Virgo', 'icon': Icons.local_florist},
    {'name': 'Libra', 'icon': Icons.balance},
    {'name': 'Scorpio', 'icon': Icons.local_drink},
    {'name': 'Sagittarius', 'icon': Icons.flight},
    {'name': 'Capricorn', 'icon': Icons.landscape},
    {'name': 'Aquarius', 'icon': Icons.water},
    {'name': 'Pisces', 'icon': Icons.water},
  ];

  // Predefined compatibility data (example pairs)
  final Map<String, Map<String, dynamic>> _compatibilityData = {
    'Aries-Leo': {
      'love': 80,
      'business': 95,
      'health': 60,
      'overall': 'Great match! Both are fire signs with high energy.',
      'loveDescription': 'A passionate and fiery connection awaits you.',
      'businessDescription': 'Together, you’ll achieve great success in professional endeavors.',
    },
    'Aries-Cancer': {
      'love': 40,
      'business': 50,
      'health': 60,
      'overall': 'Challenging but possible with effort.',
      'loveDescription': 'Emotional differences may create challenges.',
      'businessDescription': 'Work on communication to improve collaboration.',
    },
    // Add more pairs as needed or use a default for undefined pairs
  };

  // Function to calculate compatibility
  void _calculateCompatibility() {
    if (_selectedSign1 == null || _selectedSign2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both zodiac signs.")),
      );
      return;
    }
    String key = _getCompatibilityKey(_selectedSign1!, _selectedSign2!);
    setState(() {
      _compatibilityResult = _compatibilityData[key] ?? {
        'love': 50,
        'business': 50,
        'health': 50,
        'overall': 'Average compatibility. A balanced relationship is possible.',
        'loveDescription': 'A steady relationship with room for growth.',
        'businessDescription': 'Collaboration is possible with mutual effort.',
      };
    });
  }

  // Helper function to generate a unique key for compatibility lookup
  String _getCompatibilityKey(String sign1, String sign2) {
    List<String> signs = [sign1, sign2]..sort();
    return signs.join('-');
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        // Handle device back button press
        if (_compatibilityResult != null) {
          // If on result screen, return to selection screen
          setState(() {
            _compatibilityResult = null;
            _selectedSign1 = null;
            _selectedSign2 = null;
          });
          return false; // Prevent pop
        } else {
          // If on selection screen, show warning and prevent exit
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit the app.'),
              duration: Duration(seconds: 2),
            ),
          );
          return false; // Prevent pop
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // Conditionally show the back button only on the result screen
          leading: _compatibilityResult != null
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _compatibilityResult = null;
                _selectedSign1 = null;
                _selectedSign2 = null;
              });
            },
            color: isDarkMode ? Colors.white : Colors.black,
          )
              : null, // No leading widget on the selection screen
          title: Text(
            'Compatibility',
            style: GoogleFonts.jetBrainsMono(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          elevation: 2,
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.getGradient(context),
              image: const DecorationImage(
                image: AssetImage('assets/zodiac_wheel.png'), // Placeholder, add to pubspec.yaml
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black26,
                  BlendMode.darken,
                ),
              ),
            ),
            child: _compatibilityResult == null
                ? _buildSelectionScreen(isDarkMode) // Show selection screen if no result
                : _buildResultScreen(isDarkMode), // Show result screen if calculated
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionScreen(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Check love and business compatibility',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left column for Sign 1 selection
                SizedBox(
                  width: 120,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _zodiacSigns.length,
                    itemBuilder: (context, index) {
                      final sign = _zodiacSigns[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedSign1 = sign['name'];
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedSign1 == sign['name']
                                ? Colors.purple.withOpacity(0.7)
                                : Colors.grey.withOpacity(0.3),
                            foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(sign['icon'], size: 30, color: Colors.white),
                              const SizedBox(height: 5),
                              Text(
                                sign['name'],
                                style: GoogleFonts.jetBrainsMono(),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Center "Go" button
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: (_selectedSign1 != null && _selectedSign2 != null)
                          ? _calculateCompatibility
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.withOpacity(0.7),
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                      ),
                      child: const Text(
                        'Go',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                // Right column for Sign 2 selection
                SizedBox(
                  width: 120,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _zodiacSigns.length,
                    itemBuilder: (context, index) {
                      final sign = _zodiacSigns[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedSign2 = sign['name'];
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedSign2 == sign['name']
                                ? Colors.purple.withOpacity(0.7)
                                : Colors.grey.withOpacity(0.3),
                            foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(sign['icon'], size: 30, color: Colors.white),
                              const SizedBox(height: 5),
                              Text(
                                sign['name'],
                                style: GoogleFonts.jetBrainsMono(),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Zodiac Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    _zodiacSigns.firstWhere((sign) => sign['name'] == _selectedSign1)['icon'],
                    color: Colors.purple,
                    size: 40,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _selectedSign1!,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple.withOpacity(0.7),
                ),
                padding: const EdgeInsets.all(10),
                child: const Text(
                  '♥',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Text(
                    _selectedSign2!,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    _zodiacSigns.firstWhere((sign) => sign['name'] == _selectedSign2)['icon'],
                    color: Colors.purple,
                    size: 40,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress Circles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProgressCircle('Love', _compatibilityResult!['love'], Colors.red),
              _buildProgressCircle('Business', _compatibilityResult!['business'], Colors.green),
              _buildProgressCircle('Health', _compatibilityResult!['health'], Colors.purple),
            ],
          ),
          const SizedBox(height: 20),
          // Horoscope Sections
          ExpansionTile(
            title: Text(
              'Overall horoscope',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  _compatibilityResult!['overall'],
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              'Love & Passion',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  _compatibilityResult!['loveDescription'],
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              'Business & Career',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  _compatibilityResult!['businessDescription'],
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(String label, int percentage, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.withOpacity(0.3),
            color: color,
            strokeWidth: 6,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$percentage%',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}