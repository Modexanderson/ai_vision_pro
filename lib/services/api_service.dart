// services/api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/detection_result.dart';

class ApiService {
  final String? _openAiApiKey = dotenv.env['OPENAI_API_KEY'];
  final String _baseUrl = 'https://api.openai.com/v1';

  // HTTP client for API calls
  final http.Client _client = http.Client();

  // Constructor with logging to help diagnose issues
  ApiService() {
    if (_openAiApiKey == null) {
      debugPrint('Warning: OPENAI_API_KEY not found in environment variables');
    }
  }

  // Get a short description of the detected object
  Future<String> getObjectDescription(String objectName) async {
    if (_openAiApiKey == null) {
      return "Brief description not available.";
    }

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful assistant that provides brief, accurate descriptions.'
            },
            {
              'role': 'user',
              'content':
                  'Provide a concise 1-2 sentence description of a $objectName. Be factual and informative.'
            }
          ],
          'max_tokens': 100,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        return "Description unavailable right now.";
      }
    } catch (e) {
      debugPrint('API error: $e');
      return "Unable to fetch description.";
    }
  }

  // Get a fun fact about the detected object
  Future<String> getObjectFunFact(String objectName) async {
    if (_openAiApiKey == null) {
      return "Fun fact not available.";
    }

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful assistant that provides interesting facts.'
            },
            {
              'role': 'user',
              'content':
                  'Tell me a surprising or interesting fun fact about $objectName in 1-2 sentences.'
            }
          ],
          'max_tokens': 100,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        return "Fun fact unavailable right now.";
      }
    } catch (e) {
      debugPrint('API error: $e');
      return "Unable to fetch fun fact.";
    }
  }

  // Get estimated price of the detected object
  Future<double?> getEstimatedPrice(String objectName) async {
    if (_openAiApiKey == null) {
      return null;
    }

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful assistant that provides rough price estimates for common objects. Respond only with a number representing the average price in USD without any currency symbol or explanation.'
            },
            {
              'role': 'user',
              'content':
                  'What is the approximate average price of a typical $objectName in USD? Respond only with a number.'
            }
          ],
          'max_tokens': 20,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText = data['choices'][0]['message']['content'].trim();

        // Extract the number from the response
        final numberRegExp = RegExp(r'\d+(\.\d+)?');
        final match = numberRegExp.firstMatch(responseText);
        if (match != null) {
          return double.tryParse(match.group(0)!);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('API error: $e');
      return null;
    }
  }

  // NEW METHOD: Perform deep analysis on detection results
  Future<String> performDeepAnalysis(DetectionResult result) async {
    if (_openAiApiKey == null) {
      return "Deep analysis not available.";
    }

    try {
      // Create a summary of detected objects
      final objectSummary = result.objects
          .map((obj) =>
              '${obj.label} (${(obj.confidence * 100).toStringAsFixed(1)}% confidence)')
          .join(', ');

      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an expert image analyst. Provide insightful analysis about images based on detected objects. Be comprehensive but concise.'
            },
            {
              'role': 'user',
              'content':
                  'I have an image containing these detected objects: $objectSummary. '
                      'Perform a deep analysis including: '
                      '1. What this scene likely represents '
                      '2. Interesting relationships between objects '
                      '3. Possible context or setting '
                      '4. Any notable patterns or insights '
                      'Keep it informative but engaging.'
            }
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        return "Deep analysis unavailable right now.";
      }
    } catch (e) {
      debugPrint('API error: $e');
      return "Unable to perform deep analysis.";
    }
  }

  // Get translations for the object name
  Future<Map<String, String>> getTranslations(
      String objectName, List<String> languages) async {
    if (_openAiApiKey == null) {
      return {};
    }

    try {
      final languagesList = languages.join(', ');
      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful translator assistant that provides accurate translations. Respond with only a JSON object where the keys are language codes and values are translations.'
            },
            {
              'role': 'user',
              'content':
                  'Translate the word "$objectName" into these languages: $languagesList. Respond with a JSON object only.'
            }
          ],
          'max_tokens': 200,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText = data['choices'][0]['message']['content'].trim();

        // Extract JSON from the response
        final jsonRegExp = RegExp(r'\{.*\}', dotAll: true);
        final match = jsonRegExp.firstMatch(responseText);
        if (match != null) {
          final jsonStr = match.group(0)!;
          final Map<String, dynamic> decodedJson = jsonDecode(jsonStr);
          return decodedJson
              .map((key, value) => MapEntry(key, value.toString()));
        } else {
          return {};
        }
      } else {
        return {};
      }
    } catch (e) {
      debugPrint('API error: $e');
      return {};
    }
  }

  void dispose() {
    _client.close();
  }
}
