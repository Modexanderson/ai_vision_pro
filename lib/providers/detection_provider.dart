// Enhanced Detection Provider with Advanced Features
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/detected_object.dart';
import '../models/detection_result.dart';
import '../models/detection_state.dart';
import '../services/analytics_service.dart';
import '../services/api_service.dart';
import '../services/cloud_vision_service.dart';
import '../services/ml_service.dart';
import '../providers/premium_provider.dart';
import '../utils/camera_mode.dart';

class DetectionProvider extends StateNotifier<DetectionState> {
  DetectionProvider(this._ref) : super(DetectionState.initial());

  final Ref _ref; // Add Ref to access other providers

  final MLService _mlService = MLService();
  final ApiService _apiService = ApiService();
  final CloudVisionService _cloudVisionService = CloudVisionService();
  final AnalyticsService _analyticsService = AnalyticsService();

  // Helper method to check premium status
  bool get _isPremium => _ref.read(premiumProvider).isPremium;

  Future<void> processImage(File imageFile,
      {CameraMode mode = CameraMode.object}) async {
    state = state.copyWith(
      currentResult: DetectionResult(
        id: const Uuid().v4(),
        imageFile: imageFile,
        objects: [],
        timestamp: DateTime.now(),
        isProcessing: true,
      ),
    );

    try {
      List<DetectedObject> objects = [];

      switch (mode) {
        case CameraMode.object:
          objects = await _detectObjects(imageFile);
          break;
        case CameraMode.text:
          objects = await _extractText(imageFile);
          break;
        case CameraMode.barcode:
          objects = await _scanBarcodes(imageFile);
          break;
        case CameraMode.landmark:
          objects = await _recognizeLandmarks(imageFile);
          break;
        case CameraMode.plant:
          objects = await _identifyPlants(imageFile);
          break;
        case CameraMode.animal:
          objects = await _recognizeAnimals(imageFile);
          break;
        case CameraMode.food:
          objects = await _analyzeFood(imageFile);
          break;
        case CameraMode.document:
          objects = await _processDocuments(imageFile);
          break;
      }

      final result = state.currentResult!.copyWith(
        objects: objects,
        isProcessing: false,
        mode: mode,
      );

      state = state.copyWith(currentResult: result);

      // Track analytics
      _analyticsService.trackDetection(mode, objects.length);

      // Auto-fetch enhanced details for premium users
      if (_isPremium) {
        _fetchEnhancedDetails(objects);
      }
    } catch (e) {
      state = state.copyWith(
        currentResult: state.currentResult!.copyWith(
          error: e.toString(),
          isProcessing: false,
        ),
      );
    }
  }

  Future<void> fetchFunFact(DetectedObject object) async {
    try {
      final funFact = await _apiService.getObjectFunFact(object.label);

      // Update the object with the fun fact
      final updatedObject = object.copyWith(funFact: funFact);
      _updateObjectInCurrentResult(updatedObject);
    } catch (e) {
      debugPrint('Error fetching fun fact for ${object.label}: $e');
      // Optionally update with a default message
      final updatedObject =
          object.copyWith(funFact: 'Fun fact not available at the moment.');
      _updateObjectInCurrentResult(updatedObject);
    }
  }

  Future<List<DetectedObject>> _detectObjects(File imageFile) async {
    // Use both local ML Kit and cloud vision for enhanced accuracy
    final localResults = await _mlService.detectObjects(imageFile);

    if (_isPremium) {
      final cloudResults = await _cloudVisionService.detectObjects(imageFile);
      return _mergeAndRankResults(localResults, cloudResults);
    }

    return localResults;
  }

  Future<List<DetectedObject>> _extractText(File imageFile) async {
    return await _mlService.extractText(imageFile);
  }

  Future<List<DetectedObject>> _scanBarcodes(File imageFile) async {
    return await _mlService.scanBarcodes(imageFile);
  }

  Future<List<DetectedObject>> _recognizeLandmarks(File imageFile) async {
    if (!_isPremium) {
      throw Exception('Landmark recognition requires premium subscription');
    }
    return await _cloudVisionService.recognizeLandmarks(imageFile);
  }

  Future<List<DetectedObject>> _identifyPlants(File imageFile) async {
    if (!_isPremium) {
      throw Exception('Plant identification requires premium subscription');
    }
    return await _cloudVisionService.identifyPlants(imageFile);
  }

  Future<List<DetectedObject>> _recognizeAnimals(File imageFile) async {
    if (!_isPremium) {
      throw Exception('Animal recognition requires premium subscription');
    }
    return await _cloudVisionService.recognizeAnimals(imageFile);
  }

  Future<List<DetectedObject>> _analyzeFood(File imageFile) async {
    if (!_isPremium) {
      throw Exception('Food analysis requires premium subscription');
    }
    return await _cloudVisionService.analyzeFood(imageFile);
  }

  Future<List<DetectedObject>> _processDocuments(File imageFile) async {
    if (!_isPremium) {
      throw Exception('Document processing requires premium subscription');
    }
    return await _cloudVisionService.processDocuments(imageFile);
  }

  List<DetectedObject> _mergeAndRankResults(
    List<DetectedObject> local,
    List<DetectedObject> cloud,
  ) {
    // Advanced algorithm to merge and rank results from multiple sources
    final merged = <String, DetectedObject>{};

    // Add local results
    for (final object in local) {
      merged[object.label.toLowerCase()] = object;
    }

    // Merge cloud results with higher confidence
    for (final cloudObject in cloud) {
      final key = cloudObject.label.toLowerCase();
      final existing = merged[key];

      if (existing == null || cloudObject.confidence > existing.confidence) {
        merged[key] = cloudObject.copyWith(
          confidence: (existing?.confidence ?? 0 + cloudObject.confidence) / 2,
        );
      }
    }

    return merged.values.toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  Future<void> _fetchEnhancedDetails(List<DetectedObject> objects) async {
    for (final object in objects) {
      try {
        // Fetch description, fun facts, and price estimates in parallel
        final futures = await Future.wait([
          _apiService.getObjectDescription(object.label),
          _apiService.getObjectFunFact(object.label),
          _apiService.getEstimatedPrice(object.label),
        ]);

        final updatedObject = object.copyWith(
          description: futures[0] as String?,
          funFact: futures[1] as String?,
          estimatedPrice: futures[2] as double?,
        );

        _updateObjectInCurrentResult(updatedObject);
      } catch (e) {
        debugPrint('Error fetching enhanced details for ${object.label}: $e');
      }
    }
  }

  void _updateObjectInCurrentResult(DetectedObject updatedObject) {
    if (state.currentResult == null) return;

    final objects = List<DetectedObject>.from(state.currentResult!.objects);
    final index = objects.indexWhere((obj) => obj.id == updatedObject.id);

    if (index != -1) {
      objects[index] = updatedObject;
      state = state.copyWith(
        currentResult: state.currentResult!.copyWith(objects: objects),
      );
    }
  }

  Future<void> performDeepAnalysis(DetectionResult result) async {
    if (!_isPremium) {
      throw Exception('Deep analysis requires premium subscription');
    }

    // Perform advanced AI analysis
    final analysis = await _apiService.performDeepAnalysis(result);

    state = state.copyWith(
      currentResult: result.copyWith(deepAnalysis: analysis),
    );
  }

  Future<void> retryDetection(File imageFile) async {
    await processImage(imageFile);
  }

  void clearCurrentResult() {
    state = state.copyWith(currentResult: null);
  }
}

// Update the provider definition to pass the ref
final detectionProvider =
    StateNotifierProvider<DetectionProvider, DetectionState>(
  (ref) => DetectionProvider(ref),
);
