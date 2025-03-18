import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astrology_ui/services/user_service.dart';
import 'package:astrology_ui/theme/app_theme.dart';

class HoroscopeScreen extends StatefulWidget {
  @override
  _HoroscopeScreenState createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedPeriod = 'Today'; // Default tab selection

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userProfile = await _userService.getUserProfile(user.uid);
      } else {
        _errorMessage = 'Please sign in to view your horoscope.';
      }
    } catch (e) {
      _errorMessage = 'Error loading profile: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Placeholder horoscope content based on period and zodiac
  String _getHoroscopeContent(String period, String? zodiacSign) {
    const loremIpsum = 'Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacinia. Mauris at mattis laoreet quam. Cursus risus nisi nulla et magna maecenas id. Enim nibh quisque tellus urna justo. Egestas id pharetra morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesqueque scelerisque vestibulum eget et pulvinar. Eu sit gh...';
    switch (zodiacSign?.toLowerCase()) {
      case 'virgo':
        return {
          'Today': 'Virgo - $period: Focus on details today for success. $loremIpsum',
          'Tomorrow': 'Virgo - $period: Expect a calm day with new opportunities. $loremIpsum',
          'This week': 'Virgo - $period: A productive week ahead, balance work and rest. $loremIpsum',
        }[period] ?? loremIpsum;
      default:
        return '$period Horoscope: General guidance for the day. $loremIpsum';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final zodiacSign = _userProfile?['zodiacSign'] ?? 'Unknown';

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation from HoroscopeScreen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit the app.'),
            duration: Duration(seconds: 2),
          ),
        );
        return false; // Prevent pop
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Horoscope',
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
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(
              child: Text(
                _errorMessage,
                style: GoogleFonts.jetBrainsMono(),
              ),
            )
                : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Zodiac Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.purple, size: 40), // Placeholder icon
                      const SizedBox(width: 10),
                      Text(
                        zodiacSign,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Period Selection Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['Today', 'Tomorrow', 'This week'].map((period) {
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedPeriod = period;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedPeriod == period
                              ? Colors.purple.withOpacity(0.7)
                              : Colors.grey.withOpacity(0.3),
                          foregroundColor:
                          isDarkMode ? Colors.white : Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          period,
                          style: GoogleFonts.jetBrainsMono(),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // Progress Circles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProgressCircle('Love', 88, Colors.red),
                      _buildProgressCircle('Business', 95, Colors.green),
                      _buildProgressCircle('Health', 60, Colors.purple),
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
                          _getHoroscopeContent(_selectedPeriod, _userProfile?['zodiacSign']),
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
                          _getHoroscopeContent(_selectedPeriod, _userProfile?['zodiacSign']),
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
                          _getHoroscopeContent(_selectedPeriod, _userProfile?['zodiacSign']),
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
            ),
          ),
        ),
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