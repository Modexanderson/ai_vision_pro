// providers/analytics_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/camera_mode.dart';

class AnalyticsState {
  final Map<String, int> detectionCounts;
  final List<String> recentSearches;
  final int totalDetections;
  final double averageConfidence;
  final DateTime? lastActivity;

  AnalyticsState({
    this.detectionCounts = const {},
    this.recentSearches = const [],
    this.totalDetections = 0,
    this.averageConfidence = 0.0,
    this.lastActivity,
  });

  AnalyticsState copyWith({
    Map<String, int>? detectionCounts,
    List<String>? recentSearches,
    int? totalDetections,
    double? averageConfidence,
    DateTime? lastActivity,
  }) {
    return AnalyticsState(
      detectionCounts: detectionCounts ?? this.detectionCounts,
      recentSearches: recentSearches ?? this.recentSearches,
      totalDetections: totalDetections ?? this.totalDetections,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(AnalyticsState());

  void trackResultView() {
    state = state.copyWith(
      lastActivity: DateTime.now(),
    );
  }

  void trackDetection(CameraMode mode, int objectCount) {
    final modeString = mode.name;
    final currentCounts = Map<String, int>.from(state.detectionCounts);
    currentCounts[modeString] = (currentCounts[modeString] ?? 0) + 1;

    state = state.copyWith(
      detectionCounts: currentCounts,
      totalDetections: state.totalDetections + objectCount,
      lastActivity: DateTime.now(),
    );
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
  }

  void updateAverageConfidence(double confidence) {
    // Simple moving average calculation
    final newAverage = (state.averageConfidence + confidence) / 2;
    state = state.copyWith(averageConfidence: newAverage);
  }

  void clearAnalytics() {
    state = AnalyticsState();
  }
}

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>(
  (ref) => AnalyticsNotifier(),
);
