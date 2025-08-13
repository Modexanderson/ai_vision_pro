// providers/history_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/detection_result.dart';
import '../models/detection_history.dart';

class HistoryNotifier extends StateNotifier<List<DetectionHistory>> {
  HistoryNotifier() : super([]) {
    _loadHistory();
  }

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
    } catch (e) {
      debugPrint('Error saving result: $e');
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
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<DetectionHistory>>(
  (ref) => HistoryNotifier(),
);
