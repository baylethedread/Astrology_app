import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class HoroscopeService {
  static const String baseUrl = 'https://f338-2402-d000-810c-16e8-1516-a555-8d06-7891.ngrok-free.app/horoscope'; // Updated to ngrok URL

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
          final response = await http.post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'sign': normalizedZodiac, 'period': apiPeriod}),
          );

          if (response.statusCode == 200) {
            final jsonData = jsonDecode(response.body);
            return {
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
          } else if (response.statusCode == 503 && attempt < retries) {
            // If 503 error, wait and retry
            await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
            continue;
          } else {
            throw Exception('Failed to fetch horoscope: ${response.statusCode}');
          }
        } catch (e) {
          if (attempt == retries) {
            throw Exception('Error fetching horoscope after $retries retries: $e');
          }
        }
      }
      throw Exception('Failed to fetch horoscope after $retries retries');
    } catch (e) {
      // Fallback to static data if the API fails
      const fallbackDescription = 'This is a temporary horoscope message. Focus on your goals and stay positive!';
      return {
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
    }
  }
}