// services/cloud_vision_service.dart - COMPLETE IMPLEMENTATION

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/detected_object.dart';

class CloudVisionService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://vision.googleapis.com/v1';
  final String? _apiKey = dotenv.env['GOOGLE_CLOUD_API_KEY'];

  // Plant identification API (PlantNet)
  final String _plantNetUrl = 'https://my-api.plantnet.org/v2/identify';
  final String? _plantNetApiKey = dotenv.env['PLANTNET_API_KEY'];

  // Food analysis API (Spoonacular or similar)
  final String _foodApiUrl = 'https://api.spoonacular.com/food/images/analyze';
  final String? _foodApiKey = dotenv.env['SPOONACULAR_API_KEY'];

  CloudVisionService() {
    // Configure Dio with timeout and error handling
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    // Add error interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        debugPrint('CloudVisionService API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  Future<List<DetectedObject>> detectObjects(File imageFile) async {
    if (_apiKey == null) {
      throw Exception('Google Cloud Vision API key not configured');
    }

    try {
      final base64Image = base64Encode(await imageFile.readAsBytes());

      final response = await _dio.post(
        '$_baseUrl/images:annotate?key=$_apiKey',
        data: {
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'OBJECT_LOCALIZATION', 'maxResults': 20},
                {'type': 'LABEL_DETECTION', 'maxResults': 20},
              ],
            },
          ],
        },
      );

      return _parseCloudVisionResponse(response.data);
    } catch (e) {
      debugPrint('Object detection error: $e');
      throw Exception('Failed to detect objects: ${e.toString()}');
    }
  }

  Future<List<DetectedObject>> recognizeLandmarks(File imageFile) async {
    if (_apiKey == null) {
      throw Exception('Google Cloud Vision API key not configured');
    }

    try {
      final base64Image = base64Encode(await imageFile.readAsBytes());

      final response = await _dio.post(
        '$_baseUrl/images:annotate?key=$_apiKey',
        data: {
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'LANDMARK_DETECTION', 'maxResults': 10},
              ],
            },
          ],
        },
      );

      return _parseLandmarkResponse(response.data);
    } catch (e) {
      debugPrint('Landmark recognition error: $e');
      throw Exception('Failed to recognize landmarks: ${e.toString()}');
    }
  }

  Future<List<DetectedObject>> identifyPlants(File imageFile) async {
    if (_plantNetApiKey == null) {
      // Fallback: Use Google Vision with plant-specific filtering
      return await _identifyPlantsWithGoogleVision(imageFile);
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final formData = FormData.fromMap({
        'images': MultipartFile.fromBytes(
          bytes,
          filename: 'plant_image.jpg',
        ),
        'modifiers': '["crops","similar_images"]',
        'plant_details': '["common_names","url"]',
      });

      final response = await _dio.post(
        '$_plantNetUrl/weurope?api-key=$_plantNetApiKey',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return _parsePlantNetResponse(response.data);
    } catch (e) {
      debugPrint('Plant identification error: $e');
      // Fallback to Google Vision
      return await _identifyPlantsWithGoogleVision(imageFile);
    }
  }

  Future<List<DetectedObject>> _identifyPlantsWithGoogleVision(
      File imageFile) async {
    if (_apiKey == null) {
      throw Exception('Google Cloud Vision API key not configured');
    }

    try {
      final base64Image = base64Encode(await imageFile.readAsBytes());

      final response = await _dio.post(
        '$_baseUrl/images:annotate?key=$_apiKey',
        data: {
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'LABEL_DETECTION', 'maxResults': 30},
              ],
            },
          ],
        },
      );

      return _filterPlantLabels(response.data);
    } catch (e) {
      debugPrint('Plant identification with Google Vision error: $e');
      throw Exception('Failed to identify plants: ${e.toString()}');
    }
  }

  Future<List<DetectedObject>> recognizeAnimals(File imageFile) async {
    if (_apiKey == null) {
      throw Exception('Google Cloud Vision API key not configured');
    }

    try {
      final base64Image = base64Encode(await imageFile.readAsBytes());

      final response = await _dio.post(
        '$_baseUrl/images:annotate?key=$_apiKey',
        data: {
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'LABEL_DETECTION', 'maxResults': 30},
                {'type': 'OBJECT_LOCALIZATION', 'maxResults': 10},
              ],
            },
          ],
        },
      );

      return _filterAnimalLabels(response.data);
    } catch (e) {
      debugPrint('Animal recognition error: $e');
      throw Exception('Failed to recognize animals: ${e.toString()}');
    }
  }

  Future<List<DetectedObject>> analyzeFood(File imageFile) async {
    // Try Spoonacular API first, fallback to Google Vision
    if (_foodApiKey != null) {
      try {
        return await _analyzeFoodWithSpoonacular(imageFile);
      } catch (e) {
        debugPrint('Spoonacular API failed, falling back to Google Vision: $e');
      }
    }

    return await _analyzeFoodWithGoogleVision(imageFile);
  }

  Future<List<DetectedObject>> _analyzeFoodWithSpoonacular(
      File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: 'food_image.jpg',
        ),
      });

      final response = await _dio.post(
        '$_foodApiUrl?apiKey=$_foodApiKey',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return _parseSpoonacularResponse(response.data);
    } catch (e) {
      debugPrint('Spoonacular food analysis error: $e');
      rethrow;
    }
  }

  Future<List<DetectedObject>> _analyzeFoodWithGoogleVision(
      File imageFile) async {
    if (_apiKey == null) {
      throw Exception('Google Cloud Vision API key not configured');
    }

    try {
      final base64Image = base64Encode(await imageFile.readAsBytes());

      final response = await _dio.post(
        '$_baseUrl/images:annotate?key=$_apiKey',
        data: {
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'LABEL_DETECTION', 'maxResults': 30},
                {'type': 'LOGO_DETECTION', 'maxResults': 10},
              ],
            },
          ],
        },
      );

      return _filterFoodLabels(response.data);
    } catch (e) {
      debugPrint('Food analysis with Google Vision error: $e');
      throw Exception('Failed to analyze food: ${e.toString()}');
    }
  }

  Future<List<DetectedObject>> processDocuments(File imageFile) async {
    if (_apiKey == null) {
      throw Exception('Google Cloud Vision API key not configured');
    }

    try {
      final base64Image = base64Encode(await imageFile.readAsBytes());

      final response = await _dio.post(
        '$_baseUrl/images:annotate?key=$_apiKey',
        data: {
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'DOCUMENT_TEXT_DETECTION', 'maxResults': 1},
              ],
            },
          ],
        },
      );

      return _parseDocumentResponse(response.data);
    } catch (e) {
      debugPrint('Document processing error: $e');
      throw Exception('Failed to process document: ${e.toString()}');
    }
  }

  // ============================================================================
  // RESPONSE PARSERS
  // ============================================================================

  List<DetectedObject> _parseCloudVisionResponse(
      Map<String, dynamic> response) {
    final objects = <DetectedObject>[];

    try {
      // Parse object localization
      final objectAnnotations =
          response['responses'][0]['localizedObjectAnnotations'] as List?;
      if (objectAnnotations != null) {
        for (final annotation in objectAnnotations) {
          final boundingPoly =
              annotation['boundingPoly']['normalizedVertices'] as List;
          final rect = _convertBoundingPoly(boundingPoly);

          objects.add(DetectedObject(
            id: const Uuid().v4(),
            label: annotation['name'],
            confidence: annotation['score'].toDouble(),
            boundingBox: rect,
            type: 'object',
          ));
        }
      }

      // Parse label detection
      final labelAnnotations =
          response['responses'][0]['labelAnnotations'] as List?;
      if (labelAnnotations != null) {
        for (final annotation in labelAnnotations.take(10)) {
          objects.add(DetectedObject(
            id: const Uuid().v4(),
            label: annotation['description'],
            confidence: annotation['score'].toDouble(),
            boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
            type: 'label',
          ));
        }
      }
    } catch (e) {
      debugPrint('Error parsing Cloud Vision response: $e');
    }

    return objects;
  }

  List<DetectedObject> _parseLandmarkResponse(Map<String, dynamic> response) {
    final objects = <DetectedObject>[];

    try {
      final annotations =
          response['responses'][0]['landmarkAnnotations'] as List?;
      if (annotations != null) {
        for (final annotation in annotations) {
          final locations = annotation['locations'] as List?;
          String? locationInfo;

          if (locations != null && locations.isNotEmpty) {
            final latLng = locations[0]['latLng'];
            locationInfo =
                'Lat: ${latLng['latitude']}, Lng: ${latLng['longitude']}';
          }

          objects.add(DetectedObject(
            id: const Uuid().v4(),
            label: annotation['description'],
            confidence: annotation['score']?.toDouble() ?? 0.9,
            boundingBox:
                _getBoundingBoxFromVertices(annotation['boundingPoly']),
            type: 'landmark',
            description: locationInfo,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error parsing landmark response: $e');
    }

    return objects;
  }

  List<DetectedObject> _parsePlantNetResponse(Map<String, dynamic> response) {
    final objects = <DetectedObject>[];

    try {
      final results = response['results'] as List?;
      if (results != null) {
        for (final result in results.take(5)) {
          final species = result['species'];
          final commonNames = species['commonNames'] as List?;
          final commonName =
              commonNames?.isNotEmpty == true ? commonNames!.first : '';

          objects.add(DetectedObject(
            id: const Uuid().v4(),
            label: species['scientificNameWithoutAuthor'] ?? 'Unknown Plant',
            confidence: result['score']?.toDouble() ?? 0.0,
            boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
            type: 'plant',
            description:
                commonName.isNotEmpty ? 'Common name: $commonName' : null,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error parsing PlantNet response: $e');
    }

    return objects;
  }

  List<DetectedObject> _parseSpoonacularResponse(
      Map<String, dynamic> response) {
    final objects = <DetectedObject>[];

    try {
      final category = response['category'];
      final nutrition = response['nutrition'];

      if (category != null) {
        String description = '';
        if (nutrition != null) {
          final calories = nutrition['calories'];
          final carbs = nutrition['carbs'];
          final fat = nutrition['fat'];
          final protein = nutrition['protein'];

          description =
              'Calories: ${calories ?? 'N/A'}, Carbs: ${carbs ?? 'N/A'}, Fat: ${fat ?? 'N/A'}, Protein: ${protein ?? 'N/A'}';
        }

        objects.add(DetectedObject(
          id: const Uuid().v4(),
          label: category['name'] ?? 'Food Item',
          confidence: category['probability']?.toDouble() ?? 0.8,
          boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
          type: 'food',
          description: description.isNotEmpty ? description : null,
        ));
      }
    } catch (e) {
      debugPrint('Error parsing Spoonacular response: $e');
    }

    return objects;
  }

  List<DetectedObject> _parseDocumentResponse(Map<String, dynamic> response) {
    final objects = <DetectedObject>[];

    try {
      final textAnnotations =
          response['responses'][0]['textAnnotations'] as List?;
      if (textAnnotations != null && textAnnotations.isNotEmpty) {
        final fullText = textAnnotations[0]['description'] as String;

        objects.add(DetectedObject(
          id: const Uuid().v4(),
          label: fullText.length > 100
              ? '${fullText.substring(0, 100)}...'
              : fullText,
          confidence: 0.95,
          boundingBox:
              _getBoundingBoxFromVertices(textAnnotations[0]['boundingPoly']),
          type: 'document',
          rawValue: fullText,
          description: 'Full document text extracted',
        ));
      }

      // Also parse individual text blocks for better granularity
      final fullTextAnnotation = response['responses'][0]['fullTextAnnotation'];
      if (fullTextAnnotation != null) {
        final pages = fullTextAnnotation['pages'] as List?;
        if (pages != null) {
          for (final page in pages) {
            final blocks = page['blocks'] as List?;
            if (blocks != null) {
              for (final block in blocks.take(10)) {
                // Limit to avoid too many objects
                final paragraphs = block['paragraphs'] as List?;
                if (paragraphs != null) {
                  for (final paragraph in paragraphs) {
                    final words = paragraph['words'] as List?;
                    if (words != null) {
                      final text = words.map((word) {
                        final symbols = word['symbols'] as List;
                        return symbols.map((symbol) => symbol['text']).join();
                      }).join(' ');

                      if (text.trim().isNotEmpty && text.length > 3) {
                        objects.add(DetectedObject(
                          id: const Uuid().v4(),
                          label: text.length > 50
                              ? '${text.substring(0, 50)}...'
                              : text,
                          confidence: 0.9,
                          boundingBox: _getBoundingBoxFromVertices(
                              paragraph['boundingBox']),
                          type: 'text_block',
                          rawValue: text,
                        ));
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing document response: $e');
    }

    return objects;
  }

  // ============================================================================
  // LABEL FILTERS
  // ============================================================================

  List<DetectedObject> _filterPlantLabels(Map<String, dynamic> response) {
    final objects = <DetectedObject>[];
    final plantKeywords = [
      'plant',
      'flower',
      'tree',
      'leaf',
      'petal',
      'stem',
      'branch',
      'root',
      'grass',
      'herb',
      'shrub',
      'fern',
      'moss',
      'vine',
      'cactus',
      'succulent',
      'orchid',
      'rose',
      'tulip',
      'daisy',
      'sunflower',
      'lily',
      'vegetation',
      'foliage',
      'botanical',
      'flora',
      'bloom',
      'blossom',
      'garden'
    ];

    try {
      final annotations = response['responses'][0]['labelAnnotations'] as List?;
      if (annotations != null) {
        for (final annotation in annotations) {
          final description =
              annotation['description'].toString().toLowerCase();
          if (plantKeywords.any((keyword) => description.contains(keyword))) {
            objects.add(DetectedObject(
              id: const Uuid().v4(),
              label: annotation['description'],
              confidence: annotation['score'].toDouble(),
              boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
              type: 'plant',
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Error filtering plant labels: $e');
    }

    return objects;
  }

  List<DetectedObject> _filterAnimalLabels(Map<String, dynamic> response) {
    final objects = <DetectedObject>[];
    final animalKeywords = [
      'dog',
      'cat',
      'bird',
      'fish',
      'horse',
      'cow',
      'pig',
      'sheep',
      'goat',
      'chicken',
      'duck',
      'rabbit',
      'hamster',
      'mouse',
      'rat',
      'elephant',
      'lion',
      'tiger',
      'bear',
      'deer',
      'fox',
      'wolf',
      'monkey',
      'ape',
      'animal',
      'mammal',
      'reptile',
      'amphibian',
      'insect',
      'butterfly',
      'bee',
      'spider',
      'snake',
      'lizard',
      'turtle',
      'frog',
      'pet',
      'wildlife'
    ];

    try {
      final annotations = response['responses'][0]['labelAnnotations'] as List?;
      if (annotations != null) {
        for (final annotation in annotations) {
          final description =
              annotation['description'].toString().toLowerCase();
          if (animalKeywords.any((keyword) => description.contains(keyword))) {
            objects.add(DetectedObject(
              id: const Uuid().v4(),
              label: annotation['description'],
              confidence: annotation['score'].toDouble(),
              boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
              type: 'animal',
            ));
          }
        }
      }

      // Also check object localization for animals
      final objectAnnotations =
          response['responses'][0]['localizedObjectAnnotations'] as List?;
      if (objectAnnotations != null) {
        for (final annotation in objectAnnotations) {
          final name = annotation['name'].toString().toLowerCase();
          if (animalKeywords.any((keyword) => name.contains(keyword))) {
            objects.add(DetectedObject(
              id: const Uuid().v4(),
              label: annotation['name'],
              confidence: annotation['score'].toDouble(),
              boundingBox: _convertBoundingPoly(
                  annotation['boundingPoly']['normalizedVertices']),
              type: 'animal',
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Error filtering animal labels: $e');
    }

    return objects;
  }

  List<DetectedObject> _filterFoodLabels(Map<String, dynamic> response) {
    final objects = <DetectedObject>[];
    final foodKeywords = [
      'food',
      'meal',
      'dish',
      'cuisine',
      'recipe',
      'cooking',
      'restaurant',
      'pizza',
      'burger',
      'sandwich',
      'salad',
      'soup',
      'pasta',
      'rice',
      'bread',
      'cake',
      'cookie',
      'fruit',
      'vegetable',
      'meat',
      'chicken',
      'beef',
      'pork',
      'fish',
      'seafood',
      'cheese',
      'milk',
      'coffee',
      'tea',
      'drink',
      'beverage',
      'juice',
      'wine',
      'beer',
      'dessert',
      'snack',
      'breakfast',
      'lunch',
      'dinner',
      'appetizer',
      'fast food'
    ];

    try {
      final annotations = response['responses'][0]['labelAnnotations'] as List?;
      if (annotations != null) {
        for (final annotation in annotations) {
          final description =
              annotation['description'].toString().toLowerCase();
          if (foodKeywords.any((keyword) => description.contains(keyword))) {
            objects.add(DetectedObject(
              id: const Uuid().v4(),
              label: annotation['description'],
              confidence: annotation['score'].toDouble(),
              boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
              type: 'food',
            ));
          }
        }
      }

      // Check logo detection for food brands
      final logoAnnotations =
          response['responses'][0]['logoAnnotations'] as List?;
      if (logoAnnotations != null) {
        for (final annotation in logoAnnotations) {
          objects.add(DetectedObject(
            id: const Uuid().v4(),
            label: '${annotation['description']} (Brand)',
            confidence: annotation['score'].toDouble(),
            boundingBox:
                _getBoundingBoxFromVertices(annotation['boundingPoly']),
            type: 'food_brand',
          ));
        }
      }
    } catch (e) {
      debugPrint('Error filtering food labels: $e');
    }

    return objects;
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  Rect _convertBoundingPoly(List boundingPoly) {
    double minX = 1.0, minY = 1.0, maxX = 0.0, maxY = 0.0;

    for (final vertex in boundingPoly) {
      final x = vertex['x']?.toDouble() ?? 0.0;
      final y = vertex['y']?.toDouble() ?? 0.0;

      minX = math.min(minX, x);
      minY = math.min(minY, y);
      maxX = math.max(maxX, x);
      maxY = math.max(maxY, y);
    }

    return Rect.fromLTWH(minX, minY, maxX - minX, maxY - minY);
  }

  Rect _getBoundingBoxFromVertices(Map<String, dynamic>? boundingPoly) {
    if (boundingPoly == null) return const Rect.fromLTWH(0, 0, 1, 1);

    try {
      final vertices = boundingPoly['vertices'] as List?;
      if (vertices == null || vertices.isEmpty) {
        return const Rect.fromLTWH(0, 0, 1, 1);
      }

      double minX = double.infinity, minY = double.infinity;
      double maxX = 0, maxY = 0;

      for (final vertex in vertices) {
        final x = (vertex['x'] ?? 0).toDouble();
        final y = (vertex['y'] ?? 0).toDouble();

        minX = math.min(minX, x);
        minY = math.min(minY, y);
        maxX = math.max(maxX, x);
        maxY = math.max(maxY, y);
      }

      // Convert absolute coordinates to normalized coordinates (0-1 range)
      // This is a simplified conversion - you might need to adjust based on image dimensions
      return Rect.fromLTRB(
        minX / 1000, // Assuming max dimension of 1000px
        minY / 1000,
        maxX / 1000,
        maxY / 1000,
      );
    } catch (e) {
      debugPrint('Error converting bounding poly: $e');
      return const Rect.fromLTWH(0, 0, 1, 1);
    }
  }

  // Dispose method to clean up resources
  void dispose() {
    _dio.close();
  }
}
