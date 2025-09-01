// providers/challenge_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChallengeState {
  final String title;
  final String description;
  final int progress;
  final int total;
  final String reward;
  final bool isCompleted;

  ChallengeState({
    required this.title,
    required this.description,
    required this.progress,
    required this.total,
    required this.reward,
    this.isCompleted = false,
  });

  ChallengeState copyWith({
    String? title,
    String? description,
    int? progress,
    int? total,
    String? reward,
    bool? isCompleted,
  }) {
    return ChallengeState(
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      total: total ?? this.total,
      reward: reward ?? this.reward,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'progress': progress,
      'total': total,
      'reward': reward,
      'isCompleted': isCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // From Firestore map
  factory ChallengeState.fromMap(Map<String, dynamic> map) {
    return ChallengeState(
      title: map['title'] ?? "Today's Challenge",
      description:
          map['description'] ?? "Find and scan 3 different types of plants",
      progress: map['progress'] ?? 0,
      total: map['total'] ?? 3,
      reward: map['reward'] ?? "50 XP + Plant Expert Badge",
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class ChallengeNotifier extends StateNotifier<ChallengeState> {
  ChallengeNotifier()
      : super(ChallengeState(
          title: "Today's Challenge",
          description: "Find and scan 3 different types of plants",
          progress: 0,
          total: 3,
          reward: "50 XP + Plant Expert Badge",
        )) {
    _loadChallengeFromFirestore();
  }

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Load challenge state from Firestore (per user)
  Future<void> _loadChallengeFromFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('challenges')
          .doc('daily'); // Use 'daily' as document ID for daily challenge

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        state = ChallengeState.fromMap(docSnapshot.data()!);
      } else {
        // Create new if not exists
        await _saveToFirestore();
      }
    } catch (e) {
      debugPrint('Error loading challenge: $e');
    }
  }

  // Save challenge state to Firestore
  Future<void> _saveToFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('challenges')
          .doc('daily');

      await docRef.set(state.toMap());
    } catch (e) {
      debugPrint('Error saving challenge: $e');
    }
  }

  // Increment progress and save
  int incrementProgress() {
    if (state.progress < state.total && !state.isCompleted) {
      state = state.copyWith(progress: state.progress + 1);
      _saveToFirestore();
    }
    return state.progress;
  }

  // Complete the challenge and save
  void completeChallenge() {
    if (!state.isCompleted) {
      state = state.copyWith(isCompleted: true);
      _saveToFirestore();
      // Award XP/badge here (e.g., update user stats in Firestore)
      _awardRewards();
    }
  }

  // Reset challenge (e.g., for next day)
  void resetChallenge() {
    state = state.copyWith(progress: 0, isCompleted: false);
    _saveToFirestore();
  }

  // Placeholder for awarding rewards (expand as needed)
  void _awardRewards() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userRef = _firestore.collection('users').doc(user.uid);

      await userRef.update({
        'stats.xp': FieldValue.increment(50),
        'badges': FieldValue.arrayUnion(['Plant Expert Badge']),
      });
    } catch (e) {
      debugPrint('Error awarding rewards: $e');
    }
  }
}

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, ChallengeState>((ref) {
  return ChallengeNotifier();
});
