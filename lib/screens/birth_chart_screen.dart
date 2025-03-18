import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For AnnotatedRegion
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astrology_ui/services/user_service.dart'; // Assuming this exists
import 'package:astrology_ui/theme/app_theme.dart'; // Import the theme file

class BirthChartScreen extends StatefulWidget {
  @override
  _BirthChartScreenState createState() => _BirthChartScreenState();
}

class _BirthChartScreenState extends State<BirthChartScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String _errorMessage = '';

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
        _errorMessage = 'Please sign in to view your birth chart.';
      }
    } catch (e) {
      _errorMessage = 'Error loading profile: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshChart() {
    _fetchUserProfile(); // Re-fetch profile to refresh data
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation and show warning
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
            'Your Natal Birth Chart',
            style: GoogleFonts.jetBrainsMono(
              color: Theme.of(context).appBarTheme.titleTextStyle?.color ??
                  (isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
              (isDarkMode ? Colors.grey[900] : Colors.white),
          elevation: Theme.of(context).appBarTheme.elevation ?? 0,
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(
                child: Text(
                  _errorMessage,
                  style: GoogleFonts.jetBrainsMono(
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        (isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                ),
              )
                  : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Birth Details Section
                    Text(
                      'Birth Details',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headlineSmall?.color ??
                            (isDarkMode ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      color: Theme.of(context).cardTheme.color ?? Colors.white,
                      elevation: Theme.of(context).cardTheme.elevation ?? 5,
                      shape: Theme.of(context).cardTheme.shape,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${_userProfile?['name'] ?? 'Not available'}',
                              style: GoogleFonts.jetBrainsMono(
                                color: Theme.of(context).textTheme.bodyMedium?.color ??
                                    (isDarkMode ? Colors.black87 : Colors.black),
                              ),
                            ),
                            Text(
                              'Date: ${_userProfile?['birthDate'] ?? 'Not available'}',
                              style: GoogleFonts.jetBrainsMono(
                                color: Theme.of(context).textTheme.bodyMedium?.color ??
                                    (isDarkMode ? Colors.black87 : Colors.black),
                              ),
                            ),
                            Text(
                              'Time: ${_userProfile?['birthTime'] ?? 'Not available'}',
                              style: GoogleFonts.jetBrainsMono(
                                color: Theme.of(context).textTheme.bodyMedium?.color ??
                                    (isDarkMode ? Colors.black87 : Colors.black),
                              ),
                            ),
                            Text(
                              'Place: ${_userProfile?['birthLocation'] ?? 'Not available'}',
                              style: GoogleFonts.jetBrainsMono(
                                color: Theme.of(context).textTheme.bodyMedium?.color ??
                                    (isDarkMode ? Colors.black87 : Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Planetary Positions Section
                    ExpansionTile(
                      title: Text(
                        'Planetary Positions',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyMedium?.color ??
                              (isDarkMode ? Colors.white : Colors.black87),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Planet',
                                style: GoogleFonts.jetBrainsMono(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                                      (isDarkMode ? Colors.white : Colors.black87),
                                ),
                              ),
                              Text(
                                'Sign',
                                style: GoogleFonts.jetBrainsMono(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                                      (isDarkMode ? Colors.white : Colors.black87),
                                ),
                              ),
                              Text(
                                'House',
                                style: GoogleFonts.jetBrainsMono(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                                      (isDarkMode ? Colors.white : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Placeholder data (replace with actual calculation)
                        ...List.generate(5, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Planet ${index + 1}',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                                        (isDarkMode ? Colors.black87 : Colors.black),
                                  ),
                                ),
                                Text(
                                  'Sign ${index + 1}',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                                        (isDarkMode ? Colors.black87 : Colors.black),
                                  ),
                                ),
                                Text(
                                  'House ${index + 1}',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                                        (isDarkMode ? Colors.black87 : Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // House Cusps Section
                    ExpansionTile(
                      title: Text(
                        'House Cusps',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyMedium?.color ??
                              (isDarkMode ? Colors.white : Colors.black87),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'House',
                                style: GoogleFonts.jetBrainsMono(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                                      (isDarkMode ? Colors.white : Colors.black87),
                                ),
                              ),
                              Text(
                                'Sign',
                                style: GoogleFonts.jetBrainsMono(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                                      (isDarkMode ? Colors.white : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Placeholder data (replace with actual calculation)
                        ...List.generate(12, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'House ${index + 1}',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                                        (isDarkMode ? Colors.black87 : Colors.black),
                                  ),
                                ),
                                Text(
                                  'Sign ${index + 1}',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                                        (isDarkMode ? Colors.black87 : Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Refresh Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _refreshChart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Refresh Chart',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}