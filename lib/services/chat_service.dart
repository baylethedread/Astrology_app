import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class ChatService {
  static const String baseUrl = 'http://192.168.1.9:5000'; // Base URL without /horoscope
  final int maxRetries = 3;
  final Duration retryDelay = Duration(seconds: 2);

  Future<String> sendMessage(String message) async {
    print('Sending message to $baseUrl/chat: $message');
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final stopwatch = Stopwatch()..start();
        final response = await http.post(
          Uri.parse('$baseUrl/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': message}),
        ).timeout(Duration(seconds: 30), onTimeout: () {
          print('Request timed out after ${stopwatch.elapsedMilliseconds}ms');
          throw Exception('Request timed out after 30 seconds. Please check your internet connection and try again.');
        });

        stopwatch.stop();
        print('Request completed in ${stopwatch.elapsedMilliseconds}ms');
        print('Received response: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['response']?.toString() ?? 'Sorry, I couldn’t process your request.';
        } else {
          final data = jsonDecode(response.body);
          throw Exception(data['error']?.toString() ?? 'Failed to get a response from the chatbot.');
        }
      } catch (e) {
        print('Attempt $attempt failed: $e');
        if (attempt == maxRetries) {
          print('Error in ChatService after $maxRetries attempts: $e');
          return 'Sorry, I’m unable to respond right now. Please try again later.';
        }
        print('Retrying in ${retryDelay.inSeconds} seconds...');
        await Future.delayed(retryDelay);
      }
    }
    return 'Sorry, an unexpected error occurred. Please try again later.';
  }

  Future<Map<String, dynamic>> getCompatibility(String zodiacSign, String comparisonSign) async {
    print('Sending compatibility request to $baseUrl/compatibility: $zodiacSign and $comparisonSign');
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final stopwatch = Stopwatch()..start();
        final response = await http.post(
          Uri.parse('$baseUrl/compatibility'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'zodiac_sign': zodiacSign,
            'comparison_sign': comparisonSign,
          }),
        ).timeout(Duration(seconds: 30), onTimeout: () {
          print('Request timed out after ${stopwatch.elapsedMilliseconds}ms');
          throw Exception('Request timed out after 30 seconds. Please check your internet connection and try again.');
        });

        stopwatch.stop();
        print('Request completed in ${stopwatch.elapsedMilliseconds}ms');
        print('Received response: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data; // Return the entire JSON object as a Map<String, dynamic>
        } else {
          final data = jsonDecode(response.body);
          throw Exception(data['error']?.toString() ?? 'Failed to get a compatibility response.');
        }
      } catch (e) {
        print('Attempt $attempt failed: $e');
        if (attempt == maxRetries) {
          print('Error in ChatService (compatibility) after $maxRetries attempts: $e');
          throw Exception('Failed to fetch compatibility after $maxRetries attempts: $e');
        }
        print('Retrying in ${retryDelay.inSeconds} seconds...');
        await Future.delayed(retryDelay);
      }
    }
    throw Exception('An unexpected error occurred while fetching compatibility.');
  }
}