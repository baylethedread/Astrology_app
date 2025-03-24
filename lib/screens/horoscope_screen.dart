import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astrology_ui/services/user_service.dart';
import 'package:astrology_ui/services/horoscope_service.dart';
import 'package:astrology_ui/theme/app_theme.dart';
import 'package:astrology_ui/widgets/live_background.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HoroscopeScreen extends StatefulWidget {
  final String? initialZodiacSign;

  const HoroscopeScreen({Key? key, this.initialZodiacSign}) : super(key: key);

  @override
  _HoroscopeScreenState createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final HoroscopeService _horoscopeService = HoroscopeService();
  Map<String, dynamic>? _userProfile;
  Map<String, String>? _horoscopeData;
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedPeriod = 'Today';
  String? _zodiacSign;

  final Map<String, String> _zodiacImages = {
    'Aries': 'lib/assets/zodiac_aries.png',
    'Taurus': 'lib/assets/zodiac_taurus.png',
    'Gemini': 'lib/assets/zodiac_gemini.png',
    'Cancer': 'lib/assets/zodiac_cancer.png',
    'Leo': 'lib/assets/zodiac_leo.png',
    'Virgo': 'lib/assets/zodiac_virgo.png',
    'Libra': 'lib/assets/zodiac_libra.png',
    'Scorpio': 'lib/assets/zodiac_scorpio.png',
    'Sagittarius': 'lib/assets/zodiac_sagittarius.png',
    'Capricorn': 'lib/assets/zodiac_capricorn.png',
    'Aquarius': 'lib/assets/zodiac_aquarius.png',
    'Pisces': 'lib/assets/zodiac_pisces.png',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialZodiacSign != null) {
      _zodiacSign = widget.initialZodiacSign;
      _fetchHoroscopeData(_zodiacSign!, _selectedPeriod);
    } else {
      _fetchUserProfile();
    }
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _horoscopeData = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userProfile = await _userService.getUserProfile(user.uid);
        if (_userProfile != null && _userProfile!['zodiacSign'] != null) {
          _zodiacSign = _userProfile!['zodiacSign'];
          await _fetchHoroscopeData(_zodiacSign!, _selectedPeriod);
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
      _errorMessage = '';
      _horoscopeData = null;
    });
    try {
      _horoscopeData = await _horoscopeService.getHoroscope(zodiacSign, period.toLowerCase());
      if (_horoscopeData!['love_percentage'] == '0' &&
          _horoscopeData!['business_percentage'] == '0' &&
          _horoscopeData!['mood'] == 'Unknown') {
        _errorMessage = 'Failed to fetch horoscope data from the server. Showing fallback data.';
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch horoscope: $e';
      _horoscopeData = null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final zodiacSign = _zodiacSign ?? 'Unknown';

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
                style: GoogleFonts.playfairDisplay(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
              elevation: 2,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    if (_zodiacSign != null) {
                      _fetchHoroscopeData(_zodiacSign!, _selectedPeriod);
                    } else {
                      _fetchUserProfile();
                    }
                  },
                  tooltip: 'Refresh Horoscope',
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
            body: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
                statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
              ),
              child: _isLoading
                  ? _buildShimmerEffect()
                  : _errorMessage.isNotEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      style: GoogleFonts.jetBrainsMono(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_zodiacSign != null) {
                          _fetchHoroscopeData(_zodiacSign!, _selectedPeriod);
                        } else {
                          _fetchUserProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.withOpacity(0.7),
                        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.jetBrainsMono(),
                      ),
                    ),
                  ],
                ),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Zodiac Header
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.withOpacity(0.3),
                              Colors.blue.withOpacity(0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_zodiacImages.containsKey(zodiacSign))
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  _zodiacImages[zodiacSign]!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.star,
                                    color: Colors.purple,
                                    size: 40,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 10),
                            Flexible( // Use Flexible to prevent text overflow
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Colors.purple, Colors.blue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Text(
                                  zodiacSign,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis, // Handle long zodiac names
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Period Selection Buttons
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: LayoutBuilder( // Use LayoutBuilder to get available width
                          builder: (context, constraints) {
                            // Calculate dynamic minWidth based on available width
                            double availableWidth = constraints.maxWidth - 20; // Subtract padding
                            double buttonWidth = availableWidth / 3; // Divide by number of buttons
                            return Row(
                              children: [
                                Expanded(
                                  child: ToggleButtons(
                                    borderRadius: BorderRadius.circular(15),
                                    selectedColor: Colors.white,
                                    fillColor: Colors.purple.withOpacity(0.7),
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                    constraints: BoxConstraints(
                                      minHeight: 40,
                                      minWidth: buttonWidth > 80 ? buttonWidth : 80, // Ensure minimum width
                                    ),
                                    isSelected: ['Today', 'Tomorrow', 'This week']
                                        .map((period) => _selectedPeriod == period)
                                        .toList(),
                                    onPressed: (index) {
                                      setState(() {
                                        _selectedPeriod = ['Today', 'Tomorrow', 'This week'][index];
                                        if (_zodiacSign != null) {
                                          _fetchHoroscopeData(_zodiacSign!, _selectedPeriod);
                                        }
                                      });
                                    },
                                    children: ['Today', 'Tomorrow', 'This week'].map((period) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          period,
                                          style: GoogleFonts.jetBrainsMono(fontSize: 14),
                                          overflow: TextOverflow.ellipsis, // Prevent text overflow
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Check if _horoscopeData is available
                    if (_horoscopeData != null && _horoscopeData!.isNotEmpty) ...[
                      // Progress Circles
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.2),
                                Colors.blue.withOpacity(0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Tooltip(
                                message: 'Love: Your romantic prospects are looking good!',
                                child: _buildProgressCircle(
                                  'Love',
                                  int.tryParse(_horoscopeData!['love_percentage'] ?? '0') ?? 0,
                                  const LinearGradient(colors: [Colors.red, Colors.pink]),
                                ),
                              ),
                              Tooltip(
                                message: 'Business: Your career is on an upward trajectory!',
                                child: _buildProgressCircle(
                                  'Business',
                                  int.tryParse(_horoscopeData!['business_percentage'] ?? '0') ?? 0,
                                  const LinearGradient(colors: [Colors.green, Colors.teal]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Horoscope Sections
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: ExpansionTile(
                          leading: const Icon(Icons.star, color: Colors.purple),
                          title: Text(
                            'Overall Horoscope',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white.withOpacity(0.8),
                          collapsedBackgroundColor: isDarkMode ? Colors.grey[800] : Colors.white.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.purple.withOpacity(0.2)),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.purple.withOpacity(0.2)),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                _horoscopeData!['overall'] ?? 'No overall horoscope available.',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: ExpansionTile(
                          leading: const Icon(Icons.favorite, color: Colors.red),
                          title: Text(
                            'Love & Passion',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white.withOpacity(0.8),
                          collapsedBackgroundColor: isDarkMode ? Colors.grey[800] : Colors.white.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.purple.withOpacity(0.2)),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.purple.withOpacity(0.2)),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                _horoscopeData!['love'] ?? 'No love horoscope available.',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: ExpansionTile(
                          leading: const Icon(Icons.work, color: Colors.green),
                          title: Text(
                            'Business & Career',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white.withOpacity(0.8),
                          collapsedBackgroundColor: isDarkMode ? Colors.grey[800] : Colors.white.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.purple.withOpacity(0.2)),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.purple.withOpacity(0.2)),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                _horoscopeData!['business'] ?? 'No business horoscope available.',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Additional Horoscope Details
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          'Additional Insights',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.2),
                                Colors.blue.withOpacity(0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow('Mood', _horoscopeData!['mood'] ?? 'Unknown', Icons.sentiment_satisfied),
                              const SizedBox(height: 15),
                              _buildDetailRow('Color', _horoscopeData!['color'] ?? 'Unknown', Icons.color_lens),
                              const SizedBox(height: 15),
                              _buildDetailRow('Lucky Number', _horoscopeData!['lucky_number'] ?? '0', Icons.numbers),
                              const SizedBox(height: 15),
                              _buildDetailRow('Lucky Time', _horoscopeData!['lucky_time'] ?? 'Unknown', Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No horoscope data available. Please try again.',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 16,
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (_zodiacSign != null) {
                                  _fetchHoroscopeData(_zodiacSign!, _selectedPeriod);
                                } else {
                                  _fetchUserProfile();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.withOpacity(0.7),
                                foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: GoogleFonts.jetBrainsMono(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 40,
                      height: 15,
                      color: Colors.white,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 40,
                      height: 15,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: 150,
              height: 20,
              color: Colors.white,
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle(String label, int percentage, LinearGradient gradient) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40.0,
          lineWidth: 6.0,
          percent: percentage / 100,
          center: Text(
            '$percentage%',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.grey.withOpacity(0.3),
          linearGradient: gradient,
          animation: true,
          animationDuration: 800,
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.purple,
          size: 24,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$label:',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}