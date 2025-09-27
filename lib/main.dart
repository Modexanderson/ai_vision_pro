// main.dart

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
import 'models/auth_state.dart';
import 'providers/analytics_provider.dart';
import 'providers/history_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'providers/camera_provider.dart';
import 'providers/auth_provider.dart';

List<CameraDescription> cameras = [];
bool isFirebaseInitialized = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _initializeServices();
  _setupErrorHandling();

  runApp(
    ProviderScope(
      overrides: [
        cameraProvider.overrideWith((ref) => CameraNotifier(cameras)),
      ],
      child: const AIVisionProApp(),
    ),
  );
}

void _setupErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (isFirebaseInitialized) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
    ErrorHandler.logError(details.exception, details.stack);
  };

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

    await Hive.initFlutter();
    debugPrint('✅ Hive database initialized');

    try {
      await dotenv.load(fileName: ".env");
      debugPrint('✅ Environment variables loaded');
    } catch (e) {
      debugPrint('⚠️ No .env file found, using default configuration');
    }

    await _initializeFirebase();
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

    try {
      await MobileAds.instance.initialize();
      debugPrint('✅ Google Mobile Ads initialized');
    } catch (e) {
      debugPrint('⚠️ Failed to initialize Mobile Ads: $e');
    }

    await _initializeCameras();
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
  }
}

Future<void> _initializeFirebase() async {
  try {
    debugPrint('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
    debugPrint('✅ Firebase Core initialized successfully');
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
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    debugPrint('✅ Firebase Crashlytics initialized');
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    debugPrint('✅ Firebase Analytics initialized');
    await FirebaseAnalytics.instance.logEvent(
      name: 'app_initialized',
      parameters: <String, Object>{
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
    cameras = [];
  }
}

class AIVisionProApp extends ConsumerWidget {
  const AIVisionProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    return MaterialApp(
      title: 'AI Vision Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      navigatorObservers: isFirebaseInitialized
          ? [
              FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
            ]
          : [],
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

class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Initialize data loading after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppData();
    });
  }

  Future<void> _initializeAppData() async {
    try {
      debugPrint('🔄 Loading app data...');

      // Load analytics first
      await ref.read(analyticsProvider.notifier).refreshAnalytics();
      debugPrint('✅ Analytics loaded');

      // Load history (this will sync with analytics if needed)
      await ref.read(historyProvider.notifier).refreshHistory();
      debugPrint('✅ History loaded');

      if (mounted) {
        setState(() => _isDataLoaded = true);
        debugPrint('🎉 App data initialization complete!');
      }
    } catch (e) {
      debugPrint('❌ Error loading app data: $e');
      // Still mark as loaded to prevent infinite loading
      if (mounted) {
        setState(() => _isDataLoaded = true);
      }
    }
  }

  Future<void> _determineInitialRoute(AuthState authState) async {
    // Wait until auth initialization is complete (isLoading = false)
    if (authState.isLoading || !_isDataLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final bool hasCompletedOnboarding =
          prefs.getBool('onboarding_completed') ?? false;

      if (!hasCompletedOnboarding) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
          return;
        }
      }

      if (authState.isAuthenticated) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint('Error determining initial route: $e');
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
    return Consumer(
      builder: (context, ref, child) {
        // Listen to auth state changes here
        ref.listen<AuthState>(authProvider, (previous, next) {
          _determineInitialRoute(next);
        });

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                Text(
                  'AI Vision Pro',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isDataLoaded ? 'Loading...' : 'Initializing data...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ErrorHandler {
  static void logError(dynamic error, StackTrace? stackTrace) {
    debugPrint('🐛 Error: $error');
    if (stackTrace != null) {
      debugPrint('📍 Stack trace: $stackTrace');
    }
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
    if (isFirebaseInitialized) {
      FirebaseAnalytics.instance.logEvent(
        name: 'api_error',
        parameters: <String, Object>{
          'error_type': error.runtimeType.toString(),
          'error_message': message,
        },
      );
    }
  }

  static bool get isFirebaseAvailable => isFirebaseInitialized;

  static Future<void> logUserAction(String action,
      {Map<String, dynamic>? parameters}) async {
    if (isFirebaseInitialized) {
      await FirebaseAnalytics.instance.logEvent(
        name: action,
        parameters: parameters?.cast<String, Object>(),
      );
    }
  }
}
