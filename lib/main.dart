import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:camera/camera.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'config/app_config.dart';
import 'config/app_router.dart';
import 'config/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'providers/camera_provider.dart';
import 'providers/auth_provider.dart';

List<CameraDescription> cameras = [];
bool isFirebaseInitialized = false;

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for better UX
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize essential services
  await _initializeServices();

  // Set up error handling with Firebase
  _setupErrorHandling();

  runApp(
    ProviderScope(
      overrides: [
        // Override camera provider with actual cameras
        cameraProvider.overrideWith((ref) => CameraNotifier(cameras)),
      ],
      child: const AIVisionProApp(),
    ),
  );
}

void _setupErrorHandling() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    if (isFirebaseInitialized) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
    ErrorHandler.logError(details.exception, details.stack);
  };

  // Handle errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    if (isFirebaseInitialized) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    ErrorHandler.logError(error, stack);
    return true;
  };
}

Future<void> _initializeServices() async {
  try {
    debugPrint('🚀 Starting AI Vision Pro initialization...');

    // Initialize Hive database (essential)
    await Hive.initFlutter();
    debugPrint('✅ Hive database initialized');

    // Load environment variables (optional)
    try {
      await dotenv.load(fileName: ".env");
      debugPrint('✅ Environment variables loaded');
    } catch (e) {
      debugPrint('⚠️ No .env file found, using default configuration');
    }

    // Initialize Firebase (with proper error handling)
    await _initializeFirebase();

    // Initialize In-App Purchases
    try {
      final InAppPurchase inAppPurchase = InAppPurchase.instance;
      final bool isAvailable = await inAppPurchase.isAvailable();
      if (isAvailable) {
        debugPrint('✅ In-App Purchases initialized');
      } else {
        debugPrint('⚠️ In-App Purchases not available');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to initialize In-App Purchases: $e');
    }

    // Initialize Mobile Ads (optional)
    try {
      await MobileAds.instance.initialize();
      debugPrint('✅ Google Mobile Ads initialized');
    } catch (e) {
      debugPrint('⚠️ Failed to initialize Mobile Ads: $e');
    }

    // Initialize cameras (essential for camera features)
    await _initializeCameras();

    // Initialize app configuration
    try {
      await AppConfig.initialize();
      debugPrint('✅ App configuration initialized');
    } catch (e) {
      debugPrint('⚠️ App config initialization failed: $e');
    }

    debugPrint('🎉 All services initialized successfully!');
  } catch (e, stackTrace) {
    debugPrint('❌ Critical error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    // App continues to run even with initialization errors
  }
}

Future<void> _initializeFirebase() async {
  try {
    debugPrint('🔥 Initializing Firebase...');

    // Initialize Firebase with options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    isFirebaseInitialized = true;
    debugPrint('✅ Firebase Core initialized successfully');

    // Initialize Firebase services
    await _initializeFirebaseServices();
  } catch (e) {
    isFirebaseInitialized = false;
    debugPrint('❌ Firebase initialization failed: $e');
    debugPrint('📋 To fix Firebase:');
    debugPrint('   1. Ensure google-services.json is in android/app/');
    debugPrint(
        '   2. Run: flutter packages pub run flutterfire_cli:flutterfire configure');
    debugPrint('   3. Or follow Firebase setup guide');
    debugPrint('   ℹ️  App will continue without Firebase features');
  }
}

Future<void> _initializeFirebaseServices() async {
  try {
    // Initialize Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    debugPrint('✅ Firebase Crashlytics initialized');

    // Initialize Analytics
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    debugPrint('✅ Firebase Analytics initialized');

    // Log successful Firebase setup
    await FirebaseAnalytics.instance.logEvent(
      name: 'app_initialized',
      parameters: <String, Object>{
        // Explicit type declaration
        'platform': 'flutter',
        'version': '1.0.0',
      },
    );
  } catch (e) {
    debugPrint('⚠️ Some Firebase services failed to initialize: $e');
  }
}

Future<void> _initializeCameras() async {
  try {
    cameras = await availableCameras();
    debugPrint('✅ Initialized ${cameras.length} camera(s)');

    if (cameras.isEmpty) {
      debugPrint('⚠️ No cameras found on device');
    } else {
      for (int i = 0; i < cameras.length; i++) {
        debugPrint(
            '   📸 Camera $i: ${cameras[i].name} (${cameras[i].lensDirection})');
      }
    }
  } catch (e) {
    debugPrint('❌ Failed to initialize cameras: $e');
    cameras = []; // Empty list if no cameras available
  }
}

class AIVisionProApp extends ConsumerWidget {
  const AIVisionProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AI Vision Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Add Firebase Analytics navigation observer if available
      navigatorObservers: isFirebaseInitialized
          ? [
              FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
            ]
          : [],

      // Use AppInitializer to determine initial route
      home: const AppInitializer(),
      onGenerateRoute: AppRouter.generateRoute,

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}

// New widget to handle initial navigation logic
class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user has completed onboarding
      final bool hasCompletedOnboarding =
          prefs.getBool('onboarding_completed') ?? false;

      if (!hasCompletedOnboarding) {
        // First time user - go to onboarding
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
          return;
        }
      }

      // Check authentication state
      final authState = ref.read(authProvider);

      if (authState.isAuthenticated) {
        // User is authenticated - go to home
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        }
      } else {
        // User needs to authenticate - go to auth screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint('Error determining initial route: $e');
      // Default to onboarding on error
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple loading screen while determining route
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.visibility_rounded,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 32),

            // App Title
            Text(
              'AI Vision Pro',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Loading indicator
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Error Handler with Firebase integration
class ErrorHandler {
  static void logError(dynamic error, StackTrace? stackTrace) {
    // Always log to console
    debugPrint('🐛 Error: $error');
    if (stackTrace != null) {
      debugPrint('📍 Stack trace: $stackTrace');
    }

    // Log to Firebase if available
    if (isFirebaseInitialized) {
      try {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: false,
          information: ['Error logged by ErrorHandler'],
        );
      } catch (e) {
        debugPrint('Failed to log error to Firebase: $e');
      }
    }
  }

  static void handleApiError(dynamic error) {
    String message = 'An unexpected error occurred';

    if (error.toString().contains('network')) {
      message = 'Network connection error';
    } else if (error.toString().contains('timeout')) {
      message = 'Request timeout';
    } else if (error.toString().contains('unauthorized')) {
      message = 'Authentication required';
    }

    logError(error, StackTrace.current);

    // Log custom event to Analytics
    if (isFirebaseInitialized) {
      FirebaseAnalytics.instance.logEvent(
        name: 'api_error',
        parameters: <String, Object>{
          // Explicit type declaration
          'error_type': error.runtimeType.toString(),
          'error_message': message,
        },
      );
    }
  }

  // Helper methods
  static bool get isFirebaseAvailable => isFirebaseInitialized;

  static Future<void> logUserAction(String action,
      {Map<String, dynamic>? parameters}) async {
    if (isFirebaseInitialized) {
      await FirebaseAnalytics.instance.logEvent(
        name: action,
        parameters:
            parameters?.cast<String, Object>(), // Cast to the correct type
      );
    }
  }
}
