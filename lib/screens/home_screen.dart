import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For AnnotatedRegion
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astrology_ui/screens/birth_chart_screen.dart';
import 'package:astrology_ui/screens/compatibility_test_screen.dart';
import 'package:astrology_ui/screens/chatbot_screen.dart';
import 'package:astrology_ui/screens/profile_screen.dart';
import 'package:astrology_ui/screens/horoscope_screen.dart'; // Import the new screen
import 'package:astrology_ui/widgets/quick_access_card.dart';
import 'package:astrology_ui/widgets/live_background.dart'; // Import the live background
import 'package:astrology_ui/services/user_service.dart';
import 'package:astrology_ui/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart'; // Added for consistent font styling

class HomeScreen extends StatefulWidget {
  final Function(bool) toggleTheme;

  const HomeScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userProfile;
  String _todayHoroscope = '';
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedIndex = 0;

  final Map<String, String> _horoscopes = {
    'Aries': 'A day filled with opportunities to grow, take a leap of faith!',
    'Taurus': 'Focus on stability today, but don’t shy away from new ideas.',
    'Gemini': 'Communication is key today—share your thoughts openly.',
    'Cancer': 'Your intuition is strong, trust it in decision-making.',
    'Leo': 'Shine bright today, Leo! Your confidence will inspire others.',
    'Virgo': 'Pay attention to details, they’ll lead to big wins.',
    'Libra': 'Balance is your strength—seek harmony in relationships.',
    'Scorpio': 'Dive deep into your passions, Scorpio. Intensity pays off.',
    'Sagittarius': 'Adventure calls! Explore new horizons today.',
    'Capricorn': 'Hard work pays off—stay focused on your goals.',
    'Aquarius': 'Innovate and inspire, Aquarius. Your ideas are groundbreaking.',
    'Pisces': 'Embrace your creativity today, Pisces. It’s a magical day!'
  };

  final Map<String, List<int>> _luckyNumbers = {
    'Aries': [1, 9, 19],
    'Taurus': [2, 6, 15],
    'Gemini': [3, 7, 12],
    'Cancer': [4, 8, 13],
    'Leo': [5, 9, 14],
    'Virgo': [3, 6, 11],
    'Libra': [1, 5, 10],
    'Scorpio': [2, 7, 16],
    'Sagittarius': [3, 8, 12],
    'Capricorn': [4, 6, 15],
    'Aquarius': [1, 7, 14],
    'Pisces': [3, 9, 12],
  };

