import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astrology_ui/theme/app_theme.dart';
import 'package:astrology_ui/services/chat_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';

// Define the CompatibilityResult model
class CompatibilityResult {
  final int love;
  final int business;
  final int health;
  final String overall;
  final String loveDescription;
  final String businessDescription;

  CompatibilityResult({
    required this.love,
    required this.business,
    required this.health,
    required this.overall,
    required this.loveDescription,
    required this.businessDescription,
  });

  factory CompatibilityResult.fromJson(Map<String, dynamic> json) {
    return CompatibilityResult(
      love: int.tryParse(json['love'].toString()) ?? 50,
      business: int.tryParse(json['business'].toString()) ?? 50,
      health: int.tryParse(json['health'].toString()) ?? 50,
      overall: json['overall']?.toString() ?? 'Compatibility data unavailable.',
      loveDescription: json['loveDescription']?.toString() ?? 'No love description available.',
      businessDescription: json['businessDescription']?.toString() ?? 'No business description available.',
    );
  }
}

class CompatibilityTestScreen extends StatefulWidget {
  @override
  _CompatibilityTestScreenState createState() => _CompatibilityTestScreenState();
}

class _CompatibilityTestScreenState extends State<CompatibilityTestScreen> with SingleTickerProviderStateMixin {
  String? _selectedSign1;
  String? _selectedSign2;
  CompatibilityResult? _compatibilityResult;
  bool _isLoading = false;

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

  final ChatService _chatService = ChatService();

  void _calculateCompatibility() async {
    if (_selectedSign1 == null || _selectedSign2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both zodiac signs.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _compatibilityResult = null;
    });

    try {
      final result = await _chatService.getCompatibility(_selectedSign1!, _selectedSign2!);
      setState(() {
        _compatibilityResult = CompatibilityResult.fromJson(result);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch compatibility: $e")),
      );
      setState(() {
        _compatibilityResult = CompatibilityResult(
          love: 50,
          business: 50,
          health: 50,
          overall: 'Failed to fetch compatibility. Please try again later.',
          loveDescription: 'Unable to determine love compatibility.',
          businessDescription: 'Unable to determine business compatibility.',
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (_compatibilityResult != null) {
          setState(() {
            _compatibilityResult = null;
            _selectedSign1 = null;
            _selectedSign2 = null;
          });
          return false;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit the app.'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
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
              : null,
          title: Text(
            'Compatibility',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
                image: AssetImage('assets/zodiac_wheel.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black54,
                  BlendMode.darken,
                ),
              ),
            ),
            child: _compatibilityResult == null
                ? _buildSelectionScreen(isDarkMode)
                : _buildResultScreen(isDarkMode),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionScreen(bool isDarkMode) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.3),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.purple, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Check Love & Business Compatibility',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 130,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _zodiacSigns.length,
                        itemBuilder: (context, index) {
                          final sign = _zodiacSigns[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: FadeInUp(
                              duration: Duration(milliseconds: 500 + (index * 100)),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSign1 = sign['name'];
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _selectedSign1 == sign['name']
                                          ? [Colors.purple.withOpacity(0.7), Colors.blue.withOpacity(0.7)]
                                          : [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.5)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(sign['icon'], size: 30, color: Colors.white),
                                      const SizedBox(height: 5),
                                      Text(
                                        sign['name'],
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 14,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ZoomIn(
                          duration: const Duration(milliseconds: 800),
                          child: GestureDetector(
                            onTap: (_selectedSign1 != null && _selectedSign2 != null && !_isLoading)
                                ? _calculateCompatibility
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: (_selectedSign1 != null && _selectedSign2 != null && !_isLoading)
                                      ? [Colors.purple, Colors.blue]
                                      : [Colors.grey.withOpacity(0.5), Colors.grey.withOpacity(0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Go',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                    SizedBox(
                      width: 130,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _zodiacSigns.length,
                        itemBuilder: (context, index) {
                          final sign = _zodiacSigns[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: FadeInUp(
                              duration: Duration(milliseconds: 500 + (index * 100)),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSign2 = sign['name'];
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _selectedSign2 == sign['name']
                                          ? [Colors.purple.withOpacity(0.7), Colors.blue.withOpacity(0.7)]
                                          : [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.5)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(sign['icon'], size: 30, color: Colors.white),
                                      const SizedBox(height: 5),
                                      Text(
                                        sign['name'],
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 14,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
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
        ),
      ],
    );
  }

  Widget _buildResultScreen(bool isDarkMode) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.3),
        ),
        SingleChildScrollView(
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible( // Use Flexible to constrain the first zodiac sign
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _zodiacSigns.firstWhere((sign) => sign['name'] == _selectedSign1)['icon'],
                              color: Colors.purple,
                              size: MediaQuery.of(context).size.width * 0.08, // Dynamic size
                            ),
                            const SizedBox(width: 8), // Reduced spacing
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.purple, Colors.blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                _selectedSign1!,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: MediaQuery.of(context).size.width * 0.05, // Dynamic font size
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis, // Handle long text
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10), // Reduced spacing
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.red, Colors.pink],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: const Text(
                          '♥',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10), // Reduced spacing
                      Flexible( // Use Flexible to constrain the second zodiac sign
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.purple, Colors.blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                _selectedSign2!,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: MediaQuery.of(context).size.width * 0.05, // Dynamic font size
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis, // Handle long text
                              ),
                            ),
                            const SizedBox(width: 8), // Reduced spacing
                            Icon(
                              _zodiacSigns.firstWhere((sign) => sign['name'] == _selectedSign2)['icon'],
                              color: Colors.purple,
                              size: MediaQuery.of(context).size.width * 0.08, // Dynamic size
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
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
                      _buildProgressCircle(
                        'Love',
                        _compatibilityResult!.love,
                        const LinearGradient(colors: [Colors.red, Colors.pink]),
                      ),
                      _buildProgressCircle(
                        'Business',
                        _compatibilityResult!.business,
                        const LinearGradient(colors: [Colors.green, Colors.teal]),
                      ),
                      _buildProgressCircle(
                        'Health',
                        _compatibilityResult!.health,
                        const LinearGradient(colors: [Colors.purple, Colors.blue]),
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
                  title: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Overall Horoscope',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
                        _compatibilityResult!.overall,
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
                  title: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Love & Passion',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
                        _compatibilityResult!.loveDescription,
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
                  title: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Business & Career',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
                        _compatibilityResult!.businessDescription,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCircle(String label, int percentage, LinearGradient gradient) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: MediaQuery.of(context).size.width * 0.1, // Dynamic size based on screen width
          lineWidth: 6.0,
          percent: percentage / 100,
          center: Text(
            '$percentage%',
            style: GoogleFonts.playfairDisplay(
              fontSize: MediaQuery.of(context).size.width * 0.035, // Dynamic font size
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.purple.withOpacity(0.7),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.grey.withOpacity(0.3),
          linearGradient: gradient,
          animation: true,
          animationDuration: 1000,
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
}