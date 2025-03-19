import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class HoroscopeService {
  // Replace with your Prokerala access token
  static const String _accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiJiN2M4ZWZhOS02ODU1LTQwZmItYTUzNS0xODlmZmU0NGNmYTAiLCJqdGkiOiI2N2Q1ZTMyMDNjYzE4YWM4YmI1MzRiY2IxNmEwNTk4MjY0ZWQ2ODk5OTI3MjJlNmUyOGM1MmU5YjQ3NjE0ZjdhOTY4MWFmYzI0N2RjMzgwOCIsImlhdCI6MTc0MjM5OTc4MC45MDI2NzUsIm5iZiI6MTc0MjM5OTc4MC45MDI2NzksImV4cCI6MTc0MjQwMzM4MC45MDI1MjcsInN1YiI6ImZkNTc5ZWQwLTMxMzItNDBkYS1hYjYyLWNhMTg1ZGY2NmEyMyIsInNjb3BlcyI6W10sImNyZWRpdHNfcmVtYWluaW5nIjo1MDAwLCJyYXRlX2xpbWl0cyI6W3sicmF0ZSI6NSwiaW50ZXJ2YWwiOjYwfV19.WChXiSgtW0W7X2wJhchA5eUDSc3F2DsJbOyhu8vqzmlmZTc5qyuvgqql0DQ1zKCgumqu45YZfNtdVAXT32wPidemqYQHXEadglQwtF6_IgyQYaEQYalpfYKKyjDVMtdCimjEQkM6ps9sLfvY0tDVTR4_VXGAp0as5uqkkKZ8Ici804QrlbedBy-MHSR-ivCi82KnYHYmJleJPt2QFDCvxIqEqNsgPdnnBHM2y1tkv4tr95y2e7nIRQg5Yp7k-_DdyVFo6Ccr15RGqnKSxqNCFjnbejDuLsWKGdpTApdCwve51JyBAuU39SDfOXvZ_utkbzzkKkpUxvRqJhkDF-UqVw";

  Future<Map<String, String>> getHoroscope(String zodiacSign, String period, {int retries = 2}) async {
    try {
      // Normalize zodiac sign to lowercase
      final normalizedZodiac = zodiacSign.toLowerCase();

      if (period.toLowerCase() == 'this week') {
        // For "This week", fetch today and tomorrow and combine the data
        final todayData = await _fetchSingleDay(normalizedZodiac, 'daily', retries);
        final tomorrowData = await _fetchSingleDay(normalizedZodiac, 'daily', retries, dateOffset: 1);

        // Combine the descriptions for a weekly overview
        final weeklyDescription = 'Weekly Overview:\n- Today: ${todayData['prediction']}\n- Tomorrow: ${tomorrowData['prediction']}';
        return {
          'overall': '$zodiacSign - $period: $weeklyDescription',
          'love': 'Love: $weeklyDescription',
          'business': 'Business: $weeklyDescription',
        };
      } else {
        // Map the period to Prokerala API's date parameter
        int dateOffset;
        switch (period.toLowerCase()) {
          case 'today':
            dateOffset = 0;
            break;
          case 'tomorrow':
            dateOffset = 1;
            break;
          default:
            dateOffset = 0;
        }

        final data = await _fetchSingleDay(normalizedZodiac, 'daily', retries, dateOffset: dateOffset);
        final prediction = data['prediction'] ?? 'No horoscope available.';
        return {
          'overall': '$zodiacSign - $period: $prediction',
          'love': 'Love: $prediction',
          'business': 'Business: $prediction',
        };
      }
    } catch (e) {
      // Fallback to static data if the API fails
      const fallbackDescription = 'This is a temporary horoscope message. Focus on your goals and stay positive!';
      return {
        'overall': '$zodiacSign - $period: $fallbackDescription',
        'love': 'Love: $fallbackDescription',
        'business': 'Business: $fallbackDescription',
      };
    }
  }

  Future<Map<String, dynamic>> _fetchSingleDay(String zodiacSign, String type, int retries, {int dateOffset = 0}) async {
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        // Calculate the date based on the offset
        final date = DateTime.now().add(Duration(days: dateOffset)).toIso8601String().split('T')[0];
        final response = await http.get(
          Uri.parse('https://api.prokerala.com/v2/horoscope/$type?sign=$zodiacSign&date=$date'),
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return {
            'prediction': data['prediction'] ?? 'No horoscope available.',
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
  }
}