  final Map<String, String> _planetaryOverview = {
    'Sun': 'In Aries, bringing energy and initiative.',
    'Moon': 'In Pisces, enhancing intuition and emotion.',
    'Mercury': 'In Gemini, boosting communication.',
  };

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
        final userService = UserService();
        _userProfile = await userService.getUserProfile(user.uid);
        print('Fetched userProfile: $_userProfile');
        if (_userProfile != null) {
          final zodiacSign = _userProfile!['zodiacSign'] as String?;
          if (zodiacSign != null && _horoscopes.containsKey(zodiacSign)) {
            _todayHoroscope = _horoscopes[zodiacSign]!;
          } else {
            _todayHoroscope = 'Horoscope unavailable for your zodiac sign.';
          }
        } else {
          _errorMessage = 'User profile not found.';
        }
      } else {
        _errorMessage = 'Please sign in to view your homepage.';
      }
    } catch (e) {
      _errorMessage = 'Error loading profile: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getZodiacIcon(String? zodiacSign) {
    switch (zodiacSign) {
      case 'Aries':
        return Icons.local_fire_department;
      case 'Taurus':
        return Icons.agriculture;
      case 'Gemini':
        return Icons.handshake;
      case 'Cancer':
        return Icons.local_hospital;
      case 'Leo':
        return Icons.local_dining;
      case 'Virgo':
        return Icons.local_florist;
      case 'Libra':
        return Icons.balance;
      case 'Scorpio':
        return Icons.local_drink;
      case 'Sagittarius':
        return Icons.flight;
      case 'Capricorn':
        return Icons.landscape;
      case 'Aquarius':
        return Icons.water;
      case 'Pisces':
        return Icons.water;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print('HomeScreen - isDarkMode: $isDarkMode'); // Debug print to confirm theme detection

    final List<Widget> screens = [
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: Stack(
          children: [
            // Live Background
            const Positioned.fill(child: LiveBackground()),
            // Foreground content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Personalized Header
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              gradient: AppTheme.getGradient(context),
                              borderRadius: BorderRadius.circular(15),
                              image: const DecorationImage(
                                image: AssetImage('assets/zodiac_wheel.png'),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black26,
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userProfile != null
                                      ? 'Hello, ${_userProfile!['name']}!'
                                      : 'Welcome to AstroApp!',
                                  style: Theme.of(context).textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Your Zodiac: ${_userProfile?['zodiacSign'] ?? 'Unknown'}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 16,
                                        color: Theme.of(context).textTheme.bodyMedium?.color ??
                                            (isDarkMode ? Colors.white70 : Colors.black54),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      _getZodiacIcon(_userProfile?['zodiacSign']),
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Horoscope Card with Updated Tap Navigation
                          InkWell(
                            onTap: () {
                              setState(() => _selectedIndex = 1); // Navigate to HoroscopeScreen
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Card(
                              color: Theme.of(context).cardTheme.color,
                              shape: Theme.of(context).cardTheme.shape,
                              elevation: Theme.of(context).cardTheme.elevation!,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.yellow),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _userProfile != null && _userProfile!['zodiacSign'] != null
                                                ? "${_userProfile!['zodiacSign']} Horoscope"
                                                : "Today's Horoscope",
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _todayHoroscope + ' (Static data for now)',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Daily Planetary Overview with Overflow Fix
                          Text(
                            "Daily Planetary Overview",
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineMedium?.color ??
                                  (isDarkMode ? Colors.white : Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Card(
                            color: Theme.of(context).cardTheme.color,
                            shape: Theme.of(context).cardTheme.shape,
                            elevation: Theme.of(context).cardTheme.elevation!,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _planetaryOverview.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.circle, size: 12, color: Colors.yellow),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${entry.key}: ${entry.value}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Quick Access Section with Adjusted GridView
                          Text(
                            "Quick Access",
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineMedium?.color ??
                                  (isDarkMode ? Colors.white : Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            children: [
                              QuickAccessCard(
                                title: "Birth Chart",
                                icon: Icons.calendar_today,
                                onTap: () => setState(() => _selectedIndex = 2),
                              ),
                              QuickAccessCard(
                                title: "Compatibility\nTest",
                                icon: Icons.favorite,
                                onTap: () => setState(() => _selectedIndex = 3),
                              ),
                              QuickAccessCard(
                                title: "Chat with\nAstroBot",
                                icon: Icons.chat_bubble,
                                onTap: () {
                                  if (_userProfile == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please complete your profile first!'),
                                      ),
                                    );
                                  } else {
                                    setState(() => _selectedIndex = 4);
                                  }
                                },
                              ),
                              QuickAccessCard(
                                title: "Profile",
                                icon: Icons.person,
                                onTap: () => setState(() => _selectedIndex = 5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Lucky Numbers
                          Text(
                            "Lucky Numbers",
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineMedium?.color ??
                                  (isDarkMode ? Colors.white : Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Card(
                            color: Theme.of(context).cardTheme.color,
                            shape: Theme.of(context).cardTheme.shape,
                            elevation: Theme.of(context).cardTheme.elevation!,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _userProfile != null && _userProfile!['zodiacSign'] != null
                                        ? 'For ${_userProfile!['zodiacSign']}: ${_luckyNumbers[_userProfile!['zodiacSign']]?.join(', ') ?? 'N/A'}'
                                        : 'For your zodiac: N/A',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Updated Daily Insight without Read More link
                          Text(
                            "Daily Insight",
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineMedium?.color ??
                                  (isDarkMode ? Colors.white : Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Card(
                            color: Theme.of(context).cardTheme.color,
                            shape: Theme.of(context).cardTheme.shape,
                            elevation: Theme.of(context).cardTheme.elevation!,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _todayHoroscope,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      HoroscopeScreen(),
      BirthChartScreen(),
      CompatibilityTestScreen(),
      _userProfile != null
          ? ChatbotScreen(
        userProfile: {
          'zodiac_sign': _userProfile!['zodiacSign'],
          'birth_date': _userProfile!['birthDate'],
        },
      )
          : const Center(
        child: Text(
          'Please complete your profile to chat with AstroBot!',
          textAlign: TextAlign.center,
        ),
      ),
      ProfileScreen(),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit the app.'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent, // Ensure the scaffold is transparent
        appBar: AppBar(
          title: Text("AstroApp", style: Theme.of(context).appBarTheme.titleTextStyle),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: Theme.of(context).appBarTheme.elevation ?? 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                setState(() {
                  _selectedIndex = 5;
                });
              },
              color: Colors.white,
            ),
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                widget.toggleTheme(!isDarkMode);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Theme switched to ${!isDarkMode ? 'Dark' : 'Light'} mode!')),
                );
              },
              color: Colors.white,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(
          child: Text(
            _errorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        )
            : screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 4 && _userProfile == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please complete your profile first!'),
                ),
              );
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          selectedLabelStyle: Theme.of(context).textTheme.bodySmall,
          unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Horoscope'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Birth Chart'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Compatibility'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'AstroBot'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}