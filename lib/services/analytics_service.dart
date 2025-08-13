// Analytics Service for Usage Tracking
import 'package:firebase_analytics/firebase_analytics.dart';

import '../utils/camera_mode.dart';

class AnalyticsService {
  void trackDetection(CameraMode mode, int objectCount) {
    FirebaseAnalytics.instance.logEvent(
      name: 'object_detection',
      parameters: {
        'mode': mode.toString(),
        'object_count': objectCount,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void trackPremiumUpgrade(String planType) {
    FirebaseAnalytics.instance.logEvent(
      name: 'premium_upgrade',
      parameters: {
        'plan_type': planType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  void trackFeatureUsage(String feature) {
    FirebaseAnalytics.instance.logEvent(
      name: 'feature_usage',
      parameters: {
        'feature': feature,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}
