// providers/history_provider.dart - FIXED VERSION

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/detection_result.dart';
import '../models/detection_history.dart';

import '../providers/analytics_provider.dart';
import '../utils/camera_mode.dart';

class HistoryNotifier extends StateNotifier<List<DetectionHistory>> {
  HistoryNotifier(this._ref) : super([]) {
    _loadHistory();
  }

  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _loadHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('detection_history')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      final history = querySnapshot.docs
          .map((doc) => DetectionHistory.fromMap(doc.data()))
          .toList();

      state = history;

      // Sync analytics with loaded history
      _syncAnalytics();
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> saveResult(DetectionResult result) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final history = DetectionHistory(
        id: result.id,
        imagePath: result.imageFile.path,
        detectedObjects: result.objects.map((obj) => obj.label).toList(),
        averageConfidence: result.objects.isEmpty
            ? 0.0
            : result.objects
                    .map((obj) => obj.confidence)
                    .reduce((a, b) => a + b) /
                result.objects.length,
        timestamp: result.timestamp,
        mode: result.mode,
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('detection_history')
          .doc(result.id)
          .set(history.toMap());

      // Update local state
      state = [history, ...state];

      // CRITICAL: Update analytics after saving
      _updateAnalyticsForNewDetection(history);
    } catch (e) {
      debugPrint('Error saving result: $e');
    }
  }

  // New method to update analytics when a detection is saved
  void _updateAnalyticsForNewDetection(DetectionHistory history) {
    try {
      // Import the analytics provider
      final analyticsNotifier = _ref.read(analyticsProvider.notifier);

      // Call trackDetection with proper parameters
      analyticsNotifier.trackDetection(
        history.mode ?? CameraMode.object,
        history.detectedObjects.length,
        detectedObjects: history.detectedObjects,
        confidence: history.averageConfidence,
      );

      debugPrint('Analytics updated for detection: ${history.id}');
    } catch (e) {
      debugPrint('Error updating analytics: $e');
    }
  }

  // Method to sync analytics with all history items
  void _syncAnalytics() {
    try {
      final analyticsNotifier = _ref.read(analyticsProvider.notifier);
      analyticsNotifier.syncWithHistory(state);
      debugPrint('Analytics synced with ${state.length} history items');
    } catch (e) {
      debugPrint('Error syncing analytics: $e');
    }
  }

  Future<void> removeItem(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('detection_history')
          .doc(id)
          .delete();

      state = state.where((item) => item.id != id).toList();

      // Re-sync analytics after removal
      _syncAnalytics();
    } catch (e) {
      debugPrint('Error removing item: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final batch = _firestore.batch();
      final collection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('detection_history');

      final querySnapshot = await collection.get();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      state = [];

      // Clear analytics as well
      final analyticsNotifier = _ref.read(analyticsProvider.notifier);
      analyticsNotifier.clearAnalytics();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }

  // Method to manually refresh history and sync analytics
  Future<void> refreshHistory() async {
    await _loadHistory();
  }
}

// Updated provider definition to include Ref parameter
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<DetectionHistory>>(
  (ref) => HistoryNotifier(ref),
);
