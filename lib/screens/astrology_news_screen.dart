import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';

class AstrologyNewsScreen extends StatefulWidget {
  const AstrologyNewsScreen({Key? key}) : super(key: key);

  @override
  _AstrologyNewsScreenState createState() => _AstrologyNewsScreenState();
}

class _AstrologyNewsScreenState extends State<AstrologyNewsScreen> {
  List<dynamic> _newsItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAstrologyNews();
  }

  Future<void> _fetchAstrologyNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      // Replace with your Flask app URL (e.g., 'http://localhost:5000' if running locally)
      final response = await http.get(
        Uri.parse('http://192.168.1.9:5000/astrology-news'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _newsItems = jsonDecode(response.body);
        });
      } else {
        setState(() {
          _errorMessage = 'Error fetching astrology news: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching astrology news: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to launch URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Astrology News',
            style: GoogleFonts.jetBrainsMono(
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
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                  const Color(0xFF0A0F29),
                  const Color(0xFF1B1D3C),
                  const Color(0xFF3D2C8D),
                ]
                    : [
                  const Color(0xFF3A1C71),
                  const Color(0xFFD76D77),
                  const Color(0xFFFFAF7B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Semi-transparent overlay for better readability
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          // Main Content
          _isLoading
              ? Center(
            child: CircularProgressIndicator(
              color: isDarkMode ? Colors.white : Colors.purple,
            ),
          )
              : _errorMessage.isNotEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    _errorMessage,
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: 16,
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
                ),
                const SizedBox(height: 16),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: ZoomIn(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      child: ElevatedButton(
                        onPressed: _fetchAstrologyNews,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.purple, Colors.blue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          child: Text(
                            'Retry',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
              : _newsItems.isEmpty
              ? Center(
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Text(
                'No news available at the moment.',
                style: GoogleFonts.jetBrainsMono(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          )
              : RefreshIndicator(
            onRefresh: _fetchAstrologyNews,
            color: isDarkMode ? Colors.white : Colors.purple,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 16.0),
              itemCount: _newsItems.length,
              itemBuilder: (context, index) {
                final newsItem = _newsItems[index];
                return FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: GestureDetector(
                    onTap: () {
                      if (newsItem['url'] != null &&
                          newsItem['url'].isNotEmpty) {
                        _launchURL(newsItem['url']);
                      }
                    },
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 20.0),
                      child: Container(
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
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              // Image (if available)
                              if (newsItem['image_url'] != null &&
                                  newsItem['image_url'].isNotEmpty)
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  child: Image.network(
                                    newsItem['image_url'],
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error,
                                        stackTrace) =>
                                        Container(
                                          height: 150,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                  ),
                                ),
                              if (newsItem['image_url'] != null &&
                                  newsItem['image_url'].isNotEmpty)
                                const SizedBox(height: 12),
                              // Title
                              Text(
                                newsItem['title'] ?? 'No Title',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black
                                          .withOpacity(0.3),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Description
                              Text(
                                newsItem['description'] ??
                                    'No Description',
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.white,
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black
                                          .withOpacity(0.3),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Date
                              Text(
                                'Date: ${newsItem['date'] ?? 'Unknown'}',
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black
                                          .withOpacity(0.3),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}