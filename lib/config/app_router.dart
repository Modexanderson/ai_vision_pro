// config/app_router.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../screens/auth_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/history_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/premium_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/result_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/achievements_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/auth':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case '/camera':
        return MaterialPageRoute(builder: (_) => const CameraScreen());
      case '/result':
        return MaterialPageRoute(builder: (_) => const ResultScreen());
      case '/premium':
        return MaterialPageRoute(builder: (_) => const PremiumScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/history':
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/achievements':
        return MaterialPageRoute(builder: (_) => const AchievementsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Page Not Found'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Page Not Found',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No route defined for ${settings.name}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(_, '/home'),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

// Dependency Injection Setup
Future<void> configureDependencies() async {
  try {
    debugPrint('🔧 Configuring dependencies...');

    // Initialize Hive boxes for data persistence
    await Hive.openBox('user_data');
    await Hive.openBox('app_settings');
    await Hive.openBox('scan_history');
    await Hive.openBox('premium_status');
    await Hive.openBox('achievements');

    debugPrint('✅ Dependencies configured successfully');
  } catch (e) {
    debugPrint('❌ Failed to configure dependencies: $e');
    // App can continue without some dependencies
  }
}
