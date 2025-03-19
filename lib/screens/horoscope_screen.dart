import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astrology_ui/services/user_service.dart';
import 'package:astrology_ui/services/horoscope_service.dart';
import 'package:astrology_ui/theme/app_theme.dart';
import 'package:astrology_ui/widgets/live_background.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({Key? key}) : super(key: key);

  @override
  _HoroscopeScreenState createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  final UserService _userService = UserService();
  final HoroscopeService _horoscopeService = HoroscopeService();
  Map<String, dynamic>? _userProfile;
  Map<String, String>? _horoscopeData;
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedPeriod = 'Today';

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
        if (_userProfile != null && _userProfile!['zodiacSign'] != null) {
          await _fetchHoroscopeData(_userProfile!['zodiacSign'], _selectedPeriod);
        } else {
          _errorMessage = 'Zodiac sign not found in your profile.';
        }
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

  Future<void> _fetchHoroscopeData(String zodiacSign, String period) async {
    setState(() {
      _isLoading = true;
    });
    _horoscopeData = await _horoscopeService.getHoroscope(zodiacSign, period);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final zodiacSign = _userProfile?['zodiacSign'] ?? 'Unknown';

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit the app.'),
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      },
      child: Stack(
        children: [
          const Positioned.fill(child: LiveBackground()),
          Scaffold(
            backgroundColor: Colors.transparent,
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
                        const Icon(Icons.star, color: Colors.purple, size: 40),
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
                              if (_userProfile != null && _userProfile!['zodiacSign'] != null) {
                                _fetchHoroscopeData(_userProfile!['zodiacSign'], period);
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedPeriod == period
                                ? Colors.purple.withOpacity(0.7)
                                : Colors.grey.withOpacity(0.3),
                            foregroundColor: isDarkMode ? Colors.white : Colors.black87,
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
                        _buildProgressCircle('Love', 80, Colors.red),
                        _buildProgressCircle('Business', 85, Colors.green),
                        _buildProgressCircle('Health', 75, Colors.purple),
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
                            _horoscopeData?['overall'] ?? 'No horoscope available.',
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
                            _horoscopeData?['love'] ?? 'No horoscope available.',
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
                            _horoscopeData?['business'] ?? 'No horoscope available.',
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