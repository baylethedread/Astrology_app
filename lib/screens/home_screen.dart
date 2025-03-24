import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astrology_ui/screens/compatibility_test_screen.dart';
import 'package:astrology_ui/screens/chatbot_screen.dart';
import 'package:astrology_ui/screens/profile_screen.dart';
import 'package:astrology_ui/screens/horoscope_screen.dart';
import 'package:astrology_ui/screens/astrology_news_screen.dart';
import 'package:astrology_ui/widgets/quick_access_card.dart';
import 'package:astrology_ui/widgets/live_background.dart';
import 'package:astrology_ui/services/user_service.dart';
import 'package:astrology_ui/services/horoscope_service.dart';
import 'package:astrology_ui/utils/notification_service.dart';
import 'package:astrology_ui/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) toggleTheme;

  const HomeScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userProfile;
  String _todayHoroscope = '';
  String _dailyMood = 'Unknown';
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

  final Map<String, String> _dailyQuotes = {
    'Aries': 'Take bold steps today, Aries!',
    'Taurus': 'Find comfort in routine, Taurus.',
    'Gemini': 'Share your ideas, Gemini!',
    'Cancer': 'Trust your gut, Cancer.',
    'Leo': 'Let your light shine, Leo!',
    'Virgo': 'Focus on the details, Virgo.',
    'Libra': 'Seek balance, Libra.',
    'Scorpio': 'Embrace your intensity, Scorpio.',
    'Sagittarius': 'Explore new horizons, Sagittarius!',
    'Capricorn': 'Stay disciplined, Capricorn.',
    'Aquarius': 'Innovate today, Aquarius!',
    'Pisces': 'Dream big, Pisces!',
  };

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
            final horoscopeService = HoroscopeService();
            final horoscope = await horoscopeService.getHoroscope(zodiacSign, 'today');
            _dailyMood = horoscope['mood'] ?? 'Unknown';
            await _scheduleDailyHoroscopeNotification(zodiacSign);
          } else {
            _todayHoroscope = 'Horoscope unavailable for your zodiac sign.';
            _dailyMood = 'Unknown';
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

  Future<void> _scheduleDailyHoroscopeNotification(String zodiacSign) async {
    try {
      final horoscopeService = HoroscopeService();
      Map<String, String> horoscope;
      try {
        horoscope = await horoscopeService.getHoroscope(zodiacSign, 'today');
      } catch (e) {
        print('Failed to fetch horoscope: $e');
        final cachedHoroscope = await horoscopeService.getCachedHoroscope(zodiacSign, 'today');
        if (cachedHoroscope != null) {
          horoscope = cachedHoroscope;
        } else {
          horoscope = {
            'overall': 'Check your horoscope for today!',
            'love': 'No love horoscope available.',
            'business': 'No business horoscope available.',
            'mood': 'Unknown',
            'color': 'Unknown',
            'lucky_number': '0',
            'lucky_time': 'Unknown',
            'love_percentage': '0',
            'business_percentage': '0',
          };
        }
      }

      final title = '$zodiacSign Daily Horoscope';
      final body = horoscope['overall'] ?? 'Check your horoscope for today!';
      await NotificationService().scheduleDailyHoroscopeNotification(title, body, zodiacSign);
      print('Scheduled daily horoscope notification for $zodiacSign');
    } catch (e) {
      print('Error scheduling horoscope notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print('HomeScreen - isDarkMode: $isDarkMode');

    final List<Widget> screens = [
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: LiveBackground()),
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _userProfile != null
                          ? 'Hello, ${_userProfile!['name']}!'
                          : 'Welcome to AstroApp!',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary.withOpacity(0.9),
                                Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: 0.3,
                          child: Image.asset(
                            'lib/assets/stars_background.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Row(
                            children: [
                              _userProfile != null && _zodiacImages.containsKey(_userProfile!['zodiacSign'])
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  _zodiacImages[_userProfile!['zodiacSign']]!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _userProfile!['zodiacSign']![0],
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                                  : Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Your Zodiac: ${_userProfile?['zodiacSign'] ?? 'Unknown'}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedIndex = 1);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Card(
                              color: Theme.of(context).cardTheme.color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              elevation: 5,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).cardTheme.color ?? Colors.white,
                                      Theme.of(context).cardTheme.color?.withOpacity(0.8) ?? Colors.white70,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: _isLoading
                                      ? const Center(child: CircularProgressIndicator())
                                      : Row(
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
                                              _todayHoroscope,
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.refresh),
                                        onPressed: _fetchUserProfile,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(
                          color: Theme.of(context).dividerColor.withOpacity(0.3),
                          thickness: 1,
                        ),
                        const SizedBox(height: 20),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            "Today's Mood",
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineMedium?.color ??
                                  (isDarkMode ? Colors.white : Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Card(
                            color: Theme.of(context).cardTheme.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            elevation: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).cardTheme.color ?? Colors.white,
                                    Theme.of(context).cardTheme.color?.withOpacity(0.8) ?? Colors.white70,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      _dailyMood.toLowerCase() == 'happy'
                                          ? Icons.sentiment_satisfied
                                          : _dailyMood.toLowerCase() == 'sad'
                                          ? Icons.sentiment_dissatisfied
                                          : Icons.sentiment_neutral,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Mood: $_dailyMood',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(
                          color: Theme.of(context).dividerColor.withOpacity(0.3),
                          thickness: 1,
                        ),
                        const SizedBox(height: 20),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            "Daily Planetary Overview",
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineMedium?.color ??
                                  (isDarkMode ? Colors.white : Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Card(
                            color: Theme.of(context).cardTheme.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            elevation: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).cardTheme.color ?? Colors.white,
                                    Theme.of(context).cardTheme.color?.withOpacity(0.8) ?? Colors.white70,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(
                          color: Theme.of(context).dividerColor.withOpacity(0.3),
                          thickness: 1,
                        ),
                        const SizedBox(height: 20),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            "Quick Access",
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineMedium?.color ??
                                  (isDarkMode ? Colors.white : Colors.black87),
                            ),
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
                              title: "Astrology\nNews",
                              icon: Icons.newspaper,
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
                        Divider(
                          color: Theme.of(context).dividerColor.withOpacity(0.3),
                          thickness: 1,
                        ),
                        const SizedBox(height: 20),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            "Lucky Numbers",
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineMedium?.color ??
                                  (isDarkMode ? Colors.white : Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Card(
                            color: Theme.of(context).cardTheme.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            elevation: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).cardTheme.color ?? Colors.white,
                                    Theme.of(context).cardTheme.color?.withOpacity(0.8) ?? Colors.white70,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(
                          color: Theme.of(context).dividerColor.withOpacity(0.3),
                          thickness: 1,
                        ),
                        const SizedBox(height: 20),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            "Daily Affirmation",
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineMedium?.color ??
                                  (isDarkMode ? Colors.white : Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Card(
                            color: Theme.of(context).cardTheme.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            elevation: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).cardTheme.color ?? Colors.white,
                                    Theme.of(context).cardTheme.color?.withOpacity(0.8) ?? Colors.white70,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  _userProfile != null && _dailyQuotes.containsKey(_userProfile!['zodiacSign'])
                                      ? _dailyQuotes[_userProfile!['zodiacSign']]!
                                      : 'Stay inspired today!',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(
                          color: Theme.of(context).dividerColor.withOpacity(0.3),
                          thickness: 1,
                        ),
                        const SizedBox(height: 20),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            "Daily Insight",
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineMedium?.color ??
                                  (isDarkMode ? Colors.white : Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Card(
                            color: Theme.of(context).cardTheme.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            elevation: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).cardTheme.color ?? Colors.white,
                                    Theme.of(context).cardTheme.color?.withOpacity(0.8) ?? Colors.white70,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      HoroscopeScreen(),
      AstrologyNewsScreen(),
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
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
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
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.chat_bubble),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchUserProfile,
                child: const Text('Retry'),
              ),
            ],
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
            BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Compatibility'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'AstroBot'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}