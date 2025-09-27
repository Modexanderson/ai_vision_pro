// providers/analytics_provider.dart - FIXED VERSION

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/camera_mode.dart';

class AnalyticsState {
  final Map<String, int> detectionCounts;
  final List<String> recentSearches;
  final int totalDetections;
  final double averageConfidence;
  final DateTime? lastActivity;
  final int totalObjects; // Add this field
  final List<String> uniqueObjects; // Track unique object types

  AnalyticsState({
    this.detectionCounts = const {},
    this.recentSearches = const [],
    this.totalDetections = 0,
    this.averageConfidence = 0.0,
    this.lastActivity,
    this.totalObjects = 0,
    this.uniqueObjects = const [],
  });

  AnalyticsState copyWith({
    Map<String, int>? detectionCounts,
    List<String>? recentSearches,
    int? totalDetections,
    double? averageConfidence,
    DateTime? lastActivity,
    int? totalObjects,
    List<String>? uniqueObjects,
  }) {
    return AnalyticsState(
      detectionCounts: detectionCounts ?? this.detectionCounts,
      recentSearches: recentSearches ?? this.recentSearches,
      totalDetections: totalDetections ?? this.totalDetections,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      lastActivity: lastActivity ?? this.lastActivity,
      totalObjects: totalObjects ?? this.totalObjects,
      uniqueObjects: uniqueObjects ?? this.uniqueObjects,
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'detectionCounts': detectionCounts,
      'recentSearches': recentSearches,
      'totalDetections': totalDetections,
      'averageConfidence': averageConfidence,
      'lastActivity':
          lastActivity != null ? Timestamp.fromDate(lastActivity!) : null,
      'totalObjects': totalObjects,
      'uniqueObjects': uniqueObjects,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // From Firestore map
  factory AnalyticsState.fromMap(Map<String, dynamic> map) {
    return AnalyticsState(
      detectionCounts: Map<String, int>.from(map['detectionCounts'] ?? {}),
      recentSearches: List<String>.from(map['recentSearches'] ?? []),
      totalDetections: map['totalDetections'] ?? 0,
      averageConfidence: map['averageConfidence']?.toDouble() ?? 0.0,
      lastActivity: map['lastActivity'] != null
          ? (map['lastActivity'] as Timestamp).toDate()
          : null,
      totalObjects: map['totalObjects'] ?? 0,
      uniqueObjects: List<String>.from(map['uniqueObjects'] ?? []),
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(AnalyticsState()) {
    _loadAnalytics();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _loadAnalytics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analytics')
          .doc('stats');

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        state = AnalyticsState.fromMap(docSnapshot.data()!);
      } else {
        // Initialize with empty state and save
        await _saveToFirestore();
      }
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    }
  }

  Future<void> _saveToFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('analytics')
          .doc('stats');

      await docRef.set(state.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving analytics: $e');
    }
  }

  void trackResultView() {
    state = state.copyWith(
      lastActivity: DateTime.now(),
    );
    _saveToFirestore();
  }

  // This is the key method that needs to be called properly
  void trackDetection(
    CameraMode mode,
    int objectCount, {
    List<String>? detectedObjects,
    double? confidence,
  }) {
    final modeString = mode.name;
    final currentCounts = Map<String, int>.from(state.detectionCounts);
    currentCounts[modeString] = (currentCounts[modeString] ?? 0) + 1;

    // Update unique objects list
    final uniqueObjects = List<String>.from(state.uniqueObjects);
    if (detectedObjects != null) {
      for (final obj in detectedObjects) {
        if (!uniqueObjects.contains(obj.toLowerCase())) {
          uniqueObjects.add(obj.toLowerCase());
        }
      }
    }

    // Calculate new average confidence
    double newAverageConfidence = state.averageConfidence;
    if (confidence != null && confidence > 0) {
      if (state.totalDetections == 0) {
        newAverageConfidence = confidence;
      } else {
        // Running average calculation
        newAverageConfidence =
            ((state.averageConfidence * state.totalDetections) + confidence) /
                (state.totalDetections + 1);
      }
    }

    state = state.copyWith(
      detectionCounts: currentCounts,
      totalDetections: state.totalDetections + 1, // Always increment
      totalObjects:
          state.totalObjects + objectCount, // Add detected objects count
      uniqueObjects: uniqueObjects,
      averageConfidence: newAverageConfidence,
      lastActivity: DateTime.now(),
    );

    _saveToFirestore();
  }

  void trackSearch(String query) {
    final searches = List<String>.from(state.recentSearches);
    searches.insert(0, query);

    // Keep only the last 10 searches
    if (searches.length > 10) {
      searches.removeRange(10, searches.length);
    }

    state = state.copyWith(
      recentSearches: searches,
      lastActivity: DateTime.now(),
    );
    _saveToFirestore();
  }

  void updateAverageConfidence(double confidence) {
    // This method is now handled in trackDetection
    // Keeping for backward compatibility
    if (confidence > 0) {
      double newAverage;
      if (state.totalDetections <= 1) {
        newAverage = confidence;
      } else {
        newAverage = ((state.averageConfidence * (state.totalDetections - 1)) +
                confidence) /
            state.totalDetections;
      }

      state = state.copyWith(averageConfidence: newAverage);
      _saveToFirestore();
    }
  }

  void clearAnalytics() {
    state = AnalyticsState();
    _saveToFirestore();
  }

  // Method to manually refresh analytics from Firestore
  Future<void> refreshAnalytics() async {
    await _loadAnalytics();
  }

  // Method to sync with detection history
  Future<void> syncWithHistory(List<dynamic> historyItems) async {
    if (historyItems.isEmpty) return;

    int totalDetections = historyItems.length;
    int totalObjects = 0;
    double totalConfidence = 0.0;
    List<String> allUniqueObjects = [];
    Map<String, int> modeCounts = {};

    for (final item in historyItems) {
      // Count objects
      if (item.detectedObjects != null) {
        totalObjects += (item.detectedObjects as List).length;

        // Add unique objects
        for (final obj in item.detectedObjects) {
          final objLower = obj.toString().toLowerCase();
          if (!allUniqueObjects.contains(objLower)) {
            allUniqueObjects.add(objLower);
          }
        }
      }

      // Sum confidence
      if (item.averageConfidence != null) {
        totalConfidence += item.averageConfidence;
      }

      // Count by mode
      final mode = item.mode?.name ?? 'object';
      modeCounts[mode] = (modeCounts[mode] ?? 0) + 1;
    }

    final averageConfidence =
        totalDetections > 0 ? totalConfidence / totalDetections : 0.0;

    state = state.copyWith(
      totalDetections: totalDetections,
      totalObjects: totalObjects,
      averageConfidence: averageConfidence,
      uniqueObjects: allUniqueObjects,
      detectionCounts: modeCounts,
      lastActivity: DateTime.now(),
    );

    await _saveToFirestore();
  }
}

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>(
  (ref) => AnalyticsNotifier(),
);
