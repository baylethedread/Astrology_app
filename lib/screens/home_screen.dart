import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astrology_ui/screens/birth_chart_screen.dart';
import 'package:astrology_ui/screens/compatibility_test_screen.dart';
import 'package:astrology_ui/screens/chatbot_screen.dart';
import 'package:astrology_ui/screens/profile_screen.dart'; // Ensure this is imported
import 'package:astrology_ui/widgets/quick_access_card.dart';
import 'package:astrology_ui/services/user_service.dart';

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
        print('Fetched userProfile: $_userProfile'); // Debug print
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

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
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
                    Text(
                      _userProfile != null
                          ? 'Hi, ${_userProfile!['name']}!'
                          : 'Welcome to AstroApp!',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.yellow),
                                const SizedBox(width: 10),
                                Text(
                                  _userProfile != null && _userProfile!['zodiacSign'] != null
                                      ? "${_userProfile!['zodiacSign']} Horoscope"
                                      : "Today's Horoscope",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _todayHoroscope + ' (Static data for now)',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Quick Access",
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        QuickAccessCard(
                          title: "Birth Chart",
                          icon: Icons.calendar_today,
                          onTap: () => setState(() => _selectedIndex = 1),
                        ),
                        QuickAccessCard(
                          title: "Compatibility Test",
                          icon: Icons.favorite,
                          onTap: () => setState(() => _selectedIndex = 2),
                        ),
                        QuickAccessCard(
                          title: "Chat with AstroBot",
                          icon: Icons.chat_bubble,
                          onTap: () {
                            if (_userProfile == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please complete your profile first!'),
                                ),
                              );
                            } else {
                              setState(() => _selectedIndex = 3);
                            }
                          },
                        ),
                        QuickAccessCard(
                          title: "Profile",
                          icon: Icons.person,
                          onTap: () => setState(() => _selectedIndex = 4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Your Insights",
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "Today, your energy is vibrant. Trust your intuition and go for the opportunities that arise.",
                          style: Theme.of(context).textTheme.bodyMedium,
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
      BirthChartScreen(),
      CompatibilityTestScreen(),
      _userProfile != null
          ? ChatbotScreen(
        userProfile: {
          'zodiac_sign': _userProfile!['zodiacSign'],
          'birth_date': _userProfile!['birthDate'], // Match Firestore key
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("AstroApp"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              setState(() {
                _selectedIndex = 4;
              });
            },
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              widget.toggleTheme(!isDarkMode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Theme switched to ${!isDarkMode ? 'Dark' : 'Light'} mode!')),
              );
            },
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
          if (index == 3 && _userProfile == null) { // Index 3 is AstroBot
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
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: isDarkMode ? Colors.white54 : Colors.black54,
        selectedLabelStyle: Theme.of(context).textTheme.bodySmall,
        unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Birth Chart'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Compatibility'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'AstroBot'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}