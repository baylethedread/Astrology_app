import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class HoroscopeService {
  static const String baseUrl = 'http://192.168.1.9:5000/horoscope'; // Updated URL

  Future<Map<String, String>> getHoroscope(String zodiacSign, String period, {int retries = 2}) async {
    try {
      // Normalize zodiac sign to lowercase
      final normalizedZodiac = zodiacSign.toLowerCase();

      // Map the period to the Flask API's expected format
      String apiPeriod;
      switch (period.toLowerCase()) {
        case 'today':
          apiPeriod = 'daily';
          break;
        case 'tomorrow':
          apiPeriod = 'tomorrow';
          break;
        case 'this week':
          apiPeriod = 'weekly';
          break;
        default:
          apiPeriod = 'daily';
      }

      // Make the POST request to the Flask API with retries
      for (int attempt = 0; attempt <= retries; attempt++) {
        try {
          print('Fetching horoscope for $normalizedZodiac ($apiPeriod), attempt ${attempt + 1}...');
          print('Request URL: $baseUrl');
          print('Request Body: ${jsonEncode({'sign': normalizedZodiac, 'period': apiPeriod})}');

          final stopwatch = Stopwatch()..start();
          final response = await http.post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'sign': normalizedZodiac, 'period': apiPeriod}),
          ).timeout(Duration(seconds: 30), onTimeout: () {
            print('Request timed out after ${stopwatch.elapsedMilliseconds}ms');
            throw Exception('Request timed out after 30 seconds. Please check your internet connection and try again.');
          });

          stopwatch.stop();
          print('Request completed in ${stopwatch.elapsedMilliseconds}ms');
          print('Received response: ${response.statusCode} - ${response.body}');
          if (response.statusCode == 200) {
            final jsonData = jsonDecode(response.body);
            final result = {
              'overall': jsonData['overall']?.toString() ?? 'No overall horoscope available.',
              'love': jsonData['love']?.toString() ?? 'No love horoscope available.',
              'business': jsonData['business']?.toString() ?? 'No business horoscope available.',
              'mood': jsonData['mood']?.toString() ?? 'Unknown',
              'color': jsonData['color']?.toString() ?? 'Unknown',
              'lucky_number': jsonData['lucky_number']?.toString() ?? '0',
              'lucky_time': jsonData['lucky_time']?.toString() ?? 'Unknown',
              'love_percentage': jsonData['love_percentage']?.toString() ?? '0',
              'business_percentage': jsonData['business_percentage']?.toString() ?? '0',
            };
            print('Parsed horoscope data: $result');

            // Cache the horoscope
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('last_horoscope_$normalizedZodiac', jsonEncode(result));
            await prefs.setString('last_horoscope_date_$normalizedZodiac', DateTime.now().toIso8601String());
            await prefs.setString('last_horoscope_period_$normalizedZodiac', apiPeriod);

            return result;
          } else if (response.statusCode == 503 && attempt < retries) {
            print('503 Service Unavailable, retrying after ${2 * (attempt + 1)} seconds...');
            await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
            continue;
          } else {
            throw Exception('Failed to fetch horoscope: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          print('Attempt ${attempt + 1} failed: $e');
          if (attempt == retries) {
            // Try to return the cached horoscope if available and recent
            final cachedHoroscope = await getCachedHoroscope(normalizedZodiac, apiPeriod);
            if (cachedHoroscope != null) {
              print('Returning cached horoscope: $cachedHoroscope');
              return cachedHoroscope;
            }
            throw Exception('Error fetching horoscope after $retries retries: $e');
          }
        }
      }
      throw Exception('Failed to fetch horoscope after $retries retries');
    } catch (e) {
      print('Error in HoroscopeService: $e');
      // Fallback to static data if the API fails and no cached data is available
      const fallbackDescription = 'This is a temporary horoscope message. Focus on your goals and stay positive!';
      final fallbackData = {
        'overall': '$zodiacSign - $period: $fallbackDescription',
        'love': 'Love: $fallbackDescription',
        'business': 'Business: $fallbackDescription',
        'mood': 'Unknown',
        'color': 'Unknown',
        'lucky_number': '0',
        'lucky_time': 'Unknown',
        'love_percentage': '0',
        'business_percentage': '0',
      };
      print('Returning fallback data: $fallbackData');
      return fallbackData;
    }
  }

  // Method to get the cached horoscope (used for notifications if fetch fails)
  Future<Map<String, String>?> getCachedHoroscope(String zodiacSign, String period) async {
    final normalizedZodiac = zodiacSign.toLowerCase();
    String apiPeriod;
    switch (period.toLowerCase()) {
      case 'today':
        apiPeriod = 'daily';
        break;
      case 'tomorrow':
        apiPeriod = 'tomorrow';
        break;
      case 'this week':
        apiPeriod = 'weekly';
        break;
      default:
        apiPeriod = 'daily';
    }

    final prefs = await SharedPreferences.getInstance();
    final cachedHoroscope = prefs.getString('last_horoscope_$normalizedZodiac');
    final cachedDateStr = prefs.getString('last_horoscope_date_$normalizedZodiac');
    final cachedPeriod = prefs.getString('last_horoscope_period_$normalizedZodiac');

    if (cachedHoroscope != null && cachedDateStr != null && cachedPeriod != null) {
      final cachedDate = DateTime.parse(cachedDateStr);
      final now = DateTime.now();
      // Use cached horoscope if it's from today and matches the requested period
      if (cachedDate.day == now.day &&
          cachedDate.month == now.month &&
          cachedDate.year == now.year &&
          cachedPeriod == apiPeriod) {
        return Map<String, String>.from(jsonDecode(cachedHoroscope));
      }
    }
    return null;
  }
}