
// Now learn from the following codes, i have in this my AI objected identifier app, i want to have some data that i would run a script to insert certain data to the users collection of this user account i have logged in firebase, so that i can showcase the entire app screenshot with data and items detected in app store screen shots perfectly (YOU CAN ALSO INCLUDE YOU IDEAS OF WHICH AND WHCH AREA WOULD BE BEST TO TAKE THE SCREENSHOTS & YOUR ADVICES ARE WELCOME) please write the script for me to include these data, thanks:

// // main.dart

// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:camera/camera.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'firebase_options.dart';
// import 'config/app_config.dart';
// import 'config/app_router.dart';
// import 'config/app_theme.dart';
// import 'models/auth_state.dart';
// import 'providers/analytics_provider.dart';
// import 'providers/history_provider.dart';
// import 'providers/theme_provider.dart';
// import 'screens/onboarding_screen.dart';
// import 'screens/auth_screen.dart';
// import 'screens/main_navigation_screen.dart';
// import 'providers/camera_provider.dart';
// import 'providers/auth_provider.dart';
// import 'services/auto_save_service.dart';
// import 'services/image_quality_manager.dart';
// import 'services/push_notification_service.dart';
// import 'utils/haptic_feedback.dart';
// import 'utils/sound_manager.dart';

// List<CameraDescription> cameras = [];
// bool isFirebaseInitialized = false;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   await _initializeServices();
//   _setupErrorHandling();

//   runApp(
//     ProviderScope(
//       overrides: [
//         cameraProvider.overrideWith((ref) => CameraNotifier(ref, cameras)),
//       ],
//       child: const AIVisionProApp(),
//     ),
//   );
// }

// void _setupErrorHandling() {
//   FlutterError.onError = (FlutterErrorDetails details) {
//     if (isFirebaseInitialized) {
//       FirebaseCrashlytics.instance.recordFlutterFatalError(details);
//     }
//     ErrorHandler.logError(details.exception, details.stack);
//   };

//   PlatformDispatcher.instance.onError = (error, stack) {
//     if (isFirebaseInitialized) {
//       FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
//     }
//     ErrorHandler.logError(error, stack);
//     return true;
//   };
// }

// Future<void> _initializeServices() async {
//   try {
//     debugPrint('🚀 Starting AI Vision Pro initialization...');

//     await Hive.initFlutter();
//     debugPrint('✅ Hive database initialized');

//     try {
//       await dotenv.load(fileName: ".env");
//       debugPrint('✅ Environment variables loaded');
//     } catch (e) {
//       debugPrint('⚠️ No .env file found, using default configuration');
//     }

//     await _initializeFirebase();
//     try {
//       final InAppPurchase inAppPurchase = InAppPurchase.instance;
//       final bool isAvailable = await inAppPurchase.isAvailable();
//       if (isAvailable) {
//         debugPrint('✅ In-App Purchases initialized');
//       } else {
//         debugPrint('⚠️ In-App Purchases not available');
//       }
//     } catch (e) {
//       debugPrint('⚠️ Failed to initialize In-App Purchases: $e');
//     }

//     try {
//       await MobileAds.instance.initialize();
//       debugPrint('✅ Google Mobile Ads initialized');
//     } catch (e) {
//       debugPrint('⚠️ Failed to initialize Mobile Ads: $e');
//     }

//     await _initializeCameras();
//     try {
//       await AppConfig.initialize();
//       debugPrint('✅ App configuration initialized');
//     } catch (e) {
//       debugPrint('⚠️ App config initialization failed: $e');
//     }

//     // Initialize new services
//     await PushNotificationService().initialize();
//     await SoundManager().initialize();
//     await HapticFeedbackUtil().initialize();
//     await ImageQualityManager().initialize();
//     await AutoSaveService().initialize();
//     // await LanguageService().initialize();

//     debugPrint('🎉 All services initialized successfully!');
//   } catch (e, stackTrace) {
//     debugPrint('❌ Critical error during initialization: $e');
//     debugPrint('Stack trace: $stackTrace');
//   }
// }

// Future<void> _initializeFirebase() async {
//   try {
//     debugPrint('🔥 Initializing Firebase...');
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     isFirebaseInitialized = true;
//     debugPrint('✅ Firebase Core initialized successfully');
//     await _initializeFirebaseServices();
//   } catch (e) {
//     isFirebaseInitialized = false;
//     debugPrint('❌ Firebase initialization failed: $e');
//     debugPrint('📋 To fix Firebase:');
//     debugPrint('   1. Ensure google-services.json is in android/app/');
//     debugPrint(
//         '   2. Run: flutter packages pub run flutterfire_cli:flutterfire configure');
//     debugPrint('   3. Or follow Firebase setup guide');
//     debugPrint('   ℹ️  App will continue without Firebase features');
//   }
// }

// Future<void> _initializeFirebaseServices() async {
//   try {
//     await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
//     debugPrint('✅ Firebase Crashlytics initialized');
//     await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
//     debugPrint('✅ Firebase Analytics initialized');
//     await FirebaseAnalytics.instance.logEvent(
//       name: 'app_initialized',
//       parameters: <String, Object>{
//         'platform': 'flutter',
//         'version': '1.0.0',
//       },
//     );
//   } catch (e) {
//     debugPrint('⚠️ Some Firebase services failed to initialize: $e');
//   }
// }

// Future<void> _initializeCameras() async {
//   try {
//     cameras = await availableCameras();
//     debugPrint('✅ Initialized ${cameras.length} camera(s)');
//     if (cameras.isEmpty) {
//       debugPrint('⚠️ No cameras found on device');
//     } else {
//       for (int i = 0; i < cameras.length; i++) {
//         debugPrint(
//             '   📸 Camera $i: ${cameras[i].name} (${cameras[i].lensDirection})');
//       }
//     }
//   } catch (e) {
//     debugPrint('❌ Failed to initialize cameras: $e');
//     cameras = [];
//   }
// }

// class AIVisionProApp extends ConsumerWidget {
//   const AIVisionProApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final themeMode = ref.watch(themeNotifierProvider);
//     return MaterialApp(
//       title: 'AI Vision Pro',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: themeMode,
//       navigatorObservers: isFirebaseInitialized
//           ? [
//               FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
//             ]
//           : [],
//       home: const AppInitializer(),
//       onGenerateRoute: AppRouter.generateRoute,
//       builder: (context, child) {
//         return MediaQuery(
//           data: MediaQuery.of(context).copyWith(
//             textScaler: const TextScaler.linear(1.0),
//           ),
//           child: child!,
//         );
//       },
//     );
//   }
// }

// class AppInitializer extends ConsumerStatefulWidget {
//   const AppInitializer({super.key});

//   @override
//   _AppInitializerState createState() => _AppInitializerState();
// }

// class _AppInitializerState extends ConsumerState<AppInitializer> {
//   bool _isDataLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize data loading after the first frame
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeAppData();
//     });
//   }

//   Future<void> _initializeAppData() async {
//     try {
//       debugPrint('🔄 Loading app data...');

//       // Load analytics first
//       await ref.read(analyticsProvider.notifier).refreshAnalytics();
//       debugPrint('✅ Analytics loaded');

//       // Load history (this will sync with analytics if needed)
//       await ref.read(historyProvider.notifier).refreshHistory();
//       debugPrint('✅ History loaded');

//       if (mounted) {
//         setState(() => _isDataLoaded = true);
//         debugPrint('🎉 App data initialization complete!');
//       }
//     } catch (e) {
//       debugPrint('❌ Error loading app data: $e');
//       // Still mark as loaded to prevent infinite loading
//       if (mounted) {
//         setState(() => _isDataLoaded = true);
//       }
//     }
//   }

//   Future<void> _determineInitialRoute(AuthState authState) async {
//     // Wait until auth initialization is complete (isLoading = false)
//     if (authState.isLoading || !_isDataLoaded) return;

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final bool hasCompletedOnboarding =
//           prefs.getBool('onboarding_completed') ?? false;

//       if (!hasCompletedOnboarding) {
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const OnboardingScreen()),
//           );
//           return;
//         }
//       }

//       if (authState.isAuthenticated) {
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
//           );
//         }
//       } else {
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const AuthScreen()),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Error determining initial route: $e');
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const OnboardingScreen()),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, child) {
//         // Listen to auth state changes here
//         ref.listen<AuthState>(authProvider, (previous, next) {
//           _determineInitialRoute(next);
//         });

//         return Scaffold(
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(25),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 20,
//                         spreadRadius: 5,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.visibility_rounded,
//                     size: 50,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 Text(
//                   'AI Vision Pro',
//                   style: Theme.of(context).textTheme.displaySmall?.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 const SizedBox(height: 16),
//                 const SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 3,
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   _isDataLoaded ? 'Loading...' : 'Initializing data...',
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


// // Analytics Service for Usage Tracking
// import 'package:firebase_analytics/firebase_analytics.dart';

// import '../utils/camera_mode.dart';

// class AnalyticsService {
//   void trackDetection(CameraMode mode, int objectCount) {
//     FirebaseAnalytics.instance.logEvent(
//       name: 'object_detection',
//       parameters: {
//         'mode': mode.toString(),
//         'object_count': objectCount,
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//       },
//     );
//   }

//   void trackPremiumUpgrade(String planType) {
//     FirebaseAnalytics.instance.logEvent(
//       name: 'premium_upgrade',
//       parameters: {
//         'plan_type': planType,
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//       },
//     );
//   }

//   void trackFeatureUsage(String feature) {
//     FirebaseAnalytics.instance.logEvent(
//       name: 'feature_usage',
//       parameters: {
//         'feature': feature,
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//       },
//     );
//   }
// }


// // services/api_service.dart

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import '../models/detection_result.dart';

// class ApiService {
//   final String? _openAiApiKey = dotenv.env['OPENAI_API_KEY'];
//   final String _baseUrl = 'https://api.openai.com/v1';

//   // HTTP client for API calls
//   final http.Client _client = http.Client();

//   // Constructor with logging to help diagnose issues
//   ApiService() {
//     if (_openAiApiKey == null) {
//       debugPrint('Warning: OPENAI_API_KEY not found in environment variables');
//     }
//   }

//   // Get a short description of the detected object
//   Future<String> getObjectDescription(String objectName) async {
//     if (_openAiApiKey == null) {
//       return "Brief description not available.";
//     }

//     try {
//       final response = await _client.post(
//         Uri.parse('$_baseUrl/chat/completions'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $_openAiApiKey',
//         },
//         body: jsonEncode({
//           'model': 'gpt-4',
//           'messages': [
//             {
//               'role': 'system',
//               'content':
//                   'You are a helpful assistant that provides brief, accurate descriptions.'
//             },
//             {
//               'role': 'user',
//               'content':
//                   'Provide a concise 1-2 sentence description of a $objectName. Be factual and informative.'
//             }
//           ],
//           'max_tokens': 100,
//           'temperature': 0.7,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['choices'][0]['message']['content'].trim();
//       } else {
//         return "Description unavailable right now.";
//       }
//     } catch (e) {
//       debugPrint('API error: $e');
//       return "Unable to fetch description.";
//     }
//   }

//   // Get a fun fact about the detected object
//   Future<String> getObjectFunFact(String objectName) async {
//     if (_openAiApiKey == null) {
//       return "Fun fact not available.";
//     }

//     try {
//       final response = await _client.post(
//         Uri.parse('$_baseUrl/chat/completions'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $_openAiApiKey',
//         },
//         body: jsonEncode({
//           'model': 'gpt-4',
//           'messages': [
//             {
//               'role': 'system',
//               'content':
//                   'You are a helpful assistant that provides interesting facts.'
//             },
//             {
//               'role': 'user',
//               'content':
//                   'Tell me a surprising or interesting fun fact about $objectName in 1-2 sentences.'
//             }
//           ],
//           'max_tokens': 100,
//           'temperature': 0.8,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['choices'][0]['message']['content'].trim();
//       } else {
//         return "Fun fact unavailable right now.";
//       }
//     } catch (e) {
//       debugPrint('API error: $e');
//       return "Unable to fetch fun fact.";
//     }
//   }

//   // Get estimated price of the detected object
//   Future<double?> getEstimatedPrice(String objectName) async {
//     if (_openAiApiKey == null) {
//       return null;
//     }

//     try {
//       final response = await _client.post(
//         Uri.parse('$_baseUrl/chat/completions'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $_openAiApiKey',
//         },
//         body: jsonEncode({
//           'model': 'gpt-4',
//           'messages': [
//             {
//               'role': 'system',
//               'content':
//                   'You are a helpful assistant that provides rough price estimates for common objects. Respond only with a number representing the average price in USD without any currency symbol or explanation.'
//             },
//             {
//               'role': 'user',
//               'content':
//                   'What is the approximate average price of a typical $objectName in USD? Respond only with a number.'
//             }
//           ],
//           'max_tokens': 20,
//           'temperature': 0.3,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final responseText = data['choices'][0]['message']['content'].trim();

//         // Extract the number from the response
//         final numberRegExp = RegExp(r'\d+(\.\d+)?');
//         final match = numberRegExp.firstMatch(responseText);
//         if (match != null) {
//           return double.tryParse(match.group(0)!);
//         } else {
//           return null;
//         }
//       } else {
//         return null;
//       }
//     } catch (e) {
//       debugPrint('API error: $e');
//       return null;
//     }
//   }

//   // NEW METHOD: Perform deep analysis on detection results
//   Future<String> performDeepAnalysis(DetectionResult result) async {
//     if (_openAiApiKey == null) {
//       return "Deep analysis not available.";
//     }

//     try {
//       // Create a summary of detected objects
//       final objectSummary = result.objects
//           .map((obj) =>
//               '${obj.label} (${(obj.confidence * 100).toStringAsFixed(1)}% confidence)')
//           .join(', ');

//       final response = await _client.post(
//         Uri.parse('$_baseUrl/chat/completions'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $_openAiApiKey',
//         },
//         body: jsonEncode({
//           'model': 'gpt-4',
//           'messages': [
//             {
//               'role': 'system',
//               'content':
//                   'You are an expert image analyst. Provide insightful analysis about images based on detected objects. Be comprehensive but concise.'
//             },
//             {
//               'role': 'user',
//               'content':
//                   'I have an image containing these detected objects: $objectSummary. '
//                       'Perform a deep analysis including: '
//                       '1. What this scene likely represents '
//                       '2. Interesting relationships between objects '
//                       '3. Possible context or setting '
//                       '4. Any notable patterns or insights '
//                       'Keep it informative but engaging.'
//             }
//           ],
//           'max_tokens': 300,
//           'temperature': 0.7,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['choices'][0]['message']['content'].trim();
//       } else {
//         return "Deep analysis unavailable right now.";
//       }
//     } catch (e) {
//       debugPrint('API error: $e');
//       return "Unable to perform deep analysis.";
//     }
//   }

//   // Get translations for the object name
//   Future<Map<String, String>> getTranslations(
//       String objectName, List<String> languages) async {
//     if (_openAiApiKey == null) {
//       return {};
//     }

//     try {
//       final languagesList = languages.join(', ');
//       final response = await _client.post(
//         Uri.parse('$_baseUrl/chat/completions'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $_openAiApiKey',
//         },
//         body: jsonEncode({
//           'model': 'gpt-4',
//           'messages': [
//             {
//               'role': 'system',
//               'content':
//                   'You are a helpful translator assistant that provides accurate translations. Respond with only a JSON object where the keys are language codes and values are translations.'
//             },
//             {
//               'role': 'user',
//               'content':
//                   'Translate the word "$objectName" into these languages: $languagesList. Respond with a JSON object only.'
//             }
//           ],
//           'max_tokens': 200,
//           'temperature': 0.3,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final responseText = data['choices'][0]['message']['content'].trim();

//         // Extract JSON from the response
//         final jsonRegExp = RegExp(r'\{.*\}', dotAll: true);
//         final match = jsonRegExp.firstMatch(responseText);
//         if (match != null) {
//           final jsonStr = match.group(0)!;
//           final Map<String, dynamic> decodedJson = jsonDecode(jsonStr);
//           return decodedJson
//               .map((key, value) => MapEntry(key, value.toString()));
//         } else {
//           return {};
//         }
//       } else {
//         return {};
//       }
//     } catch (e) {
//       debugPrint('API error: $e');
//       return {};
//     }
//   }

//   void dispose() {
//     _client.close();
//   }
// }


// // services/cloud_vision_service.dart - COMPLETE IMPLEMENTATION

// import 'dart:convert';
// import 'dart:io';
// import 'dart:math' as math;

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// import '../models/detected_object.dart';

// class CloudVisionService {
//   final Dio _dio = Dio();
//   final String _baseUrl = 'https://vision.googleapis.com/v1';
//   final String? _apiKey = dotenv.env['GOOGLE_CLOUD_API_KEY'];

//   // Plant identification API (PlantNet)
//   final String _plantNetUrl = 'https://my-api.plantnet.org/v2/identify';
//   final String? _plantNetApiKey = dotenv.env['PLANTNET_API_KEY'];

//   // Food analysis API (Spoonacular or similar)
//   final String _foodApiUrl = 'https://api.spoonacular.com/food/images/analyze';
//   final String? _foodApiKey = dotenv.env['SPOONACULAR_API_KEY'];

//   CloudVisionService() {
//     // Configure Dio with timeout and error handling
//     _dio.options.connectTimeout = const Duration(seconds: 30);
//     _dio.options.receiveTimeout = const Duration(seconds: 30);
//     _dio.options.sendTimeout = const Duration(seconds: 30);

//     // Add error interceptor
//     _dio.interceptors.add(InterceptorsWrapper(
//       onError: (error, handler) {
//         debugPrint('CloudVisionService API Error: ${error.message}');
//         handler.next(error);
//       },
//     ));
//   }

//   Future<List<DetectedObject>> detectObjects(File imageFile) async {
//     if (_apiKey == null) {
//       throw Exception('Google Cloud Vision API key not configured');
//     }

//     try {
//       final base64Image = base64Encode(await imageFile.readAsBytes());

//       final response = await _dio.post(
//         '$_baseUrl/images:annotate?key=$_apiKey',
//         data: {
//           'requests': [
//             {
//               'image': {'content': base64Image},
//               'features': [
//                 {'type': 'OBJECT_LOCALIZATION', 'maxResults': 20},
//                 {'type': 'LABEL_DETECTION', 'maxResults': 20},
//               ],
//             },
//           ],
//         },
//       );

//       return _parseCloudVisionResponse(response.data);
//     } catch (e) {
//       debugPrint('Object detection error: $e');
//       throw Exception('Failed to detect objects: ${e.toString()}');
//     }
//   }

//   Future<List<DetectedObject>> recognizeLandmarks(File imageFile) async {
//     if (_apiKey == null) {
//       throw Exception('Google Cloud Vision API key not configured');
//     }

//     try {
//       final base64Image = base64Encode(await imageFile.readAsBytes());

//       final response = await _dio.post(
//         '$_baseUrl/images:annotate?key=$_apiKey',
//         data: {
//           'requests': [
//             {
//               'image': {'content': base64Image},
//               'features': [
//                 {'type': 'LANDMARK_DETECTION', 'maxResults': 10},
//               ],
//             },
//           ],
//         },
//       );

//       return _parseLandmarkResponse(response.data);
//     } catch (e) {
//       debugPrint('Landmark recognition error: $e');
//       throw Exception('Failed to recognize landmarks: ${e.toString()}');
//     }
//   }

//   Future<List<DetectedObject>> identifyPlants(File imageFile) async {
//     if (_plantNetApiKey == null) {
//       // Fallback: Use Google Vision with plant-specific filtering
//       return await _identifyPlantsWithGoogleVision(imageFile);
//     }

//     try {
//       final bytes = await imageFile.readAsBytes();
//       final base64Image = base64Encode(bytes);

//       final formData = FormData.fromMap({
//         'images': MultipartFile.fromBytes(
//           bytes,
//           filename: 'plant_image.jpg',
//         ),
//         'modifiers': '["crops","similar_images"]',
//         'plant_details': '["common_names","url"]',
//       });

//       final response = await _dio.post(
//         '$_plantNetUrl/weurope?api-key=$_plantNetApiKey',
//         data: formData,
//         options: Options(
//           headers: {
//             'Content-Type': 'multipart/form-data',
//           },
//         ),
//       );

//       return _parsePlantNetResponse(response.data);
//     } catch (e) {
//       debugPrint('Plant identification error: $e');
//       // Fallback to Google Vision
//       return await _identifyPlantsWithGoogleVision(imageFile);
//     }
//   }

//   Future<List<DetectedObject>> _identifyPlantsWithGoogleVision(
//       File imageFile) async {
//     if (_apiKey == null) {
//       throw Exception('Google Cloud Vision API key not configured');
//     }

//     try {
//       final base64Image = base64Encode(await imageFile.readAsBytes());

//       final response = await _dio.post(
//         '$_baseUrl/images:annotate?key=$_apiKey',
//         data: {
//           'requests': [
//             {
//               'image': {'content': base64Image},
//               'features': [
//                 {'type': 'LABEL_DETECTION', 'maxResults': 30},
//               ],
//             },
//           ],
//         },
//       );

//       return _filterPlantLabels(response.data);
//     } catch (e) {
//       debugPrint('Plant identification with Google Vision error: $e');
//       throw Exception('Failed to identify plants: ${e.toString()}');
//     }
//   }

//   Future<List<DetectedObject>> recognizeAnimals(File imageFile) async {
//     if (_apiKey == null) {
//       throw Exception('Google Cloud Vision API key not configured');
//     }

//     try {
//       final base64Image = base64Encode(await imageFile.readAsBytes());

//       final response = await _dio.post(
//         '$_baseUrl/images:annotate?key=$_apiKey',
//         data: {
//           'requests': [
//             {
//               'image': {'content': base64Image},
//               'features': [
//                 {'type': 'LABEL_DETECTION', 'maxResults': 30},
//                 {'type': 'OBJECT_LOCALIZATION', 'maxResults': 10},
//               ],
//             },
//           ],
//         },
//       );

//       return _filterAnimalLabels(response.data);
//     } catch (e) {
//       debugPrint('Animal recognition error: $e');
//       throw Exception('Failed to recognize animals: ${e.toString()}');
//     }
//   }

//   Future<List<DetectedObject>> analyzeFood(File imageFile) async {
//     // Try Spoonacular API first, fallback to Google Vision
//     if (_foodApiKey != null) {
//       try {
//         return await _analyzeFoodWithSpoonacular(imageFile);
//       } catch (e) {
//         debugPrint('Spoonacular API failed, falling back to Google Vision: $e');
//       }
//     }

//     return await _analyzeFoodWithGoogleVision(imageFile);
//   }

//   Future<List<DetectedObject>> _analyzeFoodWithSpoonacular(
//       File imageFile) async {
//     try {
//       final bytes = await imageFile.readAsBytes();

//       final formData = FormData.fromMap({
//         'file': MultipartFile.fromBytes(
//           bytes,
//           filename: 'food_image.jpg',
//         ),
//       });

//       final response = await _dio.post(
//         '$_foodApiUrl?apiKey=$_foodApiKey',
//         data: formData,
//         options: Options(
//           headers: {
//             'Content-Type': 'multipart/form-data',
//           },
//         ),
//       );

//       return _parseSpoonacularResponse(response.data);
//     } catch (e) {
//       debugPrint('Spoonacular food analysis error: $e');
//       rethrow;
//     }
//   }

//   Future<List<DetectedObject>> _analyzeFoodWithGoogleVision(
//       File imageFile) async {
//     if (_apiKey == null) {
//       throw Exception('Google Cloud Vision API key not configured');
//     }

//     try {
//       final base64Image = base64Encode(await imageFile.readAsBytes());

//       final response = await _dio.post(
//         '$_baseUrl/images:annotate?key=$_apiKey',
//         data: {
//           'requests': [
//             {
//               'image': {'content': base64Image},
//               'features': [
//                 {'type': 'LABEL_DETECTION', 'maxResults': 30},
//                 {'type': 'LOGO_DETECTION', 'maxResults': 10},
//               ],
//             },
//           ],
//         },
//       );

//       return _filterFoodLabels(response.data);
//     } catch (e) {
//       debugPrint('Food analysis with Google Vision error: $e');
//       throw Exception('Failed to analyze food: ${e.toString()}');
//     }
//   }

//   Future<List<DetectedObject>> processDocuments(File imageFile) async {
//     if (_apiKey == null) {
//       throw Exception('Google Cloud Vision API key not configured');
//     }

//     try {
//       final base64Image = base64Encode(await imageFile.readAsBytes());

//       final response = await _dio.post(
//         '$_baseUrl/images:annotate?key=$_apiKey',
//         data: {
//           'requests': [
//             {
//               'image': {'content': base64Image},
//               'features': [
//                 {'type': 'DOCUMENT_TEXT_DETECTION', 'maxResults': 1},
//               ],
//             },
//           ],
//         },
//       );

//       return _parseDocumentResponse(response.data);
//     } catch (e) {
//       debugPrint('Document processing error: $e');
//       throw Exception('Failed to process document: ${e.toString()}');
//     }
//   }

//   // ============================================================================
//   // RESPONSE PARSERS
//   // ============================================================================

//   List<DetectedObject> _parseCloudVisionResponse(
//       Map<String, dynamic> response) {
//     final objects = <DetectedObject>[];

//     try {
//       // Parse object localization
//       final objectAnnotations =
//           response['responses'][0]['localizedObjectAnnotations'] as List?;
//       if (objectAnnotations != null) {
//         for (final annotation in objectAnnotations) {
//           final boundingPoly =
//               annotation['boundingPoly']['normalizedVertices'] as List;
//           final rect = _convertBoundingPoly(boundingPoly);

//           objects.add(DetectedObject(
//             id: const Uuid().v4(),
//             label: annotation['name'],
//             confidence: annotation['score'].toDouble(),
//             boundingBox: rect,
//             type: 'object',
//           ));
//         }
//       }

//       // Parse label detection
//       final labelAnnotations =
//           response['responses'][0]['labelAnnotations'] as List?;
//       if (labelAnnotations != null) {
//         for (final annotation in labelAnnotations.take(10)) {
//           objects.add(DetectedObject(
//             id: const Uuid().v4(),
//             label: annotation['description'],
//             confidence: annotation['score'].toDouble(),
//             boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
//             type: 'label',
//           ));
//         }
//       }
//     } catch (e) {
//       debugPrint('Error parsing Cloud Vision response: $e');
//     }

//     return objects;
//   }

//   List<DetectedObject> _parseLandmarkResponse(Map<String, dynamic> response) {
//     final objects = <DetectedObject>[];

//     try {
//       final annotations =
//           response['responses'][0]['landmarkAnnotations'] as List?;
//       if (annotations != null) {
//         for (final annotation in annotations) {
//           final locations = annotation['locations'] as List?;
//           String? locationInfo;

//           if (locations != null && locations.isNotEmpty) {
//             final latLng = locations[0]['latLng'];
//             locationInfo =
//                 'Lat: ${latLng['latitude']}, Lng: ${latLng['longitude']}';
//           }

//           objects.add(DetectedObject(
//             id: const Uuid().v4(),
//             label: annotation['description'],
//             confidence: annotation['score']?.toDouble() ?? 0.9,
//             boundingBox:
//                 _getBoundingBoxFromVertices(annotation['boundingPoly']),
//             type: 'landmark',
//             description: locationInfo,
//           ));
//         }
//       }
//     } catch (e) {
//       debugPrint('Error parsing landmark response: $e');
//     }

//     return objects;
//   }

//   List<DetectedObject> _parsePlantNetResponse(Map<String, dynamic> response) {
//     final objects = <DetectedObject>[];

//     try {
//       final results = response['results'] as List?;
//       if (results != null) {
//         for (final result in results.take(5)) {
//           final species = result['species'];
//           final commonNames = species['commonNames'] as List?;
//           final commonName =
//               commonNames?.isNotEmpty == true ? commonNames!.first : '';

//           objects.add(DetectedObject(
//             id: const Uuid().v4(),
//             label: species['scientificNameWithoutAuthor'] ?? 'Unknown Plant',
//             confidence: result['score']?.toDouble() ?? 0.0,
//             boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
//             type: 'plant',
//             description:
//                 commonName.isNotEmpty ? 'Common name: $commonName' : null,
//           ));
//         }
//       }
//     } catch (e) {
//       debugPrint('Error parsing PlantNet response: $e');
//     }

//     return objects;
//   }

//   List<DetectedObject> _parseSpoonacularResponse(
//       Map<String, dynamic> response) {
//     final objects = <DetectedObject>[];

//     try {
//       final category = response['category'];
//       final nutrition = response['nutrition'];

//       if (category != null) {
//         String description = '';
//         if (nutrition != null) {
//           final calories = nutrition['calories'];
//           final carbs = nutrition['carbs'];
//           final fat = nutrition['fat'];
//           final protein = nutrition['protein'];

//           description =
//               'Calories: ${calories ?? 'N/A'}, Carbs: ${carbs ?? 'N/A'}, Fat: ${fat ?? 'N/A'}, Protein: ${protein ?? 'N/A'}';
//         }

//         objects.add(DetectedObject(
//           id: const Uuid().v4(),
//           label: category['name'] ?? 'Food Item',
//           confidence: category['probability']?.toDouble() ?? 0.8,
//           boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
//           type: 'food',
//           description: description.isNotEmpty ? description : null,
//         ));
//       }
//     } catch (e) {
//       debugPrint('Error parsing Spoonacular response: $e');
//     }

//     return objects;
//   }

//   List<DetectedObject> _parseDocumentResponse(Map<String, dynamic> response) {
//     final objects = <DetectedObject>[];

//     try {
//       final textAnnotations =
//           response['responses'][0]['textAnnotations'] as List?;
//       if (textAnnotations != null && textAnnotations.isNotEmpty) {
//         final fullText = textAnnotations[0]['description'] as String;

//         objects.add(DetectedObject(
//           id: const Uuid().v4(),
//           label: fullText.length > 100
//               ? '${fullText.substring(0, 100)}...'
//               : fullText,
//           confidence: 0.95,
//           boundingBox:
//               _getBoundingBoxFromVertices(textAnnotations[0]['boundingPoly']),
//           type: 'document',
//           rawValue: fullText,
//           description: 'Full document text extracted',
//         ));
//       }

//       // Also parse individual text blocks for better granularity
//       final fullTextAnnotation = response['responses'][0]['fullTextAnnotation'];
//       if (fullTextAnnotation != null) {
//         final pages = fullTextAnnotation['pages'] as List?;
//         if (pages != null) {
//           for (final page in pages) {
//             final blocks = page['blocks'] as List?;
//             if (blocks != null) {
//               for (final block in blocks.take(10)) {
//                 // Limit to avoid too many objects
//                 final paragraphs = block['paragraphs'] as List?;
//                 if (paragraphs != null) {
//                   for (final paragraph in paragraphs) {
//                     final words = paragraph['words'] as List?;
//                     if (words != null) {
//                       final text = words.map((word) {
//                         final symbols = word['symbols'] as List;
//                         return symbols.map((symbol) => symbol['text']).join();
//                       }).join(' ');

//                       if (text.trim().isNotEmpty && text.length > 3) {
//                         objects.add(DetectedObject(
//                           id: const Uuid().v4(),
//                           label: text.length > 50
//                               ? '${text.substring(0, 50)}...'
//                               : text,
//                           confidence: 0.9,
//                           boundingBox: _getBoundingBoxFromVertices(
//                               paragraph['boundingBox']),
//                           type: 'text_block',
//                           rawValue: text,
//                         ));
//                       }
//                     }
//                   }
//                 }
//               }
//             }
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('Error parsing document response: $e');
//     }

//     return objects;
//   }

//   // ============================================================================
//   // LABEL FILTERS
//   // ============================================================================

//   List<DetectedObject> _filterPlantLabels(Map<String, dynamic> response) {
//     final objects = <DetectedObject>[];
//     final plantKeywords = [
//       'plant',
//       'flower',
//       'tree',
//       'leaf',
//       'petal',
//       'stem',
//       'branch',
//       'root',
//       'grass',
//       'herb',
//       'shrub',
//       'fern',
//       'moss',
//       'vine',
//       'cactus',
//       'succulent',
//       'orchid',
//       'rose',
//       'tulip',
//       'daisy',
//       'sunflower',
//       'lily',
//       'vegetation',
//       'foliage',
//       'botanical',
//       'flora',
//       'bloom',
//       'blossom',
//       'garden'
//     ];

//     try {
//       final annotations = response['responses'][0]['labelAnnotations'] as List?;
//       if (annotations != null) {
//         for (final annotation in annotations) {
//           final description =
//               annotation['description'].toString().toLowerCase();
//           if (plantKeywords.any((keyword) => description.contains(keyword))) {
//             objects.add(DetectedObject(
//               id: const Uuid().v4(),
//               label: annotation['description'],
//               confidence: annotation['score'].toDouble(),
//               boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
//               type: 'plant',
//             ));
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('Error filtering plant labels: $e');
//     }

//     return objects;
//   }

//   List<DetectedObject> _filterAnimalLabels(Map<String, dynamic> response) {
//     final objects = <DetectedObject>[];
//     final animalKeywords = [
//       'dog',
//       'cat',
//       'bird',
//       'fish',
//       'horse',
//       'cow',
//       'pig',
//       'sheep',
//       'goat',
//       'chicken',
//       'duck',
//       'rabbit',
//       'hamster',
//       'mouse',
//       'rat',
//       'elephant',
//       'lion',
//       'tiger',
//       'bear',
//       'deer',
//       'fox',
//       'wolf',
//       'monkey',
//       'ape',
//       'animal',
//       'mammal',
//       'reptile',
//       'amphibian',
//       'insect',
//       'butterfly',
//       'bee',
//       'spider',
//       'snake',
//       'lizard',
//       'turtle',
//       'frog',
//       'pet',
//       'wildlife'
//     ];

//     try {
//       final annotations = response['responses'][0]['labelAnnotations'] as List?;
//       if (annotations != null) {
//         for (final annotation in annotations) {
//           final description =
//               annotation['description'].toString().toLowerCase();
//           if (animalKeywords.any((keyword) => description.contains(keyword))) {
//             objects.add(DetectedObject(
//               id: const Uuid().v4(),
//               label: annotation['description'],
//               confidence: annotation['score'].toDouble(),
//               boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
//               type: 'animal',
//             ));
//           }
//         }
//       }

//       // Also check object localization for animals
//       final objectAnnotations =
//           response['responses'][0]['localizedObjectAnnotations'] as List?;
//       if (objectAnnotations != null) {
//         for (final annotation in objectAnnotations) {
//           final name = annotation['name'].toString().toLowerCase();
//           if (animalKeywords.any((keyword) => name.contains(keyword))) {
//             objects.add(DetectedObject(
//               id: const Uuid().v4(),
//               label: annotation['name'],
//               confidence: annotation['score'].toDouble(),
//               boundingBox: _convertBoundingPoly(
//                   annotation['boundingPoly']['normalizedVertices']),
//               type: 'animal',
//             ));
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('Error filtering animal labels: $e');
//     }

//     return objects;
//   }

//   List<DetectedObject> _filterFoodLabels(Map<String, dynamic> response) {
//     final objects = <DetectedObject>[];
//     final foodKeywords = [
//       'food',
//       'meal',
//       'dish',
//       'cuisine',
//       'recipe',
//       'cooking',
//       'restaurant',
//       'pizza',
//       'burger',
//       'sandwich',
//       'salad',
//       'soup',
//       'pasta',
//       'rice',
//       'bread',
//       'cake',
//       'cookie',
//       'fruit',
//       'vegetable',
//       'meat',
//       'chicken',
//       'beef',
//       'pork',
//       'fish',
//       'seafood',
//       'cheese',
//       'milk',
//       'coffee',
//       'tea',
//       'drink',
//       'beverage',
//       'juice',
//       'wine',
//       'beer',
//       'dessert',
//       'snack',
//       'breakfast',
//       'lunch',
//       'dinner',
//       'appetizer',
//       'fast food'
//     ];

//     try {
//       final annotations = response['responses'][0]['labelAnnotations'] as List?;
//       if (annotations != null) {
//         for (final annotation in annotations) {
//           final description =
//               annotation['description'].toString().toLowerCase();
//           if (foodKeywords.any((keyword) => description.contains(keyword))) {
//             objects.add(DetectedObject(
//               id: const Uuid().v4(),
//               label: annotation['description'],
//               confidence: annotation['score'].toDouble(),
//               boundingBox: const Rect.fromLTWH(0, 0, 1, 1),
//               type: 'food',
//             ));
//           }
//         }
//       }

//       // Check logo detection for food brands
//       final logoAnnotations =
//           response['responses'][0]['logoAnnotations'] as List?;
//       if (logoAnnotations != null) {
//         for (final annotation in logoAnnotations) {
//           objects.add(DetectedObject(
//             id: const Uuid().v4(),
//             label: '${annotation['description']} (Brand)',
//             confidence: annotation['score'].toDouble(),
//             boundingBox:
//                 _getBoundingBoxFromVertices(annotation['boundingPoly']),
//             type: 'food_brand',
//           ));
//         }
//       }
//     } catch (e) {
//       debugPrint('Error filtering food labels: $e');
//     }

//     return objects;
//   }

//   // ============================================================================
//   // UTILITY METHODS
//   // ============================================================================

//   Rect _convertBoundingPoly(List boundingPoly) {
//     double minX = 1.0, minY = 1.0, maxX = 0.0, maxY = 0.0;

//     for (final vertex in boundingPoly) {
//       final x = vertex['x']?.toDouble() ?? 0.0;
//       final y = vertex['y']?.toDouble() ?? 0.0;

//       minX = math.min(minX, x);
//       minY = math.min(minY, y);
//       maxX = math.max(maxX, x);
//       maxY = math.max(maxY, y);
//     }

//     return Rect.fromLTWH(minX, minY, maxX - minX, maxY - minY);
//   }

//   Rect _getBoundingBoxFromVertices(Map<String, dynamic>? boundingPoly) {
//     if (boundingPoly == null) return const Rect.fromLTWH(0, 0, 1, 1);

//     try {
//       final vertices = boundingPoly['vertices'] as List?;
//       if (vertices == null || vertices.isEmpty) {
//         return const Rect.fromLTWH(0, 0, 1, 1);
//       }

//       double minX = double.infinity, minY = double.infinity;
//       double maxX = 0, maxY = 0;

//       for (final vertex in vertices) {
//         final x = (vertex['x'] ?? 0).toDouble();
//         final y = (vertex['y'] ?? 0).toDouble();

//         minX = math.min(minX, x);
//         minY = math.min(minY, y);
//         maxX = math.max(maxX, x);
//         maxY = math.max(maxY, y);
//       }

//       // Convert absolute coordinates to normalized coordinates (0-1 range)
//       // This is a simplified conversion - you might need to adjust based on image dimensions
//       return Rect.fromLTRB(
//         minX / 1000, // Assuming max dimension of 1000px
//         minY / 1000,
//         maxX / 1000,
//         maxY / 1000,
//       );
//     } catch (e) {
//       debugPrint('Error converting bounding poly: $e');
//       return const Rect.fromLTWH(0, 0, 1, 1);
//     }
//   }

//   // Dispose method to clean up resources
//   void dispose() {
//     _dio.close();
//   }
// }


// // services/image_service.dart

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;

// class ImageService {
//   final ImagePicker _picker = ImagePicker();

//   // Take a picture using the camera
//   Future<File?> takePicture() async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 90,
//         preferredCameraDevice: CameraDevice.rear,
//       );

//       if (image != null) {
//         return File(image.path);
//       }
//     } catch (e) {
//       debugPrint('Error taking picture: $e');
//     }
//     return null;
//   }

//   // Pick an image from the gallery
//   Future<File?> pickImage() async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 90,
//       );

//       if (image != null) {
//         return File(image.path);
//       }
//     } catch (e) {
//       debugPrint('Error picking image: $e');
//     }
//     return null;
//   }

//   // Save camera captured image to app's documents directory
//   Future<File?> saveImage(XFile imageFile) async {
//     try {
//       final appDir = await getApplicationDocumentsDirectory();
//       final fileName = path.basename(imageFile.path);
//       final savedImage =
//           await File(imageFile.path).copy('${appDir.path}/$fileName');
//       return savedImage;
//     } catch (e) {
//       debugPrint('Error saving image: $e');
//       return null;
//     }
//   }
// }


// // services/ml_service.dart

// import 'dart:io';
// import 'package:uuid/uuid.dart';
// import 'package:flutter/material.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:ai_vision_pro/models/detected_object.dart' as app_models;

// class MLService {
//   final _objectDetector = GoogleMlKit.vision.objectDetector(
//     options: ObjectDetectorOptions(
//       mode: DetectionMode.single,
//       classifyObjects: true,
//       multipleObjects: true,
//     ),
//   );

//   final _textRecognizer = GoogleMlKit.vision.textRecognizer();
//   final _barcodeScanner = GoogleMlKit.vision.barcodeScanner();
//   final Uuid _uuid = const Uuid();

//   Future<List<app_models.DetectedObject>> detectObjects(File imageFile) async {
//     final inputImage = InputImage.fromFile(imageFile);
//     final List<app_models.DetectedObject> results = [];

//     try {
//       final objects = await _objectDetector.processImage(inputImage);

//       // Get image size for accurate bounding box conversion
//       final decodedImage =
//           await decodeImageFromList(imageFile.readAsBytesSync());
//       final imageWidth = decodedImage.width.toDouble();
//       final imageHeight = decodedImage.height.toDouble();

//       // Convert ML Kit objects to our model
//       for (final object in objects) {
//         final boundingBox =
//             _convertBoundingBox(object.boundingBox, imageWidth, imageHeight);

//         // Get the label with highest confidence
//         String label = 'Unknown';
//         double highestConfidence = 0;

//         for (final classification in object.labels) {
//           if (classification.confidence > highestConfidence) {
//             highestConfidence = classification.confidence;
//             label = classification.text;
//           }
//         }

//         results.add(
//           app_models.DetectedObject(
//             id: _uuid.v4(),
//             label: label,
//             confidence: highestConfidence,
//             boundingBox: boundingBox,
//           ),
//         );
//       }

//       return results;
//     } catch (e) {
//       debugPrint('Object detection error: $e');
//       rethrow;
//     }
//   }

//   Future<List<app_models.DetectedObject>> extractText(File imageFile) async {
//     final inputImage = InputImage.fromFile(imageFile);
//     final List<app_models.DetectedObject> results = [];

//     try {
//       final RecognizedText recognizedText =
//           await _textRecognizer.processImage(inputImage);

//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           if (line.text.trim().isNotEmpty) {
//             results.add(
//               app_models.DetectedObject(
//                 id: _uuid.v4(),
//                 label: line.text.trim(),
//                 confidence: 0.9, // Text recognition is generally reliable
//                 boundingBox: line.boundingBox,
//                 type: 'text',
//               ),
//             );
//           }
//         }
//       }

//       return results;
//     } catch (e) {
//       debugPrint('Text extraction error: $e');
//       rethrow;
//     }
//   }

//   Future<List<app_models.DetectedObject>> scanBarcodes(File imageFile) async {
//     final inputImage = InputImage.fromFile(imageFile);
//     final List<app_models.DetectedObject> results = [];

//     try {
//       final List<Barcode> barcodes =
//           await _barcodeScanner.processImage(inputImage);

//       for (Barcode barcode in barcodes) {
//         String label = 'Barcode';
//         String? displayValue = barcode.displayValue;

//         // Determine barcode type
//         switch (barcode.format) {
//           case BarcodeFormat.qrCode:
//             label = 'QR Code';
//             break;
//           case BarcodeFormat.ean13:
//             label = 'EAN-13';
//             break;
//           case BarcodeFormat.ean8:
//             label = 'EAN-8';
//             break;
//           case BarcodeFormat.upca:
//             label = 'UPC-A';
//             break;
//           case BarcodeFormat.upce:
//             label = 'UPC-E';
//             break;
//           case BarcodeFormat.code128:
//             label = 'Code 128';
//             break;
//           case BarcodeFormat.code39:
//             label = 'Code 39';
//             break;
//           default:
//             label = 'Barcode';
//         }

//         results.add(
//           app_models.DetectedObject(
//             id: _uuid.v4(),
//             label: displayValue ?? label,
//             confidence:
//                 1.0, // Barcode detection is binary - it either works or doesn't
//             boundingBox: barcode.boundingBox,
//             type: 'barcode',
//             rawValue: barcode.rawValue,
//           ),
//         );
//       }

//       return results;
//     } catch (e) {
//       debugPrint('Barcode scanning error: $e');
//       rethrow;
//     }
//   }

//   Rect _convertBoundingBox(
//       Rect mlkitBox, double imageWidth, double imageHeight) {
//     // Convert ML Kit coordinates to normalized coordinates for Flutter
//     return Rect.fromLTWH(
//       mlkitBox.left,
//       mlkitBox.top,
//       mlkitBox.width,
//       mlkitBox.height,
//     );
//   }

//   void dispose() {
//     _objectDetector.close();
//     _textRecognizer.close();
//     _barcodeScanner.close();
//   }
// }


// // providers/app_providers.dart

// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../models/premium_plan.dart';
// import '../services/auto_save_service.dart';
// import '../services/image_quality_manager.dart';
// import '../utils/haptic_feedback.dart';
// import '../utils/sound_manager.dart';
// import 'premium_provider.dart';

// final isPremiumProvider = Provider<bool>((ref) {
//   return ref.watch(premiumProvider).isPremium;
// });

// final shouldShowAdsProvider = Provider<bool>((ref) {
//   return !ref.watch(isPremiumProvider);
// });

// final premiumPlansProvider = Provider<List<PremiumPlan>>((ref) {
//   return ref.watch(premiumProvider.notifier).getAvailablePlans();
// });

// final soundManagerProvider = Provider<SoundManager>((ref) {
//   return SoundManager();
// });

// final hapticFeedbackProvider = Provider<HapticFeedbackUtil>((ref) {
//   return HapticFeedbackUtil();
// });

// final imageQualityManagerProvider = Provider<ImageQualityManager>((ref) {
//   return ImageQualityManager();
// });

// final autoSaveServiceProvider = Provider<AutoSaveService>((ref) {
//   return AutoSaveService();
// });


// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:io';

// import '../models/app_user.dart';
// import '../models/auth_state.dart';

// class AuthNotifier extends StateNotifier<AuthState> {
//   AuthNotifier() : super(AuthState()) {
//     _initialize();
//   }

//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   Future<void> _initialize() async {
//     state = state.copyWith(isLoading: true);

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final hasCompletedOnboarding =
//           prefs.getBool('onboarding_completed') ?? false;

//       User? firebaseUser = _firebaseAuth.currentUser;

//       if (firebaseUser != null) {
//         try {
//           await _createOrUpdateUserDocument(firebaseUser);
//           final appUser = await _buildAppUserFromFirebase(firebaseUser);
//           await _cacheUserData(appUser);

//           state = state.copyWith(
//             user: appUser,
//             isAuthenticated: true,
//             isLoading: false,
//             hasCompletedOnboarding: hasCompletedOnboarding,
//           );
//         } catch (e) {
//           debugPrint('Error creating/updating user doc during init: $e');
//           state = state.copyWith(
//             isLoading: false,
//             error: 'Failed to initialize user data: ${e.toString()}',
//           );
//         }
//       } else {
//         _firebaseAuth.authStateChanges().listen((User? user) async {
//           if (user != null) {
//             try {
//               await _createOrUpdateUserDocument(user);
//               final appUser = await _buildAppUserFromFirebase(user);
//               await _cacheUserData(appUser);

//               state = state.copyWith(
//                 user: appUser,
//                 isAuthenticated: true,
//                 isLoading: false,
//                 hasCompletedOnboarding: hasCompletedOnboarding,
//               );
//             } catch (e) {
//               debugPrint('Error creating/updating user doc on auth change: $e');
//               state = state.copyWith(
//                 isLoading: false,
//                 error: 'Failed to sync user data: ${e.toString()}',
//               );
//             }
//           } else {
//             await _clearCachedUserData();
//             state = state.copyWith(
//               user: null,
//               isAuthenticated: false,
//               isLoading: false,
//               hasCompletedOnboarding: hasCompletedOnboarding,
//             );
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint('Initialization error: $e');
//       state = state.copyWith(
//         isLoading: false,
//         error: 'Failed to initialize authentication: ${e.toString()}',
//       );
//     }
//   }

//   // Enhanced method to build AppUser with Firestore data
//   Future<AppUser> _buildAppUserFromFirebase(User firebaseUser) async {
//     try {
//       // Get additional user data from Firestore
//       final userDoc =
//           await _firestore.collection('users').doc(firebaseUser.uid).get();

//       String provider = 'email';
//       if (firebaseUser.providerData.isNotEmpty) {
//         switch (firebaseUser.providerData.first.providerId) {
//           case 'google.com':
//             provider = 'google';
//             break;
//           case 'apple.com':
//             provider = 'apple';
//             break;
//           case 'password':
//             provider = 'email';
//             break;
//         }
//       }
//       if (firebaseUser.isAnonymous) provider = 'anonymous';

//       // Create base AppUser
//       var appUser = AppUser(
//         id: firebaseUser.uid,
//         email: firebaseUser.email,
//         displayName: firebaseUser.displayName,
//         photoURL: firebaseUser.photoURL,
//         isAnonymous: firebaseUser.isAnonymous,
//         createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
//         lastSignIn: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
//         provider: provider,
//       );

//       // If Firestore document exists, merge additional data
//       if (userDoc.exists) {
//         final data = userDoc.data() as Map<String, dynamic>;

//         // Override with Firestore data if available
//         appUser = AppUser(
//           id: appUser.id,
//           email: appUser.email,
//           displayName: data['displayName'] ?? appUser.displayName,
//           photoURL: data['photoURL'] ?? appUser.photoURL,
//           isAnonymous: appUser.isAnonymous,
//           createdAt: appUser.createdAt,
//           lastSignIn: appUser.lastSignIn,
//           provider: appUser.provider,
//         );
//       }

//       return appUser;
//     } catch (e) {
//       debugPrint('Error building AppUser: $e');
//       // Fallback to basic AppUser if Firestore fails
//       return AppUser.fromFirebaseUser(firebaseUser);
//     }
//   }

//   Future<void> _cacheUserData(AppUser user) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('cached_user_data', user.toJson().toString());
//       await prefs.setBool('user_authenticated', true);
//     } catch (e) {
//       debugPrint('Failed to cache user data: $e');
//     }
//   }

//   Future<void> _clearCachedUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('cached_user_data');
//       await prefs.setBool('user_authenticated', false);
//     } catch (e) {
//       debugPrint('Failed to clear cached user data: $e');
//     }
//   }

//   Future<void> _createOrUpdateUserDocument(User firebaseUser,
//       {bool isNewUser = false}) async {
//     try {
//       final userRef = _firestore.collection('users').doc(firebaseUser.uid);
//       final userDoc = await userRef.get();

//       final userData = {
//         'uid': firebaseUser.uid,
//         'email': firebaseUser.email,
//         'displayName': firebaseUser.displayName,
//         'photoURL': firebaseUser.photoURL,
//         'phoneNumber': firebaseUser.phoneNumber,
//         'isEmailVerified': firebaseUser.emailVerified,
//         'isAnonymous': firebaseUser.isAnonymous,
//         'lastSignIn': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       };

//       if (!userDoc.exists || isNewUser) {
//         await userRef.set(
//             {
//               ...userData,
//               'createdAt': FieldValue.serverTimestamp(),
//               'preferences': {
//                 'theme': 'system',
//                 'notifications': true,
//                 'language': 'en',
//               },
//               'profile': {
//                 'bio': '',
//                 'location': '',
//                 'website': '',
//               },
//               'stats': {
//                 'totalScans': 0,
//                 'totalImages': 0,
//                 'favoriteCount': 0,
//               },
//             },
//             SetOptions(
//                 merge: true)); // Use merge to avoid overwriting existing data
//         debugPrint('Created new user document for ${firebaseUser.uid}');
//       } else {
//         await userRef.update(userData);
//         debugPrint('Updated user document for ${firebaseUser.uid}');
//       }
//     } catch (e) {
//       debugPrint(
//           'Failed to create/update user document: $e - User: ${firebaseUser.uid}');
//       // Re-throw to ensure the error is visible in the state
//       rethrow;
//     }
//   }

//   Future<void> signInWithEmailAndPassword(String email, String password) async {
//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       final UserCredential result =
//           await _firebaseAuth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       if (result.user != null) {
//         await _createOrUpdateUserDocument(result.user!);
//         final appUser = AppUser.fromFirebaseUser(result.user!);
//         await _cacheUserData(appUser);

//         state = state.copyWith(
//           user: appUser,
//           isAuthenticated: true,
//           isLoading: false,
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: _getErrorMessage(e.code),
//       );
//       debugPrint(_getErrorMessage(e.code));
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: 'An unexpected error occurred: ${e.toString()}',
//       );
//       debugPrint('An unexpected error occurred: ${e.toString()}');
//     }
//   }

//   Future<void> registerWithEmailAndPassword(
//       String email, String password) async {
//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       final UserCredential result =
//           await _firebaseAuth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       if (result.user != null) {
//         await result.user!.sendEmailVerification();
//         await _createOrUpdateUserDocument(result.user!, isNewUser: true);
//         final appUser = AppUser.fromFirebaseUser(result.user!);
//         await _cacheUserData(appUser);

//         state = state.copyWith(
//           user: appUser,
//           isAuthenticated: true,
//           isLoading: false,
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: _getErrorMessage(e.code),
//       );
//       debugPrint(_getErrorMessage(e.code));
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: 'An unexpected error occurred: ${e.toString()}',
//       );
//       debugPrint('An unexpected error occurred: ${e.toString()}');
//     }
//   }

//   Future<void> signInWithGoogle() async {
//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

//       if (googleUser == null) {
//         state = state.copyWith(isLoading: false);
//         return;
//       }

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final UserCredential result =
//           await _firebaseAuth.signInWithCredential(credential);

//       if (result.user != null) {
//         final isNewUser = result.additionalUserInfo?.isNewUser ?? false;
//         await _createOrUpdateUserDocument(result.user!, isNewUser: isNewUser);
//         final appUser = AppUser.fromFirebaseUser(result.user!);
//         await _cacheUserData(appUser);

//         state = state.copyWith(
//           user: appUser,
//           isAuthenticated: true,
//           isLoading: false,
//         );
//       }
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: 'Google sign in failed: ${e.toString()}',
//       );
//       debugPrint('An unexpected error occurred: ${e.toString()}');
//     }
//   }

//   Future<void> signInWithApple() async {
//     if (!Platform.isIOS) {
//       state = state.copyWith(
//         error: 'Apple Sign In is only available on iOS devices',
//       );
//       return;
//     }

//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       // Check if Apple Sign In is available
//       final isAvailable = await SignInWithApple.isAvailable();
//       debugPrint('Apple Sign In available: $isAvailable');

//       if (!isAvailable) {
//         state = state.copyWith(
//           isLoading: false,
//           error:
//               'Apple Sign In is not available on this device. Please ensure you\'re running iOS 13+ and signed into an Apple ID.',
//         );
//         return;
//       }

//       debugPrint('Attempting Apple Sign In...');

//       final appleCredential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//         webAuthenticationOptions: WebAuthenticationOptions(
//           clientId: 'your-service-id', // Add your service ID if you have one
//           redirectUri:
//               Uri.parse('https://your-domain.com/callback'), // Add if needed
//         ),
//       );

//       debugPrint('Apple credential obtained successfully');
//       debugPrint('User ID: ${appleCredential.userIdentifier}');
//       debugPrint('Email: ${appleCredential.email}');
//       debugPrint('Given Name: ${appleCredential.givenName}');
//       debugPrint('Family Name: ${appleCredential.familyName}');

//       if (appleCredential.identityToken == null) {
//         throw Exception('Apple Sign In failed: No identity token received');
//       }

//       final oAuthCredential = OAuthProvider("apple.com").credential(
//         idToken: appleCredential.identityToken,
//         accessToken: appleCredential.authorizationCode,
//       );

//       debugPrint('Creating Firebase credential...');

//       final UserCredential result =
//           await _firebaseAuth.signInWithCredential(oAuthCredential);

//       debugPrint('Firebase authentication successful');

//       if (result.user != null) {
//         // Update display name if available and not already set
//         if (appleCredential.givenName != null &&
//             result.user!.displayName == null) {
//           final displayName =
//               '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
//                   .trim();
//           await result.user!.updateDisplayName(displayName);
//           debugPrint('Updated display name: $displayName');
//         }

//         final isNewUser = result.additionalUserInfo?.isNewUser ?? false;
//         debugPrint('Is new user: $isNewUser');

//         await _createOrUpdateUserDocument(result.user!, isNewUser: isNewUser);
//         final appUser = AppUser.fromFirebaseUser(result.user!);
//         await _cacheUserData(appUser);

//         state = state.copyWith(
//           user: appUser,
//           isAuthenticated: true,
//           isLoading: false,
//         );

//         debugPrint('Apple Sign In completed successfully');
//       }
//     } on SignInWithAppleAuthorizationException catch (e) {
//       debugPrint(
//           'Apple Sign In Authorization Exception: ${e.code} - ${e.message}');

//       String errorMessage;
//       switch (e.code) {
//         case AuthorizationErrorCode.canceled:
//           errorMessage = 'Sign in was canceled';
//           break;
//         case AuthorizationErrorCode.failed:
//           errorMessage = 'Sign in failed. Please try again';
//           break;
//         case AuthorizationErrorCode.invalidResponse:
//           errorMessage = 'Invalid response from Apple. Please try again';
//           break;
//         case AuthorizationErrorCode.notHandled:
//           errorMessage = 'Sign in not handled. Please try again';
//           break;
//         case AuthorizationErrorCode.notInteractive:
//           errorMessage = 'Sign in requires user interaction';
//           break;
//         case AuthorizationErrorCode.unknown:
//         default:
//           errorMessage =
//               'Apple Sign In failed. Please ensure you\'re signed into your Apple ID in Settings and try again';
//           break;
//       }

//       state = state.copyWith(
//         isLoading: false,
//         error: errorMessage,
//       );
//     } on FirebaseAuthException catch (e) {
//       debugPrint('Firebase Auth Exception: ${e.code} - ${e.message}');
//       state = state.copyWith(
//         isLoading: false,
//         error: _getErrorMessage(e.code),
//       );
//     } catch (e) {
//       debugPrint('Unexpected error during Apple Sign In: $e');
//       state = state.copyWith(
//         isLoading: false,
//         error: 'Apple sign in failed: ${e.toString()}',
//       );
//     }
//   }

//   Future<void> signInAnonymously() async {
//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       final UserCredential result = await _firebaseAuth.signInAnonymously();

//       if (result.user != null) {
//         await _createOrUpdateUserDocument(result.user!, isNewUser: true);
//         final appUser = AppUser.fromFirebaseUser(result.user!);
//         await _cacheUserData(appUser);

//         state = state.copyWith(
//           user: appUser,
//           isAuthenticated: true,
//           isLoading: false,
//         );
//       }
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: 'Anonymous sign in failed: ${e.toString()}',
//       );
//       debugPrint('Anonymous sign in failed: ${e.toString()}');
//     }
//   }

//   Future<void> linkEmailPassword(String email, String password) async {
//     if (state.user == null || !state.user!.isAnonymous) {
//       state = state.copyWith(error: 'No anonymous user to link');
//       return;
//     }

//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       final credential =
//           EmailAuthProvider.credential(email: email, password: password);
//       final UserCredential result =
//           await _firebaseAuth.currentUser!.linkWithCredential(credential);

//       if (result.user != null) {
//         await _createOrUpdateUserDocument(result.user!, isNewUser: false);
//         final appUser = AppUser.fromFirebaseUser(result.user!);
//         await _cacheUserData(appUser);

//         state = state.copyWith(
//           user: appUser,
//           isAuthenticated: true,
//           isLoading: false,
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: _getErrorMessage(e.code),
//       );
//       debugPrint(
//         _getErrorMessage(e.code),
//       );
//     }
//   }

//   Future<void> signOut() async {
//     state = state.copyWith(isLoading: true);

//     try {
//       await Future.wait([
//         _firebaseAuth.signOut(),
//         _googleSignIn.signOut(),
//       ]);

//       await _clearCachedUserData();

//       state = state.copyWith(
//         user: null,
//         isAuthenticated: false,
//         isLoading: false,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: 'Failed to sign out: ${e.toString()}',
//       );
//     }
//   }

//   Future<void> resetPassword(String email) async {
//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       await _firebaseAuth.sendPasswordResetEmail(email: email);
//       state = state.copyWith(isLoading: false);
//     } on FirebaseAuthException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: _getErrorMessage(e.code),
//       );
//     }
//   }

//   // Enhanced updateProfile method
//   Future<void> updateProfile({
//     String? displayName,
//     String? photoURL,
//     File? photoFile,
//     String? bio,
//     Map<String, dynamic>? additionalData,
//   }) async {
//     if (state.user == null) return;

//     state = state.copyWith(isLoading: true, error: null);

//     try {
//       final user = _firebaseAuth.currentUser!;

//       String? finalPhotoURL = photoURL;

//       // Upload photo if file is provided
//       if (photoFile != null) {
//         finalPhotoURL = await _uploadProfileImage(photoFile, user.uid);
//       }

//       // Update Firebase Auth profile
//       if (displayName != null || finalPhotoURL != null) {
//         await user.updateDisplayName(displayName);
//         if (finalPhotoURL != null) {
//           await user.updatePhotoURL(finalPhotoURL);
//         }
//       }

//       // Prepare Firestore update data
//       Map<String, dynamic> firestoreUpdates = {
//         'updatedAt': FieldValue.serverTimestamp(),
//       };

//       if (displayName != null) {
//         firestoreUpdates['displayName'] = displayName;
//       }

//       if (finalPhotoURL != null) {
//         firestoreUpdates['photoURL'] = finalPhotoURL;
//       }

//       if (bio != null) {
//         firestoreUpdates['profile.bio'] = bio;
//       }

//       if (additionalData != null) {
//         firestoreUpdates.addAll(additionalData);
//       }

//       // Update Firestore document
//       await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .update(firestoreUpdates);

//       // Reload user and update state
//       await user.reload();
//       final updatedUser = _firebaseAuth.currentUser!;
//       final appUser = await _buildAppUserFromFirebase(updatedUser);
//       await _cacheUserData(appUser);

//       state = state.copyWith(
//         user: appUser,
//         isLoading: false,
//       );

//       debugPrint('Profile updated successfully');
//     } catch (e) {
//       debugPrint('Failed to update profile: $e');
//       state = state.copyWith(
//         isLoading: false,
//         error: 'Failed to update profile: ${e.toString()}',
//       );
//       rethrow;
//     }
//   }

//   // Method to upload profile image to Firebase Storage
//   Future<String> _uploadProfileImage(File imageFile, String userId) async {
//     try {
//       final fileName =
//           'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       final storageRef = _storage.ref().child('profile_images').child(fileName);

//       // Delete old profile image if exists
//       try {
//         final oldImageRef = _storage.ref().child('profile_images');
//         final listResult = await oldImageRef.listAll();

//         for (final item in listResult.items) {
//           if (item.name.startsWith('profile_$userId')) {
//             await item.delete();
//             debugPrint('Deleted old profile image: ${item.name}');
//           }
//         }
//       } catch (e) {
//         debugPrint('Could not delete old profile images: $e');
//         // Continue anyway, old images won't break anything
//       }

//       // Upload new image
//       final uploadTask = storageRef.putFile(
//         imageFile,
//         SettableMetadata(
//           contentType: 'image/jpeg',
//           customMetadata: {
//             'userId': userId,
//             'uploadedAt': DateTime.now().toIso8601String(),
//           },
//         ),
//       );

//       final snapshot = await uploadTask.whenComplete(() => null);

//       if (snapshot.state == TaskState.success) {
//         final downloadURL = await storageRef.getDownloadURL();
//         debugPrint('Profile image uploaded successfully: $downloadURL');
//         return downloadURL;
//       } else {
//         throw Exception('Upload failed with state: ${snapshot.state}');
//       }
//     } catch (e) {
//       debugPrint('Error uploading profile image: $e');
//       rethrow;
//     }
//   }

//   // Method to update user profile data in Firestore only
//   Future<void> updateUserProfileData(Map<String, dynamic> updates) async {
//     if (state.user == null) return;

//     try {
//       updates['updatedAt'] = FieldValue.serverTimestamp();

//       await _firestore.collection('users').doc(state.user!.id).update(updates);

//       // Refresh user data
//       final currentUser = _firebaseAuth.currentUser;
//       if (currentUser != null) {
//         final appUser = await _buildAppUserFromFirebase(currentUser);
//         await _cacheUserData(appUser);

//         state = state.copyWith(user: appUser);
//       }

//       debugPrint('User profile data updated successfully');
//     } catch (e) {
//       debugPrint('Error updating user profile data: $e');
//       rethrow;
//     }
//   }

//   Future<void> completeOnboarding() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('onboarding_completed', true);

//       state = state.copyWith(hasCompletedOnboarding: true);
//     } catch (e) {
//       debugPrint('Failed to mark onboarding as completed: $e');
//     }
//   }

//   void clearError() {
//     state = state.copyWith(error: null);
//   }

//   String _getErrorMessage(String errorCode) {
//     switch (errorCode) {
//       case 'user-not-found':
//         return 'No account found with this email address.';
//       case 'wrong-password':
//         return 'Incorrect password. Please try again.';
//       case 'email-already-in-use':
//         return 'An account already exists with this email address.';
//       case 'weak-password':
//         return 'Password should be at least 6 characters long.';
//       case 'invalid-email':
//         return 'Please enter a valid email address.';
//       case 'user-disabled':
//         return 'This account has been temporarily disabled.';
//       case 'too-many-requests':
//         return 'Too many failed attempts. Please try again later.';
//       case 'operation-not-allowed':
//         return 'This sign-in method is not enabled.';
//       case 'account-exists-with-different-credential':
//         return 'An account already exists with this email using a different sign-in method.';
//       case 'invalid-credential':
//         return 'The provided credential is invalid or expired.';
//       case 'network-request-failed':
//         return 'Network error. Please check your connection and try again.';
//       default:
//         return 'An error occurred. Please try again.';
//     }
//   }
// }

// final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
//   (ref) => AuthNotifier(),
// );

// final currentUserProvider = Provider<AppUser?>((ref) {
//   return ref.watch(authProvider).user;
// });

// final isAuthenticatedProvider = Provider<bool>((ref) {
//   return ref.watch(authProvider).isAuthenticated;
// });

// final isLoadingProvider = Provider<bool>((ref) {
//   return ref.watch(authProvider).isLoading;
// });

// final hasCompletedOnboardingProvider = Provider<bool>((ref) {
//   return ref.watch(authProvider).hasCompletedOnboarding;
// });

// final isGuestUserProvider = Provider<bool>((ref) {
//   final user = ref.watch(currentUserProvider);
//   return user?.isAnonymous ?? false;
// });


// // providers/camera_provider.dart - FIXED VERSION

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:camera/camera.dart';
// import '../models/camera_state.dart';
// import '../services/image_quality_manager.dart';
// import 'premium_provider.dart';

// class CameraNotifier extends StateNotifier<CameraState> {
//   final Ref ref;
//   final ImageQualityManager _qualityManager = ImageQualityManager();

//   CameraNotifier(this.ref, List<CameraDescription> cameras)
//       : super(CameraState(cameras: cameras));

//   Future<void> initializeCamera() async {
//     if (state.cameras.isEmpty) {
//       state = state.copyWith(
//           status: CameraStatus.error, errorMessage: 'No cameras available');
//       return;
//     }

//     // Avoid reinitializing if already initialized
//     if (state.isInitialized) {
//       return;
//     }

//     // FIXED: Use microtask to avoid modifying state during widget build
//     await Future.microtask(() async {
//       if (mounted) {
//         state = state.copyWith(status: CameraStatus.initializing);
//         await _prepareCamera();
//       }
//     });
//   }

//   Future<void> _prepareCamera() async {
//     if (state.controller != null) {
//       try {
//         await state.controller!.dispose();
//       } catch (e) {
//         debugPrint('Error disposing previous camera controller: $e');
//       }
//     }

//     try {
//       // ✅ now ref is available
//       final isPremium = ref.read(premiumProvider).isPremium;

//       final preset = _qualityManager.getResolutionPreset(isPremium);

//       final controller = CameraController(
//         state.cameras[state.selectedCameraIndex],
//         preset,
//         enableAudio: false,
//         imageFormatGroup: ImageFormatGroup.jpeg,
//       );

//       await controller.initialize();

//       if (mounted) {
//         state = state.copyWith(
//           controller: controller,
//           status: CameraStatus.initialized,
//           errorMessage: null,
//         );
//       } else {
//         await controller.dispose();
//       }
//     } catch (e) {
//       if (mounted) {
//         state = state.copyWith(
//           status: CameraStatus.error,
//           errorMessage: 'Failed to initialize camera: ${e.toString()}',
//         );
//       }
//       debugPrint('Error initializing camera: $e');
//     }
//   }

//   Future<void> startStream() async {
//     if (!state.isInitialized || state.status == CameraStatus.streaming) return;

//     try {
//       if (mounted) {
//         state = state.copyWith(status: CameraStatus.streaming);
//       }
//     } catch (e) {
//       if (mounted) {
//         state = state.copyWith(
//           status: CameraStatus.error,
//           errorMessage: 'Failed to start camera stream: ${e.toString()}',
//         );
//       }
//       debugPrint('Error starting camera stream: $e');
//     }
//   }

//   Future<void> stopStream() async {
//     if (!state.isInitialized) return;

//     try {
//       if (mounted) {
//         state = state.copyWith(status: CameraStatus.initialized);
//       }
//     } catch (e) {
//       if (mounted) {
//         state = state.copyWith(
//           status: CameraStatus.error,
//           errorMessage: 'Failed to stop camera stream: ${e.toString()}',
//         );
//       }
//       debugPrint('Error stopping camera stream: $e');
//     }
//   }

//   Future<void> switchCamera() async {
//     if (state.cameras.length <= 1) return;

//     try {
//       final newIndex = (state.selectedCameraIndex + 1) % state.cameras.length;

//       if (mounted) {
//         state = state.copyWith(selectedCameraIndex: newIndex);
//         await _prepareCamera();

//         if (state.status == CameraStatus.initialized && mounted) {
//           await startStream();
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         state = state.copyWith(
//           status: CameraStatus.error,
//           errorMessage: 'Failed to switch camera: ${e.toString()}',
//         );
//       }
//       debugPrint('Error switching camera: $e');
//     }
//   }

//   Future<XFile?> takePicture() async {
//     if (!state.isInitialized || state.controller == null) {
//       debugPrint('Camera not initialized or controller is null');
//       return null;
//     }

//     try {
//       // Ensure camera is ready
//       if (!state.controller!.value.isInitialized) {
//         debugPrint('Camera controller not initialized');
//         return null;
//       }

//       final image = await state.controller!.takePicture();
//       return image;
//     } catch (e) {
//       debugPrint('Error taking picture: $e');
//       if (mounted) {
//         state = state.copyWith(
//           status: CameraStatus.error,
//           errorMessage: 'Failed to take picture: ${e.toString()}',
//         );
//       }
//       return null;
//     }
//   }

//   Future<void> toggleFlash() async {
//     if (!state.isInitialized || state.controller == null) return;

//     try {
//       final newFlashState = !state.isFlashOn;
//       await state.controller!
//           .setFlashMode(newFlashState ? FlashMode.torch : FlashMode.off);

//       if (mounted) {
//         state = state.copyWith(isFlashOn: newFlashState);
//       }
//     } catch (e) {
//       debugPrint('Error toggling flash: $e');
//       if (mounted) {
//         state = state.copyWith(
//           status: CameraStatus.error,
//           errorMessage: 'Failed to toggle flash: ${e.toString()}',
//         );
//       }
//     }
//   }

//   Future<void> setFocusPoint(Offset point) async {
//     if (!state.isInitialized || state.controller == null) return;

//     try {
//       // Convert screen coordinates to camera coordinates
//       final size = state.controller!.value.previewSize!;
//       final double x = point.dx / size.width;
//       final double y = point.dy / size.height;

//       await state.controller!.setFocusPoint(Offset(x, y));
//       await state.controller!.setExposurePoint(Offset(x, y));
//     } catch (e) {
//       debugPrint('Error setting focus point: $e');
//     }
//   }

//   Future<void> setZoomLevel(double zoom) async {
//     if (!state.isInitialized || state.controller == null) return;

//     try {
//       final minZoom = await state.controller!.getMinZoomLevel();
//       final maxZoom = await state.controller!.getMaxZoomLevel();

//       final clampedZoom = zoom.clamp(minZoom, maxZoom);
//       await state.controller!.setZoomLevel(clampedZoom);
//     } catch (e) {
//       debugPrint('Error setting zoom level: $e');
//     }
//   }

//   Future<void> setExposureOffset(double offset) async {
//     if (!state.isInitialized || state.controller == null) return;

//     try {
//       final minOffset = await state.controller!.getMinExposureOffset();
//       final maxOffset = await state.controller!.getMaxExposureOffset();

//       final clampedOffset = offset.clamp(minOffset, maxOffset);
//       await state.controller!.setExposureOffset(clampedOffset);
//     } catch (e) {
//       debugPrint('Error setting exposure offset: $e');
//     }
//   }

//   Future<void> pausePreview() async {
//     if (!state.isInitialized || state.controller == null) return;

//     try {
//       await state.controller!.pausePreview();
//     } catch (e) {
//       debugPrint('Error pausing preview: $e');
//     }
//   }

//   Future<void> resumePreview() async {
//     if (!state.isInitialized || state.controller == null) return;

//     try {
//       await state.controller!.resumePreview();
//     } catch (e) {
//       debugPrint('Error resuming preview: $e');
//     }
//   }

//   Future<void> cleanupResources() async {
//     if (state.controller != null) {
//       try {
//         await state.controller!.dispose();
//       } catch (e) {
//         debugPrint('Error disposing camera controller: $e');
//       }

//       if (mounted) {
//         state = state.copyWith(
//           controller: null,
//           status: CameraStatus.uninitialized,
//         );
//       }
//     }
//   }

//   // Helper method to check if the notifier is still valid
//   bool get isValid => mounted;

//   @override
//   void dispose() {
//     // Clean up resources when the provider is disposed
//     if (state.controller != null) {
//       state.controller!.dispose();
//     }
//     super.dispose();
//   }
// }

// // Provider definition with better error handling
// final cameraProvider =
//     StateNotifierProvider<CameraNotifier, CameraState>((ref) {
//   return CameraNotifier(ref, []); // ✅ pass ref
// });

// // Helper providers for camera state
// final cameraStatusProvider = Provider<CameraStatus>((ref) {
//   return ref.watch(cameraProvider).status;
// });

// final isCameraInitializedProvider = Provider<bool>((ref) {
//   return ref.watch(cameraProvider).isInitialized;
// });

// final cameraErrorProvider = Provider<String?>((ref) {
//   return ref.watch(cameraProvider).errorMessage;
// });


// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:uuid/uuid.dart';

// import '../models/detected_object.dart';
// import '../models/detection_result.dart';
// import '../models/detection_state.dart';
// import '../services/analytics_service.dart';
// import '../services/api_service.dart';
// import '../services/auto_save_service.dart';
// import '../services/cloud_vision_service.dart';
// import '../services/ml_service.dart';
// import '../services/subscription_service.dart';
// import '../providers/premium_provider.dart';
// import '../utils/camera_mode.dart';
// import '../providers/history_provider.dart'; // Add this import

// class DetectionProvider extends StateNotifier<DetectionState> {
//   DetectionProvider(this._ref) : super(DetectionState.initial());

//   final Ref _ref;

//   final MLService _mlService = MLService();
//   final ApiService _apiService = ApiService();
//   final CloudVisionService _cloudVisionService = CloudVisionService();
//   final AnalyticsService _analyticsService = AnalyticsService();
//   final SubscriptionService _subscriptionService = SubscriptionService();
//   // Add auto save service
//   final AutoSaveService _autoSaveService = AutoSaveService();

//   bool get _isPremium => _ref.read(premiumProvider).isPremium;

//   Future<void> processImage(File imageFile,
//       {CameraMode mode = CameraMode.object}) async {
//     state = state.copyWith(
//       currentResult: DetectionResult(
//         id: const Uuid().v4(),
//         imageFile: imageFile,
//         objects: [],
//         timestamp: DateTime.now(),
//         isProcessing: true,
//         mode: mode,
//       ),
//     );

//     try {
//       List<DetectedObject> objects = [];

//       switch (mode) {
//         case CameraMode.object:
//           objects = await _detectObjects(imageFile);
//           break;
//         case CameraMode.text:
//           objects = await _extractText(imageFile);
//           break;
//         case CameraMode.barcode:
//           objects = await _scanBarcodes(imageFile);
//           break;
//         case CameraMode.landmark:
//           objects = await _recognizeLandmarks(imageFile);
//           break;
//         case CameraMode.plant:
//           objects = await _identifyPlants(imageFile);
//           break;
//         case CameraMode.animal:
//           objects = await _recognizeAnimals(imageFile);
//           break;
//         case CameraMode.food:
//           objects = await _analyzeFood(imageFile);
//           break;
//         case CameraMode.document:
//           objects = await _processDocuments(imageFile);
//           break;
//       }

//       final result = state.currentResult!.copyWith(
//         objects: objects,
//         isProcessing: false,
//         mode: mode,
//       );

//       state = state.copyWith(currentResult: result);

//       if (objects.isNotEmpty) {
//         // Auto-save if enabled
//         final history = await _autoSaveService.autoSaveDetectionResult(result);
//         if (history != null) {
//           // Update history provider
//           await _ref.read(historyProvider.notifier).addFromAutoSave(history);
//         }
//       }

//       // Track analytics (this will now be handled by history provider)
//       _analyticsService.trackDetection(mode, objects.length);

//       if (_isPremium) {
//         await _fetchEnhancedDetails(objects);
//       }
//     } catch (e) {
//       state = state.copyWith(
//         currentResult: state.currentResult!.copyWith(
//           error: e.toString(),
//           isProcessing: false,
//         ),
//       );
//     }
//   }

//   // New method to save detection result to history
//   Future<void> _saveToHistory(DetectionResult result) async {
//     try {
//       final historyNotifier = _ref.read(historyProvider.notifier);
//       await historyNotifier.saveResult(result);
//       debugPrint('Detection result saved to history: ${result.id}');
//     } catch (e) {
//       debugPrint('Error saving to history: $e');
//     }
//   }

//   Future<void> fetchFunFact(DetectedObject object) async {
//     try {
//       final funFact = await _apiService.getObjectFunFact(object.label);
//       final updatedObject = object.copyWith(funFact: funFact);
//       _updateObjectInCurrentResult(updatedObject);
//     } catch (e) {
//       debugPrint('Error fetching fun fact for ${object.label}: $e');
//       final updatedObject =
//           object.copyWith(funFact: 'Fun fact not available at the moment.');
//       _updateObjectInCurrentResult(updatedObject);
//     }
//   }

//   Future<List<DetectedObject>> _detectObjects(File imageFile) async {
//     final localResults = await _mlService.detectObjects(imageFile);
//     if (_isPremium) {
//       final canProceed =
//           await _subscriptionService.checkUsageLimits(apiCalls: 1);
//       if (!canProceed) {
//         throw Exception('API usage limit reached. Please try again later.');
//       }
//       final cloudResults = await _cloudVisionService.detectObjects(imageFile);
//       return _mergeAndRankResults(localResults, cloudResults);
//     }
//     return localResults;
//   }

//   Future<List<DetectedObject>> _extractText(File imageFile) async {
//     return await _mlService.extractText(imageFile);
//   }

//   Future<List<DetectedObject>> _scanBarcodes(File imageFile) async {
//     return await _mlService.scanBarcodes(imageFile);
//   }

//   Future<List<DetectedObject>> _recognizeLandmarks(File imageFile) async {
//     if (!_isPremium) {
//       throw Exception('Landmark recognition requires premium subscription');
//     }
//     final canProceed = await _subscriptionService.checkUsageLimits(apiCalls: 1);
//     if (!canProceed) {
//       throw Exception('API usage limit reached. Please try again later.');
//     }
//     return await _cloudVisionService.recognizeLandmarks(imageFile);
//   }

//   Future<List<DetectedObject>> _identifyPlants(File imageFile) async {
//     if (!_isPremium) {
//       throw Exception('Plant identification requires premium subscription');
//     }
//     final canProceed = await _subscriptionService.checkUsageLimits(apiCalls: 1);
//     if (!canProceed) {
//       throw Exception('API usage limit reached. Please try again later.');
//     }
//     return await _cloudVisionService.identifyPlants(imageFile);
//   }

//   Future<List<DetectedObject>> _recognizeAnimals(File imageFile) async {
//     if (!_isPremium) {
//       throw Exception('Animal recognition requires premium subscription');
//     }
//     final canProceed = await _subscriptionService.checkUsageLimits(apiCalls: 1);
//     if (!canProceed) {
//       throw Exception('API usage limit reached. Please try again later.');
//     }
//     return await _cloudVisionService.recognizeAnimals(imageFile);
//   }

//   Future<List<DetectedObject>> _analyzeFood(File imageFile) async {
//     if (!_isPremium) {
//       throw Exception('Food analysis requires premium subscription');
//     }
//     final canProceed = await _subscriptionService.checkUsageLimits(apiCalls: 1);
//     if (!canProceed) {
//       throw Exception('API usage limit reached. Please try again later.');
//     }
//     return await _cloudVisionService.analyzeFood(imageFile);
//   }

//   Future<List<DetectedObject>> _processDocuments(File imageFile) async {
//     if (!_isPremium) {
//       throw Exception('Document processing requires premium subscription');
//     }
//     final canProceed = await _subscriptionService.checkUsageLimits(apiCalls: 1);
//     if (!canProceed) {
//       throw Exception('API usage limit reached. Please try again later.');
//     }
//     return await _cloudVisionService.processDocuments(imageFile);
//   }

//   List<DetectedObject> _mergeAndRankResults(
//     List<DetectedObject> local,
//     List<DetectedObject> cloud,
//   ) {
//     final merged = <String, DetectedObject>{};
//     for (final object in local) {
//       merged[object.label.toLowerCase()] = object;
//     }
//     for (final cloudObject in cloud) {
//       final key = cloudObject.label.toLowerCase();
//       final existing = merged[key];
//       if (existing == null || cloudObject.confidence > existing.confidence) {
//         merged[key] = cloudObject.copyWith(
//           confidence: (existing?.confidence ?? 0 + cloudObject.confidence) / 2,
//         );
//       }
//     }
//     return merged.values.toList()
//       ..sort((a, b) => b.confidence.compareTo(a.confidence));
//   }

//   Future<void> _fetchEnhancedDetails(List<DetectedObject> objects) async {
//     final canProceed = await _subscriptionService.checkUsageLimits(
//       apiCalls: objects.length,
//       batchScans: 1,
//     );
//     if (!canProceed) {
//       throw Exception('API usage limit reached. Please try again later.');
//     }
//     for (final object in objects) {
//       try {
//         final futures = await Future.wait([
//           _apiService.getObjectDescription(object.label),
//           _apiService.getObjectFunFact(object.label),
//           _apiService.getEstimatedPrice(object.label),
//         ]);

//         final updatedObject = object.copyWith(
//           description: futures[0] as String?,
//           funFact: futures[1] as String?,
//           estimatedPrice: futures[2] as double?,
//         );

//         _updateObjectInCurrentResult(updatedObject);
//       } catch (e) {
//         debugPrint('Error fetching enhanced details for ${object.label}: $e');
//       }
//     }
//   }

//   void _updateObjectInCurrentResult(DetectedObject updatedObject) {
//     if (state.currentResult == null) return;
//     final objects = List<DetectedObject>.from(state.currentResult!.objects);
//     final index = objects.indexWhere((obj) => obj.id == updatedObject.id);
//     if (index != -1) {
//       objects[index] = updatedObject;
//       state = state.copyWith(
//         currentResult: state.currentResult!.copyWith(objects: objects),
//       );
//     }
//   }

//   Future<void> performDeepAnalysis(DetectionResult result) async {
//     if (!_isPremium) {
//       throw Exception('Deep analysis requires premium subscription');
//     }
//     final canProceed = await _subscriptionService.checkUsageLimits(apiCalls: 1);
//     if (!canProceed) {
//       throw Exception('API usage limit reached. Please try again later.');
//     }
//     final analysis = await _apiService.performDeepAnalysis(result);
//     state = state.copyWith(
//       currentResult: result.copyWith(deepAnalysis: analysis),
//     );
//   }

//   Future<void> retryDetection(File imageFile) async {
//     await processImage(imageFile);
//   }

//   void clearCurrentResult() {
//     state = state.copyWith(currentResult: null);
//   }
// }

// final detectionProvider =
//     StateNotifierProvider<DetectionProvider, DetectionState>(
//   (ref) => DetectionProvider(ref),
// );


// // providers/favorites_provider.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/detected_object.dart';

// class FavoritesNotifier extends StateNotifier<List<DetectedObject>> {
//   FavoritesNotifier() : super([]) {
//     _loadFavorites();
//   }

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<void> _loadFavorites() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       final querySnapshot = await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('favorites')
//           .orderBy('addedAt', descending: true)
//           .get();

//       final favorites = querySnapshot.docs
//           .map((doc) => DetectedObject.fromMap(doc.data()))
//           .toList();

//       state = favorites;
//     } catch (e) {
//       debugPrint('Error loading favorites: $e');
//     }
//   }

//   Future<void> addFavorite(DetectedObject object) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       // Check if already in favorites
//       if (state.any((fav) => fav.id == object.id)) return;

//       final favoriteData = object.toMap();
//       favoriteData['addedAt'] = FieldValue.serverTimestamp();

//       await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('favorites')
//           .doc(object.id)
//           .set(favoriteData);

//       state = [object, ...state];
//     } catch (e) {
//       debugPrint('Error adding favorite: $e');
//     }
//   }

//   Future<void> removeFavorite(String objectId) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('favorites')
//           .doc(objectId)
//           .delete();

//       state = state.where((fav) => fav.id != objectId).toList();
//     } catch (e) {
//       debugPrint('Error removing favorite: $e');
//     }
//   }

//   Future<void> clearFavorites() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       final batch = _firestore.batch();
//       final collection =
//           _firestore.collection('users').doc(user.uid).collection('favorites');

//       final querySnapshot = await collection.get();
//       for (final doc in querySnapshot.docs) {
//         batch.delete(doc.reference);
//       }

//       await batch.commit();
//       state = [];
//     } catch (e) {
//       debugPrint('Error clearing favorites: $e');
//     }
//   }

//   bool isFavorite(String objectId) {
//     return state.any((fav) => fav.id == objectId);
//   }
// }

// final favoritesProvider =
//     StateNotifierProvider<FavoritesNotifier, List<DetectedObject>>(
//   (ref) => FavoritesNotifier(),
// );


// // providers/history_provider.dart - FIXED VERSION

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/detection_result.dart';
// import '../models/detection_history.dart';

// import '../providers/analytics_provider.dart';
// import '../utils/camera_mode.dart';

// class HistoryNotifier extends StateNotifier<List<DetectionHistory>> {
//   HistoryNotifier(this._ref) : super([]) {
//     _loadHistory();
//   }

//   final Ref _ref;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<void> _loadHistory() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       final querySnapshot = await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('detection_history')
//           .orderBy('timestamp', descending: true)
//           .limit(100)
//           .get();

//       final history = querySnapshot.docs
//           .map((doc) => DetectionHistory.fromMap(doc.data()))
//           .toList();

//       state = history;

//       // Sync analytics with loaded history
//       _syncAnalytics();
//     } catch (e) {
//       debugPrint('Error loading history: $e');
//     }
//   }

//   Future<void> saveResult(DetectionResult result) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       final history = DetectionHistory(
//         id: result.id,
//         imagePath: result.imageFile.path,
//         detectedObjects: result.objects.map((obj) => obj.label).toList(),
//         averageConfidence: result.objects.isEmpty
//             ? 0.0
//             : result.objects
//                     .map((obj) => obj.confidence)
//                     .reduce((a, b) => a + b) /
//                 result.objects.length,
//         timestamp: result.timestamp,
//         mode: result.mode,
//       );

//       // Save to Firestore
//       await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('detection_history')
//           .doc(result.id)
//           .set(history.toMap());

//       // Update local state
//       state = [history, ...state];

//       // CRITICAL: Update analytics after saving
//       _updateAnalyticsForNewDetection(history);
//     } catch (e) {
//       debugPrint('Error saving result: $e');
//     }
//   }

//   Future<void> addFromAutoSave(DetectionHistory history) async {
//     try {
//       // Add directly to state without saving again (since AutoSaveService already saved)
//       state = [history, ...state];

//       // Update analytics too
//       final analyticsNotifier = _ref.read(analyticsProvider.notifier);
//       analyticsNotifier.trackDetection(
//         history.mode ?? CameraMode.object,
//         history.detectedObjects.length,
//         detectedObjects: history.detectedObjects,
//         confidence: history.averageConfidence,
//       );

//       debugPrint('History updated from AutoSave: ${history.id}');
//     } catch (e) {
//       debugPrint('Error adding from AutoSave: $e');
//     }
//   }

//   // New method to update analytics when a detection is saved
//   void _updateAnalyticsForNewDetection(DetectionHistory history) {
//     try {
//       // Import the analytics provider
//       final analyticsNotifier = _ref.read(analyticsProvider.notifier);

//       // Call trackDetection with proper parameters
//       analyticsNotifier.trackDetection(
//         history.mode ?? CameraMode.object,
//         history.detectedObjects.length,
//         detectedObjects: history.detectedObjects,
//         confidence: history.averageConfidence,
//       );

//       debugPrint('Analytics updated for detection: ${history.id}');
//     } catch (e) {
//       debugPrint('Error updating analytics: $e');
//     }
//   }

//   // Method to sync analytics with all history items
//   void _syncAnalytics() {
//     try {
//       final analyticsNotifier = _ref.read(analyticsProvider.notifier);
//       analyticsNotifier.syncWithHistory(state);
//       debugPrint('Analytics synced with ${state.length} history items');
//     } catch (e) {
//       debugPrint('Error syncing analytics: $e');
//     }
//   }

//   Future<void> removeItem(String id) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('detection_history')
//           .doc(id)
//           .delete();

//       state = state.where((item) => item.id != id).toList();

//       // Re-sync analytics after removal
//       _syncAnalytics();
//     } catch (e) {
//       debugPrint('Error removing item: $e');
//     }
//   }

//   Future<void> clearHistory() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       final batch = _firestore.batch();
//       final collection = _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('detection_history');

//       final querySnapshot = await collection.get();
//       for (final doc in querySnapshot.docs) {
//         batch.delete(doc.reference);
//       }

//       await batch.commit();
//       state = [];

//       // Clear analytics as well
//       final analyticsNotifier = _ref.read(analyticsProvider.notifier);
//       analyticsNotifier.clearAnalytics();
//     } catch (e) {
//       debugPrint('Error clearing history: $e');
//     }
//   }

//   // Method to manually refresh history and sync analytics
//   Future<void> refreshHistory() async {
//     await _loadHistory();
//   }
// }

// // Updated provider definition to include Ref parameter
// final historyProvider =
//     StateNotifierProvider<HistoryNotifier, List<DetectionHistory>>(
//   (ref) => HistoryNotifier(ref),
// );


// // providers/real_time_detection_provider.dart

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/detected_object.dart';
// import '../services/ml_service.dart';
// import '../utils/camera_mode.dart';

// class RealTimeDetectionNotifier extends StateNotifier<List<DetectedObject>> {
//   RealTimeDetectionNotifier() : super([]);

//   final MLService _mlService = MLService();

//   Future<void> processFrame(File imageFile, CameraMode mode) async {
//     try {
//       List<DetectedObject> objects = [];

//       switch (mode) {
//         case CameraMode.object:
//           objects = await _mlService.detectObjects(imageFile);
//           break;
//         case CameraMode.text:
//           objects = await _mlService.extractText(imageFile);
//           break;
//         case CameraMode.barcode:
//           objects = await _mlService.scanBarcodes(imageFile);
//           break;
//         default:
//           // For other modes, use basic object detection as fallback
//           objects = await _mlService.detectObjects(imageFile);
//       }

//       // Filter out low confidence detections for real-time use
//       final filteredObjects = objects
//           .where((obj) => obj.confidence > 0.5)
//           .take(5) // Limit to top 5 detections for performance
//           .toList();

//       state = filteredObjects;
//     } catch (e) {
//       debugPrint('Real-time detection error: $e');
//       state = [];
//     }
//   }

//   void clearDetections() {
//     state = [];
//   }

//   @override
//   void dispose() {
//     _mlService.dispose();
//     super.dispose();
//   }
// }

// final realTimeDetectionProvider =
//     StateNotifierProvider<RealTimeDetectionNotifier, List<DetectedObject>>(
//         (ref) {
//   return RealTimeDetectionNotifier();
// });


// // screens/camera_screen.dart - ENHANCED VERSION

// import 'dart:async';
// import 'dart:io';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:sensors_plus/sensors_plus.dart';

// import '../models/camera_state.dart';
// import '../providers/ads_provider.dart';
// import '../providers/camera_provider.dart';
// import '../providers/challenge_provider.dart';
// import '../providers/detection_provider.dart';
// import '../providers/premium_provider.dart';
// import '../providers/real_time_detection_provider.dart';
// import '../providers/analytics_provider.dart';
// import '../config/app_theme.dart';
// import '../utils/camera_mode.dart';
// import '../utils/haptic_feedback.dart';
// import '../utils/sound_manager.dart';
// import '../widgets/camera_settings_sheet.dart';
// import '../widgets/grid_painter.dart';
// import '../widgets/tutorial_overlay.dart';
// import '../widgets/detection_result_overlay.dart';

// class CameraScreen extends ConsumerStatefulWidget {
//   const CameraScreen({super.key});

//   @override
//   ConsumerState<CameraScreen> createState() => _CameraScreenState();
// }

// class _CameraScreenState extends ConsumerState<CameraScreen>
//     with TickerProviderStateMixin, WidgetsBindingObserver {
//   // Animation Controllers
//   late AnimationController _pulseController;
//   late AnimationController _focusController;
//   late AnimationController _overlayController;
//   late AnimationController _modeTransitionController;
//   late AnimationController _captureAnimationController;
//   late AnimationController _uiAnimationController;

//   // Timers
//   Timer? _autoFocusTimer;
//   Timer? _realTimeDetectionTimer;
//   Timer? _captureTimer;
//   StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
//   late final SoundManager _soundManager;
//   late final HapticFeedbackUtil _hapticFeedback;

//   // State Variables
//   bool _isProcessing = false;
//   bool _isRealTimeMode = false;
//   bool _showTutorial = false;
//   bool _isFlashOn = false;
//   bool _showGrid = false;
//   bool _showLevel = false;
//   bool _isBatchMode = false;
//   bool _isTimerMode = false;
//   int _timerSeconds = 3;
//   int _batchCount = 0;
//   final int _maxBatchImages = 5;
//   bool _hasSensorsError = false;

//   Offset? _focusPoint;
//   CameraMode _currentMode = CameraMode.object;

//   // Device orientation tracking
//   double _deviceTilt = 0.0;
//   bool _isDeviceLevel = false;

//   // Voice control
//   final FlutterTts _tts = FlutterTts();
//   bool _isListening = false;

//   // Capture feedback
//   bool _showCaptureFlash = false;

//   Map<String, dynamic>? _challengeArgs;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initializeControllers();
//     _initializeVoiceControl();
//     _initializeSensors();
//     _checkFirstTime();
//     _soundManager = SoundManager();
//     _hapticFeedback = HapticFeedbackUtil();

//     // Initialize camera after build is complete
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeCamera();
//       _checkChallengeArgs();
//     });
//   }

//   void _checkChallengeArgs() {
//     final args =
//         ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//     if (args != null && args['challenge'] == true) {
//       _challengeArgs = args;
//       if (args['challengeType'] == 'plants') {
//         setState(() => _currentMode = CameraMode.plant);
//         _tts.speak("Challenge started: Scan 3 different plants");
//         _showChallengeSnackBar();
//       }
//     }
//   }

//   void _showChallengeSnackBar() {
//     final challengeState = ref.read(challengeProvider);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           '${challengeState.description}\nProgress: ${challengeState.progress}/${challengeState.total}',
//         ),
//         duration: const Duration(seconds: 5),
//         action: SnackBarAction(
//           label: 'OK',
//           onPressed: () {},
//         ),
//       ),
//     );
//   }

//   void _initializeControllers() {
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat(reverse: true);

//     _focusController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _overlayController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _modeTransitionController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );

//     _captureAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );

//     _uiAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     )..forward();
//   }

//   void _initializeVoiceControl() async {
//     try {
//       await _tts.setLanguage("en-US");
//       await _tts.setSpeechRate(0.8);
//       await _tts.setVolume(0.8);
//       await _tts.setPitch(1.0);
//     } catch (e) {
//       debugPrint('TTS initialization failed: $e');
//     }
//   }

//   void _initializeSensors() {
//     try {
//       _accelerometerSubscription = accelerometerEvents.listen(
//         (event) {
//           if (!_hasSensorsError) {
//             final tilt = math.atan2(event.x, event.y) * 180 / math.pi;
//             if (mounted) {
//               setState(() {
//                 _deviceTilt = tilt;
//                 _isDeviceLevel = tilt.abs() < 5;
//               });
//             }
//           }
//         },
//         onError: (error) {
//           debugPrint('Accelerometer error: $error');
//           setState(() => _hasSensorsError = true);
//         },
//       );
//     } catch (e) {
//       debugPrint('Failed to initialize sensors: $e');
//       setState(() => _hasSensorsError = true);
//     }
//   }

//   void _initializeCamera() {
//     Future.microtask(() async {
//       if (mounted) {
//         final cameraNotifier = ref.read(cameraProvider.notifier);
//         await cameraNotifier.initializeCamera();
//       }
//     });
//   }

//   void _checkFirstTime() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final tutorialShown = prefs.getBool('camera_tutorial_shown') ?? false;
//       if (!tutorialShown && mounted) {
//         setState(() => _showTutorial = true);
//         prefs.setBool('camera_tutorial_shown', true);
//       }
//     } catch (e) {
//       debugPrint('Error checking first time: $e');
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     final cameraState = ref.read(cameraProvider);
//     if (!cameraState.isInitialized) return;

//     if (state == AppLifecycleState.inactive) {
//       _stopRealTimeDetection();
//     } else if (state == AppLifecycleState.resumed) {
//       if (_isRealTimeMode) {
//         _startRealTimeDetection();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _pulseController.dispose();
//     _focusController.dispose();
//     _overlayController.dispose();
//     _modeTransitionController.dispose();
//     _captureAnimationController.dispose();
//     _uiAnimationController.dispose();
//     _autoFocusTimer?.cancel();
//     _realTimeDetectionTimer?.cancel();
//     _captureTimer?.cancel();
//     _accelerometerSubscription?.cancel();
//     _tts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cameraState = ref.watch(cameraProvider);
//     final isPremium = ref.watch(premiumProvider).isPremium;
//     final realTimeDetections = ref.watch(realTimeDetectionProvider);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Camera Preview
//           _buildCameraPreview(cameraState),

//           // Real-time Detection Overlay
//           if (_isRealTimeMode && isPremium && realTimeDetections.isNotEmpty)
//             DetectionResultOverlay(
//               detections: realTimeDetections,
//               mode: _currentMode,
//               isRealTime: true,
//             ),

//           // Grid Lines
//           if (_showGrid && cameraState.isInitialized) _buildGridOverlay(),

//           // Level Indicator
//           if (_showLevel && isPremium && !_hasSensorsError)
//             _buildLevelIndicator(),

//           // Focus Point Indicator
//           if (_focusPoint != null) _buildFocusIndicator(),

//           // UI Overlay
//           _buildUIOverlay(isPremium),

//           // Tutorial Overlay
//           if (_showTutorial)
//             TutorialOverlay(
//               mode: _currentMode,
//               onComplete: () => setState(() => _showTutorial = false),
//             ),

//           // Processing Indicator
//           if (_isProcessing) _buildProcessingOverlay(),

//           // Timer Countdown
//           if (_isTimerMode && _captureTimer != null) _buildTimerCountdown(),

//           // Capture Flash Effect
//           if (_showCaptureFlash) _buildCaptureFlash(),

//           // Batch Mode Indicator
//           if (_isBatchMode) _buildBatchModeIndicator(),
//         ],
//       ),
//     );
//   }

//   Widget _buildCameraPreview(CameraState cameraState) {
//     if (cameraState.status == CameraStatus.error) {
//       return _buildErrorState(cameraState.errorMessage ?? 'Camera error');
//     }

//     if (!cameraState.isInitialized) {
//       return _buildLoadingState();
//     }

//     return GestureDetector(
//       onTapUp: _handleFocusTap,
//       onDoubleTap: _switchCamera,
//       onLongPress: _showQuickSettings,
//       child: SizedBox(
//         width: double.infinity,
//         height: double.infinity,
//         child: FittedBox(
//           fit: BoxFit.cover,
//           child: SizedBox(
//             width: cameraState.controller!.value.previewSize!.height,
//             height: cameraState.controller!.value.previewSize!.width,
//             child: CameraPreview(cameraState.controller!),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.black.withOpacity(0.8),
//             Colors.black,
//           ],
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 color: AppTheme.primaryColor.withOpacity(0.2),
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: AppTheme.primaryColor.withOpacity(0.3),
//                   width: 2,
//                 ),
//               ),
//               child: const Icon(
//                 Icons.camera_alt_rounded,
//                 color: AppTheme.primaryColor,
//                 size: 60,
//               ),
//             ).animate().scale().then().shimmer(duration: 2000.ms),
//             const SizedBox(height: 32),
//             Text(
//               'Initializing Camera...',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Setting up AI vision capabilities',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: 200,
//               child: LinearProgressIndicator(
//                 backgroundColor: Colors.white.withOpacity(0.2),
//                 valueColor:
//                     const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorState(String error) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             AppTheme.errorColor.withOpacity(0.1),
//             Colors.black,
//           ],
//         ),
//       ),
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: AppTheme.errorColor.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.error_outline_rounded,
//                   color: AppTheme.errorColor,
//                   size: 50,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Camera Error',
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 error,
//                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       color: Colors.white.withOpacity(0.8),
//                       height: 1.5,
//                     ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       AppTheme.primaryColor,
//                       AppTheme.primaryColor.withOpacity(0.8),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: AppTheme.getElevationShadow(context, 4),
//                 ),
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     HapticFeedback.lightImpact();
//                     _initializeCamera();
//                   },
//                   icon: const Icon(
//                     Icons.refresh_rounded,
//                     color: Colors.white,
//                   ),
//                   label: const Text(
//                     'Retry',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 32,
//                       vertical: 16,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGridOverlay() {
//     return Positioned.fill(
//       child: CustomPaint(
//         painter: GridPainter(
//           lineColor: AppTheme.primaryColor.withOpacity(0.4),
//           strokeWidth: 1.5,
//         ),
//       ),
//     );
//   }

//   Widget _buildLevelIndicator() {
//     return Positioned(
//       top: 120,
//       left: 0,
//       right: 0,
//       child: Center(
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           decoration: BoxDecoration(
//             color: _isDeviceLevel
//                 ? AppTheme.successColor.withOpacity(0.9)
//                 : Colors.black.withOpacity(0.8),
//             borderRadius: BorderRadius.circular(24),
//             border: Border.all(
//               color: _isDeviceLevel
//                   ? AppTheme.successColor
//                   : Colors.white.withOpacity(0.3),
//               width: 2,
//             ),
//             boxShadow: AppTheme.getElevationShadow(context, 4),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 _isDeviceLevel
//                     ? Icons.check_circle_rounded
//                     : Icons.straighten_rounded,
//                 color: Colors.white,
//                 size: 18,
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 _isDeviceLevel
//                     ? 'Perfect Level'
//                     : '${_deviceTilt.toStringAsFixed(1)}°',
//                 style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//               ),
//             ],
//           ),
//         ),
//       )
//           .animate(target: _isDeviceLevel ? 1 : 0)
//           .tint(color: AppTheme.successColor),
//     );
//   }

//   Widget _buildFocusIndicator() {
//     final modeColor = _getModeColor();

//     return Positioned(
//       left: _focusPoint!.dx - 50,
//       top: _focusPoint!.dy - 50,
//       child: AnimatedBuilder(
//         animation: _focusController,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: 1.0 - (_focusController.value * 0.2),
//             child: Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.white.withOpacity(1.0 - _focusController.value),
//                   width: 3,
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Container(
//                 margin: const EdgeInsets.all(25),
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: modeColor.withOpacity(1.0 - _focusController.value),
//                     width: 2,
//                   ),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Center(
//                   child: Container(
//                     width: 4,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: modeColor,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildUIOverlay(bool isPremium) {
//     return AnimatedBuilder(
//       animation: _uiAnimationController,
//       builder: (context, child) {
//         return SafeArea(
//           child: Column(
//             children: [
//               Transform.translate(
//                 offset: Offset(0, -50 * (1 - _uiAnimationController.value)),
//                 child: Opacity(
//                   opacity: _uiAnimationController.value,
//                   child: _buildTopBar(isPremium),
//                 ),
//               ),
//               const Spacer(),
//               Transform.translate(
//                 offset: Offset(0, 50 * (1 - _uiAnimationController.value)),
//                 child: Opacity(
//                   opacity: _uiAnimationController.value,
//                   child: _buildBottomControls(isPremium),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTopBar(bool isPremium) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       child: Row(
//         children: [
//           _buildTopBarButton(
//             icon: Icons.arrow_back_ios_new_rounded,
//             onPressed: () {
//               HapticFeedback.lightImpact();
//               Navigator.pop(context);
//             },
//           ),
//           const SizedBox(width: 12),
//           _buildTopBarButton(
//             icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
//             isActive: _isFlashOn,
//             onPressed: _toggleFlash,
//           ),
//           const Spacer(),
//           _buildModeSelector(),
//           const Spacer(),
//           if (isPremium)
//             _buildTopBarButton(
//               icon: Icons.grid_on_rounded,
//               isActive: _showGrid,
//               onPressed: () {
//                 HapticFeedback.lightImpact();
//                 setState(() => _showGrid = !_showGrid);
//               },
//             ),
//           const SizedBox(width: 12),
//           _buildTopBarButton(
//             icon: Icons.settings_rounded,
//             onPressed: _showCameraSettings,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopBarButton({
//     required IconData icon,
//     required VoidCallback onPressed,
//     bool isActive = false,
//   }) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           color: isActive
//               ? _getModeColor().withOpacity(0.9)
//               : Colors.black.withOpacity(0.6),
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//             color: isActive ? _getModeColor() : Colors.white.withOpacity(0.3),
//             width: 2,
//           ),
//           boxShadow: AppTheme.getElevationShadow(context, 4),
//         ),
//         child: Icon(
//           icon,
//           color: Colors.white,
//           size: 22,
//         ),
//       ),
//     );
//   }

//   Widget _buildModeSelector() {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         _showModeSelection();
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               _getModeColor(),
//               _getModeColor().withOpacity(0.8),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(28),
//           border: Border.all(
//             color: Colors.white.withOpacity(0.3),
//             width: 2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: _getModeColor().withOpacity(0.4),
//               blurRadius: 12,
//               spreadRadius: 2,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               _getModeIcon(_currentMode),
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 10),
//             Text(
//               _getModeLabel(_currentMode),
//               style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//             ),
//             const SizedBox(width: 6),
//             const Icon(
//               Icons.keyboard_arrow_down_rounded,
//               color: Colors.white,
//               size: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomControls(bool isPremium) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (isPremium) ...[
//             _buildPremiumControls(),
//             const SizedBox(height: 24),
//           ],
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildControlButton(
//                 icon: Icons.photo_library_rounded,
//                 onPressed: _pickFromGallery,
//                 size: 56,
//               ),
//               if (isPremium)
//                 _buildControlButton(
//                   icon:
//                       _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
//                   onPressed: _toggleVoiceControl,
//                   size: 56,
//                   isActive: _isListening,
//                   activeColor: AppTheme.errorColor,
//                 ),
//               _buildCaptureButton(),
//               if (isPremium)
//                 _buildControlButton(
//                   icon: Icons.burst_mode_rounded,
//                   onPressed: _toggleBatchMode,
//                   size: 56,
//                   isActive: _isBatchMode,
//                 ),
//               _buildControlButton(
//                 icon: Icons.flip_camera_ios_rounded,
//                 onPressed: _switchCamera,
//                 size: 56,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPremiumControls() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildPremiumControlChip(
//           icon: _isRealTimeMode
//               ? Icons.visibility_rounded
//               : Icons.visibility_off_rounded,
//           label: 'Real-time',
//           isActive: _isRealTimeMode,
//           onTap: () {
//             HapticFeedback.lightImpact();
//             setState(() => _isRealTimeMode = !_isRealTimeMode);
//             if (_isRealTimeMode) {
//               _startRealTimeDetection();
//             } else {
//               _stopRealTimeDetection();
//             }
//           },
//         ),
//         const SizedBox(width: 16),
//         if (!_hasSensorsError)
//           _buildPremiumControlChip(
//             icon: Icons.straighten_rounded,
//             label: 'Level',
//             isActive: _showLevel,
//             onTap: () {
//               HapticFeedback.lightImpact();
//               setState(() => _showLevel = !_showLevel);
//             },
//           ),
//       ],
//     );
//   }

//   Widget _buildPremiumControlChip({
//     required IconData icon,
//     required String label,
//     required bool isActive,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: isActive
//               ? _getModeColor().withOpacity(0.9)
//               : Colors.white.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//             color: isActive ? _getModeColor() : Colors.white.withOpacity(0.3),
//             width: 2,
//           ),
//           boxShadow: isActive ? AppTheme.getElevationShadow(context, 2) : null,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: Colors.white,
//               size: 18,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                     color: Colors.white,
//                     fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
//                   ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildControlButton({
//     required IconData icon,
//     required VoidCallback onPressed,
//     double size = 56,
//     bool isActive = false,
//     Color? activeColor,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         onPressed();
//       },
//       child: Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           color: isActive
//               ? (activeColor ?? _getModeColor()).withOpacity(0.9)
//               : Colors.white.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(size / 2),
//           border: Border.all(
//             color: isActive
//                 ? (activeColor ?? _getModeColor())
//                 : Colors.white.withOpacity(0.5),
//             width: 2,
//           ),
//           boxShadow: AppTheme.getElevationShadow(context, 4),
//         ),
//         child: Icon(
//           icon,
//           color: Colors.white,
//           size: size * 0.4,
//         ),
//       ),
//     );
//   }

//   Widget _buildCaptureButton() {
//     return GestureDetector(
//       onTap: _isProcessing
//           ? null
//           : () {
//               HapticFeedback.mediumImpact();
//               _capturePhoto();
//             },
//       child: AnimatedBuilder(
//         animation: _pulseController,
//         builder: (context, child) {
//           return Container(
//             width: 84,
//             height: 84,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: _getModeColor(),
//                 width: 4 + (_pulseController.value * 2),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: _getModeColor().withOpacity(0.5),
//                   blurRadius: 20 + (_pulseController.value * 10),
//                   spreadRadius: _pulseController.value * 8,
//                 ),
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 15,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: AnimatedBuilder(
//               animation: _captureAnimationController,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: 1.0 - (_captureAnimationController.value * 0.1),
//                   child: Icon(
//                     _getCaptureIcon(),
//                     color: _getModeColor(),
//                     size: 36,
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildProcessingOverlay() {
//     final modeColor = _getModeColor();

//     return Container(
//       color: Colors.black.withOpacity(0.9),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 140,
//               height: 140,
//               decoration: BoxDecoration(
//                 color: modeColor.withOpacity(0.2),
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: modeColor.withOpacity(0.3),
//                   width: 3,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: modeColor.withOpacity(0.3),
//                     blurRadius: 20,
//                     spreadRadius: 5,
//                   ),
//                 ],
//               ),
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   SizedBox(
//                     width: 100,
//                     height: 100,
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation(modeColor),
//                       strokeWidth: 4,
//                     ),
//                   ),
//                   Icon(
//                     _getModeIcon(_currentMode),
//                     color: modeColor,
//                     size: 45,
//                   ),
//                 ],
//               ),
//             ).animate().scale().then().shimmer(duration: 1500.ms),
//             const SizedBox(height: 40),
//             Text(
//               _getProcessingText(),
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'AI is analyzing your ${_currentMode.name}...',
//               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                     color: Colors.white.withOpacity(0.7),
//                   ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 40),
//             SizedBox(
//               width: 250,
//               child: LinearProgressIndicator(
//                 backgroundColor: Colors.white.withOpacity(0.2),
//                 valueColor: AlwaysStoppedAnimation(modeColor),
//                 minHeight: 4,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Please wait...',
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: Colors.white.withOpacity(0.5),
//                   ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTimerCountdown() {
//     final modeColor = _getModeColor();

//     return Container(
//       color: Colors.black.withOpacity(0.95),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: modeColor,
//                   width: 6,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: modeColor.withOpacity(0.5),
//                     blurRadius: 30,
//                     spreadRadius: 10,
//                   ),
//                 ],
//               ),
//               child: Center(
//                 child: Text(
//                   '$_timerSeconds',
//                   style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                         color: modeColor,
//                         fontSize: 120,
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//               ),
//             ).animate().scale(duration: 1000.ms),
//             const SizedBox(height: 40),
//             Text(
//               'Get ready!',
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     color: Colors.white.withOpacity(0.9),
//                     fontWeight: FontWeight.w600,
//                   ),
//             ),
//             const SizedBox(height: 60),
//             Container(
//               decoration: BoxDecoration(
//                 color: AppTheme.errorColor,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: AppTheme.getElevationShadow(context, 4),
//               ),
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   HapticFeedback.lightImpact();
//                   _cancelTimer();
//                 },
//                 icon: const Icon(
//                   Icons.close_rounded,
//                   color: Colors.white,
//                 ),
//                 label: const Text(
//                   'Cancel',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   elevation: 0,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCaptureFlash() {
//     return AnimatedOpacity(
//       opacity: _showCaptureFlash ? 1.0 : 0.0,
//       duration: const Duration(milliseconds: 100),
//       child: Container(
//         color: Colors.white,
//         width: double.infinity,
//         height: double.infinity,
//       ),
//     );
//   }

//   Widget _buildBatchModeIndicator() {
//     final modeColor = _getModeColor();

//     return Positioned(
//       top: 180,
//       right: 24,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               modeColor,
//               modeColor.withOpacity(0.8),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: Colors.white.withOpacity(0.3),
//             width: 2,
//           ),
//           boxShadow: AppTheme.getElevationShadow(context, 4),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'BATCH MODE',
//               style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.5,
//                   ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '$_batchCount/$_maxBatchImages',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//           ],
//         ),
//       ).animate().slideX().fadeIn(),
//     );
//   }

//   // Event handlers and helper methods
//   void _handleFocusTap(TapUpDetails details) async {
//     final cameraState = ref.read(cameraProvider);
//     if (!cameraState.isInitialized) return;

//     setState(() => _focusPoint = details.localPosition);

//     _focusController.forward().then((_) {
//       _focusController.reverse().then((_) {
//         if (mounted) {
//           setState(() => _focusPoint = null);
//         }
//       });
//     });

//     try {
//       final cameraNotifier = ref.read(cameraProvider.notifier);
//       await cameraNotifier.setFocusPoint(details.localPosition);
//       // Enhanced feedback
//       await _hapticFeedback.focusTap();
//       await _soundManager.playFocusSound();
//       await _tts.speak("Focus set");
//     } catch (e) {
//       debugPrint('Focus error: $e');
//     }
//   }

//   void _switchCamera() async {
//     try {
//       // Enhanced feedback
//       await _hapticFeedback.cameraSwitch();
//       await _soundManager.playModeSwitch();
//       final cameraNotifier = ref.read(cameraProvider.notifier);
//       await cameraNotifier.switchCamera();
//       await _tts.speak("Camera switched");
//     } catch (e) {
//       _showErrorSnackBar('Failed to switch camera: $e');
//     }
//   }

//   void _capturePhoto() async {
//     if (_isProcessing) return;

//     if (_isTimerMode) {
//       _startCaptureTimer();
//       return;
//     }

//     await _performCapture();
//   }

//   void _startCaptureTimer() {
//     setState(() => _timerSeconds = 3);

//     _captureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         setState(() => _timerSeconds--);
//         _tts.speak(_timerSeconds.toString());
//         HapticFeedback.lightImpact();

//         if (_timerSeconds <= 0) {
//           timer.cancel();
//           _captureTimer = null;
//           _performCapture();
//         }
//       } else {
//         timer.cancel();
//         _captureTimer = null;
//       }
//     });
//   }

//   Future<void> _performCapture() async {
//     if (!mounted) return;

//     setState(() => _isProcessing = true);

//     // Enhanced feedback
//     await _hapticFeedback.capturePhoto();
//     await _soundManager.playShutter();

//     // Capture animation and feedback
//     _captureAnimationController.forward().then((_) {
//       _captureAnimationController.reverse();
//     });

//     setState(() => _showCaptureFlash = true);
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (mounted) {
//         setState(() => _showCaptureFlash = false);
//       }
//     });

//     try {
//       final cameraNotifier = ref.read(cameraProvider.notifier);
//       final detectionNotifier = ref.read(detectionProvider.notifier);

//       final imageFile = await cameraNotifier.takePicture();
//       if (imageFile != null) {
//         await detectionNotifier.processImage(
//           File(imageFile.path),
//           mode: _currentMode,
//         );

//         ref.read(analyticsProvider.notifier).trackDetection(_currentMode, 1);

//         if (_isBatchMode) {
//           setState(() => _batchCount++);

//           if (_batchCount >= _maxBatchImages) {
//             setState(() {
//               _isBatchMode = false;
//               _batchCount = 0;
//             });
//             await _tts.speak("Batch capture complete");
//           } else {
//             await _tts.speak("Image $_batchCount captured");
//           }
//         }

//         // Use the confidence from the current detection result
//         final detectionResult = ref.read(detectionProvider).currentResult;
//         final confidence =
//             detectionResult?.averageConfidence ?? 0.5; // fallback default

//         await _hapticFeedback.detectionComplete(confidence: confidence);

//         await _soundManager.playDetectionComplete();

//         if (mounted) {
//           final isPremium = ref.read(premiumProvider).isPremium;

//           // Show interstitial ad before navigating to results
//           if (!isPremium) {
//             ref.read(adsProvider.notifier).showInterstitialAd(
//               onAdDismissed: () {
//                 if (mounted) {
//                   Navigator.pushNamed(context, '/result');
//                 }
//               },
//             );
//           } else {
//             Navigator.pushNamed(context, '/result');
//           }
//         }
//       }

//       // In _performCapture (add to the try block after processing image)
//       final detectionResult = ref.read(detectionProvider).currentResult;
//       if (detectionResult != null && _challengeArgs != null) {
//         if (_currentMode == CameraMode.plant &&
//             detectionResult.objects.isNotEmpty) {
//           // Assume first object is the detected plant; adjust based on your model
//           if (detectionResult.objects.first.type?.toLowerCase() == 'plant') {
//             final notifier = ref.read(challengeProvider.notifier);
//             final newProgress = notifier.incrementProgress();

//             _tts.speak(
//                 "Plant detected. Progress: $newProgress/${_challengeArgs!['challengeTarget']}");

//             if (newProgress >= _challengeArgs!['challengeTarget']) {
//               notifier.completeChallenge();
//               _tts.speak(
//                   "Challenge completed! You've earned ${_challengeArgs!['reward']}");
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                     content: Text(
//                         'Challenge Completed! Reward: ${_challengeArgs!['reward']}')),
//               );
//               // Optionally pop back to HomeScreen
//               Navigator.pop(context);
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                     content: Text(
//                         'Progress: $newProgress/${_challengeArgs!['challengeTarget']}')),
//               );
//             }
//           } else {
//             _tts.speak("No plant detected. Try again.");
//           }
//         }
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to capture image: $e');
//       await _hapticFeedback.detectionError();
//       await _soundManager.playError();
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//       }
//     }
//   }

//   void _cancelTimer() {
//     _captureTimer?.cancel();
//     _captureTimer = null;
//     if (mounted) {
//       setState(() => _timerSeconds = 3);
//     }
//   }

//   void _pickFromGallery() async {
//     try {
//       HapticFeedback.lightImpact();
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 90,
//         maxWidth: 1920,
//         maxHeight: 1080,
//       );

//       if (image != null && mounted) {
//         setState(() => _isProcessing = true);

//         final detectionNotifier = ref.read(detectionProvider.notifier);
//         await detectionNotifier.processImage(
//           File(image.path),
//           mode: _currentMode, // Use the currently selected mode
//         );

//         ref.read(analyticsProvider.notifier).trackDetection(_currentMode, 0);

//         if (mounted) {
//           // Check if processing was successful
//           final detectionState = ref.read(detectionProvider);
//           if (detectionState.currentResult != null) {
//             final isPremium = ref.read(premiumProvider).isPremium;

//             // Show interstitial ad for non-premium users
//             if (!isPremium) {
//               ref.read(adsProvider.notifier).showInterstitialAd(
//                 onAdDismissed: () {
//                   if (mounted) {
//                     Navigator.pushNamed(context, '/result');
//                   }
//                 },
//               );
//             } else {
//               Navigator.pushNamed(context, '/result');
//             }
//           } else {
//             _showErrorSnackBar('Failed to process the selected image');
//           }
//         }
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to pick image: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//       }
//     }
//   }

//   void _toggleVoiceControl() async {
//     HapticFeedback.lightImpact();

//     if (_isListening) {
//       setState(() => _isListening = false);
//       await _tts.speak("Voice commands disabled");
//     } else {
//       setState(() => _isListening = true);
//       await _tts.speak(
//           "Voice commands enabled. Say capture, switch camera, or toggle flash");

//       if (mounted) {
//         _showVoiceCommandsSnackBar();
//       }
//     }
//   }

//   void _showVoiceCommandsSnackBar() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.mic_rounded,
//               color: Theme.of(context).colorScheme.onPrimary,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             const Expanded(
//               child: Text(
//                 'Voice commands: "Capture", "Switch camera", "Toggle flash"',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         duration: const Duration(seconds: 4),
//         backgroundColor: _getModeColor(),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//         action: SnackBarAction(
//           label: 'OK',
//           textColor: Colors.white,
//           onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
//         ),
//       ),
//     );
//   }

//   void _toggleBatchMode() {
//     if (!ref.read(premiumProvider).isPremium) {
//       _showPremiumRequired();
//       return;
//     }

//     HapticFeedback.lightImpact();
//     setState(() {
//       _isBatchMode = !_isBatchMode;
//       if (!_isBatchMode) {
//         _batchCount = 0;
//       }
//     });

//     final message = _isBatchMode
//         ? "Batch mode enabled. Capture up to $_maxBatchImages images."
//         : "Batch mode disabled";

//     _tts.speak(message);
//   }

//   void _toggleFlash() async {
//     try {
//       HapticFeedback.lightImpact();
//       final cameraNotifier = ref.read(cameraProvider.notifier);
//       await cameraNotifier.toggleFlash();

//       final flashState = ref.read(cameraProvider).isFlashOn;
//       setState(() => _isFlashOn = flashState);

//       await _tts.speak(flashState ? "Flash on" : "Flash off");
//     } catch (e) {
//       _showErrorSnackBar('Failed to toggle flash: $e');
//     }
//   }

//   void _startRealTimeDetection() {
//     if (!ref.read(premiumProvider).isPremium) {
//       _showPremiumRequired();
//       return;
//     }

//     _realTimeDetectionTimer = Timer.periodic(
//       const Duration(milliseconds: 800),
//       (timer) async {
//         if (!_isRealTimeMode || _isProcessing || !mounted) {
//           return;
//         }

//         try {
//           final cameraState = ref.read(cameraProvider);
//           if (!cameraState.isInitialized) return;

//           final cameraNotifier = ref.read(cameraProvider.notifier);
//           final image = await cameraNotifier.takePicture();

//           if (image != null && mounted) {
//             ref.read(realTimeDetectionProvider.notifier).processFrame(
//                   File(image.path),
//                   _currentMode,
//                 );
//           }
//         } catch (e) {
//           debugPrint('Real-time detection error: $e');
//         }
//       },
//     );
//   }

//   void _stopRealTimeDetection() {
//     _realTimeDetectionTimer?.cancel();
//     _realTimeDetectionTimer = null;
//     if (mounted) {
//       ref.read(realTimeDetectionProvider.notifier).clearDetections();
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.error_outline_rounded,
//               color: Theme.of(context).colorScheme.onError,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.onError,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Theme.of(context).colorScheme.error,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 3),
//         action: SnackBarAction(
//           label: 'Dismiss',
//           textColor: Theme.of(context).colorScheme.onError,
//           onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
//         ),
//       ),
//     );
//   }

//   void _showCameraSettings() {
//     HapticFeedback.lightImpact();
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const CameraSettingsSheet(),
//     );
//   }

//   void _showModeSelection() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true, // Important: allows custom height
//       builder: (context) => Container(
//         // Use constraints to limit height and make it responsive
//         constraints: BoxConstraints(
//           maxHeight:
//               MediaQuery.of(context).size.height * 0.8, // Max 80% of screen
//         ),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.95),
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           border: Border.all(
//             color: Colors.white.withOpacity(0.1),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Handle
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(top: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),

//             // Header
//             Padding(
//               padding: const EdgeInsets.all(16), // Reduced from 24
//               child: Text(
//                 'Detection Mode',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//             ),

//             // Mode grid - Make it flexible and scrollable
//             Flexible(
//               child: GridView.builder(
//                 shrinkWrap: true, // Important: allows grid to size itself
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 16), // Reduced padding
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio:
//                       _getAspectRatio(context), // Dynamic aspect ratio
//                   crossAxisSpacing: 12, // Reduced spacing
//                   mainAxisSpacing: 12,
//                 ),
//                 itemCount: CameraMode.values.length,
//                 itemBuilder: (context, index) {
//                   final mode = CameraMode.values[index];
//                   final isSelected = mode == _currentMode;
//                   final isPremiumMode = _isPremiumMode(mode);
//                   final isPremium = ref.read(premiumProvider).isPremium;

//                   return GestureDetector(
//                     onTap: () {
//                       HapticFeedback.lightImpact();

//                       if (isPremiumMode && !isPremium) {
//                         Navigator.pop(context);
//                         _showPremiumRequired(mode);
//                         return;
//                       }

//                       setState(() => _currentMode = mode);
//                       Navigator.pop(context);
//                       _onModeChanged(mode);
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: isSelected
//                             ? LinearGradient(
//                                 colors: [
//                                   _getModeColor(mode),
//                                   _getModeColor(mode).withOpacity(0.8),
//                                 ],
//                               )
//                             : null,
//                         color:
//                             !isSelected ? Colors.white.withOpacity(0.1) : null,
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: isSelected
//                               ? _getModeColor(mode)
//                               : Colors.white.withOpacity(0.3),
//                           width: isSelected ? 3 : 1,
//                         ),
//                         boxShadow: isSelected
//                             ? [
//                                 BoxShadow(
//                                   color: _getModeColor(mode).withOpacity(0.3),
//                                   blurRadius: 12,
//                                   spreadRadius: 2,
//                                 ),
//                               ]
//                             : null,
//                       ),
//                       child: Stack(
//                         children: [
//                           Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   _getModeIcon(mode),
//                                   color: Colors.white,
//                                   size: _getIconSize(
//                                       context), // Dynamic icon size
//                                 ),
//                                 SizedBox(
//                                     height: _getSpacing(
//                                         context)), // Dynamic spacing
//                                 Text(
//                                   _getModeLabel(mode),
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .labelLarge
//                                       ?.copyWith(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: _getFontSize(
//                                             context), // Dynamic font size
//                                       ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           if (isPremiumMode && !isPremium)
//                             Positioned(
//                               top: 8,
//                               right: 8,
//                               child: Container(
//                                 padding: const EdgeInsets.all(4),
//                                 decoration: BoxDecoration(
//                                   color: AppTheme.premiumGold,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: const Icon(
//                                   Icons.diamond_rounded,
//                                   color: Colors.white,
//                                   size: 12,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             SizedBox(
//                 height: _getBottomSpacing(context)), // Dynamic bottom spacing
//           ],
//         ),
//       ),
//     );
//   }

// // Helper methods for responsive sizing
//   double _getAspectRatio(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     // Adjust aspect ratio based on screen height
//     if (screenHeight < 600) return 1.8; // Taller items on very small screens
//     if (screenHeight < 700) return 1.6; // Medium adjustment
//     return 1.5; // Default for larger screens
//   }

//   double _getIconSize(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     if (screenHeight < 600) return 24;
//     if (screenHeight < 700) return 26;
//     return 28;
//   }

//   double _getSpacing(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     if (screenHeight < 600) return 4;
//     if (screenHeight < 700) return 6;
//     return 8;
//   }

//   double _getFontSize(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     if (screenHeight < 600) return 12;
//     if (screenHeight < 700) return 13;
//     return 14;
//   }

//   double _getBottomSpacing(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     if (screenHeight < 600) return 16;
//     return 24;
//   }

//   void _showQuickSettings() {
//     HapticFeedback.mediumImpact();
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.95),
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           border: Border.all(
//             color: Colors.white.withOpacity(0.1),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Handle
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(top: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),

//             // Header
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Text(
//                 'Quick Settings',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//             ),

//             // Settings list
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 children: [
//                   _buildQuickSettingTile(
//                     icon: Icons.grid_on_rounded,
//                     title: 'Grid Lines',
//                     value: _showGrid,
//                     onChanged: (value) => setState(() => _showGrid = value),
//                   ),
//                   if (!_hasSensorsError)
//                     _buildQuickSettingTile(
//                       icon: Icons.straighten_rounded,
//                       title: 'Level Indicator',
//                       value: _showLevel,
//                       onChanged: (value) => setState(() => _showLevel = value),
//                       isPremium: true,
//                     ),
//                   _buildQuickSettingTile(
//                     icon: Icons.timer_rounded,
//                     title: 'Timer Mode',
//                     value: _isTimerMode,
//                     onChanged: (value) => setState(() => _isTimerMode = value),
//                   ),
//                   _buildQuickSettingTile(
//                     icon: Icons.burst_mode_rounded,
//                     title: 'Batch Mode',
//                     value: _isBatchMode,
//                     onChanged: (value) => _toggleBatchMode(),
//                     isPremium: true,
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickSettingTile({
//     required IconData icon,
//     required String title,
//     required bool value,
//     required Function(bool) onChanged,
//     bool isPremium = false,
//   }) {
//     final userIsPremium = ref.read(premiumProvider).isPremium;
//     final isEnabled = !isPremium || userIsPremium;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.1),
//           width: 1,
//         ),
//       ),
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: isEnabled ? Colors.white : Colors.grey,
//           size: 24,
//         ),
//         title: Row(
//           children: [
//             Text(
//               title,
//               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                     color: isEnabled ? Colors.white : Colors.grey,
//                     fontWeight: FontWeight.w500,
//                   ),
//             ),
//             if (isPremium && !userIsPremium) ...[
//               const SizedBox(width: 8),
//               const Icon(
//                 Icons.diamond_rounded,
//                 color: AppTheme.premiumGold,
//                 size: 16,
//               ),
//             ],
//           ],
//         ),
//         trailing: Switch(
//           value: isEnabled ? value : false,
//           onChanged: isEnabled
//               ? (newValue) {
//                   HapticFeedback.lightImpact();
//                   onChanged(newValue);
//                 }
//               : (value) => _showPremiumRequired(),
//           thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
//             if (states.contains(WidgetState.selected)) {
//               return _getModeColor(); // Active thumb color
//             }
//             return Colors.grey.shade400; // Inactive thumb color
//           }),
//           trackColor: WidgetStateProperty.resolveWith<Color>((states) {
//             if (states.contains(WidgetState.selected)) {
//               return _getModeColor().withOpacity(0.3); // Active track color
//             }
//             return Colors.grey.shade600; // Inactive track color
//           }),
//         ),
//         onTap: isEnabled
//             ? () {
//                 HapticFeedback.lightImpact();
//                 onChanged(!value);
//               }
//             : () => _showPremiumRequired(),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     );
//   }

//   void _onModeChanged(CameraMode newMode) {
//     _modeTransitionController.forward().then((_) {
//       _modeTransitionController.reverse();
//     });

//     if (_isRealTimeMode) {
//       _stopRealTimeDetection();
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted) {
//           _startRealTimeDetection();
//         }
//       });
//     }

//     _tts.speak("${_getModeLabel(newMode)} mode selected");
//   }

//   void _showPremiumRequired([CameraMode? mode]) {
//     final modeText = mode != null ? ' for ${_getModeLabel(mode)} mode' : '';

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             const Icon(
//               Icons.diamond_rounded,
//               color: AppTheme.premiumGold,
//               size: 24,
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'Premium Required',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//           ],
//         ),
//         content: Text(
//           'This feature$modeText requires a premium subscription. Upgrade now to unlock advanced AI capabilities.',
//           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                 height: 1.5,
//               ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Later',
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               gradient: AppTheme.premiumGradient,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/premium');
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//               ),
//               child: const Text(
//                 'Upgrade',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper methods
//   bool _isPremiumMode(CameraMode mode) {
//     return [
//       CameraMode.landmark,
//       CameraMode.plant,
//       CameraMode.animal,
//       CameraMode.food,
//       CameraMode.document,
//     ].contains(mode);
//   }

//   Color _getModeColor([CameraMode? mode]) {
//     final targetMode = mode ?? _currentMode;
//     switch (targetMode) {
//       case CameraMode.object:
//         return AppTheme.primaryColor;
//       case CameraMode.text:
//         return AppTheme.successColor;
//       case CameraMode.barcode:
//         return AppTheme.secondaryColor;
//       case CameraMode.landmark:
//         return AppTheme.warningColor;
//       case CameraMode.plant:
//         return AppTheme.successColor.withOpacity(0.8);
//       case CameraMode.animal:
//         return const Color(0xFF8D6E63); // Brown
//       case CameraMode.food:
//         return AppTheme.errorColor;
//       case CameraMode.document:
//         return const Color(0xFF3F51B5); // Indigo
//     }
//   }

//   IconData _getModeIcon(CameraMode mode) {
//     switch (mode) {
//       case CameraMode.object:
//         return Icons.category_rounded;
//       case CameraMode.text:
//         return Icons.text_fields_rounded;
//       case CameraMode.barcode:
//         return Icons.qr_code_rounded;
//       case CameraMode.landmark:
//         return Icons.location_city_rounded;
//       case CameraMode.plant:
//         return Icons.local_florist_rounded;
//       case CameraMode.animal:
//         return Icons.pets_rounded;
//       case CameraMode.food:
//         return Icons.restaurant_rounded;
//       case CameraMode.document:
//         return Icons.description_rounded;
//     }
//   }

//   String _getModeLabel(CameraMode mode) {
//     switch (mode) {
//       case CameraMode.object:
//         return 'Objects';
//       case CameraMode.text:
//         return 'Text';
//       case CameraMode.barcode:
//         return 'Barcode';
//       case CameraMode.landmark:
//         return 'Landmarks';
//       case CameraMode.plant:
//         return 'Plants';
//       case CameraMode.animal:
//         return 'Animals';
//       case CameraMode.food:
//         return 'Food';
//       case CameraMode.document:
//         return 'Documents';
//     }
//   }

//   IconData _getCaptureIcon() {
//     switch (_currentMode) {
//       case CameraMode.text:
//         return Icons.text_format_rounded;
//       case CameraMode.barcode:
//         return Icons.qr_code_scanner_rounded;
//       case CameraMode.document:
//         return Icons.document_scanner_rounded;
//       default:
//         return Icons.camera_rounded;
//     }
//   }

//   String _getProcessingText() {
//     switch (_currentMode) {
//       case CameraMode.object:
//         return 'Identifying Objects';
//       case CameraMode.text:
//         return 'Extracting Text';
//       case CameraMode.barcode:
//         return 'Scanning Code';
//       case CameraMode.landmark:
//         return 'Recognizing Landmark';
//       case CameraMode.plant:
//         return 'Identifying Plant';
//       case CameraMode.animal:
//         return 'Recognizing Animal';
//       case CameraMode.food:
//         return 'Analyzing Food';
//       case CameraMode.document:
//         return 'Processing Document';
//     }
//   }
// }

// // screens/history_screen.dart

// import 'dart:convert';
// import 'dart:io';
// import 'package:csv/csv.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:share_plus/share_plus.dart';

// import '../models/detection_history.dart';
// import '../providers/history_provider.dart';
// import '../providers/premium_provider.dart';
// import '../providers/analytics_provider.dart';
// import '../config/app_theme.dart';
// import '../widgets/ad_widgets.dart';

// class HistoryScreen extends ConsumerStatefulWidget {
//   const HistoryScreen({super.key});

//   @override
//   ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends ConsumerState<HistoryScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late AnimationController _searchController;

//   String _sortBy = 'Recent';
//   String _filterBy = 'All';
//   bool _isSearching = false;
//   final TextEditingController _searchTextController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _searchController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _fadeController.forward();
//     _slideController.forward();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     _searchController.dispose();
//     _searchTextController.dispose();
//     super.dispose();
//   }

//   List<DetectionHistory> _getFilteredHistory(List<DetectionHistory> history) {
//     var filtered = List<DetectionHistory>.from(history);

//     // Apply search filter
//     if (_searchTextController.text.isNotEmpty) {
//       filtered = filtered.where((item) {
//         return item.detectedObjects.any((object) => object
//             .toLowerCase()
//             .contains(_searchTextController.text.toLowerCase()));
//       }).toList();
//     }

//     // Apply category filter
//     if (_filterBy != 'All') {
//       filtered = filtered.where((item) {
//         return item.detectedObjects.any(
//             (object) => _categorizeObject(object) == _filterBy.toLowerCase());
//       }).toList();
//     }

//     // Apply sorting
//     switch (_sortBy) {
//       case 'Recent':
//         filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//         break;
//       case 'Oldest':
//         filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
//         break;
//       case 'Confidence':
//         filtered
//             .sort((a, b) => b.averageConfidence.compareTo(a.averageConfidence));
//         break;
//     }

//     return filtered;
//   }

//   String _categorizeObject(String label) {
//     final lowercaseLabel = label.toLowerCase();
//     if (lowercaseLabel.contains('person') ||
//         lowercaseLabel.contains('people')) {
//       return 'people';
//     } else if (lowercaseLabel.contains('car') ||
//         lowercaseLabel.contains('vehicle')) {
//       return 'vehicles';
//     } else if (lowercaseLabel.contains('animal') ||
//         lowercaseLabel.contains('dog') ||
//         lowercaseLabel.contains('cat')) {
//       return 'animals';
//     }
//     return 'objects';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final historyList = ref.watch(historyProvider);
//     final isPremium = ref.watch(premiumProvider).isPremium;
//     final analyticsState = ref.watch(analyticsProvider);
//     final filteredHistory = _getFilteredHistory(historyList);
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           _buildSliverAppBar(historyList.length, theme),
//           if (historyList.isNotEmpty) ...[
//             _buildStatsOverview(analyticsState, historyList, theme),
//             _buildFilterSortBar(theme),
//           ],
//           _buildHistoryContent(filteredHistory, isPremium, theme),
//         ],
//       ),
//     );
//   }

//   Widget _buildSliverAppBar(int totalCount, ThemeData theme) {
//     return SliverAppBar(
//       expandedHeight: 140,
//       floating: true,
//       pinned: false,
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 theme.colorScheme.primary.withOpacity(0.1),
//                 theme.colorScheme.secondary.withOpacity(0.05),
//                 theme.colorScheme.surface,
//               ],
//             ),
//           ),
//           padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _isSearching ? 'Search History' : 'Detection History',
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ).animate().slideX().fadeIn(),
//                     const SizedBox(height: 8),
//                     Text(
//                       '$totalCount ${totalCount == 1 ? 'detection' : 'detections'} saved',
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: theme.colorScheme.onSurfaceVariant,
//                       ),
//                     ).animate(delay: 200.ms).slideX().fadeIn(),
//                   ],
//                 ),
//               ),
//               _buildAppBarActions(theme)
//                   .animate(delay: 400.ms)
//                   .slideX()
//                   .fadeIn(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAppBarActions(ThemeData theme) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (_isSearching) ...[
//           Container(
//             width: 200,
//             height: 44,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.surfaceContainerHighest,
//               borderRadius: BorderRadius.circular(22),
//               border: Border.all(
//                 color: theme.colorScheme.outline.withOpacity(0.3),
//               ),
//             ),
//             child: TextField(
//               controller: _searchTextController,
//               style: theme.textTheme.bodyMedium,
//               decoration: InputDecoration(
//                 hintText: 'Search detections...',
//                 hintStyle: TextStyle(
//                   color: theme.colorScheme.onSurfaceVariant,
//                 ),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//                 prefixIcon: Icon(
//                   Icons.search_rounded,
//                   color: theme.colorScheme.onSurfaceVariant,
//                   size: 20,
//                 ),
//               ),
//               onChanged: (value) {
//                 HapticFeedback.selectionClick();
//                 setState(() {});
//               },
//             ),
//           ),
//           const SizedBox(width: 8),
//           _buildActionButton(
//             icon: Icons.close_rounded,
//             onPressed: () {
//               HapticFeedback.lightImpact();
//               setState(() {
//                 _isSearching = false;
//                 _searchTextController.clear();
//               });
//               _searchController.reverse();
//             },
//             theme: theme,
//           ),
//         ] else ...[
//           _buildActionButton(
//             icon: Icons.search_rounded,
//             onPressed: () {
//               HapticFeedback.lightImpact();
//               setState(() => _isSearching = true);
//               _searchController.forward();
//             },
//             theme: theme,
//           ),
//           const SizedBox(width: 8),
//           _buildPopupMenu(theme),
//         ],
//       ],
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required VoidCallback onPressed,
//     required ThemeData theme,
//   }) {
//     return Container(
//       width: 44,
//       height: 44,
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.3),
//         ),
//       ),
//       child: IconButton(
//         icon: Icon(
//           icon,
//           color: theme.colorScheme.onSurfaceVariant,
//           size: 20,
//         ),
//         onPressed: onPressed,
//         splashRadius: 22,
//       ),
//     );
//   }

//   Widget _buildPopupMenu(ThemeData theme) {
//     return Container(
//       width: 44,
//       height: 44,
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.3),
//         ),
//       ),
//       child: PopupMenuButton<String>(
//         onSelected: _handleMenuAction,
//         icon: Icon(
//           Icons.more_vert_rounded,
//           color: theme.colorScheme.onSurfaceVariant,
//           size: 20,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         itemBuilder: (context) => [
//           PopupMenuItem(
//             value: 'export',
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.download_rounded,
//                   color: theme.colorScheme.primary,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Export History',
//                   style: theme.textTheme.bodyMedium,
//                 ),
//               ],
//             ),
//           ),
//           PopupMenuItem(
//             value: 'clear_all',
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.delete_sweep_rounded,
//                   color: theme.colorScheme.error,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Clear All',
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: theme.colorScheme.error,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsOverview(AnalyticsState analyticsState,
//       List<DetectionHistory> history, ThemeData theme) {
//     final totalObjects =
//         history.fold<int>(0, (sum, item) => sum + item.detectedObjects.length);
//     final avgConfidence = history.isEmpty
//         ? 0.0
//         : history.fold<double>(0, (sum, item) => sum + item.averageConfidence) /
//             history.length;

//     return SliverToBoxAdapter(
//       child: Container(
//         margin: const EdgeInsets.all(20),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               theme.colorScheme.primary.withOpacity(0.1),
//               theme.colorScheme.secondary.withOpacity(0.1),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: theme.colorScheme.outline.withOpacity(0.2),
//           ),
//           boxShadow: AppTheme.getElevationShadow(context, 2),
//         ),
//         child: IntrinsicHeight(
//           child: Row(
//             children: [
//               Expanded(
//                 child: _buildStatItem(
//                   'Total\nScans',
//                   '${history.length}',
//                   Icons.history_rounded,
//                   theme,
//                 ),
//               ),
//               _buildDivider(theme),
//               Expanded(
//                 child: _buildStatItem(
//                   'Objects\nFound',
//                   '$totalObjects',
//                   Icons.category_rounded,
//                   theme,
//                 ),
//               ),
//               _buildDivider(theme),
//               Expanded(
//                 child: _buildStatItem(
//                   'Avg\nAccuracy',
//                   '${(avgConfidence * 100).toInt()}%',
//                   Icons.trending_up_rounded,
//                   theme,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ).animate().slideY(begin: 0.3).fadeIn(),
//     );
//   }

//   Widget _buildDivider(ThemeData theme) {
//     return Container(
//       width: 1,
//       height: 50,
//       color: theme.colorScheme.outline.withOpacity(0.3),
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//     );
//   }

//   Widget _buildStatItem(
//       String label, String value, IconData icon, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: theme.colorScheme.primary,
//               size: 20,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: theme.textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: theme.colorScheme.onSurfaceVariant,
//               height: 1.3,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterSortBar(ThemeData theme) {
//     return SliverToBoxAdapter(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 20),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surface,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: theme.colorScheme.outline.withOpacity(0.2),
//           ),
//           boxShadow: AppTheme.getElevationShadow(context, 1),
//         ),
//         child: Row(
//           children: [
//             // Filter Dropdown
//             Expanded(
//               child: _buildDropdown(
//                 value: _filterBy,
//                 hint: 'Filter',
//                 items: ['All', 'People', 'Objects', 'Animals', 'Vehicles'],
//                 onChanged: (value) {
//                   HapticFeedback.selectionClick();
//                   setState(() => _filterBy = value!);
//                 },
//                 icon: Icons.filter_list_rounded,
//                 theme: theme,
//               ),
//             ),

//             const SizedBox(width: 16),

//             // Sort Dropdown
//             Expanded(
//               child: _buildDropdown(
//                 value: _sortBy,
//                 hint: 'Sort',
//                 items: ['Recent', 'Oldest', 'Confidence'],
//                 onChanged: (value) {
//                   HapticFeedback.selectionClick();
//                   setState(() => _sortBy = value!);
//                 },
//                 icon: Icons.sort_rounded,
//                 theme: theme,
//               ),
//             ),
//           ],
//         ),
//       ).animate(delay: 200.ms).slideY(begin: 0.3).fadeIn(),
//     );
//   }

//   Widget _buildDropdown({
//     required String value,
//     required String hint,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//     required IconData icon,
//     required ThemeData theme,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.3),
//         ),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           hint: Row(
//             children: [
//               Icon(
//                 icon,
//                 size: 16,
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 hint,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.colorScheme.onSurfaceVariant,
//                 ),
//               ),
//             ],
//           ),
//           isExpanded: true,
//           style: theme.textTheme.bodyMedium?.copyWith(
//             color: theme.colorScheme.onSurface,
//           ),
//           icon: Icon(
//             Icons.keyboard_arrow_down_rounded,
//             color: theme.colorScheme.onSurfaceVariant,
//           ),
//           items: items
//               .map((item) => DropdownMenuItem(
//                     value: item,
//                     child: Row(
//                       children: [
//                         Icon(
//                           icon,
//                           size: 16,
//                           color: theme.colorScheme.primary,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(item),
//                       ],
//                     ),
//                   ))
//               .toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }

//   Widget _buildHistoryContent(
//       List<DetectionHistory> filteredHistory, bool isPremium, ThemeData theme) {
//     if (filteredHistory.isEmpty) {
//       return _buildEmptyState(theme);
//     }

//     return SliverList(
//       delegate: SliverChildBuilderDelegate(
//         (context, index) {
//           final item = filteredHistory[index];

//           // Banner ad every 5 items for non-premium users
//           if (!isPremium && index > 0 && index % 5 == 0) {
//             return Column(
//               children: [
//                 Container(
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   child: const AdBanner(placement: 'history'),
//                 ),
//                 _buildHistoryItem(item, index, isPremium, theme),
//               ],
//             );
//           }

//           return _buildHistoryItem(item, index, isPremium, theme);
//         },
//         childCount: filteredHistory.length,
//       ),
//     );
//   }

//   Widget _buildHistoryItem(
//       DetectionHistory item, int index, bool isPremium, ThemeData theme) {
//     return Container(
//       margin: EdgeInsets.fromLTRB(20, index == 0 ? 20 : 8, 20, 8),
//       child: Card(
//         elevation: 0,
//         color: theme.colorScheme.surface,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//           side: BorderSide(
//             color: theme.colorScheme.outline.withOpacity(0.2),
//           ),
//         ),
//         child: Column(
//           children: [
//             InkWell(
//               onTap: () {
//                 HapticFeedback.lightImpact();
//                 _showHistoryDetails(item, theme);
//               },
//               borderRadius: BorderRadius.circular(16),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     _buildImageThumbnail(item, theme),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item.detectedObjects.join(', '),
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.w600,
//                               color: theme.colorScheme.onSurface,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             _formatTimestamp(item.timestamp),
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               color: theme.colorScheme.onSurfaceVariant,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Row(
//                             children: [
//                               _buildStatChip(
//                                 '${(item.averageConfidence * 100).toInt()}%',
//                                 _getConfidenceColor(item.averageConfidence),
//                                 theme,
//                               ),
//                               const SizedBox(width: 8),
//                               _buildStatChip(
//                                 '${item.detectedObjects.length} objects',
//                                 theme.colorScheme.onSurfaceVariant,
//                                 theme,
//                                 isSecondary: true,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     _buildItemMenu(item, isPremium, theme),
//                   ],
//                 ),
//               ),
//             ),

//             // Ad-supported export for free users
//             if (!isPremium)
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                 child: RewardedAdButton(
//                   featureName: 'Export Data',
//                   onRewardEarned: () => _exportSingleItem(item, theme),
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 12,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppTheme.warningColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: AppTheme.warningColor.withOpacity(0.3),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.download_rounded,
//                           size: 18,
//                           color: AppTheme.warningColor,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Export (Watch Ad)',
//                           style: theme.textTheme.labelLarge?.copyWith(
//                             color: AppTheme.warningColor,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ).animate(delay: (index * 50).ms).slideX().fadeIn(),
//     );
//   }

//   Widget _buildStatChip(String text, Color color, ThemeData theme,
//       {bool isSecondary = false}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: isSecondary
//             ? theme.colorScheme.surfaceContainerHighest
//             : color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isSecondary
//               ? theme.colorScheme.outline.withOpacity(0.3)
//               : color.withOpacity(0.3),
//         ),
//       ),
//       child: Text(
//         text,
//         style: theme.textTheme.labelSmall?.copyWith(
//           color: isSecondary ? theme.colorScheme.onSurfaceVariant : color,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   Widget _buildImageThumbnail(DetectionHistory item, ThemeData theme) {
//     return Container(
//       width: 64,
//       height: 64,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.3),
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(11),
//         child: File(item.imagePath).existsSync()
//             ? Image.file(
//                 File(item.imagePath),
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return _buildPlaceholderThumbnail(theme);
//                 },
//               )
//             : _buildPlaceholderThumbnail(theme),
//       ),
//     );
//   }

//   Widget _buildPlaceholderThumbnail(ThemeData theme) {
//     return Container(
//       color: theme.colorScheme.surfaceContainerHighest,
//       child: Icon(
//         Icons.image_rounded,
//         color: theme.colorScheme.onSurfaceVariant,
//         size: 28,
//       ),
//     );
//   }

//   Widget _buildItemMenu(
//       DetectionHistory item, bool isPremium, ThemeData theme) {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: PopupMenuButton<String>(
//         onSelected: (value) => _handleItemAction(value, item, theme),
//         icon: Icon(
//           Icons.more_vert_rounded,
//           color: theme.colorScheme.onSurfaceVariant,
//           size: 18,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         itemBuilder: (context) => [
//           PopupMenuItem(
//             value: 'view',
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.visibility_rounded,
//                   color: theme.colorScheme.primary,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'View Details',
//                   style: theme.textTheme.bodyMedium,
//                 ),
//               ],
//             ),
//           ),
//           PopupMenuItem(
//             value: 'share',
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.share_rounded,
//                   color: theme.colorScheme.secondary,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Share',
//                   style: theme.textTheme.bodyMedium,
//                 ),
//               ],
//             ),
//           ),
//           if (isPremium)
//             PopupMenuItem(
//               value: 'export',
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.download_rounded,
//                     color: AppTheme.successColor,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     'Export',
//                     style: theme.textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//             ),
//           PopupMenuItem(
//             value: 'delete',
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.delete_rounded,
//                   color: theme.colorScheme.error,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Delete',
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: theme.colorScheme.error,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(ThemeData theme) {
//     return SliverFillRemaining(
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24), // Reduced padding
//           child: SingleChildScrollView(
//             // Added scrollability
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min, // Use minimum space needed
//               children: [
//                 Container(
//                   width: 100, // Reduced size
//                   height: 100, // Reduced size
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     _searchTextController.text.isNotEmpty
//                         ? Icons.search_off_rounded
//                         : Icons.history_rounded,
//                     size: 48, // Reduced icon size
//                     color: theme.colorScheme.primary.withOpacity(0.7),
//                   ),
//                 ).animate().scale(),
//                 const SizedBox(height: 20), // Reduced spacing
//                 Text(
//                   _searchTextController.text.isNotEmpty
//                       ? 'No results found'
//                       : 'No detection history',
//                   style: theme.textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                   textAlign: TextAlign.center,
//                 ).animate(delay: 200.ms).slideY(begin: 0.3).fadeIn(),
//                 const SizedBox(height: 8), // Reduced spacing
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     _searchTextController.text.isNotEmpty
//                         ? 'Try a different search term or filter'
//                         : 'Your scan results will appear here after you start detecting objects',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       // Changed to bodyMedium
//                       color: theme.colorScheme.onSurfaceVariant,
//                       height: 1.4, // Reduced line height
//                     ),
//                     textAlign: TextAlign.center,
//                     maxLines: 3, // Limit lines to prevent overflow
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ).animate(delay: 400.ms).slideY(begin: 0.3).fadeIn(),
//                 if (_searchTextController.text.isEmpty) ...[
//                   const SizedBox(height: 24), // Reduced spacing
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           theme.colorScheme.primary,
//                           theme.colorScheme.secondary,
//                         ],
//                       ),
//                       borderRadius:
//                           BorderRadius.circular(14), // Slightly smaller radius
//                       boxShadow: AppTheme.getElevationShadow(context, 4),
//                     ),
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         HapticFeedback.lightImpact();
//                         Navigator.pushNamed(context, '/camera');
//                       },
//                       icon: const Icon(
//                         Icons.camera_alt_rounded,
//                         color: Colors.white,
//                         size: 20, // Specified icon size
//                       ),
//                       label: const Text(
//                         'Start Scanning',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16, // Specified font size
//                         ),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.transparent,
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 28, // Reduced padding
//                           vertical: 14, // Reduced padding
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                     ),
//                   ).animate(delay: 600.ms).scale(),
//                   const SizedBox(height: 16), // Add bottom spacing for safety
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper Methods
//   String _formatTimestamp(DateTime timestamp) {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);

//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         if (difference.inMinutes == 0) {
//           return 'Just now';
//         }
//         return '${difference.inMinutes}m ago';
//       }
//       return '${difference.inHours}h ago';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d ago';
//     } else {
//       return DateFormat('MMM d, y').format(timestamp);
//     }
//   }

//   Color _getConfidenceColor(double confidence) {
//     if (confidence >= 0.8) return AppTheme.successColor;
//     if (confidence >= 0.6) return AppTheme.warningColor;
//     return AppTheme.errorColor;
//   }

//   // Action Methods
//   void _handleMenuAction(String action) {
//     HapticFeedback.lightImpact();
//     switch (action) {
//       case 'export':
//         _exportHistory();
//         break;
//       case 'clear_all':
//         _showClearAllDialog();
//         break;
//     }
//   }

//   void _handleItemAction(
//       String action, DetectionHistory item, ThemeData theme) {
//     HapticFeedback.lightImpact();
//     switch (action) {
//       case 'view':
//         _showHistoryDetails(item, theme);
//         break;
//       case 'share':
//         _shareHistoryItem(item);
//         break;
//       case 'export':
//         _exportSingleItem(item, theme);
//         break;
//       case 'delete':
//         _deleteHistoryItem(item, theme);
//         break;
//     }
//   }

//   void _showHistoryDetails(DetectionHistory item, ThemeData theme) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.7,
//         minChildSize: 0.5,
//         maxChildSize: 0.9,
//         builder: (context, scrollController) => Container(
//           decoration: BoxDecoration(
//             color: theme.colorScheme.surface,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//             boxShadow: AppTheme.getElevationShadow(context, 8),
//           ),
//           child: Column(
//             children: [
//               // Handle
//               Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(top: 12),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.outline.withOpacity(0.4),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),

//               // Header
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Detection Details',
//                             style: theme.textTheme.headlineSmall?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: theme.colorScheme.onSurface,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             _formatTimestamp(item.timestamp),
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               color: theme.colorScheme.onSurfaceVariant,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.surfaceContainerHighest,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: IconButton(
//                         onPressed: () => Navigator.pop(context),
//                         icon: Icon(
//                           Icons.close_rounded,
//                           color: theme.colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Content
//               Expanded(
//                 child: SingleChildScrollView(
//                   controller: scrollController,
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Image
//                       Container(
//                         width: double.infinity,
//                         height: 220,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: theme.colorScheme.outline.withOpacity(0.3),
//                           ),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(15),
//                           child: File(item.imagePath).existsSync()
//                               ? Image.file(
//                                   File(item.imagePath),
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       color: theme
//                                           .colorScheme.surfaceContainerHighest,
//                                       child: Icon(
//                                         Icons.image_rounded,
//                                         size: 64,
//                                         color:
//                                             theme.colorScheme.onSurfaceVariant,
//                                       ),
//                                     );
//                                   },
//                                 )
//                               : Container(
//                                   color:
//                                       theme.colorScheme.surfaceContainerHighest,
//                                   child: Icon(
//                                     Icons.image_rounded,
//                                     size: 64,
//                                     color: theme.colorScheme.onSurfaceVariant,
//                                   ),
//                                 ),
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       // Detected Objects
//                       Text(
//                         'Detected Objects',
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: theme.colorScheme.onSurface,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: item.detectedObjects.map((object) {
//                           return Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 10,
//                             ),
//                             decoration: BoxDecoration(
//                               color: theme.colorScheme.primary.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                 color:
//                                     theme.colorScheme.primary.withOpacity(0.3),
//                               ),
//                             ),
//                             child: Text(
//                               object,
//                               style: theme.textTheme.bodyMedium?.copyWith(
//                                 color: theme.colorScheme.primary,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),

//                       const SizedBox(height: 24),

//                       // Statistics
//                       Text(
//                         'Detection Statistics',
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: theme.colorScheme.onSurface,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: theme.colorScheme.surfaceContainerHighest
//                               .withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: theme.colorScheme.outline.withOpacity(0.2),
//                           ),
//                         ),
//                         child: Column(
//                           children: [
//                             _buildStatRow(
//                               'Objects Found',
//                               '${item.detectedObjects.length}',
//                               theme,
//                             ),
//                             const SizedBox(height: 16),
//                             _buildStatRow(
//                               'Average Confidence',
//                               '${(item.averageConfidence * 100).toInt()}%',
//                               theme,
//                               color:
//                                   _getConfidenceColor(item.averageConfidence),
//                             ),
//                             const SizedBox(height: 16),
//                             _buildStatRow(
//                               'Detection Mode',
//                               item.mode?.displayName ?? 'Object Detection',
//                               theme,
//                             ),
//                             const SizedBox(height: 16),
//                             _buildStatRow(
//                               'Processing Time',
//                               '${(item.averageConfidence * 3).toStringAsFixed(1)}s',
//                               theme,
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 32),

//                       // Action Buttons
//                       Row(
//                         children: [
//                           Expanded(
//                             child: OutlinedButton.icon(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 _shareHistoryItem(item);
//                               },
//                               icon: Icon(
//                                 Icons.share_rounded,
//                                 color: theme.colorScheme.primary,
//                               ),
//                               label: Text(
//                                 'Share',
//                                 style: TextStyle(
//                                   color: theme.colorScheme.primary,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               style: OutlinedButton.styleFrom(
//                                 side: BorderSide(
//                                   color: theme.colorScheme.primary,
//                                 ),
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 16),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     theme.colorScheme.primary,
//                                     theme.colorScheme.secondary,
//                                   ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: ElevatedButton.icon(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                   Navigator.pushNamed(context, '/camera');
//                                 },
//                                 icon: const Icon(
//                                   Icons.camera_alt_rounded,
//                                   color: Colors.white,
//                                 ),
//                                 label: const Text(
//                                   'Scan Again',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.transparent,
//                                   elevation: 0,
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 16),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatRow(String label, String value, ThemeData theme,
//       {Color? color}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: theme.textTheme.bodyMedium?.copyWith(
//             color: theme.colorScheme.onSurfaceVariant,
//           ),
//         ),
//         Text(
//           value,
//           style: theme.textTheme.bodyMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: color ?? theme.colorScheme.onSurface,
//           ),
//         ),
//       ],
//     );
//   }

//   void _shareHistoryItem(DetectionHistory item) async {
//     final objectsText = item.detectedObjects.join(', ');
//     final timestamp = DateFormat('MMM d, y - h:mm a').format(item.timestamp);

//     await Share.share(
//       'AI Vision Detection Results\n\n'
//       'Objects: $objectsText\n'
//       'Confidence: ${(item.averageConfidence * 100).toInt()}%\n'
//       'Date: $timestamp\n\n'
//       'Powered by AI Vision Pro',
//       subject: 'Detection Results',
//     );
//   }

//   void _exportSingleItem(DetectionHistory item, ThemeData theme) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _buildExportSheet(item, theme),
//     );
//   }

//   Widget _buildExportSheet(DetectionHistory item, ThemeData theme) {
//     return Container(
//       height: 380, // Increased height to accommodate content
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//         boxShadow: AppTheme.getElevationShadow(context, 8),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min, // Important: Use minimum space needed
//         children: [
//           // Handle
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(top: 12),
//             decoration: BoxDecoration(
//               color: theme.colorScheme.outline.withOpacity(0.4),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),

//           // Header
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Text(
//               'Export Detection',
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//           ),

//           // Export Options - Using Flexible instead of Expanded
//           Flexible(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 children: [
//                   _buildExportOption(
//                     icon: Icons.picture_as_pdf_rounded,
//                     color: AppTheme.errorColor,
//                     title: 'Export as PDF',
//                     subtitle: 'Detailed report with image and analysis',
//                     onTap: () => _performExport(item, 'PDF', theme),
//                     theme: theme,
//                   ),
//                   const SizedBox(height: 12),
//                   _buildExportOption(
//                     icon: Icons.table_chart_rounded,
//                     color: AppTheme.successColor,
//                     title: 'Export as CSV',
//                     subtitle: 'Spreadsheet format for data analysis',
//                     onTap: () => _performExport(item, 'CSV', theme),
//                     theme: theme,
//                   ),
//                   const SizedBox(height: 12),
//                   _buildExportOption(
//                     icon: Icons.code_rounded,
//                     color: AppTheme.primaryColor,
//                     title: 'Export as JSON',
//                     subtitle: 'Raw data format for developers',
//                     onTap: () => _performExport(item, 'JSON', theme),
//                     theme: theme,
//                   ),
//                   const SizedBox(height: 20), // Bottom padding
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExportOption({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//     required ThemeData theme,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         onTap: onTap,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         tileColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
//         leading: Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: color, size: 24),
//         ),
//         title: Text(
//           title,
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.w600,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: theme.textTheme.bodySmall?.copyWith(
//             color: theme.colorScheme.onSurfaceVariant,
//           ),
//         ),
//         trailing: Icon(
//           Icons.arrow_forward_ios_rounded,
//           size: 16,
//           color: theme.colorScheme.onSurfaceVariant,
//         ),
//       ),
//     );
//   }

//   void _performExport(
//       DetectionHistory item, String format, ThemeData theme) async {
//     Navigator.pop(context);

//     // Show export progress
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(
//               color: theme.colorScheme.primary,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Exporting as $format...',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );

//     try {
//       String? filePath;

//       switch (format) {
//         case 'PDF':
//           filePath = await _exportToPDF(item);
//           break;
//         case 'CSV':
//           filePath = await _exportToCSV([item]);
//           break;
//         case 'JSON':
//           filePath = await _exportToJSON([item]);
//           break;
//       }

//       Navigator.pop(context); // Close progress dialog

//       if (filePath != null) {
//         // Show success and share option
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(
//                   Icons.check_circle_rounded,
//                   color: theme.colorScheme.onPrimary,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Detection exported as $format successfully',
//                     style: TextStyle(
//                       color: theme.colorScheme.onPrimary,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: AppTheme.successColor,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.all(16),
//             action: SnackBarAction(
//               label: 'Share',
//               textColor: theme.colorScheme.onPrimary,
//               onPressed: () => _shareFile(filePath!),
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       Navigator.pop(context); // Close progress dialog

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(
//                 Icons.error_rounded,
//                 color: theme.colorScheme.onError,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   'Export failed: ${e.toString()}',
//                   style: TextStyle(
//                     color: theme.colorScheme.onError,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: theme.colorScheme.error,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//     }
//   }

//   void _deleteHistoryItem(DetectionHistory item, ThemeData theme) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Text(
//           'Delete Detection',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),
//         content: Text(
//           'Are you sure you want to delete this detection result? This action cannot be undone.',
//           style: theme.textTheme.bodyMedium?.copyWith(
//             color: theme.colorScheme.onSurfaceVariant,
//             height: 1.5,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               color: theme.colorScheme.error,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 ref.read(historyProvider.notifier).removeItem(item.id);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Row(
//                       children: [
//                         Icon(
//                           Icons.check_circle_rounded,
//                           color: theme.colorScheme.onPrimary,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 12),
//                         const Text(
//                           'Detection deleted successfully',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                     backgroundColor: AppTheme.successColor,
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     margin: const EdgeInsets.all(16),
//                   ),
//                 );
//               },
//               child: Text(
//                 'Delete',
//                 style: TextStyle(
//                   color: theme.colorScheme.onError,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showClearAllDialog() {
//     final historyCount = ref.read(historyProvider).length;
//     final theme = Theme.of(context);

//     if (historyCount == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(
//                 Icons.info_rounded,
//                 color: theme.colorScheme.onPrimary,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'No history to clear',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: AppTheme.warningColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Text(
//           'Clear All History',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),
//         content: Text(
//           'Are you sure you want to delete all $historyCount detection${historyCount == 1 ? '' : 's'}? This action cannot be undone.',
//           style: theme.textTheme.bodyMedium?.copyWith(
//             color: theme.colorScheme.onSurfaceVariant,
//             height: 1.5,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               color: theme.colorScheme.error,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 ref.read(historyProvider.notifier).clearHistory();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Row(
//                       children: [
//                         Icon(
//                           Icons.check_circle_rounded,
//                           color: theme.colorScheme.onPrimary,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 12),
//                         Text(
//                           'All $historyCount detection${historyCount == 1 ? '' : 's'} cleared',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                     backgroundColor: AppTheme.successColor,
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     margin: const EdgeInsets.all(16),
//                   ),
//                 );
//               },
//               child: Text(
//                 'Clear All',
//                 style: TextStyle(
//                   color: theme.colorScheme.onError,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _exportHistory() {
//     final historyList = ref.read(historyProvider);
//     final isPremium = ref.watch(premiumProvider).isPremium;
//     final theme = Theme.of(context);

//     if (historyList.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(
//                 Icons.info_rounded,
//                 color: theme.colorScheme.onPrimary,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'No history to export',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: AppTheme.warningColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//       return;
//     }

//     // For premium users, show export options directly
//     if (isPremium) {
//       _showExportOptions(theme);
//     } else {
//       // For free users, show ad-supported export
//       _showAdSupportedExport(theme);
//     }
//   }

//   void _showAdSupportedExport(ThemeData theme) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.5,
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surface,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           boxShadow: AppTheme.getElevationShadow(context, 8),
//         ),
//         child: Column(
//           children: [
//             // Handle
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(top: 12),
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.outline.withOpacity(0.4),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),

//             // Header
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   const Icon(
//                     Icons.download_rounded,
//                     size: 48,
//                     color: AppTheme.warningColor,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Export History',
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Watch an ad to export your entire detection history',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),

//             // Ad-supported export button
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     RewardedAdButton(
//                       featureName: 'Export All History',
//                       onRewardEarned: () {
//                         Navigator.pop(context);
//                         _showExportOptions(theme);
//                       },
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 16,
//                         ),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               AppTheme.warningColor,
//                               AppTheme.warningColor.withOpacity(0.8),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: AppTheme.getElevationShadow(context, 4),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(
//                               Icons.play_circle_filled_rounded,
//                               color: Colors.white,
//                               size: 24,
//                             ),
//                             const SizedBox(width: 12),
//                             Text(
//                               'Watch Ad to Export',
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // Premium upgrade option
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.surfaceContainerHighest
//                             .withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: theme.colorScheme.outline.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               const Icon(
//                                 Icons.star_rounded,
//                                 color: AppTheme.primaryColor,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'Upgrade to Premium',
//                                 style: theme.textTheme.titleSmall?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                   color: theme.colorScheme.onSurface,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Export unlimited history without ads',
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: theme.colorScheme.onSurfaceVariant,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           SizedBox(
//                             width: double.infinity,
//                             child: OutlinedButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 Navigator.pushNamed(context, '/premium');
//                               },
//                               style: OutlinedButton.styleFrom(
//                                 side: const BorderSide(
//                                     color: AppTheme.primaryColor),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: const Text(
//                                 'Learn More',
//                                 style: TextStyle(
//                                   color: AppTheme.primaryColor,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showExportOptions(ThemeData theme) {
//     final historyList = ref.read(historyProvider);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.6,
//         minChildSize: 0.4,
//         maxChildSize: 0.8,
//         builder: (context, scrollController) => Container(
//           decoration: BoxDecoration(
//             color: theme.colorScheme.surface,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//             boxShadow: AppTheme.getElevationShadow(context, 8),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Handle
//               Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(top: 12),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.outline.withOpacity(0.4),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),

//               // Header
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
//                 child: Text(
//                   'Export All History (${historyList.length} items)',
//                   style: theme.textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),

//               // Export Options with ScrollView
//               Expanded(
//                 child: SingleChildScrollView(
//                   controller: scrollController,
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     children: [
//                       _buildExportOption(
//                         icon: Icons.picture_as_pdf_rounded,
//                         color: AppTheme.errorColor,
//                         title: 'Export as PDF Report',
//                         subtitle: 'Complete history with images and analysis',
//                         onTap: () => _performBulkExport('PDF', theme),
//                         theme: theme,
//                       ),
//                       const SizedBox(height: 8),
//                       _buildExportOption(
//                         icon: Icons.table_chart_rounded,
//                         color: AppTheme.successColor,
//                         title: 'Export as CSV',
//                         subtitle: 'Spreadsheet format for data analysis',
//                         onTap: () => _performBulkExport('CSV', theme),
//                         theme: theme,
//                       ),
//                       const SizedBox(height: 8),
//                       _buildExportOption(
//                         icon: Icons.code_rounded,
//                         color: AppTheme.primaryColor,
//                         title: 'Export as JSON',
//                         subtitle: 'Raw data format with all metadata',
//                         onTap: () => _performBulkExport('JSON', theme),
//                         theme: theme,
//                       ),
//                       const SizedBox(height: 8),
//                       _buildExportOption(
//                         icon: Icons.archive_rounded,
//                         color: AppTheme.warningColor,
//                         title: 'Export as Archive',
//                         subtitle: 'ZIP file with images and data',
//                         onTap: () => _performBulkExport('ZIP', theme),
//                         theme: theme,
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _performBulkExport(String format, ThemeData theme) async {
//     Navigator.pop(context);
//     final historyList = ref.read(historyProvider);

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(
//               color: theme.colorScheme.primary,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Exporting ${historyList.length} detections as $format...',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 color: theme.colorScheme.onSurface,
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'This may take a few moments',
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );

//     try {
//       String? filePath;

//       switch (format) {
//         case 'PDF':
//           filePath = await _exportBulkToPDF(historyList);
//           break;
//         case 'CSV':
//           filePath = await _exportToCSV(historyList);
//           break;
//         case 'JSON':
//           filePath = await _exportToJSON(historyList);
//           break;
//         case 'ZIP':
//           filePath = await _exportToZIP(historyList);
//           break;
//       }

//       Navigator.pop(context); // Close progress dialog

//       if (filePath != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(
//                   Icons.check_circle_rounded,
//                   color: theme.colorScheme.onPrimary,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     '${historyList.length} detections exported as $format successfully',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: AppTheme.successColor,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.all(16),
//             duration: const Duration(seconds: 4),
//             action: SnackBarAction(
//               label: 'Share',
//               textColor: theme.colorScheme.onPrimary,
//               onPressed: () => _shareFile(filePath!),
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       Navigator.pop(context); // Close progress dialog

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(
//                 Icons.error_rounded,
//                 color: theme.colorScheme.onError,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   'Bulk export failed: ${e.toString()}',
//                   style: TextStyle(
//                     color: theme.colorScheme.onError,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: theme.colorScheme.error,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//     }
//   }

// // Add these helper methods for actual file export functionality

//   Future<String?> _exportToPDF(DetectionHistory item) async {
//     try {
//       // Request storage permission
//       if (await Permission.storage.request().isGranted ||
//           await Permission.manageExternalStorage.request().isGranted) {
//         final pdf = pw.Document();

//         // Load image if it exists
//         pw.ImageProvider? imageProvider;
//         if (File(item.imagePath).existsSync()) {
//           final imageBytes = await File(item.imagePath).readAsBytes();
//           imageProvider = pw.MemoryImage(imageBytes);
//         }

//         pdf.addPage(
//           pw.Page(
//             pageFormat: PdfPageFormat.a4,
//             build: (pw.Context context) {
//               return pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   // Header
//                   pw.Container(
//                     padding: const pw.EdgeInsets.all(20),
//                     decoration: pw.BoxDecoration(
//                       color: PdfColors.blue50,
//                       borderRadius: pw.BorderRadius.circular(10),
//                     ),
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text(
//                           'AI Vision Detection Report',
//                           style: pw.TextStyle(
//                             fontSize: 24,
//                             fontWeight: pw.FontWeight.bold,
//                             color: PdfColors.blue800,
//                           ),
//                         ),
//                         pw.SizedBox(height: 10),
//                         pw.Text(
//                           'Generated on ${DateFormat('MMM d, y - h:mm a').format(DateTime.now())}',
//                           style: const pw.TextStyle(
//                               fontSize: 12, color: PdfColors.grey600),
//                         ),
//                       ],
//                     ),
//                   ),

//                   pw.SizedBox(height: 30),

//                   // Detection Details
//                   pw.Text(
//                     'Detection Details',
//                     style: pw.TextStyle(
//                         fontSize: 18, fontWeight: pw.FontWeight.bold),
//                   ),
//                   pw.SizedBox(height: 15),

//                   // Image if available
//                   if (imageProvider != null) ...[
//                     pw.Container(
//                       height: 200,
//                       width: double.infinity,
//                       decoration: pw.BoxDecoration(
//                         border: pw.Border.all(color: PdfColors.grey300),
//                         borderRadius: pw.BorderRadius.circular(8),
//                       ),
//                       child: pw.ClipRRect(
//                         // borderRadius: pw.BorderRadius.circular(8),
//                         child: pw.Image(imageProvider, fit: pw.BoxFit.cover),
//                       ),
//                     ),
//                     pw.SizedBox(height: 20),
//                   ],

//                   // Detection Info Table
//                   pw.Table(
//                     border: pw.TableBorder.all(color: PdfColors.grey300),
//                     columnWidths: {
//                       0: const pw.FlexColumnWidth(1),
//                       1: const pw.FlexColumnWidth(2),
//                     },
//                     children: [
//                       _buildPdfTableRow(
//                           'Detection Time',
//                           DateFormat('MMM d, y - h:mm a')
//                               .format(item.timestamp)),
//                       _buildPdfTableRow(
//                           'Objects Detected', item.detectedObjects.join(', ')),
//                       _buildPdfTableRow('Number of Objects',
//                           '${item.detectedObjects.length}'),
//                       _buildPdfTableRow('Average Confidence',
//                           '${(item.averageConfidence * 100).toInt()}%'),
//                       _buildPdfTableRow('Detection Quality', item.qualityText),
//                       _buildPdfTableRow('Category', item.categoryText),
//                     ],
//                   ),

//                   pw.SizedBox(height: 30),

//                   // Objects List
//                   pw.Text(
//                     'Detected Objects',
//                     style: pw.TextStyle(
//                         fontSize: 16, fontWeight: pw.FontWeight.bold),
//                   ),
//                   pw.SizedBox(height: 10),

//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: item.detectedObjects
//                         .map((object) => pw.Container(
//                               margin: const pw.EdgeInsets.only(bottom: 5),
//                               padding: const pw.EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 5),
//                               decoration: pw.BoxDecoration(
//                                 color: PdfColors.grey100,
//                                 borderRadius: pw.BorderRadius.circular(15),
//                               ),
//                               child: pw.Text('• $object',
//                                   style: const pw.TextStyle(fontSize: 12)),
//                             ))
//                         .toList(),
//                   ),

//                   pw.Spacer(),

//                   // Footer
//                   pw.Container(
//                     padding: const pw.EdgeInsets.all(10),
//                     decoration: pw.BoxDecoration(
//                       border: pw.Border.all(color: PdfColors.grey300),
//                       borderRadius: pw.BorderRadius.circular(5),
//                     ),
//                     child: pw.Text(
//                       'This report was generated by AI Vision Pro. For more information, visit our website.',
//                       style: const pw.TextStyle(
//                           fontSize: 10, color: PdfColors.grey600),
//                       textAlign: pw.TextAlign.center,
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         );

//         // Save the PDF
//         final directory = await getApplicationDocumentsDirectory();
//         final file = File(
//             '${directory.path}/detection_${item.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
//         await file.writeAsBytes(await pdf.save());

//         return file.path;
//       } else {
//         throw Exception('Storage permission denied');
//       }
//     } catch (e) {
//       throw Exception('PDF export failed: $e');
//     }
//   }

//   Future<String?> _exportBulkToPDF(List<DetectionHistory> items) async {
//     try {
//       if (await Permission.storage.request().isGranted ||
//           await Permission.manageExternalStorage.request().isGranted) {
//         final pdf = pw.Document();

//         // Cover page
//         pdf.addPage(
//           pw.Page(
//             pageFormat: PdfPageFormat.a4,
//             build: (pw.Context context) {
//               return pw.Center(
//                 child: pw.Column(
//                   mainAxisAlignment: pw.MainAxisAlignment.center,
//                   children: [
//                     pw.Text(
//                       'AI Vision Detection History',
//                       style: pw.TextStyle(
//                           fontSize: 32, fontWeight: pw.FontWeight.bold),
//                     ),
//                     pw.SizedBox(height: 20),
//                     pw.Text(
//                       'Complete Detection Report',
//                       style: const pw.TextStyle(
//                           fontSize: 18, color: PdfColors.grey600),
//                     ),
//                     pw.SizedBox(height: 40),
//                     pw.Container(
//                       padding: const pw.EdgeInsets.all(20),
//                       decoration: pw.BoxDecoration(
//                         color: PdfColors.blue50,
//                         borderRadius: pw.BorderRadius.circular(10),
//                       ),
//                       child: pw.Column(
//                         children: [
//                           pw.Text('Total Detections: ${items.length}',
//                               style: const pw.TextStyle(fontSize: 16)),
//                           pw.SizedBox(height: 5),
//                           pw.Text(
//                               'Generated: ${DateFormat('MMM d, y - h:mm a').format(DateTime.now())}',
//                               style: const pw.TextStyle(
//                                   fontSize: 12, color: PdfColors.grey600)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         );

//         // Add pages for each detection (limit to prevent huge files)
//         final limitedItems = items.take(50).toList(); // Limit to 50 items

//         for (int i = 0; i < limitedItems.length; i++) {
//           final item = limitedItems[i];

//           pdf.addPage(
//             pw.Page(
//               pageFormat: PdfPageFormat.a4,
//               build: (pw.Context context) {
//                 return pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text(
//                       'Detection ${i + 1} of ${limitedItems.length}',
//                       style: pw.TextStyle(
//                           fontSize: 20, fontWeight: pw.FontWeight.bold),
//                     ),
//                     pw.SizedBox(height: 20),

//                     // Detection summary table
//                     pw.Table(
//                       border: pw.TableBorder.all(color: PdfColors.grey300),
//                       columnWidths: {
//                         0: const pw.FlexColumnWidth(1),
//                         1: const pw.FlexColumnWidth(2),
//                       },
//                       children: [
//                         _buildPdfTableRow(
//                             'Time',
//                             DateFormat('MMM d, y - h:mm a')
//                                 .format(item.timestamp)),
//                         _buildPdfTableRow(
//                             'Objects', item.detectedObjects.join(', ')),
//                         _buildPdfTableRow('Confidence',
//                             '${(item.averageConfidence * 100).toInt()}%'),
//                         _buildPdfTableRow('Category', item.categoryText),
//                       ],
//                     ),
//                   ],
//                 );
//               },
//             ),
//           );
//         }

//         // Save the PDF
//         final directory = await getApplicationDocumentsDirectory();
//         final file = File(
//             '${directory.path}/detection_history_${DateTime.now().millisecondsSinceEpoch}.pdf');
//         await file.writeAsBytes(await pdf.save());

//         return file.path;
//       } else {
//         throw Exception('Storage permission denied');
//       }
//     } catch (e) {
//       throw Exception('Bulk PDF export failed: $e');
//     }
//   }

//   pw.TableRow _buildPdfTableRow(String label, String value) {
//     return pw.TableRow(
//       children: [
//         pw.Container(
//           padding: const pw.EdgeInsets.all(8),
//           color: PdfColors.grey100,
//           child: pw.Text(label,
//               style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//         ),
//         pw.Container(
//           padding: const pw.EdgeInsets.all(8),
//           child: pw.Text(value),
//         ),
//       ],
//     );
//   }

//   Future<String?> _exportToCSV(List<DetectionHistory> items) async {
//     try {
//       if (await Permission.storage.request().isGranted ||
//           await Permission.manageExternalStorage.request().isGranted) {
//         // Prepare CSV data
//         List<List<dynamic>> rows = [
//           // Header row
//           [
//             'ID',
//             'Timestamp',
//             'Date',
//             'Time',
//             'Detected Objects',
//             'Object Count',
//             'Average Confidence (%)',
//             'Quality',
//             'Category',
//             'Image Path',
//             'Description'
//           ]
//         ];

//         // Add data rows
//         for (final item in items) {
//           rows.add([
//             item.id,
//             item.timestamp.toIso8601String(),
//             DateFormat('yyyy-MM-dd').format(item.timestamp),
//             DateFormat('HH:mm:ss').format(item.timestamp),
//             item.detectedObjects.join('; '),
//             item.detectedObjects.length,
//             (item.averageConfidence * 100).toInt(),
//             item.qualityText,
//             item.categoryText,
//             item.imagePath,
//             item.description,
//           ]);
//         }

//         // Convert to CSV string
//         final csvString = const ListToCsvConverter().convert(rows);

//         // Save the file
//         final directory = await getApplicationDocumentsDirectory();
//         final fileName = items.length == 1
//             ? 'detection_${items.first.id}_${DateTime.now().millisecondsSinceEpoch}.csv'
//             : 'detection_history_${DateTime.now().millisecondsSinceEpoch}.csv';
//         final file = File('${directory.path}/$fileName');
//         await file.writeAsString(csvString);

//         return file.path;
//       } else {
//         throw Exception('Storage permission denied');
//       }
//     } catch (e) {
//       throw Exception('CSV export failed: $e');
//     }
//   }

//   Future<String?> _exportToJSON(List<DetectionHistory> items) async {
//     try {
//       if (await Permission.storage.request().isGranted ||
//           await Permission.manageExternalStorage.request().isGranted) {
//         // Prepare JSON data
//         final exportData = {
//           'exportInfo': {
//             'timestamp': DateTime.now().toIso8601String(),
//             'version': '1.0',
//             'totalDetections': items.length,
//             'exportedBy': 'AI Vision Pro',
//           },
//           'detections': items.map((item) => item.exportData).toList(),
//         };

//         // Convert to JSON string with pretty formatting
//         final jsonString =
//             const JsonEncoder.withIndent('  ').convert(exportData);

//         // Save the file
//         final directory = await getApplicationDocumentsDirectory();
//         final fileName = items.length == 1
//             ? 'detection_${items.first.id}_${DateTime.now().millisecondsSinceEpoch}.json'
//             : 'detection_history_${DateTime.now().millisecondsSinceEpoch}.json';
//         final file = File('${directory.path}/$fileName');
//         await file.writeAsString(jsonString);

//         return file.path;
//       } else {
//         throw Exception('Storage permission denied');
//       }
//     } catch (e) {
//       throw Exception('JSON export failed: $e');
//     }
//   }

//   Future<String?> _exportToZIP(List<DetectionHistory> items) async {
//     try {
//       if (await Permission.storage.request().isGranted ||
//           await Permission.manageExternalStorage.request().isGranted) {
//         // For ZIP functionality, you'll need to add the 'archive' package to pubspec.yaml
//         // archive: ^3.4.0

//         // This is a placeholder - you would implement ZIP creation here
//         // using the archive package to compress JSON data and images together

//         final directory = await getApplicationDocumentsDirectory();
//         final fileName =
//             'detection_archive_${DateTime.now().millisecondsSinceEpoch}.zip';
//         final file = File('${directory.path}/$fileName');

//         // For now, just create the JSON file (you would add ZIP compression here)
//         final jsonPath = await _exportToJSON(items);
//         if (jsonPath != null) {
//           // Copy JSON file as ZIP placeholder
//           await File(jsonPath).copy(file.path);
//           return file.path;
//         }

//         throw Exception('ZIP creation failed');
//       } else {
//         throw Exception('Storage permission denied');
//       }
//     } catch (e) {
//       throw Exception('ZIP export failed: $e');
//     }
//   }

//   Future<void> _shareFile(String filePath) async {
//     try {
//       await Share.shareXFiles(
//         [XFile(filePath)],
//         text: 'AI Vision Detection Export',
//         subject: 'Detection Results',
//       );
//     } catch (e) {
//       // Fallback to regular share if file sharing fails
//       final fileName = filePath.split('/').last;
//       await Share.share(
//         'Detection results exported as $fileName\n\nFile location: $filePath',
//         subject: 'Detection Results',
//       );
//     }
//   }
// }

// // Enhanced detection history model with additional utilities
// extension DetectionHistoryExtensions on DetectionHistory {
//   String get primaryObject =>
//       detectedObjects.isNotEmpty ? detectedObjects.first : 'Unknown';

//   String get confidenceText => '${(averageConfidence * 100).toInt()}%';

//   String get objectCountText =>
//       '${detectedObjects.length} object${detectedObjects.length == 1 ? '' : 's'}';

//   Color get confidenceColor {
//     if (averageConfidence >= 0.8) return AppTheme.successColor;
//     if (averageConfidence >= 0.6) return AppTheme.warningColor;
//     return AppTheme.errorColor;
//   }

//   String get categoryText {
//     if (detectedObjects.isEmpty) return 'Unknown';

//     final categories = <String, int>{};
//     for (final object in detectedObjects) {
//       final category = _categorizeObject(object);
//       categories[category] = (categories[category] ?? 0) + 1;
//     }

//     final primaryCategory =
//         categories.entries.reduce((a, b) => a.value > b.value ? a : b).key;

//     return primaryCategory.substring(0, 1).toUpperCase() +
//         primaryCategory.substring(1);
//   }

//   String _categorizeObject(String label) {
//     final lowercaseLabel = label.toLowerCase();
//     if (lowercaseLabel.contains('person') ||
//         lowercaseLabel.contains('people')) {
//       return 'people';
//     } else if (lowercaseLabel.contains('car') ||
//         lowercaseLabel.contains('vehicle')) {
//       return 'vehicles';
//     } else if (lowercaseLabel.contains('animal') ||
//         lowercaseLabel.contains('dog') ||
//         lowercaseLabel.contains('cat')) {
//       return 'animals';
//     } else if (lowercaseLabel.contains('food') ||
//         lowercaseLabel.contains('eat')) {
//       return 'food';
//     } else if (lowercaseLabel.contains('plant') ||
//         lowercaseLabel.contains('flower')) {
//       return 'plants';
//     }
//     return 'objects';
//   }

//   /// Get a human-readable description of the detection
//   String get description {
//     if (detectedObjects.isEmpty) return 'No objects detected';

//     if (detectedObjects.length == 1) {
//       return 'Detected ${detectedObjects.first}';
//     } else if (detectedObjects.length <= 3) {
//       return 'Detected ${detectedObjects.join(', ')}';
//     } else {
//       return 'Detected ${detectedObjects.take(2).join(', ')} and ${detectedObjects.length - 2} more';
//     }
//   }

//   /// Get the detection quality based on confidence
//   String get qualityText {
//     if (averageConfidence >= 0.9) return 'Excellent';
//     if (averageConfidence >= 0.8) return 'Very Good';
//     if (averageConfidence >= 0.7) return 'Good';
//     if (averageConfidence >= 0.6) return 'Fair';
//     return 'Poor';
//   }

//   /// Get an icon representing the primary category
//   IconData get categoryIcon {
//     final category = categoryText.toLowerCase();
//     switch (category) {
//       case 'people':
//         return Icons.person_rounded;
//       case 'vehicles':
//         return Icons.directions_car_rounded;
//       case 'animals':
//         return Icons.pets_rounded;
//       case 'food':
//         return Icons.restaurant_rounded;
//       case 'plants':
//         return Icons.local_florist_rounded;
//       default:
//         return Icons.category_rounded;
//     }
//   }

//   /// Get the time ago string in a more detailed format
//   String get detailedTimeAgo {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);

//     if (difference.inSeconds < 60) {
//       return 'Just now';
//     } else if (difference.inMinutes < 60) {
//       final minutes = difference.inMinutes;
//       return '$minutes minute${minutes == 1 ? '' : 's'} ago';
//     } else if (difference.inHours < 24) {
//       final hours = difference.inHours;
//       return '$hours hour${hours == 1 ? '' : 's'} ago';
//     } else if (difference.inDays < 7) {
//       final days = difference.inDays;
//       return '$days day${days == 1 ? '' : 's'} ago';
//     } else if (difference.inDays < 30) {
//       final weeks = (difference.inDays / 7).floor();
//       return '$weeks week${weeks == 1 ? '' : 's'} ago';
//     } else if (difference.inDays < 365) {
//       final months = (difference.inDays / 30).floor();
//       return '$months month${months == 1 ? '' : 's'} ago';
//     } else {
//       final years = (difference.inDays / 365).floor();
//       return '$years year${years == 1 ? '' : 's'} ago';
//     }
//   }

//   /// Check if the detection is recent (within last 24 hours)
//   bool get isRecent {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);
//     return difference.inHours < 24;
//   }

//   /// Check if the detection has high confidence
//   bool get hasHighConfidence => averageConfidence >= 0.8;

//   /// Get a color representing the detection quality
//   Color get qualityColor {
//     if (averageConfidence >= 0.8) return AppTheme.successColor;
//     if (averageConfidence >= 0.6) return AppTheme.warningColor;
//     return AppTheme.errorColor;
//   }

//   /// Get export data as a map for serialization
//   Map<String, dynamic> get exportData => {
//         'id': id,
//         'timestamp': timestamp.toIso8601String(),
//         'detectedObjects': detectedObjects,
//         'averageConfidence': averageConfidence,
//         'imagePath': imagePath,
//         'description': description,
//         'category': categoryText,
//         'quality': qualityText,
//         'objectCount': detectedObjects.length,
//         'confidencePercentage': '${(averageConfidence * 100).toInt()}%',
//         'timeAgo': detailedTimeAgo,
//         'isRecent': isRecent,
//         'hasHighConfidence': hasHighConfidence,
//       };
// }


// // screens/home_screen.dart

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:carousel_slider/carousel_slider.dart' as carousel;
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';

// import '../models/achievement.dart';
// import '../models/feature_highlight.dart';
// import '../providers/ads_provider.dart';
// import '../providers/auth_provider.dart';
// import '../providers/challenge_provider.dart';
// import '../providers/detection_provider.dart';
// import '../providers/history_provider.dart';
// import '../providers/analytics_provider.dart';
// import '../providers/premium_provider.dart';
// import '../config/app_theme.dart';
// import '../utils/camera_mode.dart';
// import '../widgets/achievement_banner.dart';
// import '../widgets/ad_widgets.dart';
// import '../widgets/daily_challenge.dart';
// import '../widgets/feature_explore_sheet.dart';
// import '../widgets/feature_showcase.dart';
// import '../widgets/quick_action_card.dart';
// import 'main_navigation_screen.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _rotationController;
//   late AnimationController _welcomeController;
//   int _carouselIndex = 0;
//   bool _showWelcomeAnimation = true;

//   final List<FeatureHighlight> _features = [
//     FeatureHighlight(
//       title: 'Smart Object Detection',
//       description:
//           'Identify thousands of objects with 95%+ accuracy using advanced AI',
//       icon: Icons.smart_toy_rounded,
//       color: AppTheme.primaryColor,
//       gradient: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
//     ),
//     FeatureHighlight(
//       title: 'Real-time Recognition',
//       description: 'Get instant results as you point your camera at objects',
//       icon: Icons.speed_rounded,
//       color: AppTheme.successColor,
//       gradient: [AppTheme.successColor, AppTheme.successColor.withOpacity(0.7)],
//     ),
//     FeatureHighlight(
//       title: 'Multi-language Support',
//       description: 'Translate and learn object names in 50+ languages',
//       icon: Icons.translate_rounded,
//       color: AppTheme.secondaryColor,
//       gradient: [
//         AppTheme.secondaryColor,
//         AppTheme.secondaryColor.withOpacity(0.7)
//       ],
//     ),
//     FeatureHighlight(
//       title: 'Educational Insights',
//       description:
//           'Discover fascinating facts and learn about the world around you',
//       icon: Icons.school_rounded,
//       color: AppTheme.warningColor,
//       gradient: [AppTheme.warningColor, AppTheme.warningColor.withOpacity(0.7)],
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _checkFirstTime();
//   }

//   void _initializeAnimations() {
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     )..repeat(reverse: true);

//     _rotationController = AnimationController(
//       duration: const Duration(seconds: 8),
//       vsync: this,
//     )..repeat();

//     _welcomeController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//   }

//   void _checkFirstTime() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isFirstTime = prefs.getBool('is_first_time') ?? true;

//     if (isFirstTime) {
//       _welcomeController.forward();
//       Future.delayed(const Duration(seconds: 3), () {
//         if (mounted) {
//           setState(() => _showWelcomeAnimation = false);
//         }
//       });
//       prefs.setBool('is_first_time', false);
//     } else {
//       setState(() => _showWelcomeAnimation = false);
//     }
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _rotationController.dispose();
//     _welcomeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (_showWelcomeAnimation) {
//       return _buildWelcomeAnimation(theme);
//     }

//     // Get real data from providers
//     final user = ref.watch(currentUserProvider);
//     final isPremium = ref.watch(premiumProvider).isPremium;
//     final historyState = ref.watch(historyProvider);
//     final analyticsState = ref.watch(analyticsProvider);

//     final userName = user?.displayName ?? 'Explorer';
//     final recentDetections = historyState.take(5).toList();

//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       body: SafeArea(
//         child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             _buildSliverAppBar(userName, isPremium, theme),

//             // Banner ad after app bar (for non-premium users)
//             if (!isPremium)
//               SliverToBoxAdapter(
//                 child: Container(
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   child: const AdBanner(
//                     placement: 'home',
//                     adSize: AdSize.mediumRectangle,
//                   ),
//                 ).animate().slideY(begin: 0.3).fadeIn(),
//               ),

//             _buildQuickStats(analyticsState, theme),
//             _buildQuickActions(theme),

//             // Native ad in content feed
//             if (!isPremium)
//               SliverToBoxAdapter(
//                 child: Container(
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                   child: const NativeAdWidget(placement: 'home_feed'),
//                 ),
//               ),

//             _buildFeaturesCarousel(theme),

//             if (!isPremium) _buildPremiumPromo(theme),

//             _buildRecentDetections(recentDetections, theme),

//             // Another banner ad before daily challenge
//             if (!isPremium)
//               SliverToBoxAdapter(
//                 child: Container(
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   child: const AdBanner(placement: 'home'),
//                 ),
//               ),

//             _buildDailyChallenge(theme),
//             _buildAchievements(analyticsState, theme),
//             _buildTipsAndTricks(theme),
//             const SliverToBoxAdapter(child: SizedBox(height: 100)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWelcomeAnimation(ThemeData theme) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               theme.colorScheme.primary,
//               theme.colorScheme.secondary,
//               theme.colorScheme.tertiary,
//             ],
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Animated logo
//               AnimatedBuilder(
//                 animation: _rotationController,
//                 builder: (context, child) {
//                   return Transform.rotate(
//                     angle: _rotationController.value * 2 * 3.14159,
//                     child: Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.onPrimary.withOpacity(0.2),
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: theme.colorScheme.onPrimary.withOpacity(0.3),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         Icons.visibility_rounded,
//                         size: 60,
//                         color: theme.colorScheme.onPrimary,
//                       ),
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: 32),

//               // App title
//               Text(
//                 'AI Vision Pro',
//                 style: theme.textTheme.displaySmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onPrimary,
//                   letterSpacing: -0.5,
//                 ),
//               ).animate().slideY(begin: 0.3).fadeIn(delay: 500.ms),

//               const SizedBox(height: 16),

//               // Subtitle
//               Text(
//                 'See the world through AI eyes',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   color: theme.colorScheme.onPrimary.withOpacity(0.9),
//                 ),
//               ).animate().slideY(begin: 0.3).fadeIn(delay: 800.ms),

//               const SizedBox(height: 40),

//               // Pulse indicator
//               AnimatedBuilder(
//                 animation: _pulseController,
//                 builder: (context, child) {
//                   return Transform.scale(
//                     scale: 1.0 + (_pulseController.value * 0.3),
//                     child: Container(
//                       width: 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.onPrimary,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSliverAppBar(String userName, bool isPremium, ThemeData theme) {
//     return SliverAppBar(
//       expandedHeight: 140,
//       floating: true,
//       pinned: false,
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 theme.colorScheme.primary.withOpacity(0.05),
//                 theme.colorScheme.surface,
//               ],
//             ),
//           ),
//           padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _getGreeting(),
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: theme.colorScheme.onSurfaceVariant,
//                           ),
//                         ).animate().slideX().fadeIn(),
//                         const SizedBox(height: 4),
//                         Text(
//                           userName,
//                           style: theme.textTheme.headlineSmall?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: theme.colorScheme.onSurface,
//                           ),
//                         ).animate(delay: 200.ms).slideX().fadeIn(),
//                       ],
//                     ),
//                   ),

//                   // Premium badge
//                   if (isPremium)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         gradient: AppTheme.premiumGradient,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppTheme.premiumGold.withOpacity(0.3),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.diamond_rounded,
//                             color: Colors.white,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'PRO',
//                             style: theme.textTheme.labelSmall?.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ).animate().shimmer(duration: 2000.ms),

//                   const SizedBox(width: 12),

//                   // Profile picture
//                   GestureDetector(
//                     onTap: () {
//                       HapticFeedback.lightImpact();
//                       Navigator.pushNamed(context, '/profile');
//                     },
//                     child: Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.primary.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: theme.colorScheme.primary.withOpacity(0.2),
//                         ),
//                       ),
//                       child: Icon(
//                         Icons.person_rounded,
//                         color: theme.colorScheme.primary,
//                         size: 20,
//                       ),
//                     ),
//                   ).animate(delay: 400.ms).scale(),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickStats(AnalyticsState analyticsState, ThemeData theme) {
//     return SliverToBoxAdapter(
//       child: Container(
//         margin: const EdgeInsets.all(20),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               theme.colorScheme.primary.withOpacity(0.1),
//               theme.colorScheme.secondary.withOpacity(0.1),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: theme.colorScheme.outline.withOpacity(0.2),
//           ),
//           boxShadow: AppTheme.getElevationShadow(context, 2),
//         ),
//         child: IntrinsicHeight(
//           child: Row(
//             children: [
//               Expanded(
//                 child: _buildStatItem(
//                   'Objects\nDetected',
//                   '${analyticsState.totalDetections}', // Use totalDetections instead
//                   Icons.category_rounded,
//                   theme,
//                 ),
//               ),
//               _buildStatDivider(theme),
//               Expanded(
//                 child: _buildStatItem(
//                   'Accuracy\nRate',
//                   analyticsState.totalDetections > 0
//                       ? '${(analyticsState.averageConfidence * 100).toStringAsFixed(1)}%'
//                       : '0%', // Handle case when no detections
//                   Icons.trending_up_rounded,
//                   theme,
//                 ),
//               ),
//               _buildStatDivider(theme),
//               Expanded(
//                 child: _buildStatItem(
//                   'Achievements\nUnlocked',
//                   '${_calculateUnlockedAchievements(analyticsState)}', // Calculate achievements
//                   Icons.emoji_events_rounded,
//                   theme,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ).animate().slideY(begin: 0.3).fadeIn(),
//     );
//   }

// // Add this helper method to calculate unlocked achievements
//   int _calculateUnlockedAchievements(AnalyticsState analyticsState) {
//     int unlockedCount = 0;

//     // First Scan achievement
//     if (analyticsState.totalDetections > 0) unlockedCount++;

//     // Explorer achievement (100 scans)
//     if (analyticsState.totalDetections >= 100) unlockedCount++;

//     // Accuracy Master (90%+ average accuracy)
//     if (analyticsState.averageConfidence >= 0.9) unlockedCount++;

//     // Add more achievements as needed
//     return unlockedCount;
//   }

//   Widget _buildStatDivider(ThemeData theme) {
//     return Container(
//       width: 1,
//       height: 50,
//       color: theme.colorScheme.outline.withOpacity(0.3),
//       margin: const EdgeInsets.symmetric(horizontal: 12),
//     );
//   }

//   Widget _buildStatItem(
//       String label, String value, IconData icon, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: theme.colorScheme.primary,
//               size: 20,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: theme.textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: theme.colorScheme.onSurfaceVariant,
//               height: 1.3,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActions(ThemeData theme) {
//     return SliverToBoxAdapter(
//       child: Container(
//         height: 140,
//         margin: const EdgeInsets.symmetric(horizontal: 20),
//         child: Row(
//           children: [
//             // Large scan card
//             // Expanded(
//             //   flex: 1,
//             //   child: InterstitialAdTrigger(
//             //     trigger: 'camera_action',
//             //     onAdDismissed: () {
//             //       ref.read(bottomNavIndexProvider.notifier).state = 2;
//             //     },
//             //     child: QuickActionCard(
//             //       title: 'Scan Object',
//             //       subtitle: 'Point and identify',
//             //       icon: Icons.camera_alt_rounded,
//             //       color: theme.colorScheme.primary,
//             //       onTap: () {
//             //         HapticFeedback.lightImpact();
//             //       },
//             //       isLarge: true,
//             //     ),
//             //   ),
//             // ),
//             Expanded(
//               flex: 1,
//               child: QuickActionCard(
//                 title: 'Scan Object',
//                 subtitle: 'Point and identify',
//                 icon: Icons.camera_alt_rounded,
//                 color: theme.colorScheme.primary,
//                 isLarge: true,
//                 onTap: () {
//                   HapticFeedback.lightImpact();

//                   final isPremium = ref.read(premiumProvider).isPremium;
//                   if (isPremium) {
//                     // Directly go to Camera tab
//                     ref.read(bottomNavIndexProvider.notifier).state = 2;
//                   } else {
//                     // Show ad first, then navigate
//                     ref.read(adsProvider.notifier).showInterstitialAd(
//                       // trigger: 'camera_action',
//                       onAdDismissed: () {
//                         ref.read(bottomNavIndexProvider.notifier).state = 2;
//                       },
//                     );
//                   }
//                 },
//               ),
//             ),

//             const SizedBox(width: 12),

//             // Small cards column
//             Expanded(
//               flex: 1,
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: QuickActionCard(
//                       title: 'Gallery',
//                       subtitle: 'Upload photo',
//                       icon: Icons.photo_library_rounded,
//                       color: AppTheme.successColor,
//                       onTap: () {
//                         HapticFeedback.lightImpact();
//                         _pickFromGallery();
//                       },
//                       isLarge: false,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Expanded(
//                     child: QuickActionCard(
//                       title: 'History',
//                       subtitle: 'Past scans',
//                       icon: Icons.history_rounded,
//                       color: AppTheme.warningColor,
//                       onTap: () {
//                         HapticFeedback.lightImpact();
//                         Navigator.pushNamed(context, '/history');
//                       },
//                       isLarge: false,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ).animate(delay: 200.ms).slideX().fadeIn(),
//     );
//   }

//   Widget _buildFeaturesCarousel(ThemeData theme) {
//     return SliverToBoxAdapter(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
//             child: Text(
//               'Discover Features',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 200,
//             child: carousel.CarouselSlider.builder(
//               itemCount: _features.length,
//               itemBuilder: (context, index, realIndex) {
//                 final feature = _features[index];
//                 return FeatureShowcase(
//                   feature: feature,
//                   onTap: () {
//                     HapticFeedback.lightImpact();
//                     _exploreFeature(feature);
//                   },
//                 );
//               },
//               options: carousel.CarouselOptions(
//                 height: 200,
//                 viewportFraction: 0.85,
//                 enlargeCenterPage: true,
//                 enableInfiniteScroll: true,
//                 autoPlay: true,
//                 autoPlayInterval: const Duration(seconds: 5),
//                 onPageChanged: (index, reason) {
//                   setState(() => _carouselIndex = index);
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Center(
//             child: AnimatedSmoothIndicator(
//               activeIndex: _carouselIndex,
//               count: _features.length,
//               effect: WormEffect(
//                 dotColor: theme.colorScheme.outline.withOpacity(0.4),
//                 activeDotColor: theme.colorScheme.primary,
//                 dotHeight: 8,
//                 dotWidth: 8,
//                 spacing: 12,
//               ),
//             ),
//           ),
//         ],
//       ).animate(delay: 400.ms).slideY(begin: 0.3).fadeIn(),
//     );
//   }

//   Widget _buildPremiumPromo(ThemeData theme) {
//     return SliverToBoxAdapter(
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(20, 32, 20, 0),
//         child: Stack(
//           children: [
//             Container(
//               height: 120,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     AppTheme.premiumGold,
//                     AppTheme.premiumGold.withOpacity(0.8),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppTheme.premiumGold.withOpacity(0.3),
//                     blurRadius: 12,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//             ),

//             // Floating elements animation
//             Positioned(
//               top: 12,
//               right: 20,
//               child: AnimatedBuilder(
//                 animation: _pulseController,
//                 builder: (context, child) {
//                   return Transform.translate(
//                     offset: Offset(0, _pulseController.value * 10),
//                     child: Container(
//                       width: 28,
//                       height: 28,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             Positioned(
//               bottom: 20,
//               right: 40,
//               child: AnimatedBuilder(
//                 animation: _pulseController,
//                 builder: (context, child) {
//                   return Transform.translate(
//                     offset: Offset(0, -_pulseController.value * 6),
//                     child: Container(
//                       width: 20,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.15),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.diamond_rounded,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               'Upgrade to Pro',
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Unlock real-time detection, advanced analytics, and more powerful features',
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: Colors.white.withOpacity(0.9),
//                             height: 1.4,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         HapticFeedback.lightImpact();
//                         Navigator.pushNamed(context, '/premium');
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: AppTheme.premiumGold,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 12,
//                         ),
//                       ),
//                       child: Text(
//                         'Try Free',
//                         style: theme.textTheme.labelLarge?.copyWith(
//                             fontWeight: FontWeight.bold, color: Colors.black),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ).animate(delay: 600.ms).slideX().fadeIn(),
//     );
//   }

//   Widget _buildRecentDetections(List<dynamic> detections, ThemeData theme) {
//     if (detections.isEmpty) {
//       return SliverToBoxAdapter(
//         child: Container(
//           margin: const EdgeInsets.fromLTRB(20, 32, 20, 0),
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: theme.colorScheme.outline.withOpacity(0.2),
//             ),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 width: 64,
//                 height: 64,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.history_rounded,
//                   size: 32,
//                   color: theme.colorScheme.primary.withOpacity(0.7),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'No Recent Detections',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Start by taking your first photo',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.colorScheme.onSurfaceVariant,
//                 ),
//               ),
//             ],
//           ),
//         ).animate(delay: 800.ms).slideY(begin: 0.3).fadeIn(),
//       );
//     }

//     return SliverToBoxAdapter(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
//             child: Text(
//               'Recent Detections',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 100,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               itemCount: detections.length,
//               itemBuilder: (context, index) {
//                 final detection = detections[index];
//                 return Container(
//                   width: 220,
//                   margin: const EdgeInsets.only(right: 16),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.surface,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: theme.colorScheme.outline.withOpacity(0.2),
//                     ),
//                     boxShadow: AppTheme.getElevationShadow(context, 1),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         detection.detectedObjects.first,
//                         style: theme.textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: theme.colorScheme.onSurface,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         '${detection.detectedObjects.length} objects detected',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: theme.colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                       const Spacer(),
//                       Text(
//                         _formatTimeAgo(detection.timestamp),
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: theme.colorScheme.onSurfaceVariant
//                               .withOpacity(0.8),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ).animate(delay: 800.ms).slideX().fadeIn(),
//     );
//   }

//   // In HomeScreen's _buildDailyChallenge
//   Widget _buildDailyChallenge(ThemeData theme) {
//     return SliverToBoxAdapter(
//       child: Consumer(
//         builder: (context, ref, child) {
//           final challengeState = ref.watch(challengeProvider);

//           // Optional: Daily reset logic (e.g., if date changed)
//           // You can add a 'lastUpdated' field in Firestore and check here

//           return Container(
//             margin: const EdgeInsets.fromLTRB(20, 32, 20, 0),
//             child: DailyChallenge(
//               title: challengeState.title,
//               description: challengeState.description,
//               progress: challengeState.progress,
//               total: challengeState.total,
//               reward: challengeState.reward,
//               onTap: () {
//                 HapticFeedback.lightImpact();
//                 if (!challengeState.isCompleted) {
//                   _startChallenge();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text('Challenge already completed today!')),
//                   );
//                 }
//               },
//             ),
//           ).animate(delay: 1000.ms).slideY(begin: 0.3).fadeIn();
//         },
//       ),
//     );
//   }

//   Widget _buildAchievements(AnalyticsState analyticsState, ThemeData theme) {
//     final achievements = [
//       Achievement(
//         title: 'First Scan',
//         description: 'Complete your first object detection',
//         icon: Icons.camera_alt_rounded,
//         isUnlocked: analyticsState.totalDetections > 0, // Use analytics data
//         color: AppTheme.successColor,
//       ),
//       Achievement(
//         title: 'Explorer',
//         description: 'Complete 50 object detections',
//         icon: Icons.explore_rounded,
//         isUnlocked: analyticsState.totalDetections >= 50, // Use real data
//         color: AppTheme.primaryColor,
//       ),
//       Achievement(
//         title: 'Accuracy Master',
//         description: 'Achieve 85%+ average accuracy',
//         icon: Icons.trending_up_rounded,
//         isUnlocked: analyticsState.averageConfidence >= 0.85, // Use real data
//         color: AppTheme.secondaryColor,
//       ),
//       Achievement(
//         title: 'Variety Seeker',
//         description: 'Detect 20+ different object types',
//         icon: Icons.diversity_1_rounded,
//         isUnlocked: analyticsState.uniqueObjects.length >= 20, // Use real data
//         color: AppTheme.warningColor,
//       ),
//     ];

//     return SliverToBoxAdapter(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
//             child: Row(
//               children: [
//                 Text(
//                   'Achievements',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // Show progress indicator
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '${achievements.where((a) => a.isUnlocked).length}/${achievements.length}',
//                     style: theme.textTheme.labelSmall?.copyWith(
//                       color: theme.colorScheme.primary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const Spacer(),
//                 TextButton(
//                   onPressed: () {
//                     HapticFeedback.lightImpact();
//                     Navigator.pushNamed(context, '/achievements');
//                   },
//                   style: TextButton.styleFrom(
//                     foregroundColor: theme.colorScheme.primary,
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'View All',
//                         style: theme.textTheme.labelLarge?.copyWith(
//                           color: theme.colorScheme.primary,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Icon(
//                         Icons.arrow_forward_ios_rounded,
//                         size: 14,
//                         color: theme.colorScheme.primary,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(
//             height: 100,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               itemCount: achievements.length,
//               itemBuilder: (context, index) {
//                 final achievement = achievements[index];
//                 return Container(
//                   width: 200,
//                   margin: const EdgeInsets.only(right: 16),
//                   child: AchievementBanner(achievement: achievement),
//                 );
//               },
//             ),
//           ),
//         ],
//       ).animate(delay: 1200.ms).slideX().fadeIn(),
//     );
//   }

//   Widget _buildTipsAndTricks(ThemeData theme) {
//     final tips = [
//       'Hold your phone steady for better detection accuracy',
//       'Good lighting improves recognition results significantly',
//       'Try different angles for complex or partially hidden objects',
//       'Use the grid feature for better composition and framing',
//       'Clean your camera lens for clearer image capture',
//     ];

//     return SliverToBoxAdapter(
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(20, 32, 20, 0),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               theme.colorScheme.primary.withOpacity(0.1),
//               theme.colorScheme.tertiary.withOpacity(0.1),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: theme.colorScheme.primary.withOpacity(0.2),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     Icons.lightbulb_rounded,
//                     color: theme.colorScheme.primary,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Pro Tips',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ...tips.asMap().entries.map((entry) {
//               final index = entry.key;
//               final tip = entry.value;
//               return Padding(
//                 padding:
//                     EdgeInsets.only(bottom: index < tips.length - 1 ? 12 : 0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: 6,
//                       height: 6,
//                       margin: const EdgeInsets.only(top: 8),
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.primary,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Text(
//                         tip,
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: theme.colorScheme.onSurfaceVariant,
//                           height: 1.5,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ],
//         ),
//       ).animate(delay: 1400.ms).slideY(begin: 0.3).fadeIn(),
//     );
//   }

//   // Helper Methods
//   String _getGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) return 'Good morning';
//     if (hour < 17) return 'Good afternoon';
//     return 'Good evening';
//   }

//   String _formatTimeAgo(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);

//     if (difference.inMinutes < 1) {
//       return 'Just now';
//     } else if (difference.inHours < 1) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inDays < 1) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d ago';
//     } else {
//       return '${difference.inDays ~/ 7}w ago';
//     }
//   }

//   // Action Methods
//   void _pickFromGallery() async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 90,
//         maxWidth: 1920,
//         maxHeight: 1920,
//       );

//       if (image != null) {
//         // Show loading indicator
//         if (mounted) {
//           showDialog(
//             context: context,
//             barrierDismissible: false,
//             builder: (context) => AlertDialog(
//               backgroundColor: Theme.of(context).colorScheme.surface,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Processing image...',
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                           color: Theme.of(context).colorScheme.onSurface,
//                         ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         // Process the image through the detection provider
//         final detectionNotifier = ref.read(detectionProvider.notifier);
//         await detectionNotifier.processImage(
//           File(image.path),
//           mode: CameraMode.object, // Default mode or get from user preference
//         );

//         // Track analytics
//         ref
//             .read(analyticsProvider.notifier)
//             .trackDetection(CameraMode.object, 0);

//         if (mounted) {
//           Navigator.pop(context); // Close loading dialog

//           // Check if detection was successful before navigating
//           final detectionState = ref.read(detectionProvider);
//           if (detectionState.currentResult != null) {
//             Navigator.pushNamed(context, '/result');
//           } else {
//             // Handle case where detection failed
//             _showErrorSnackBar('Failed to process image. Please try again.');
//           }
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         // Close loading dialog if it's open
//         Navigator.of(context, rootNavigator: true).pop();

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(
//                   Icons.error_outline_rounded,
//                   color: Theme.of(context).colorScheme.onError,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Failed to pick image: ${e.toString()}',
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.onError,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: Theme.of(context).colorScheme.error,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.error_outline_rounded,
//               color: Theme.of(context).colorScheme.onError,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.onError,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Theme.of(context).colorScheme.error,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   void _exploreFeature(FeatureHighlight feature) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       useSafeArea: true,
//       builder: (context) => FeatureExploreSheet(feature: feature),
//     );
//   }

//   void _startChallenge() {
//     Navigator.pushNamed(
//       context,
//       '/camera',
//       arguments: {
//         'challenge': true,
//         'challengeType': 'plants',
//         'challengeTarget': 3,
//       },
//     );
//   }

//   void _showFeatureComingSoon(String featureName) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.info_outline_rounded,
//               color: Theme.of(context).colorScheme.onPrimary,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 '$featureName is coming soon! Stay tuned for updates.',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.primaryColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _navigateToSettings() {
//     HapticFeedback.lightImpact();
//     Navigator.pushNamed(context, '/settings');
//   }

//   void _navigateToFeedback() {
//     HapticFeedback.lightImpact();
//     Navigator.pushNamed(context, '/feedback');
//   }

//   void _handleQuickAction(String action) {
//     HapticFeedback.lightImpact();

//     switch (action) {
//       case 'camera':
//         Navigator.pushNamed(context, '/camera');
//         break;
//       case 'gallery':
//         _pickFromGallery();
//         break;
//       case 'history':
//         Navigator.pushNamed(context, '/history');
//         break;
//       case 'settings':
//         _navigateToSettings();
//         break;
//       case 'feedback':
//         _navigateToFeedback();
//         break;
//       default:
//         _showFeatureComingSoon(action);
//     }
//   }

//   void _onAchievementTap(Achievement achievement) {
//     HapticFeedback.lightImpact();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: achievement.color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 achievement.icon,
//                 color: achievement.color,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 achievement.title,
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               achievement.description,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Theme.of(context).colorScheme.onSurfaceVariant,
//                     height: 1.5,
//                   ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: achievement.isUnlocked
//                     ? AppTheme.successColor.withOpacity(0.1)
//                     : Theme.of(context).colorScheme.surfaceContainerHighest,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: achievement.isUnlocked
//                       ? AppTheme.successColor.withOpacity(0.3)
//                       : Theme.of(context).colorScheme.outline.withOpacity(0.3),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     achievement.isUnlocked
//                         ? Icons.check_circle_rounded
//                         : Icons.lock_rounded,
//                     color: achievement.isUnlocked
//                         ? AppTheme.successColor
//                         : Theme.of(context).colorScheme.onSurfaceVariant,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     achievement.isUnlocked ? 'Unlocked!' : 'Locked',
//                     style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                           color: achievement.isUnlocked
//                               ? AppTheme.successColor
//                               : Theme.of(context).colorScheme.onSurfaceVariant,
//                           fontWeight: FontWeight.w600,
//                         ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Close',
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.primary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           if (!achievement.isUnlocked)
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Theme.of(context).colorScheme.primary,
//                     Theme.of(context).colorScheme.secondary,
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _handleQuickAction(
//                       'camera'); // Start scanning to work towards achievement
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text(
//                   'Start Scanning',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // screens/achievements_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// import '../models/achievement.dart';
// import '../providers/analytics_provider.dart';
// import '../providers/premium_provider.dart';
// import '../config/app_theme.dart';
// import '../widgets/ad_widgets.dart';

// class AchievementsScreen extends ConsumerStatefulWidget {
//   const AchievementsScreen({super.key});

//   @override
//   ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
// }

// class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _sparkleController;
//   String _selectedCategory = 'all';

//   final List<String> _categories = [
//     'all',
//     'detection',
//     'exploration',
//     'social',
//     'challenges'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat(reverse: true);

//     _sparkleController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _sparkleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final analyticsState = ref.watch(analyticsProvider);
//     final isPremium = ref.watch(premiumProvider).isPremium;

//     final achievements = _getAllAchievements(analyticsState);
//     final filteredAchievements = _selectedCategory == 'all'
//         ? achievements
//         : achievements.where((a) => a.category == _selectedCategory).toList();

//     final unlockedCount = achievements.where((a) => a.isUnlocked).length;
//     final totalCount = achievements.length;
//     final completionPercentage = (unlockedCount / totalCount * 100).round();

//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           _buildSliverAppBar(
//               theme, unlockedCount, totalCount, completionPercentage),

//           // Banner ad for non-premium users
//           if (!isPremium)
//             SliverToBoxAdapter(
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                 child: const AdBanner(
//                   placement: 'achievements_top',
//                   adSize: AdSize.mediumRectangle,
//                 ),
//               ).animate().slideY(begin: 0.3).fadeIn(),
//             ),

//           _buildProgressSection(
//               theme, unlockedCount, totalCount, completionPercentage),
//           _buildCategoryFilters(theme),

//           // Native ad in content feed
//           if (!isPremium && filteredAchievements.length > 6)
//             SliverToBoxAdapter(
//               child: Container(
//                 margin:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                 child: const NativeAdWidget(placement: 'achievements_feed'),
//               ),
//             ),

//           _buildAchievementsGrid(filteredAchievements, theme),

//           // Another banner ad at bottom
//           if (!isPremium)
//             SliverToBoxAdapter(
//               child: Container(
//                 margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
//                 child: const AdBanner(placement: 'achievements_bottom'),
//               ),
//             ),

//           const SliverToBoxAdapter(child: SizedBox(height: 100)),
//         ],
//       ),
//     );
//   }

//   Widget _buildSliverAppBar(
//       ThemeData theme, int unlockedCount, int totalCount, int percentage) {
//     return SliverAppBar(
//       expandedHeight: 200,
//       floating: false,
//       pinned: true,
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       leading: IconButton(
//         onPressed: () {
//           HapticFeedback.lightImpact();
//           Navigator.pop(context);
//         },
//         icon: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: theme.colorScheme.surface.withOpacity(0.9),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: AppTheme.getElevationShadow(context, 2),
//           ),
//           child: Icon(
//             Icons.arrow_back_ios_new_rounded,
//             color: theme.colorScheme.onSurface,
//             size: 18,
//           ),
//         ),
//       ),
//       actions: [
//         Container(
//           margin: const EdgeInsets.only(right: 16),
//           child: IconButton(
//             onPressed: () {
//               HapticFeedback.lightImpact();
//               _showAchievementTips();
//             },
//             icon: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.surface.withOpacity(0.9),
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: AppTheme.getElevationShadow(context, 2),
//               ),
//               child: Icon(
//                 Icons.help_outline_rounded,
//                 color: theme.colorScheme.onSurface,
//                 size: 20,
//               ),
//             ),
//           ),
//         ),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 theme.colorScheme.primary.withOpacity(0.1),
//                 theme.colorScheme.secondary.withOpacity(0.1),
//                 theme.colorScheme.surface,
//               ],
//             ),
//           ),
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Row(
//                     children: [
//                       AnimatedBuilder(
//                         animation: _sparkleController,
//                         builder: (context, child) {
//                           return Transform.rotate(
//                             angle: _sparkleController.value * 2 * 3.14159,
//                             child: Container(
//                               width: 48,
//                               height: 48,
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     AppTheme.premiumGold,
//                                     AppTheme.premiumGold.withOpacity(0.7),
//                                   ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(16),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color:
//                                         AppTheme.premiumGold.withOpacity(0.3),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: const Icon(
//                                 Icons.emoji_events_rounded,
//                                 color: Colors.white,
//                                 size: 24,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Achievements',
//                               style: theme.textTheme.headlineSmall?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: theme.colorScheme.onSurface,
//                               ),
//                             ).animate().slideX().fadeIn(),
//                             const SizedBox(height: 4),
//                             Text(
//                               '$unlockedCount of $totalCount unlocked ($percentage%)',
//                               style: theme.textTheme.bodyMedium?.copyWith(
//                                 color: theme.colorScheme.onSurfaceVariant,
//                               ),
//                             ).animate(delay: 200.ms).slideX().fadeIn(),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProgressSection(
//       ThemeData theme, int unlockedCount, int totalCount, int percentage) {
//     return SliverToBoxAdapter(
//       child: Container(
//         margin: const EdgeInsets.all(20),
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               theme.colorScheme.primary.withOpacity(0.1),
//               theme.colorScheme.secondary.withOpacity(0.1),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: theme.colorScheme.outline.withOpacity(0.2),
//           ),
//           boxShadow: AppTheme.getElevationShadow(context, 2),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'Overall Progress',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '$percentage%',
//                     style: theme.textTheme.labelLarge?.copyWith(
//                       color: theme.colorScheme.primary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // Progress bar
//             Container(
//               height: 8,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.surfaceContainerHighest,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: FractionallySizedBox(
//                 alignment: Alignment.centerLeft,
//                 widthFactor: unlockedCount / totalCount,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         theme.colorScheme.primary,
//                         theme.colorScheme.secondary,
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             Row(
//               children: [
//                 _buildProgressItem(
//                   'Unlocked',
//                   unlockedCount.toString(),
//                   Icons.check_circle_rounded,
//                   AppTheme.successColor,
//                   theme,
//                 ),
//                 const SizedBox(width: 24),
//                 _buildProgressItem(
//                   'Remaining',
//                   (totalCount - unlockedCount).toString(),
//                   Icons.lock_rounded,
//                   theme.colorScheme.onSurfaceVariant,
//                   theme,
//                 ),
//                 const SizedBox(width: 24),
//                 _buildProgressItem(
//                   'Total XP',
//                   '${unlockedCount * 50}',
//                   Icons.star_rounded,
//                   AppTheme.warningColor,
//                   theme,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ).animate().slideY(begin: 0.3).fadeIn(),
//     );
//   }

//   Widget _buildProgressItem(
//       String label, String value, IconData icon, Color color, ThemeData theme) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 16, color: color),
//               const SizedBox(width: 4),
//               Text(
//                 label,
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: theme.colorScheme.onSurfaceVariant,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryFilters(ThemeData theme) {
//     return SliverToBoxAdapter(
//       child: Container(
//         height: 50,
//         margin: const EdgeInsets.symmetric(horizontal: 20),
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           itemCount: _categories.length,
//           itemBuilder: (context, index) {
//             final category = _categories[index];
//             final isSelected = category == _selectedCategory;

//             return Container(
//               margin: const EdgeInsets.only(right: 12),
//               child: FilterChip(
//                 label: Text(
//                   _getCategoryLabel(category),
//                   style: TextStyle(
//                     color: isSelected
//                         ? Colors.white
//                         : theme.colorScheme.onSurfaceVariant,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 selected: isSelected,
//                 onSelected: (selected) {
//                   HapticFeedback.selectionClick();
//                   setState(() => _selectedCategory = category);
//                 },
//                 selectedColor: theme.colorScheme.primary,
//                 backgroundColor: theme.colorScheme.surfaceContainerHighest,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 elevation: isSelected ? 2 : 0,
//                 pressElevation: 4,
//               ),
//             );
//           },
//         ),
//       ).animate(delay: 600.ms).slideX().fadeIn(),
//     );
//   }

//   Widget _buildAchievementsGrid(
//       List<ExtendedAchievement> achievements, ThemeData theme) {
//     return SliverPadding(
//       padding: const EdgeInsets.all(20),
//       sliver: SliverGrid(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 0.85,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//         ),
//         delegate: SliverChildBuilderDelegate(
//           (context, index) {
//             final achievement = achievements[index];
//             return _buildAchievementCard(achievement, theme, index);
//           },
//           childCount: achievements.length,
//         ),
//       ),
//     );
//   }

//   Widget _buildAchievementCard(
//       ExtendedAchievement achievement, ThemeData theme, int index) {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         _showAchievementDetail(achievement);
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surface,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: achievement.isUnlocked
//                 ? achievement.color.withOpacity(0.3)
//                 : theme.colorScheme.outline.withOpacity(0.2),
//             width: achievement.isUnlocked ? 2 : 1,
//           ),
//           boxShadow: achievement.isUnlocked
//               ? [
//                   BoxShadow(
//                     color: achievement.color.withOpacity(0.2),
//                     blurRadius: 12,
//                     offset: const Offset(0, 6),
//                   ),
//                 ]
//               : AppTheme.getElevationShadow(context, 2),
//         ),
//         child: Stack(
//           children: [
//             // Background pattern for unlocked achievements
//             if (achievement.isUnlocked)
//               Positioned.fill(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         achievement.color.withOpacity(0.05),
//                         achievement.color.withOpacity(0.02),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Icon and status
//                   Row(
//                     children: [
//                       Container(
//                         width: 48,
//                         height: 48,
//                         decoration: BoxDecoration(
//                           color: achievement.isUnlocked
//                               ? achievement.color
//                               : theme.colorScheme.surfaceContainerHighest,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: achievement.isUnlocked
//                               ? [
//                                   BoxShadow(
//                                     color: achievement.color.withOpacity(0.3),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ]
//                               : null,
//                         ),
//                         child: Icon(
//                           achievement.icon,
//                           color: achievement.isUnlocked
//                               ? Colors.white
//                               : theme.colorScheme.onSurfaceVariant,
//                           size: 24,
//                         ),
//                       ),
//                       const Spacer(),
//                       if (achievement.isUnlocked)
//                         AnimatedBuilder(
//                           animation: _pulseController,
//                           builder: (context, child) {
//                             return Transform.scale(
//                               scale: 1.0 + (_pulseController.value * 0.2),
//                               child: const Icon(
//                                 Icons.check_circle_rounded,
//                                 color: AppTheme.successColor,
//                                 size: 24,
//                               ),
//                             );
//                           },
//                         )
//                       else
//                         Icon(
//                           Icons.lock_rounded,
//                           color: theme.colorScheme.onSurfaceVariant
//                               .withOpacity(0.5),
//                           size: 20,
//                         ),
//                     ],
//                   ),

//                   const SizedBox(height: 16),

//                   // Title
//                   Text(
//                     achievement.title,
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: achievement.isUnlocked
//                           ? theme.colorScheme.onSurface
//                           : theme.colorScheme.onSurfaceVariant,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),

//                   const SizedBox(height: 8),

//                   // Description
//                   Text(
//                     achievement.description,
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: achievement.isUnlocked
//                           ? theme.colorScheme.onSurfaceVariant
//                           : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
//                       height: 1.4,
//                     ),
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),

//                   const Spacer(),

//                   // Progress or reward
//                   if (achievement.progress != null && !achievement.isUnlocked)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               'Progress',
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 color: theme.colorScheme.onSurfaceVariant,
//                               ),
//                             ),
//                             const Spacer(),
//                             Text(
//                               '${achievement.progress}/${achievement.target}',
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 color: theme.colorScheme.primary,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         LinearProgressIndicator(
//                           value: (achievement.progress! / achievement.target!),
//                           backgroundColor:
//                               theme.colorScheme.surfaceContainerHighest,
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(achievement.color),
//                         ),
//                       ],
//                     )
//                   else
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: achievement.isUnlocked
//                             ? AppTheme.successColor.withOpacity(0.1)
//                             : theme.colorScheme.surfaceContainerHighest,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         achievement.isUnlocked
//                             ? '+${achievement.xp} XP'
//                             : '${achievement.xp} XP',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: achievement.isUnlocked
//                               ? AppTheme.successColor
//                               : theme.colorScheme.onSurfaceVariant,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       )
//           .animate(delay: Duration(milliseconds: 100 * index))
//           .slideY(begin: 0.3)
//           .fadeIn(),
//     );
//   }

//   // Helper methods
//   String _getCategoryLabel(String category) {
//     switch (category) {
//       case 'all':
//         return 'All';
//       case 'detection':
//         return 'Detection';
//       case 'exploration':
//         return 'Explorer';
//       case 'social':
//         return 'Social';
//       case 'challenges':
//         return 'Challenges';
//       default:
//         return category;
//     }
//   }

//   List<ExtendedAchievement> _getAllAchievements(AnalyticsState analyticsState) {
//     return [
//       // Detection Achievements
//       ExtendedAchievement(
//         title: 'First Scan',
//         description: 'Complete your first object detection',
//         icon: Icons.camera_alt_rounded,
//         isUnlocked: analyticsState.totalDetections > 0,
//         color: AppTheme.successColor,
//         category: 'detection',
//         xp: 50,
//         progress: analyticsState.totalDetections > 0 ? 1 : 0,
//         target: 1,
//       ),
//       ExtendedAchievement(
//         title: 'Scanner',
//         description: 'Scan 10 different objects',
//         icon: Icons.qr_code_scanner_rounded,
//         isUnlocked: analyticsState.totalDetections >= 10,
//         color: AppTheme.primaryColor,
//         category: 'detection',
//         xp: 100,
//         progress: analyticsState.totalDetections.clamp(0, 10),
//         target: 10,
//       ),
//       ExtendedAchievement(
//         title: 'Explorer',
//         description: 'Scan 100 different objects',
//         icon: Icons.explore_rounded,
//         isUnlocked: analyticsState.totalDetections >= 100,
//         color: AppTheme.secondaryColor,
//         category: 'detection',
//         xp: 500,
//         progress: analyticsState.totalDetections.clamp(0, 100),
//         target: 100,
//       ),
//       ExtendedAchievement(
//         title: 'Master Detective',
//         description: 'Scan 1000 different objects',
//         icon: Icons.search_rounded,
//         isUnlocked: analyticsState.totalDetections >= 1000,
//         color: AppTheme.premiumGold,
//         category: 'detection',
//         xp: 2000,
//         progress: analyticsState.totalDetections.clamp(0, 1000),
//         target: 1000,
//       ),

//       // Accuracy Achievements
//       ExtendedAchievement(
//         title: 'Sharp Eye',
//         description: 'Achieve 80%+ average accuracy',
//         icon: Icons.visibility_rounded,
//         isUnlocked: analyticsState.averageConfidence >= 0.8,
//         color: AppTheme.warningColor,
//         category: 'detection',
//         xp: 200,
//       ),
//       ExtendedAchievement(
//         title: 'Accuracy Master',
//         description: 'Achieve 90%+ average accuracy',
//         icon: Icons.trending_up_rounded,
//         isUnlocked: analyticsState.averageConfidence >= 0.9,
//         color: AppTheme.primaryColor,
//         category: 'detection',
//         xp: 500,
//       ),
//       ExtendedAchievement(
//         title: 'Perfect Vision',
//         description: 'Achieve 95%+ average accuracy',
//         icon: Icons.remove_red_eye_rounded,
//         isUnlocked: analyticsState.averageConfidence >= 0.95,
//         color: AppTheme.premiumGold,
//         category: 'detection',
//         xp: 1000,
//       ),

//       // Exploration Achievements
//       ExtendedAchievement(
//         title: 'Animal Lover',
//         description: 'Scan 20 different animals',
//         icon: Icons.pets_rounded,
//         isUnlocked: false, // Would need to track animal detections
//         color: Colors.brown,
//         category: 'exploration',
//         xp: 300,
//         progress: 5, // Mock progress
//         target: 20,
//       ),
//       ExtendedAchievement(
//         title: 'Plant Expert',
//         description: 'Scan 15 different plants',
//         icon: Icons.local_florist_rounded,
//         isUnlocked: false,
//         color: Colors.green,
//         category: 'exploration',
//         xp: 250,
//         progress: 3,
//         target: 15,
//       ),
//       ExtendedAchievement(
//         title: 'Food Critic',
//         description: 'Scan 30 different food items',
//         icon: Icons.restaurant_rounded,
//         isUnlocked: false,
//         color: Colors.orange,
//         category: 'exploration',
//         xp: 400,
//         progress: 12,
//         target: 30,
//       ),

//       // Challenge Achievements
//       ExtendedAchievement(
//         title: 'Daily Challenger',
//         description: 'Complete 7 daily challenges',
//         icon: Icons.star_rounded,
//         isUnlocked: false,
//         color: AppTheme.warningColor,
//         category: 'challenges',
//         xp: 350,
//         progress: 2,
//         target: 7,
//       ),
//       ExtendedAchievement(
//         title: 'Streak Master',
//         description: 'Maintain a 30-day challenge streak',
//         icon: Icons.local_fire_department_rounded,
//         isUnlocked: false,
//         color: Colors.deepOrange,
//         category: 'challenges',
//         xp: 1500,
//         progress: 5,
//         target: 30,
//       ),

//       // Social Achievements
//       ExtendedAchievement(
//         title: 'Sharer',
//         description: 'Share your first detection',
//         icon: Icons.share_rounded,
//         isUnlocked: false,
//         color: Colors.blue,
//         category: 'social',
//         xp: 100,
//       ),
//       ExtendedAchievement(
//         title: 'Collector',
//         description: 'Save 50 detections to favorites',
//         icon: Icons.favorite_rounded,
//         isUnlocked: false,
//         color: Colors.pink,
//         category: 'social',
//         xp: 300,
//         progress: 8,
//         target: 50,
//       ),
//     ];
//   }

//   void _showAchievementDetail(ExtendedAchievement achievement) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.surface,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: Column(
//           children: [
//             // Handle
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),

//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   children: [
//                     // Achievement icon and status
//                     Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: achievement.isUnlocked
//                             ? achievement.color
//                             : Theme.of(context)
//                                 .colorScheme
//                                 .surfaceContainerHighest,
//                         borderRadius: BorderRadius.circular(24),
//                         boxShadow: achievement.isUnlocked
//                             ? [
//                                 BoxShadow(
//                                   color: achievement.color.withOpacity(0.3),
//                                   blurRadius: 16,
//                                   offset: const Offset(0, 8),
//                                 ),
//                               ]
//                             : null,
//                       ),
//                       child: Icon(
//                         achievement.icon,
//                         color: achievement.isUnlocked
//                             ? Colors.white
//                             : Theme.of(context).colorScheme.onSurfaceVariant,
//                         size: 40,
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // Title and status
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           achievement.title,
//                           style: Theme.of(context)
//                               .textTheme
//                               .headlineSmall
//                               ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: Theme.of(context).colorScheme.onSurface,
//                               ),
//                         ),
//                         const SizedBox(width: 8),
//                         if (achievement.isUnlocked)
//                           const Icon(
//                             Icons.check_circle_rounded,
//                             color: AppTheme.successColor,
//                             size: 24,
//                           )
//                         else
//                           Icon(
//                             Icons.lock_rounded,
//                             color:
//                                 Theme.of(context).colorScheme.onSurfaceVariant,
//                             size: 20,
//                           ),
//                       ],
//                     ),

//                     const SizedBox(height: 12),

//                     // Description
//                     Text(
//                       achievement.description,
//                       textAlign: TextAlign.center,
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             color:
//                                 Theme.of(context).colorScheme.onSurfaceVariant,
//                             height: 1.5,
//                           ),
//                     ),

//                     const SizedBox(height: 32),

//                     // Progress section
//                     if (achievement.progress != null &&
//                         !achievement.isUnlocked) ...[
//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: Theme.of(context)
//                               .colorScheme
//                               .surfaceContainerHighest
//                               .withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .outline
//                                 .withOpacity(0.2),
//                           ),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'Progress',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleMedium
//                                       ?.copyWith(
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                 ),
//                                 Text(
//                                   '${achievement.progress}/${achievement.target}',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleMedium
//                                       ?.copyWith(
//                                         color: achievement.color,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             LinearProgressIndicator(
//                               value:
//                                   (achievement.progress! / achievement.target!),
//                               backgroundColor: Theme.of(context)
//                                   .colorScheme
//                                   .surfaceContainerHighest,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                   achievement.color),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               '${((achievement.progress! / achievement.target!) * 100).round()}% Complete',
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodySmall
//                                   ?.copyWith(
//                                     color: Theme.of(context)
//                                         .colorScheme
//                                         .onSurfaceVariant,
//                                   ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],

//                     // Reward section
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: achievement.isUnlocked
//                               ? [
//                                   AppTheme.successColor.withOpacity(0.1),
//                                   AppTheme.successColor.withOpacity(0.05),
//                                 ]
//                               : [
//                                   achievement.color.withOpacity(0.1),
//                                   achievement.color.withOpacity(0.05),
//                                 ],
//                         ),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: achievement.isUnlocked
//                               ? AppTheme.successColor.withOpacity(0.3)
//                               : achievement.color.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: achievement.isUnlocked
//                                   ? AppTheme.successColor.withOpacity(0.2)
//                                   : achievement.color.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Icon(
//                               Icons.star_rounded,
//                               color: achievement.isUnlocked
//                                   ? AppTheme.successColor
//                                   : achievement.color,
//                               size: 20,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Reward',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .labelLarge
//                                       ?.copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .onSurfaceVariant,
//                                       ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   '${achievement.xp} XP',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleMedium
//                                       ?.copyWith(
//                                         fontWeight: FontWeight.bold,
//                                         color: achievement.isUnlocked
//                                             ? AppTheme.successColor
//                                             : achievement.color,
//                                       ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           if (achievement.isUnlocked)
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 6),
//                               decoration: BoxDecoration(
//                                 color: AppTheme.successColor,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Text(
//                                 'Earned',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),

//                     const Spacer(),

//                     // Action buttons
//                     if (!achievement.isUnlocked) ...[
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             HapticFeedback.lightImpact();
//                             Navigator.pop(context);
//                             Navigator.pushNamed(context, '/camera');
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: achievement.color,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             elevation: 2,
//                           ),
//                           child: const Text(
//                             'Start Scanning',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                     ],

//                     SizedBox(
//                       width: double.infinity,
//                       child: TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         style: TextButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                         child: Text(
//                           achievement.isUnlocked ? 'Close' : 'Maybe Later',
//                           style: TextStyle(
//                             color:
//                                 Theme.of(context).colorScheme.onSurfaceVariant,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showAchievementTips() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: AppTheme.primaryColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.lightbulb_rounded,
//                 color: AppTheme.primaryColor,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 'Achievement Tips',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildTipItem(
//               'Use the camera regularly to unlock detection achievements',
//               Icons.camera_alt_rounded,
//               Theme.of(context),
//             ),
//             const SizedBox(height: 12),
//             _buildTipItem(
//               'Complete daily challenges for bonus XP and special achievements',
//               Icons.star_rounded,
//               Theme.of(context),
//             ),
//             const SizedBox(height: 12),
//             _buildTipItem(
//               'Try scanning different categories of objects to unlock exploration achievements',
//               Icons.explore_rounded,
//               Theme.of(context),
//             ),
//             const SizedBox(height: 12),
//             _buildTipItem(
//               'Share your detections and save favorites for social achievements',
//               Icons.share_rounded,
//               Theme.of(context),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'Got It',
//               style: TextStyle(
//                 color: AppTheme.primaryColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTipItem(String tip, IconData icon, ThemeData theme) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 24,
//           height: 24,
//           decoration: BoxDecoration(
//             color: theme.colorScheme.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Icon(
//             icon,
//             size: 14,
//             color: theme.colorScheme.primary,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             tip,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: theme.colorScheme.onSurfaceVariant,
//               height: 1.4,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Extended Achievement model with additional properties
// class ExtendedAchievement extends Achievement {
//   final String category;
//   final int xp;
//   final int? progress;
//   final int? target;

//   ExtendedAchievement({
//     required super.title,
//     required super.description,
//     required super.icon,
//     required super.isUnlocked,
//     required super.color,
//     required this.category,
//     required this.xp,
//     this.progress,
//     this.target,
//   });
// }


// // screens/result_screen.dart

// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:csv/csv.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:image/image.dart' as img;
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:translator/translator.dart';

// import '../models/detected_object.dart';
// import '../models/detection_result.dart';
// import '../providers/analytics_provider.dart';
// import '../providers/detection_provider.dart';
// import '../providers/favorites_provider.dart';
// import '../providers/history_provider.dart';
// import '../providers/premium_provider.dart';
// import '../config/app_theme.dart';
// import '../utils/camera_mode.dart';
// import '../widgets/ad_widgets.dart';
// import '../widgets/interactive_overlay.dart';

// class ResultScreen extends ConsumerStatefulWidget {
//   const ResultScreen({super.key});

//   @override
//   ConsumerState<ResultScreen> createState() => _ResultScreenState();
// }

// class _ResultScreenState extends ConsumerState<ResultScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   late AnimationController _overlayController;
//   late AnimationController _bounceController;
//   late AnimationController _shimmerController;

//   final FlutterTts _tts = FlutterTts();
//   final GoogleTranslator _translator = GoogleTranslator();

//   bool _showOverlays = true;
//   bool _isAnalyzing = false;
//   double _imageScale = 1.0;
//   String _selectedLanguage = 'es';

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//     _initializeTTS();

//     // Check if we have a result, if not, handle arguments
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final detectionState = ref.read(detectionProvider);
//       if (detectionState.currentResult == null) {
//         // Try to get arguments and process them
//         final args =
//             ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//         if (args != null && args.containsKey('imagePath')) {
//           _processImageFromArguments(args);
//         } else {
//           // No result and no arguments, navigate back
//           Navigator.pop(context);
//         }
//       }
//       _triggerAnalytics();
//     });
//   }

//   void _processImageFromArguments(Map<String, dynamic> args) async {
//     final imagePath = args['imagePath'] as String;
//     final source = args['source'] as String? ?? 'unknown';

//     try {
//       final detectionNotifier = ref.read(detectionProvider.notifier);
//       await detectionNotifier.processImage(
//         File(imagePath),
//         mode:
//             CameraMode.object, // You might want to pass this as an argument too
//       );

//       // Track analytics
//       ref.read(analyticsProvider.notifier).trackDetection(
//             CameraMode.object,
//             source == 'gallery' ? 0 : 1,
//           );
//     } catch (e) {
//       // Handle error and navigate back
//       if (mounted) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to process image: $e'),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     }
//   }

//   void _initializeControllers() {
//     _tabController = TabController(length: 4, vsync: this);
//     _overlayController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _bounceController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _shimmerController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat();

//     _overlayController.forward();
//   }

//   void _initializeTTS() async {
//     try {
//       await _tts.setLanguage("en-US");
//       await _tts.setSpeechRate(0.8);
//       await _tts.setVolume(0.8);
//     } catch (e) {
//       debugPrint('TTS initialization failed: $e');
//     }
//   }

//   void _triggerAnalytics() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(analyticsProvider.notifier).trackResultView();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _overlayController.dispose();
//     _bounceController.dispose();
//     _shimmerController.dispose();
//     _tts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, child) {
//         final detectionState = ref.watch(detectionProvider);
//         final isPremium = ref.watch(premiumProvider).isPremium;
//         final theme = Theme.of(context);

//         if (detectionState.currentResult == null) {
//           return _buildNoResultScreen(theme);
//         }

//         final result = detectionState.currentResult!;

//         if (result.isProcessing) {
//           return _buildProcessingScreen(result, theme);
//         }

//         if (result.error != null) {
//           return _buildErrorScreen(result, theme);
//         }

//         return _buildResultScreen(result, isPremium, theme);
//       },
//     );
//   }

//   Widget _buildNoResultScreen(ThemeData theme) {
//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       appBar: AppBar(
//         title: Text(
//           'No Results',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () {
//             HapticFeedback.lightImpact();
//             Navigator.pop(context);
//           },
//           icon: Icon(
//             Icons.arrow_back_rounded,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 140,
//                   height: 140,
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.surfaceContainerHighest
//                         .withOpacity(0.5),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.image_not_supported_rounded,
//                     size: 70,
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                 ).animate().scale(delay: 200.ms),
//                 const SizedBox(height: 32),
//                 Text(
//                   'No detection results available',
//                   style: theme.textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   'Take a photo to start analyzing objects with AI',
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 40),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       HapticFeedback.lightImpact();
//                       Navigator.pushReplacementNamed(context, '/camera');
//                     },
//                     icon: const Icon(Icons.camera_alt_rounded, size: 20),
//                     label: Text(
//                       'Take Photo',
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: theme.colorScheme.primary,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                   ),
//                 ).animate().slideY(begin: 0.3).fadeIn(delay: 400.ms),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProcessingScreen(DetectionResult result, ThemeData theme) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SingleChildScrollView(
//         child: Stack(
//           children: [
//             // Background image
//             Positioned.fill(
//               child: Image.file(
//                 result.imageFile,
//                 fit: BoxFit.cover,
//               ),
//             ),

//             // Blur overlay
//             Positioned.fill(
//               child: BackdropFilter(
//                 filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//                 child: Container(
//                   color: Colors.black.withOpacity(0.75),
//                 ),
//               ),
//             ),

//             // Processing UI
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 140,
//                     height: 140,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           theme.colorScheme.primary.withOpacity(0.3),
//                           theme.colorScheme.secondary.withOpacity(0.3),
//                         ],
//                       ),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: theme.colorScheme.primary.withOpacity(0.3),
//                           blurRadius: 30,
//                           spreadRadius: 5,
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.psychology_rounded,
//                       size: 70,
//                       color: Colors.white,
//                     ),
//                   )
//                       .animate()
//                       .scale(delay: 200.ms)
//                       .then()
//                       .shimmer(duration: 2000.ms),

//                   const SizedBox(height: 40),

//                   Text(
//                     'AI is analyzing your image',
//                     style: theme.textTheme.headlineMedium?.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ).animate().slideY(begin: 0.3).fadeIn(delay: 400.ms),

//                   const SizedBox(height: 16),

//                   Text(
//                     'This may take a few seconds...',
//                     style: theme.textTheme.bodyLarge?.copyWith(
//                       color: Colors.white.withOpacity(0.9),
//                     ),
//                   ).animate().fadeIn(delay: 600.ms),

//                   const SizedBox(height: 48),

//                   // Progress indicators
//                   _buildProcessingSteps(theme),
//                 ],
//               ),
//             ),

//             // Back button
//             Positioned(
//               top: MediaQuery.of(context).padding.top + 16,
//               left: 16,
//               child: Container(
//                 width: 44,
//                 height: 44,
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.6),
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.2),
//                   ),
//                 ),
//                 child: IconButton(
//                   onPressed: () {
//                     HapticFeedback.lightImpact();
//                     Navigator.pop(context);
//                   },
//                   icon: const Icon(
//                     Icons.arrow_back_rounded,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProcessingSteps(ThemeData theme) {
//     final steps = [
//       {'title': 'Preprocessing image', 'completed': true, 'active': false},
//       {'title': 'Detecting objects', 'completed': true, 'active': false},
//       {'title': 'Analyzing features', 'completed': false, 'active': true},
//       {'title': 'Generating insights', 'completed': false, 'active': false},
//     ];

//     return Column(
//       children: steps.asMap().entries.map((entry) {
//         final index = entry.key;
//         final step = entry.value;
//         return _buildProcessStep(
//           step['title'] as String,
//           step['completed'] as bool,
//           step['active'] as bool,
//           index,
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildProcessStep(
//       String title, bool isCompleted, bool isActive, int index) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             width: 24,
//             height: 24,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: isCompleted
//                   ? AppTheme.successColor
//                   : isActive
//                       ? AppTheme.primaryColor
//                       : Colors.grey.withOpacity(0.5),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: isCompleted
//                 ? const Icon(
//                     Icons.check_rounded,
//                     color: Colors.white,
//                     size: 16,
//                   )
//                 : isActive
//                     ? Container(
//                         width: 12,
//                         height: 12,
//                         margin: const EdgeInsets.all(6),
//                         child: const CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Colors.white,
//                           ),
//                         ),
//                       )
//                     : null,
//           ),
//           const SizedBox(width: 16),
//           Text(
//             title,
//             style: TextStyle(
//               color: isCompleted || isActive
//                   ? Colors.white
//                   : Colors.white.withOpacity(0.6),
//               fontSize: 16,
//               fontWeight:
//                   isCompleted || isActive ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     ).animate(delay: (index * 200 + 800).ms).slideX().fadeIn();
//   }

//   Widget _buildErrorScreen(DetectionResult result, ThemeData theme) {
//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       appBar: AppBar(
//         title: Text(
//           'Analysis Error',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: AppTheme.errorColor,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () {
//             HapticFeedback.lightImpact();
//             Navigator.pop(context);
//           },
//           icon: Icon(
//             Icons.arrow_back_rounded,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 140,
//                   height: 140,
//                   decoration: BoxDecoration(
//                     color: AppTheme.errorColor.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: AppTheme.errorColor.withOpacity(0.3),
//                       width: 2,
//                     ),
//                   ),
//                   child: const Icon(
//                     Icons.error_outline_rounded,
//                     size: 70,
//                     color: AppTheme.errorColor,
//                   ),
//                 ).animate().scale(delay: 200.ms),
//                 const SizedBox(height: 32),
//                 Text(
//                   'Analysis Failed',
//                   style: theme.textTheme.headlineMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: AppTheme.errorColor,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: AppTheme.errorColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: AppTheme.errorColor.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Text(
//                     result.error ??
//                         'An unexpected error occurred during image analysis',
//                     textAlign: TextAlign.center,
//                     style: theme.textTheme.bodyLarge?.copyWith(
//                       color: theme.colorScheme.onSurface,
//                       height: 1.5,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () {
//                           HapticFeedback.lightImpact();
//                           Navigator.pop(context);
//                         },
//                         icon: const Icon(Icons.arrow_back_rounded, size: 20),
//                         label: const Text('Go Back'),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: theme.colorScheme.onSurface,
//                           side: BorderSide(color: theme.colorScheme.outline),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           HapticFeedback.lightImpact();
//                           _retryAnalysis();
//                         },
//                         icon: const Icon(Icons.refresh_rounded, size: 20),
//                         label: const Text('Retry'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.errorColor,
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ).animate().slideY(begin: 0.3).fadeIn(delay: 400.ms),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildResultScreen(
//       DetectionResult result, bool isPremium, ThemeData theme) {
//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       body: Column(
//         children: [
//           // Main content
//           Expanded(
//             child: NestedScrollView(
//               headerSliverBuilder: (context, innerBoxIsScrolled) {
//                 return [
//                   SliverAppBar(
//                     expandedHeight: 320,
//                     pinned: true,
//                     elevation: 0,
//                     backgroundColor: Colors.transparent,
//                     surfaceTintColor: Colors.transparent,
//                     leading: Container(
//                       margin: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.surface.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(10),
//                         boxShadow: AppTheme.getElevationShadow(context, 2),
//                       ),
//                       child: IconButton(
//                         onPressed: () {
//                           HapticFeedback.lightImpact();
//                           Navigator.pop(context);
//                         },
//                         icon: Icon(
//                           Icons.arrow_back_rounded,
//                           color: theme.colorScheme.onSurface,
//                         ),
//                       ),
//                     ),
//                     flexibleSpace: FlexibleSpaceBar(
//                       background: _buildImageViewer(result, theme),
//                     ),
//                     actions: [
//                       Container(
//                         margin: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: theme.colorScheme.surface.withOpacity(0.9),
//                           borderRadius: BorderRadius.circular(10),
//                           boxShadow: AppTheme.getElevationShadow(context, 2),
//                         ),
//                         child: IconButton(
//                           icon: Icon(
//                             Icons.share_rounded,
//                             color: theme.colorScheme.onSurface,
//                           ),
//                           onPressed: () {
//                             HapticFeedback.lightImpact();
//                             _shareResults(result);
//                           },
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: theme.colorScheme.surface.withOpacity(0.9),
//                           borderRadius: BorderRadius.circular(10),
//                           boxShadow: AppTheme.getElevationShadow(context, 2),
//                         ),
//                         child: IconButton(
//                           icon: Icon(
//                             _showOverlays
//                                 ? Icons.visibility_rounded
//                                 : Icons.visibility_off_rounded,
//                             color: theme.colorScheme.onSurface,
//                           ),
//                           onPressed: _toggleOverlays,
//                         ),
//                       ),
//                       if (isPremium)
//                         Container(
//                           margin: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: theme.colorScheme.surface.withOpacity(0.9),
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: AppTheme.getElevationShadow(context, 2),
//                           ),
//                           child: PopupMenuButton<String>(
//                             onSelected: (value) =>
//                                 _handleMenuAction(value, result),
//                             icon: Icon(
//                               Icons.more_vert_rounded,
//                               color: theme.colorScheme.onSurface,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             itemBuilder: (context) => [
//                               PopupMenuItem(
//                                 value: 'export',
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       Icons.download_rounded,
//                                       color: theme.colorScheme.onSurface,
//                                       size: 20,
//                                     ),
//                                     const SizedBox(width: 12),
//                                     const Text('Export Data'),
//                                   ],
//                                 ),
//                               ),
//                               PopupMenuItem(
//                                 value: 'analyze',
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       Icons.analytics_rounded,
//                                       color: theme.colorScheme.onSurface,
//                                       size: 20,
//                                     ),
//                                     const SizedBox(width: 12),
//                                     const Text('Deep Analysis'),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                     bottom: PreferredSize(
//                       preferredSize: const Size.fromHeight(48),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: theme.colorScheme.surface,
//                           borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(20),
//                           ),
//                           boxShadow: AppTheme.getElevationShadow(context, 4),
//                         ),
//                         child: TabBar(
//                           controller: _tabController,
//                           // isScrollable: true,
//                           // tabAlignment: TabAlignment.start,
//                           indicatorColor: theme.colorScheme.primary,
//                           indicatorWeight: 3,
//                           labelColor: theme.colorScheme.primary,
//                           unselectedLabelColor:
//                               theme.colorScheme.onSurfaceVariant,
//                           labelStyle: theme.textTheme.labelLarge?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                           unselectedLabelStyle:
//                               theme.textTheme.labelLarge?.copyWith(
//                             fontWeight: FontWeight.w500,
//                           ),
//                           tabs: const [
//                             Tab(
//                               icon: Icon(Icons.category_rounded, size: 20),
//                               text: 'Objects',
//                             ),
//                             Tab(
//                               icon: Icon(Icons.analytics_rounded, size: 20),
//                               text: 'Analysis',
//                             ),
//                             Tab(
//                               icon: Icon(Icons.info_rounded, size: 20),
//                               text: 'Details',
//                             ),
//                             Tab(
//                               icon: Icon(Icons.translate_rounded, size: 20),
//                               text: 'Translate',
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ];
//               },
//               body: Column(
//                 children: [
//                   // Banner ad at top of results for non-premium users
//                   if (!isPremium)
//                     Container(
//                       margin: const EdgeInsets.all(16),
//                       child: const AdBanner(placement: 'results'),
//                     ),

//                   Expanded(
//                     child: TabBarView(
//                       controller: _tabController,
//                       children: [
//                         _buildObjectsTab(result, isPremium, theme),
//                         _buildAnalysisTabWithAds(result, isPremium, theme),
//                         _buildDetailsTab(result, isPremium, theme),
//                         _buildTranslateTab(result, isPremium, theme),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Bottom banner ad for non-premium users
//           if (!isPremium)
//             Container(
//               padding: const EdgeInsets.all(16),
//               child: const AdBanner(placement: 'results'),
//             ),
//         ],
//       ),
//       floatingActionButton: _buildFloatingActions(result, isPremium, theme),
//     );
//   }

//   Widget _buildAnalysisTabWithAds(
//       DetectionResult result, bool isPremium, ThemeData theme) {
//     if (!isPremium) {
//       return SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   gradient: AppTheme.premiumGradient,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppTheme.premiumGold.withOpacity(0.3),
//                       blurRadius: 20,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.analytics_rounded,
//                   color: Colors.white,
//                   size: 60,
//                 ),
//               ).animate().scale().then().shimmer(duration: 2000.ms),
//               const SizedBox(height: 32),
//               Text(
//                 'Advanced Analysis',
//                 style: theme.textTheme.headlineMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Get detailed AI insights, confidence analysis, and advanced metrics about your detected objects.',
//                 textAlign: TextAlign.center,
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   color: theme.colorScheme.onSurfaceVariant,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     HapticFeedback.lightImpact();
//                     Navigator.pushNamed(context, '/premium');
//                   },
//                   icon: const Icon(Icons.diamond_rounded, size: 20),
//                   label: Text(
//                     'Upgrade to Premium',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.premiumGold,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),
//               ).animate().slideY(begin: 0.3).fadeIn(delay: 500.ms),
//             ],
//           ),
//         ),
//       );
//     }

//     return _buildAnalysisTab(result, theme);
//   }

//   Widget _buildImageViewer(DetectionResult result, ThemeData theme) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         // Main image with gesture controls
//         InteractiveViewer(
//           minScale: 0.5,
//           maxScale: 4.0,
//           onInteractionUpdate: (details) {
//             setState(() {
//               _imageScale = details.scale;
//             });
//           },
//           child: Container(
//             color: Colors.black,
//             child: Center(
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.vertical(
//                   bottom: Radius.circular(20),
//                 ),
//                 child: Image.file(
//                   result.imageFile,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // Interactive overlay with detections
//         if (_showOverlays && result.objects.isNotEmpty)
//           Positioned.fill(
//             child: InteractiveOverlay(
//               result: result,
//               onObjectTap: _handleObjectTap,
//               scale: _imageScale,
//             ),
//           ),

//         // Image info overlay
//         Positioned(
//           bottom: 20,
//           left: 20,
//           child: _buildImageInfo(result, theme),
//         ),

//         // Quick actions overlay
//         Positioned(
//           top: 100,
//           right: 20,
//           child: _buildQuickActions(result, theme),
//         ),
//       ],
//     );
//   }

//   Widget _buildImageInfo(DetectionResult result, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.8),
//         borderRadius: BorderRadius.circular(25),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.2),
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 24,
//             height: 24,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.image_rounded,
//               color: Colors.white,
//               size: 14,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             '${result.objects.length} objects detected',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActions(DetectionResult result, ThemeData theme) {
//     final actions = [
//       {
//         'icon': Icons.volume_up_rounded,
//         'action': () => _readResults(result),
//         'tooltip': 'Read aloud',
//       },
//       {
//         'icon': Icons.save_alt_rounded,
//         'action': () => _saveResults(result),
//         'tooltip': 'Save results',
//       },
//       {
//         'icon': Icons.search_rounded,
//         'action': () => _searchSimilar(result),
//         'tooltip': 'Search similar',
//       },
//     ];

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: actions.asMap().entries.map((entry) {
//         final index = entry.key;
//         final action = entry.value;
//         return Container(
//           margin: EdgeInsets.only(bottom: index < actions.length - 1 ? 12 : 0),
//           child: _buildQuickActionButton(
//             action['icon'] as IconData,
//             action['action'] as VoidCallback,
//             action['tooltip'] as String,
//             theme,
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildQuickActionButton(
//     IconData icon,
//     VoidCallback onTap,
//     String tooltip,
//     ThemeData theme,
//   ) {
//     return Tooltip(
//       message: tooltip,
//       child: GestureDetector(
//         onTap: () {
//           HapticFeedback.lightImpact();
//           onTap();
//         },
//         child: Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.8),
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: Colors.white.withOpacity(0.2),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.3),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Icon(
//             icon,
//             color: Colors.white,
//             size: 22,
//           ),
//         ),
//       ),
//     ).animate().scale(delay: 100.ms);
//   }

//   Widget _buildObjectsTab(
//       DetectionResult result, bool isPremium, ThemeData theme) {
//     if (result.objects.isEmpty) {
//       return _buildEmptyState(
//         'No objects detected',
//         'Try a different image or adjust the camera angle',
//         theme,
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(20),
//       itemCount: result.objects.length,
//       itemBuilder: (context, index) {
//         final object = result.objects[index];
//         return _buildObjectCard(object, isPremium, theme)
//             .animate(delay: (index * 100).ms)
//             .slideX()
//             .fadeIn();
//       },
//     );
//   }

//   Widget _buildObjectCard(
//       DetectedObject object, bool isPremium, ThemeData theme) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: InkWell(
//         onTap: () {
//           HapticFeedback.lightImpact();
//           _showObjectDetails(object, theme);
//         },
//         borderRadius: BorderRadius.circular(20),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       color: _getConfidenceColor(object.confidence)
//                           .withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Icon(
//                       _getObjectIcon(object.label),
//                       color: _getConfidenceColor(object.confidence),
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           object.label,
//                           style: theme.textTheme.titleLarge?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: theme.colorScheme.onSurface,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Container(
//                               width: 8,
//                               height: 8,
//                               decoration: BoxDecoration(
//                                 color: _getConfidenceColor(object.confidence),
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               '${(object.confidence * 100).toInt()}% confidence',
//                               style: theme.textTheme.bodyMedium?.copyWith(
//                                 color: _getConfidenceColor(object.confidence),
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: _getConfidenceColor(object.confidence)
//                           .withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: _getConfidenceColor(object.confidence)
//                             .withOpacity(0.3),
//                       ),
//                     ),
//                     child: Text(
//                       '${(object.confidence * 100).toInt()}%',
//                       style: theme.textTheme.labelMedium?.copyWith(
//                         color: _getConfidenceColor(object.confidence),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               if (object.description != null) ...[
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.surfaceContainerHighest
//                         .withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     object.description!,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                       height: 1.5,
//                     ),
//                   ),
//                 ),
//               ],

//               const SizedBox(height: 20),

//               // Action buttons
//               Wrap(
//                 spacing: 12,
//                 runSpacing: 12,
//                 children: [
//                   _buildActionChip(
//                     Icons.info_outline_rounded,
//                     'Details',
//                     () => _showObjectDetails(object, theme),
//                     theme,
//                   ),
//                   if (isPremium) ...[
//                     _buildActionChip(
//                       Icons.lightbulb_outline_rounded,
//                       'Fun Fact',
//                       () => _showFunFact(object),
//                       theme,
//                     ),
//                     _buildActionChip(
//                       Icons.shopping_cart_outlined,
//                       'Buy',
//                       () => _searchToBuy(object),
//                       theme,
//                     ),
//                   ] else ...[
//                     _buildPremiumActionChip(
//                       Icons.lightbulb_outline_rounded,
//                       'Fun Fact',
//                       theme,
//                     ),
//                     _buildPremiumActionChip(
//                       Icons.shopping_cart_outlined,
//                       'Buy',
//                       theme,
//                     ),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionChip(
//     IconData icon,
//     String label,
//     VoidCallback onTap,
//     ThemeData theme,
//   ) {
//     return InkWell(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         onTap();
//       },
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: theme.colorScheme.primary.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: theme.colorScheme.primary.withOpacity(0.3),
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 18,
//               color: theme.colorScheme.primary,
//             ),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: theme.textTheme.labelMedium?.copyWith(
//                 color: theme.colorScheme.primary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPremiumActionChip(IconData icon, String label, ThemeData theme) {
//     return InkWell(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         Navigator.pushNamed(context, '/premium');
//       },
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: AppTheme.premiumGold.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: AppTheme.premiumGold.withOpacity(0.3),
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.diamond_rounded,
//               size: 16,
//               color: AppTheme.premiumGold,
//             ),
//             const SizedBox(width: 4),
//             Icon(
//               icon,
//               size: 18,
//               color: AppTheme.premiumGold,
//             ),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: theme.textTheme.labelMedium?.copyWith(
//                 color: AppTheme.premiumGold,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAnalysisTab(DetectionResult result, ThemeData theme) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildAnalyticsPanel(result, theme),
//           const SizedBox(height: 24),
//           _buildInsightsSection(result, theme),
//           const SizedBox(height: 24),
//           _buildRecommendationsSection(result, theme),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnalyticsPanel(DetectionResult result, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.analytics_rounded,
//                   color: theme.colorScheme.primary,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'Image Analytics',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),

//           // Confidence distribution
//           if (result.objects.isNotEmpty) _buildConfidenceChart(result, theme),

//           const SizedBox(height: 24),

//           // Statistics grid
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 2,
//             childAspectRatio: 1.2,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             children: [
//               _buildStatCard(
//                 'Objects',
//                 '${result.objects.length}',
//                 Icons.category_rounded,
//                 theme.colorScheme.primary,
//                 theme,
//               ),
//               _buildStatCard(
//                 'Avg Confidence',
//                 '${_getAverageConfidence(result)}%',
//                 Icons.trending_up_rounded,
//                 AppTheme.successColor,
//                 theme,
//               ),
//               _buildStatCard(
//                 'Processing Time',
//                 '2.3s',
//                 Icons.timer_rounded,
//                 AppTheme.warningColor,
//                 theme,
//               ),
//               _buildStatCard(
//                 'Image Quality',
//                 'High',
//                 Icons.hd_rounded,
//                 AppTheme.infoColor,
//                 theme,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildConfidenceChart(DetectionResult result, ThemeData theme) {
//     return Container(
//       height: 140,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Confidence Distribution',
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: result.objects.asMap().entries.map((entry) {
//                 final index = entry.key;
//                 final object = entry.value;
//                 return Expanded(
//                   child: Container(
//                     margin: EdgeInsets.only(
//                       right: index < result.objects.length - 1 ? 6 : 0,
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Text(
//                           '${(object.confidence * 100).toInt()}%',
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: theme.colorScheme.onSurface,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Container(
//                           width: double.infinity,
//                           height: 60 * object.confidence,
//                           decoration: BoxDecoration(
//                             color: _getConfidenceColor(object.confidence),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Flexible(
//                           child: Text(
//                             object.label,
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: theme.colorScheme.onSurfaceVariant,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                             textAlign: TextAlign.center,
//                             maxLines: 2,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//     ThemeData theme,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             color.withOpacity(0.1),
//             color.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: color.withOpacity(0.2),
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(height: 12),
//           FittedBox(
//             child: Text(
//               value,
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           FittedBox(
//             child: Text(
//               title,
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: theme.colorScheme.onSurfaceVariant,
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInsightsSection(DetectionResult result, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: AppTheme.secondaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.lightbulb_rounded,
//                   color: AppTheme.secondaryColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'AI Insights',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           _buildInsightItem(
//             '🎯',
//             'Primary Focus',
//             'The image mainly contains ${_getPrimaryCategory(result)} with high confidence levels.',
//             theme,
//           ),
//           _buildInsightItem(
//             '📊',
//             'Detection Quality',
//             'All objects were detected with above-average confidence scores.',
//             theme,
//           ),
//           _buildInsightItem(
//             '🔍',
//             'Image Analysis',
//             'The lighting and angle are optimal for object recognition.',
//             theme,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInsightItem(
//       String emoji, String title, String description, ThemeData theme) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.surface,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Center(
//               child: Text(
//                 emoji,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   description,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: theme.colorScheme.onSurfaceVariant,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecommendationsSection(DetectionResult result, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: AppTheme.warningColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.recommend_rounded,
//                   color: AppTheme.warningColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'Recommendations',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           _buildRecommendationItem(
//             Icons.search_rounded,
//             'Explore Similar Objects',
//             'Find more images with similar objects',
//             () => _searchSimilar(result),
//             theme,
//           ),
//           _buildRecommendationItem(
//             Icons.share_rounded,
//             'Share Your Discovery',
//             'Share these results with friends',
//             () => _shareResults(result),
//             theme,
//           ),
//           _buildRecommendationItem(
//             Icons.bookmark_rounded,
//             'Save to Collection',
//             'Add to your personal collection',
//             () => _saveToCollection(result),
//             theme,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecommendationItem(
//     IconData icon,
//     String title,
//     String subtitle,
//     VoidCallback onTap,
//     ThemeData theme,
//   ) {
//     return InkWell(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         onTap();
//       },
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 color: theme.colorScheme.primary,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 16,
//               color: theme.colorScheme.onSurfaceVariant,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailsTab(
//       DetectionResult result, bool isPremium, ThemeData theme) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildImageMetadata(result, theme),
//           const SizedBox(height: 20),
//           _buildDetectionDetails(result, theme),
//           if (isPremium) ...[
//             const SizedBox(height: 20),
//             _buildAdvancedDetails(result, theme),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildImageMetadata(DetectionResult result, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: AppTheme.infoColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.info_rounded,
//                   color: AppTheme.infoColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'Image Information',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           _buildDetailRow(
//               'Timestamp', _formatTimestamp(result.timestamp), theme),
//           _buildDetailRow('File Size', _getFileSize(result.imageFile), theme),
//           _buildDetailRow('Objects Found', '${result.objects.length}', theme),
//           _buildDetailRow(
//               'Mode', result.mode?.displayName ?? 'Object Detection', theme),
//           _buildDetailRow(
//             'Status',
//             result.error != null ? 'Error' : 'Success',
//             theme,
//             valueColor: result.error != null
//                 ? AppTheme.errorColor
//                 : AppTheme.successColor,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetectionDetails(DetectionResult result, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.category_rounded,
//                   color: theme.colorScheme.primary,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'Detection Details',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           if (result.objects.isEmpty)
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color:
//                     theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline_rounded,
//                     color: theme.colorScheme.onSurfaceVariant,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'No objects were detected in this image.',
//                       overflow: TextOverflow.ellipsis,
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: theme.colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           else
//             ...result.objects
//                 .map((object) => _buildObjectDetail(object, theme)),
//         ],
//       ),
//     );
//   }

//   Widget _buildObjectDetail(DetectedObject object, ThemeData theme) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: _getConfidenceColor(object.confidence).withOpacity(0.3),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   object.label,
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color:
//                       _getConfidenceColor(object.confidence).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '${(object.confidence * 100).toStringAsFixed(1)}%',
//                   style: theme.textTheme.labelMedium?.copyWith(
//                     color: _getConfidenceColor(object.confidence),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildDetailItem(
//                   'Position',
//                   '(${object.boundingBox.left.toInt()}, ${object.boundingBox.top.toInt()})',
//                   theme,
//                 ),
//               ),
//               Expanded(
//                 child: _buildDetailItem(
//                   'Size',
//                   '${object.boundingBox.width.toInt()} x ${object.boundingBox.height.toInt()}',
//                   theme,
//                 ),
//               ),
//             ],
//           ),
//           if (object.type != null) ...[
//             const SizedBox(height: 8),
//             _buildDetailItem('Type', object.type!, theme),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailItem(String label, String value, ThemeData theme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: theme.textTheme.bodySmall?.copyWith(
//             color: theme.colorScheme.onSurfaceVariant,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: theme.textTheme.bodyMedium?.copyWith(
//             color: theme.colorScheme.onSurface,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAdvancedDetails(DetectionResult result, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppTheme.premiumGold.withOpacity(0.1),
//             AppTheme.premiumGold.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: AppTheme.premiumGold.withOpacity(0.3),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   gradient: AppTheme.premiumGradient,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.diamond_rounded,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'Advanced Analytics',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           _buildDetailRow('Processing Model', 'AI Vision Pro v2.1', theme),
//           _buildDetailRow(
//               'Confidence Score', '${_getAverageConfidence(result)}%', theme),
//           _buildDetailRow('Detection Speed', '2.3 seconds', theme),
//           _buildDetailRow('API Calls Used', '${result.objects.length}', theme),
//           _buildDetailRow('Accuracy Rating', _getAccuracyRating(result), theme),
//           if (result.deepAnalysis != null) ...[
//             const SizedBox(height: 20),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.surface.withOpacity(0.8),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Deep Analysis',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     result.deepAnalysis!,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       height: 1.5,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildTranslateTab(
//       DetectionResult result, bool isPremium, ThemeData theme) {
//     if (!isPremium) {
//       return SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   gradient: AppTheme.premiumGradient,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppTheme.premiumGold.withOpacity(0.3),
//                       blurRadius: 20,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.translate_rounded,
//                   color: Colors.white,
//                   size: 60,
//                 ),
//               ).animate().scale().then().shimmer(duration: 2000.ms),
//               const SizedBox(height: 20),
//               Text(
//                 'Multi-language Translation',
//                 style: theme.textTheme.headlineMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Translate object names and descriptions into 50+ languages with premium access.',
//                 textAlign: TextAlign.center,
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   color: theme.colorScheme.onSurfaceVariant,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     HapticFeedback.lightImpact();
//                     Navigator.pushNamed(context, '/premium');
//                   },
//                   icon: const Icon(Icons.diamond_rounded, size: 20),
//                   label: Text(
//                     'Upgrade to Premium',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.premiumGold,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),
//               ).animate().slideY(begin: 0.3).fadeIn(delay: 500.ms),
//             ],
//           ),
//         ),
//       );
//     }

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildLanguageSelector(theme),
//           const SizedBox(height: 20),
//           if (result.objects.isNotEmpty)
//             _buildTranslationResults(result, theme)
//           else
//             _buildEmptyState(
//               'No objects to translate',
//               'Detection results are required for translation',
//               theme,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLanguageSelector(ThemeData theme) {
//     final languages = {
//       'es': '🇪🇸 Spanish',
//       'fr': '🇫🇷 French',
//       'de': '🇩🇪 German',
//       'it': '🇮🇹 Italian',
//       'pt': '🇵🇹 Portuguese',
//       'ja': '🇯🇵 Japanese',
//       'ko': '🇰🇷 Korean',
//       'zh': '🇨🇳 Chinese',
//       'ar': '🇸🇦 Arabic',
//       'hi': '🇮🇳 Hindi',
//     };

//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.language_rounded,
//                   color: theme.colorScheme.primary,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'Select Language',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: languages.entries.map((entry) {
//               final isSelected = _selectedLanguage == entry.key;
//               return FilterChip(
//                 label: Text(entry.value),
//                 selected: isSelected,
//                 onSelected: (selected) {
//                   if (selected) {
//                     HapticFeedback.lightImpact();
//                     setState(() => _selectedLanguage = entry.key);
//                     _translateResults();
//                   }
//                 },
//                 selectedColor: theme.colorScheme.primary.withOpacity(0.2),
//                 backgroundColor:
//                     theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
//                 labelStyle: theme.textTheme.labelMedium?.copyWith(
//                   color: isSelected
//                       ? theme.colorScheme.primary
//                       : theme.colorScheme.onSurfaceVariant,
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                 ),
//                 side: BorderSide(
//                   color: isSelected
//                       ? theme.colorScheme.primary
//                       : theme.colorScheme.outline.withOpacity(0.3),
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTranslationResults(DetectionResult result, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: AppTheme.successColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.translate_rounded,
//                   color: AppTheme.successColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'Translations',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           ...result.objects
//               .map((object) => _buildTranslationItem(object, theme)),
//         ],
//       ),
//     );
//   }

//   Widget _buildTranslationItem(DetectedObject object, ThemeData theme) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   object.label,
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//               ),
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.volume_up_rounded,
//                     size: 20,
//                     color: theme.colorScheme.primary,
//                   ),
//                   onPressed: () {
//                     HapticFeedback.lightImpact();
//                     _speakTranslation(object.label);
//                   },
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           FutureBuilder<String>(
//             future: _getTranslation(object.label),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.surface.withOpacity(0.8),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: theme.colorScheme.primary,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         'Translating...',
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: theme.colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               if (snapshot.hasError) {
//                 return Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: AppTheme.errorColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: AppTheme.errorColor.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.error_outline_rounded,
//                         color: AppTheme.errorColor,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         'Translation failed',
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: AppTheme.errorColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               return Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: theme.colorScheme.primary.withOpacity(0.3),
//                   ),
//                 ),
//                 child: Text(
//                   snapshot.data ?? 'Translation not available',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     color: theme.colorScheme.primary,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value, ThemeData theme,
//       {Color? valueColor}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: theme.colorScheme.onSurfaceVariant,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Flexible(
//             child: Text(
//               value,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: valueColor ?? theme.colorScheme.onSurface,
//               ),
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(String title, String subtitle, ThemeData theme) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 color:
//                     theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.search_off_rounded,
//                 size: 50,
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               title,
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: theme.colorScheme.onSurface,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               subtitle,
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingActions(
//       DetectionResult result, bool isPremium, ThemeData theme) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (isPremium)
//           Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: FloatingActionButton(
//               heroTag: "compare",
//               onPressed: () {
//                 HapticFeedback.lightImpact();
//                 _compareWithSimilar(result);
//               },
//               backgroundColor: theme.colorScheme.secondary,
//               foregroundColor: Colors.white,
//               elevation: 4,
//               child: const Icon(Icons.compare_rounded),
//             ),
//           ),
//         FloatingActionButton(
//           heroTag: "camera",
//           onPressed: () {
//             HapticFeedback.lightImpact();
//             Navigator.pushReplacementNamed(context, '/camera');
//           },
//           backgroundColor: theme.colorScheme.primary,
//           foregroundColor: Colors.white,
//           elevation: 4,
//           child: const Icon(Icons.camera_alt_rounded),
//         ),
//       ],
//     );
//   }

//   // Event Handlers and Utility Methods
//   void _toggleOverlays() {
//     setState(() => _showOverlays = !_showOverlays);
//     HapticFeedback.lightImpact();
//   }

//   void _handleObjectTap(DetectedObject object) {
//     HapticFeedback.lightImpact();
//     _showObjectDetails(object, Theme.of(context));
//   }

//   void _handleMenuAction(String action, DetectionResult result) {
//     HapticFeedback.lightImpact();
//     switch (action) {
//       case 'export':
//         _exportData(result);
//         break;
//       case 'analyze':
//         _deepAnalysis(result);
//         break;
//       case 'compare':
//         _compareWithSimilar(result);
//         break;
//     }
//   }

//   void _retryAnalysis() {
//     final result = ref.read(detectionProvider).currentResult;
//     if (result != null) {
//       ref.read(detectionProvider.notifier).retryDetection(result.imageFile);
//     }
//   }

//   void _showObjectDetails(DetectedObject object, ThemeData theme) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       useSafeArea: true,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.8,
//         minChildSize: 0.6,
//         maxChildSize: 0.95,
//         builder: (context, scrollController) => Container(
//           decoration: BoxDecoration(
//             color: theme.colorScheme.surface,
//             borderRadius: const BorderRadius.vertical(
//               top: Radius.circular(24),
//             ),
//             boxShadow: AppTheme.getElevationShadow(context, 12),
//           ),
//           child: Column(
//             children: [
//               // Handle
//               Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(top: 12),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.outline.withOpacity(0.4),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),

//               // Header
//               Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 56,
//                       height: 56,
//                       decoration: BoxDecoration(
//                         color: _getConfidenceColor(object.confidence)
//                             .withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Icon(
//                         _getObjectIcon(object.label),
//                         color: _getConfidenceColor(object.confidence),
//                         size: 28,
//                       ),
//                     ),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             object.label,
//                             style: theme.textTheme.headlineSmall?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: theme.colorScheme.onSurface,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Confidence: ${(object.confidence * 100).toInt()}%',
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               color: _getConfidenceColor(object.confidence),
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () {
//                         HapticFeedback.lightImpact();
//                         Navigator.pop(context);
//                       },
//                       icon: Icon(
//                         Icons.close_rounded,
//                         color: theme.colorScheme.onSurfaceVariant,
//                       ),
//                       style: IconButton.styleFrom(
//                         backgroundColor: theme
//                             .colorScheme.surfaceContainerHighest
//                             .withOpacity(0.5),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Content
//               Expanded(
//                 child: SingleChildScrollView(
//                   controller: scrollController,
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Description
//                       if (object.description != null) ...[
//                         _buildSectionHeader('Description', theme),
//                         const SizedBox(height: 12),
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: theme.colorScheme.surfaceContainerHighest
//                                 .withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Text(
//                             object.description!,
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               height: 1.6,
//                               color: theme.colorScheme.onSurface,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                       ],

//                       // Quick Actions
//                       _buildSectionHeader('Quick Actions', theme),
//                       const SizedBox(height: 16),
//                       _buildQuickActionsGrid(object, theme),
//                       const SizedBox(height: 24),

//                       // Technical Details
//                       _buildSectionHeader('Technical Details', theme),
//                       const SizedBox(height: 12),
//                       _buildTechnicalDetails(object, theme),

//                       const SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, ThemeData theme) {
//     return Text(
//       title,
//       style: theme.textTheme.titleLarge?.copyWith(
//         fontWeight: FontWeight.bold,
//         color: theme.colorScheme.onSurface,
//       ),
//     );
//   }

//   Widget _buildQuickActionsGrid(DetectedObject object, ThemeData theme) {
//     final actions = [
//       {
//         'icon': Icons.search_rounded,
//         'label': 'Search Web',
//         'action': () => _searchWeb(object)
//       },
//       {
//         'icon': Icons.share_rounded,
//         'label': 'Share',
//         'action': () => _shareObject(object)
//       },
//       {
//         'icon': Icons.bookmark_rounded,
//         'label': 'Save',
//         'action': () => _saveObject(object)
//       },
//       {
//         'icon': Icons.shopping_cart_rounded,
//         'label': 'Buy',
//         'action': () => _searchToBuy(object)
//       },
//       {
//         'icon': Icons.volume_up_rounded,
//         'label': 'Speak',
//         'action': () => _speakObject(object)
//       },
//       {
//         'icon': Icons.translate_rounded,
//         'label': 'Translate',
//         'action': () => _translateObject(object)
//       },
//     ];

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         childAspectRatio: 1.2,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//       ),
//       itemCount: actions.length,
//       itemBuilder: (context, index) {
//         final action = actions[index];
//         return InkWell(
//           onTap: () {
//             HapticFeedback.lightImpact();
//             (action['action'] as VoidCallback)();
//           },
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: theme.colorScheme.primary.withOpacity(0.2),
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   action['icon'] as IconData,
//                   color: theme.colorScheme.primary,
//                   size: 28,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   action['label'] as String,
//                   style: theme.textTheme.labelMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: theme.colorScheme.primary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTechnicalDetails(DetectedObject object, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//       ),
//       child: Column(
//         children: [
//           _buildTechnicalDetailRow(
//               'Object ID', object.id.substring(0, 8), theme),
//           _buildTechnicalDetailRow(
//             'Confidence Score',
//             '${(object.confidence * 100).toStringAsFixed(2)}%',
//             theme,
//           ),
//           _buildTechnicalDetailRow(
//             'Bounding Box',
//             '(${object.boundingBox.left.toInt()}, ${object.boundingBox.top.toInt()}, '
//                 '${object.boundingBox.width.toInt()}, ${object.boundingBox.height.toInt()})',
//             theme,
//           ),
//           _buildTechnicalDetailRow(
//               'Detection Model', 'AI Vision Pro v2.1', theme),
//           _buildTechnicalDetailRow(
//             'Processing Time',
//             '0.${(object.confidence * 1000).toInt()}s',
//             theme,
//           ),
//           if (object.type != null)
//             _buildTechnicalDetailRow('Object Type', object.type!, theme),
//         ],
//       ),
//     );
//   }

//   Widget _buildTechnicalDetailRow(String label, String value, ThemeData theme) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: theme.colorScheme.onSurfaceVariant,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Flexible(
//             child: Text(
//               value,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: theme.colorScheme.onSurface,
//               ),
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Utility Methods
//   Color _getConfidenceColor(double confidence) {
//     if (confidence >= 0.8) return AppTheme.successColor;
//     if (confidence >= 0.6) return AppTheme.warningColor;
//     return AppTheme.errorColor;
//   }

//   IconData _getObjectIcon(String label) {
//     final lowercaseLabel = label.toLowerCase();
//     if (lowercaseLabel.contains('person') ||
//         lowercaseLabel.contains('people')) {
//       return Icons.person_rounded;
//     } else if (lowercaseLabel.contains('car') ||
//         lowercaseLabel.contains('vehicle')) {
//       return Icons.directions_car_rounded;
//     } else if (lowercaseLabel.contains('food') ||
//         lowercaseLabel.contains('eat')) {
//       return Icons.restaurant_rounded;
//     } else if (lowercaseLabel.contains('animal') ||
//         lowercaseLabel.contains('dog') ||
//         lowercaseLabel.contains('cat')) {
//       return Icons.pets_rounded;
//     } else if (lowercaseLabel.contains('plant') ||
//         lowercaseLabel.contains('flower')) {
//       return Icons.local_florist_rounded;
//     } else if (lowercaseLabel.contains('book') ||
//         lowercaseLabel.contains('text')) {
//       return Icons.book_rounded;
//     } else if (lowercaseLabel.contains('phone') ||
//         lowercaseLabel.contains('mobile')) {
//       return Icons.phone_android_rounded;
//     } else if (lowercaseLabel.contains('computer') ||
//         lowercaseLabel.contains('laptop')) {
//       return Icons.computer_rounded;
//     }
//     return Icons.category_rounded;
//   }

//   int _getAverageConfidence(DetectionResult result) {
//     if (result.objects.isEmpty) return 0;
//     final sum =
//         result.objects.fold<double>(0, (sum, obj) => sum + obj.confidence);
//     return ((sum / result.objects.length) * 100).round();
//   }

//   String _getPrimaryCategory(DetectionResult result) {
//     if (result.objects.isEmpty) return 'unknown objects';

//     final categories = <String, int>{};
//     for (final object in result.objects) {
//       final category = _categorizeObject(object.label);
//       categories[category] = (categories[category] ?? 0) + 1;
//     }

//     final primaryCategory =
//         categories.entries.reduce((a, b) => a.value > b.value ? a : b).key;
//     return primaryCategory;
//   }

//   String _categorizeObject(String label) {
//     final lowercaseLabel = label.toLowerCase();
//     if (lowercaseLabel.contains('person') ||
//         lowercaseLabel.contains('people')) {
//       return 'people';
//     } else if (lowercaseLabel.contains('car') ||
//         lowercaseLabel.contains('vehicle') ||
//         lowercaseLabel.contains('truck') ||
//         lowercaseLabel.contains('bus')) {
//       return 'vehicles';
//     } else if (lowercaseLabel.contains('food') ||
//         lowercaseLabel.contains('eat') ||
//         lowercaseLabel.contains('drink')) {
//       return 'food items';
//     } else if (lowercaseLabel.contains('animal') ||
//         lowercaseLabel.contains('dog') ||
//         lowercaseLabel.contains('cat') ||
//         lowercaseLabel.contains('bird')) {
//       return 'animals';
//     } else if (lowercaseLabel.contains('plant') ||
//         lowercaseLabel.contains('flower') ||
//         lowercaseLabel.contains('tree')) {
//       return 'plants';
//     } else if (lowercaseLabel.contains('building') ||
//         lowercaseLabel.contains('house') ||
//         lowercaseLabel.contains('structure')) {
//       return 'architecture';
//     }
//     return 'miscellaneous objects';
//   }

//   String _formatTimestamp(DateTime timestamp) {
//     return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
//   }

//   String _getFileSize(dynamic file) {
//     try {
//       final bytes = file.lengthSync();
//       if (bytes < 1024) return '$bytes B';
//       if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
//       return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
//     } catch (e) {
//       return 'Unknown';
//     }
//   }

//   String _getAccuracyRating(DetectionResult result) {
//     final avgConfidence = _getAverageConfidence(result);
//     if (avgConfidence >= 90) return 'Excellent';
//     if (avgConfidence >= 80) return 'High';
//     if (avgConfidence >= 70) return 'Good';
//     if (avgConfidence >= 60) return 'Fair';
//     return 'Low';
//   }

//   // Action Methods with Enhanced Theme Integration
//   void _shareResults(DetectionResult result) async {
//     final objectsText = result.objects
//         .map((obj) => '${obj.label} (${(obj.confidence * 100).toInt()}%)')
//         .join(', ');

//     await Share.share(
//       'I found these objects using AI Vision Pro: $objectsText',
//       subject: 'My AI Vision Detection Results',
//     );

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(
//                 Icons.check_circle_rounded,
//                 color: Theme.of(context).colorScheme.onPrimary,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Text(
//                   'Results shared successfully!',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: AppTheme.successColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   void _saveResults(DetectionResult result) async {
//     ref.read(historyProvider.notifier).saveResult(result);

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(
//                 Icons.bookmark_rounded,
//                 color: Theme.of(context).colorScheme.onPrimary,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Text(
//                   'Results saved to your collection',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: AppTheme.successColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//           action: SnackBarAction(
//             label: 'View',
//             textColor: Colors.white,
//             onPressed: () => Navigator.pushNamed(context, '/history'),
//           ),
//         ),
//       );
//     }
//   }

//   void _readResults(DetectionResult result) async {
//     if (result.objects.isEmpty) {
//       await _tts.speak('No objects were detected in this image.');
//       return;
//     }

//     final objectsText = result.objects.map((obj) => obj.label).join(', ');
//     await _tts.speak('I detected the following objects: $objectsText');

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(
//                 Icons.volume_up_rounded,
//                 color: Theme.of(context).colorScheme.onPrimary,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Text(
//                   'Reading results aloud...',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: AppTheme.infoColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   void _searchSimilar(DetectionResult result) {
//     if (result.objects.isNotEmpty) {
//       Navigator.pushNamed(
//         context,
//         '/search',
//         arguments: {'query': result.objects.first.label, 'type': 'similar'},
//       );
//     }
//   }

//   void _saveToCollection(DetectionResult result) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _buildCollectionSelectorSheet(result),
//     );
//   }

//   Widget _buildCollectionSelectorSheet(DetectionResult result) {
//     final theme = Theme.of(context);

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.6,
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//         boxShadow: AppTheme.getElevationShadow(context, 12),
//       ),
//       child: Column(
//         children: [
//           // Handle
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(top: 12),
//             decoration: BoxDecoration(
//               color: theme.colorScheme.outline.withOpacity(0.4),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),

//           // Header
//           Padding(
//             padding: const EdgeInsets.all(24),
//             child: Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     Icons.collections_rounded,
//                     color: theme.colorScheme.primary,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Text(
//                   'Save to Collection',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Collections List
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               children: [
//                 _buildCollectionTile(
//                   icon: Icons.star_rounded,
//                   color: AppTheme.warningColor,
//                   title: 'Favorites',
//                   subtitle: 'Personal favorites collection',
//                   onTap: () => _saveToCollectionAction('favorites'),
//                   theme: theme,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildCollectionTile(
//                   icon: Icons.work_rounded,
//                   color: AppTheme.infoColor,
//                   title: 'Work Projects',
//                   subtitle: 'Professional use collection',
//                   onTap: () => _saveToCollectionAction('work'),
//                   theme: theme,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildCollectionTile(
//                   icon: Icons.home_rounded,
//                   color: AppTheme.successColor,
//                   title: 'Personal',
//                   subtitle: 'Personal items collection',
//                   onTap: () => _saveToCollectionAction('personal'),
//                   theme: theme,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildCollectionTile(
//                   icon: Icons.school_rounded,
//                   color: AppTheme.secondaryColor,
//                   title: 'Educational',
//                   subtitle: 'Learning and research',
//                   onTap: () => _saveToCollectionAction('educational'),
//                   theme: theme,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildCollectionTile(
//                   icon: Icons.add_rounded,
//                   color: theme.colorScheme.onSurfaceVariant,
//                   title: 'Create New Collection',
//                   subtitle: 'Make a custom collection',
//                   onTap: () => _createNewCollection(),
//                   theme: theme,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCollectionTile({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//     required ThemeData theme,
//   }) {
//     return InkWell(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         onTap();
//       },
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: theme.colorScheme.outline.withOpacity(0.2),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: color, size: 24),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 16,
//               color: theme.colorScheme.onSurfaceVariant,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _saveToCollectionAction(String collection) {
//     Navigator.pop(context);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.check_circle_rounded,
//               color: Theme.of(context).colorScheme.onPrimary,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 'Saved to $collection collection',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.successColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   void _createNewCollection() {
//     Navigator.pop(context);
//     showDialog(
//       context: context,
//       builder: (context) => _buildCreateCollectionDialog(),
//     );
//   }

//   Widget _buildCreateCollectionDialog() {
//     final theme = Theme.of(context);
//     final controller = TextEditingController();

//     return AlertDialog(
//       backgroundColor: theme.colorScheme.surface,
//       surfaceTintColor: Colors.transparent,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       title: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               Icons.add_rounded,
//               color: theme.colorScheme.primary,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Text(
//             'Create Collection',
//             style: theme.textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Enter a name for your new collection',
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: theme.colorScheme.onSurfaceVariant,
//             ),
//           ),
//           const SizedBox(height: 16),
//           TextField(
//             controller: controller,
//             autofocus: true,
//             style: theme.textTheme.bodyLarge,
//             decoration: InputDecoration(
//               labelText: 'Collection Name',
//               hintText: 'e.g., My Objects',
//               prefixIcon: Icon(
//                 Icons.collections_outlined,
//                 color: theme.colorScheme.primary,
//               ),
//               filled: true,
//               fillColor:
//                   theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(
//                   color: theme.colorScheme.outline,
//                   width: 1,
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(
//                   color: theme.colorScheme.primary,
//                   width: 2,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           style: TextButton.styleFrom(
//             foregroundColor: theme.colorScheme.onSurfaceVariant,
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           ),
//           child: const Text('Cancel'),
//         ),
//         Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 theme.colorScheme.primary,
//                 theme.colorScheme.primary.withOpacity(0.8),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: ElevatedButton(
//             onPressed: () {
//               if (controller.text.trim().isNotEmpty) {
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Row(
//                       children: [
//                         Icon(
//                           Icons.check_circle_rounded,
//                           color: Theme.of(context).colorScheme.onPrimary,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             'Collection "${controller.text.trim()}" created successfully!',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     backgroundColor: AppTheme.successColor,
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     margin: const EdgeInsets.all(16),
//                   ),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.transparent,
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shadowColor: Colors.transparent,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: const Text(
//               'Create',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _exportData(DetectionResult result) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _buildExportOptionsSheet(result),
//     );
//   }

//   Widget _buildExportOptionsSheet(DetectionResult result) {
//     final theme = Theme.of(context);

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.5,
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//         boxShadow: AppTheme.getElevationShadow(context, 12),
//       ),
//       child: Column(
//         children: [
//           // Handle
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(top: 12),
//             decoration: BoxDecoration(
//               color: theme.colorScheme.outline.withOpacity(0.4),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),

//           // Header
//           Padding(
//             padding: const EdgeInsets.all(24),
//             child: Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     Icons.download_rounded,
//                     color: theme.colorScheme.primary,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Text(
//                   'Export Options',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Export Options
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               children: [
//                 _buildExportOption(
//                   icon: Icons.picture_as_pdf_rounded,
//                   color: AppTheme.errorColor,
//                   title: 'Export as PDF',
//                   subtitle: 'Detailed report with images and analysis',
//                   onTap: () => _exportAsPDF(),
//                   theme: theme,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildExportOption(
//                   icon: Icons.table_chart_rounded,
//                   color: AppTheme.successColor,
//                   title: 'Export as CSV',
//                   subtitle: 'Spreadsheet format for data analysis',
//                   onTap: () => _exportAsCSV(),
//                   theme: theme,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildExportOption(
//                   icon: Icons.code_rounded,
//                   color: AppTheme.infoColor,
//                   title: 'Export as JSON',
//                   subtitle: 'Raw data format for developers',
//                   onTap: () => _exportAsJSON(),
//                   theme: theme,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildExportOption(
//                   icon: Icons.image_rounded,
//                   color: AppTheme.warningColor,
//                   title: 'Export Image with Annotations',
//                   subtitle: 'Image with detection overlays',
//                   onTap: () => _exportAnnotatedImage(),
//                   theme: theme,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExportOption({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//     required ThemeData theme,
//   }) {
//     return InkWell(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         onTap();
//       },
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: theme.colorScheme.outline.withOpacity(0.2),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: color, size: 24),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 16,
//               color: theme.colorScheme.onSurfaceVariant,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _exportAsPDF() async {
//     Navigator.pop(context);

//     final result = ref.read(detectionProvider).currentResult;
//     if (result == null) {
//       _showErrorSnackBar('No detection result available');
//       return;
//     }

//     final pdf = pw.Document();
//     pdf.addPage(pw.Page(
//       pageFormat: PdfPageFormat.a4,
//       build: (pw.Context context) {
//         return pw.Column(
//           children: [
//             pw.Text('Detection Results',
//                 style: const pw.TextStyle(fontSize: 24)),
//             pw.SizedBox(height: 20),
//             pw.Image(pw.MemoryImage(result.imageFile.readAsBytesSync())),
//             pw.SizedBox(height: 20),
//             pw.Table.fromTextArray(data: <List<String>>[
//               <String>['Label', 'Confidence'],
//               ...result.objects.map((obj) =>
//                   [obj.label, '${(obj.confidence * 100).toStringAsFixed(2)}%'])
//             ]),
//           ],
//         );
//       },
//     ));

//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/detection_results.pdf');
//     await file.writeAsBytes(await pdf.save());

//     OpenFile.open(file.path);
//     _showExportProgress('PDF');
//   }

//   void _exportAsCSV() async {
//     Navigator.pop(context);

//     final result = ref.read(detectionProvider).currentResult;
//     if (result == null) {
//       _showErrorSnackBar('No detection result available');
//       return;
//     }

//     List<List<dynamic>> rows = [
//       ['Label', 'Confidence', 'Description'],
//       ...result.objects.map((obj) => [
//             obj.label,
//             obj.confidence,
//             obj.description ?? '',
//           ]),
//     ];

//     String csv = const ListToCsvConverter().convert(rows);

//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/detection_results.csv');
//     await file.writeAsString(csv);

//     OpenFile.open(file.path);
//     _showExportProgress('CSV');
//   }

//   void _exportAsJSON() async {
//     Navigator.pop(context);

//     final result = ref.read(detectionProvider).currentResult;
//     if (result == null) {
//       _showErrorSnackBar('No detection result available');
//       return;
//     }

//     final json = result.toJson();

//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/detection_results.json');
//     await file.writeAsString(json.toString());

//     OpenFile.open(file.path);
//     _showExportProgress('JSON');
//   }

//   void _exportAnnotatedImage() async {
//     Navigator.pop(context);

//     final result = ref.read(detectionProvider).currentResult;
//     if (result == null) {
//       _showErrorSnackBar('No detection result available');
//       return;
//     }

//     final originalImage = img.decodeImage(result.imageFile.readAsBytesSync())!;
//     final annotatedImage =
//         img.copyResize(originalImage, width: originalImage.width);

//     for (var obj in result.objects) {
//       img.drawRect(
//         annotatedImage,
//         x1: obj.boundingBox.left.toInt(),
//         y1: obj.boundingBox.top.toInt(),
//         x2: obj.boundingBox.right.toInt(),
//         y2: obj.boundingBox.bottom.toInt(),
//         color: img.ColorRgb8(255, 0, 0),
//       );
//       img.drawString(
//         annotatedImage,
//         '${obj.label} ${(obj.confidence * 100).toInt()}%',
//         font: img.arial14,
//         x: obj.boundingBox.left.toInt(),
//         y: obj.boundingBox.top.toInt() - 20,
//         color: img.ColorRgb8(255, 0, 0),
//       );
//     }

//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/annotated_image.png');
//     await file.writeAsBytes(img.encodePng(annotatedImage));

//     OpenFile.open(file.path);
//     _showExportProgress('Image');
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.error_outline_rounded,
//               color: Theme.of(context).colorScheme.onError,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(fontWeight: FontWeight.w500),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.errorColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   void _showExportProgress(String format) {
//     final theme = Theme.of(context);

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: CircularProgressIndicator(
//                 color: theme.colorScheme.primary,
//                 strokeWidth: 3,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'Exporting as $format...',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Please wait while we prepare your file',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );

//     // Simulate export process
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) {
//         Navigator.pop(context); // Close progress dialog
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(
//                   Icons.check_circle_rounded,
//                   color: Theme.of(context).colorScheme.onPrimary,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Successfully exported as $format',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: AppTheme.successColor,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.all(16),
//             action: SnackBarAction(
//               label: 'Share',
//               textColor: Colors.white,
//               onPressed: () {
//                 // Implement sharing logic
//                 _shareExportedFile(format);
//               },
//             ),
//           ),
//         );
//       }
//     });
//   }

//   void _shareExportedFile(String format) {
//     // Simulate sharing the exported file
//     Share.share(
//       'Here\'s my AI Vision Pro analysis exported as $format!',
//       subject: 'AI Vision Pro Export',
//     );
//   }

//   void _deepAnalysis(DetectionResult result) async {
//     setState(() => _isAnalyzing = true);

//     try {
//       await ref.read(detectionProvider.notifier).performDeepAnalysis(result);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(
//                   Icons.analytics_rounded,
//                   color: Theme.of(context).colorScheme.onPrimary,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 const Expanded(
//                   child: Text(
//                     'Deep analysis completed! Check the Analysis tab.',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: AppTheme.successColor,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.all(16),
//             action: SnackBarAction(
//               label: 'View',
//               textColor: Colors.white,
//               onPressed: () => _tabController.animateTo(1),
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(
//                   Icons.error_outline_rounded,
//                   color: Theme.of(context).colorScheme.onError,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Analysis failed: $e',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: AppTheme.errorColor,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isAnalyzing = false);
//       }
//     }
//   }

//   void _compareWithSimilar(DetectionResult result) {
//     Navigator.pushNamed(
//       context,
//       '/compare',
//       arguments: result,
//     );
//   }

//   void _showFunFact(DetectedObject object) async {
//     final theme = Theme.of(context);

//     if (object.funFact == null) {
//       // Show loading dialog
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           backgroundColor: theme.colorScheme.surface,
//           surfaceTintColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: AppTheme.warningColor.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const CircularProgressIndicator(
//                   color: AppTheme.warningColor,
//                   strokeWidth: 3,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Loading fun fact...',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );

//       try {
//         await ref.read(detectionProvider.notifier).fetchFunFact(object);
//         if (mounted) Navigator.pop(context); // Close loading dialog
//       } catch (e) {
//         if (mounted) {
//           Navigator.pop(context); // Close loading dialog
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Row(
//                 children: [
//                   Icon(
//                     Icons.error_outline_rounded,
//                     color: Theme.of(context).colorScheme.onError,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text('Failed to load fun fact: $e'),
//                   ),
//                 ],
//               ),
//               backgroundColor: AppTheme.errorColor,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//         }
//         return;
//       }
//     }

//     if (mounted) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           backgroundColor: theme.colorScheme.surface,
//           surfaceTintColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       AppTheme.warningColor,
//                       AppTheme.warningColor.withOpacity(0.8),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.lightbulb_rounded,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Text(
//                   'Fun Fact: ${object.label}',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           content: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: AppTheme.warningColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: AppTheme.warningColor.withOpacity(0.3),
//               ),
//             ),
//             child: Text(
//               object.funFact ?? 'Fun fact not available.',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 height: 1.5,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               style: TextButton.styleFrom(
//                 foregroundColor: theme.colorScheme.onSurfaceVariant,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//               child: const Text('Close'),
//             ),
//             if (object.funFact != null)
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       AppTheme.warningColor,
//                       AppTheme.warningColor.withOpacity(0.8),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     _tts.speak(object.funFact!);
//                   },
//                   icon: const Icon(Icons.volume_up_rounded, size: 18),
//                   label: const Text('Read Aloud'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shadowColor: Colors.transparent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20, vertical: 12),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       );
//     }
//   }

//   void _searchWeb(DetectedObject object) async {
//     final url =
//         'https://www.google.com/search?q=${Uri.encodeComponent(object.label)}';
//     final uri = Uri.parse(url);

//     try {
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//       } else {
//         throw 'Could not launch $url';
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(
//                   Icons.error_outline_rounded,
//                   color: Theme.of(context).colorScheme.onError,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text('Failed to open web search: $e'),
//                 ),
//               ],
//             ),
//             backgroundColor: AppTheme.errorColor,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }

//   void _shareObject(DetectedObject object) async {
//     await Share.share(
//       'I found a ${object.label} using AI Vision Pro! '
//       'Confidence: ${(object.confidence * 100).toInt()}%',
//     );
//   }

//   void _saveObject(DetectedObject object) {
//     ref.read(favoritesProvider.notifier).addFavorite(object);

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(
//                 Icons.bookmark_rounded,
//                 color: Theme.of(context).colorScheme.onPrimary,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text('${object.label} saved to favorites'),
//               ),
//             ],
//           ),
//           backgroundColor: AppTheme.successColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//           action: SnackBarAction(
//             label: 'View',
//             textColor: Colors.white,
//             onPressed: () => Navigator.pushNamed(context, '/favorites'),
//           ),
//         ),
//       );
//     }
//   }

//   void _searchToBuy(DetectedObject object) async {
//     final theme = Theme.of(context);

//     final stores = [
//       {
//         'name': 'Amazon',
//         'url':
//             'https://www.amazon.com/s?k=${Uri.encodeComponent(object.label)}',
//         'icon': Icons.shopping_bag_rounded,
//         'color': AppTheme.warningColor,
//       },
//       {
//         'name': 'eBay',
//         'url':
//             'https://www.ebay.com/sch/i.html?_nkw=${Uri.encodeComponent(object.label)}',
//         'icon': Icons.local_offer_rounded,
//         'color': AppTheme.infoColor,
//       },
//       {
//         'name': 'Google Shopping',
//         'url':
//             'https://shopping.google.com/search?q=${Uri.encodeComponent(object.label)}',
//         'icon': Icons.shopping_cart_rounded,
//         'color': AppTheme.successColor,
//       },
//     ];

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surface,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           boxShadow: AppTheme.getElevationShadow(context, 12),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Handle
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(top: 12),
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.outline.withOpacity(0.4),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),

//             // Header
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: AppTheme.successColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(
//                       Icons.shopping_cart_rounded,
//                       color: AppTheme.successColor,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Text(
//                       'Shop for ${object.label}',
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Store options
//             ...stores.map((store) {
//               return Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
//                 child: InkWell(
//                   onTap: () async {
//                     Navigator.pop(context);
//                     final uri = Uri.parse(store['url'] as String);
//                     try {
//                       if (await canLaunchUrl(uri)) {
//                         await launchUrl(uri,
//                             mode: LaunchMode.externalApplication);
//                       }
//                     } catch (e) {
//                       if (mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Row(
//                               children: [
//                                 Icon(
//                                   Icons.error_outline_rounded,
//                                   color: Theme.of(context).colorScheme.onError,
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Text(
//                                       'Failed to open ${store['name']}: $e'),
//                                 ),
//                               ],
//                             ),
//                             backgroundColor: AppTheme.errorColor,
//                             behavior: SnackBarBehavior.floating,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             margin: const EdgeInsets.all(16),
//                           ),
//                         );
//                       }
//                     }
//                   },
//                   borderRadius: BorderRadius.circular(16),
//                   child: Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.surfaceContainerHighest
//                           .withOpacity(0.3),
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: theme.colorScheme.outline.withOpacity(0.2),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 48,
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: (store['color'] as Color).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Icon(
//                             store['icon'] as IconData,
//                             color: store['color'] as Color,
//                             size: 24,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Search on ${store['name']}',
//                                 style: theme.textTheme.titleMedium?.copyWith(
//                                   fontWeight: FontWeight.w600,
//                                   color: theme.colorScheme.onSurface,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 'Find ${object.label} deals and prices',
//                                 style: theme.textTheme.bodyMedium?.copyWith(
//                                   color: theme.colorScheme.onSurfaceVariant,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(
//                           Icons.arrow_forward_ios_rounded,
//                           size: 16,
//                           color: theme.colorScheme.onSurfaceVariant,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }),

//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   void _speakObject(DetectedObject object) async {
//     try {
//       final text = object.description != null
//           ? '${object.label}. ${object.description}'
//           : object.label;
//       await _tts.speak(text);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(
//                   Icons.volume_up_rounded,
//                   color: Theme.of(context).colorScheme.onPrimary,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text('Speaking: ${object.label}'),
//                 ),
//               ],
//             ),
//             backgroundColor: AppTheme.infoColor,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.all(16),
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(
//                   Icons.error_outline_rounded,
//                   color: Theme.of(context).colorScheme.onError,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text('Text-to-speech failed: $e'),
//                 ),
//               ],
//             ),
//             backgroundColor: AppTheme.errorColor,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }

//   void _translateObject(DetectedObject object) {
//     // Switch to translate tab and focus on this object
//     _tabController.animateTo(3);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.translate_rounded,
//               color: Theme.of(context).colorScheme.onPrimary,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text('Switched to translation tab for ${object.label}'),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.infoColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   void _speakTranslation(String text) async {
//     try {
//       await _tts.setLanguage(_getLanguageCode(_selectedLanguage));
//       await _tts.speak(text);
//       await _tts.setLanguage("en-US"); // Reset to English
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(
//                   Icons.error_outline_rounded,
//                   color: Theme.of(context).colorScheme.onError,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text('Translation speech failed: $e'),
//                 ),
//               ],
//             ),
//             backgroundColor: AppTheme.errorColor,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }

//   Future<String> _getTranslation(String text) async {
//     try {
//       final translation =
//           await _translator.translate(text, to: _selectedLanguage);
//       return translation.text;
//     } catch (e) {
//       debugPrint('Translation error: $e');
//       return 'Translation failed';
//     }
//   }

//   void _translateResults() {
//     // Trigger translation for all objects
//     setState(() {});
//   }

//   String _getLanguageCode(String code) {
//     final languageCodes = {
//       'es': 'es-ES',
//       'fr': 'fr-FR',
//       'de': 'de-DE',
//       'it': 'it-IT',
//       'pt': 'pt-PT',
//       'ja': 'ja-JP',
//       'ko': 'ko-KR',
//       'zh': 'zh-CN',
//       'ar': 'ar-SA',
//       'hi': 'hi-IN',
//     };
//     return languageCodes[code] ?? 'en-US';
//   }
// }


// // screens/profile_screen.dart

// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../models/app_user.dart';
// import '../models/detection_history.dart';
// import '../providers/auth_provider.dart';
// import '../providers/premium_provider.dart';
// import '../providers/analytics_provider.dart';
// import '../providers/history_provider.dart';
// import '../providers/favorites_provider.dart';
// import '../config/app_theme.dart';
// import '../utils/haptic_feedback.dart';

// class ProfileScreen extends ConsumerStatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends ConsumerState<ProfileScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late AnimationController _shimmerController;

//   bool _isEditing = false;
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _bioController = TextEditingController();

//   File? _selectedImage;
//   String? _originalPhotoURL;
//   bool _hasImageChanged = false;

//   // Override initState to listen for user changes
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _loadUserData();

//     // Listen for user changes and reload data
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.listen<AppUser?>(currentUserProvider, (previous, next) {
//         if (next != null && next != previous) {
//           _loadUserData();
//         }
//       });
//     });
//   }

// // Method to refresh user data from server
//   Future<void> _refreshUserData() async {
//     try {
//       final user = ref.read(currentUserProvider);
//       if (user != null) {
//         // Force refresh from Firestore
//         final userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.id)
//             .get(const GetOptions(source: Source.server));

//         if (userDoc.exists && mounted) {
//           _loadUserData();
//         }
//       }
//     } catch (e) {
//       debugPrint('Error refreshing user data: $e');
//     }
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _shimmerController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat();

//     _fadeController.forward();
//     _slideController.forward();
//   }

//   // Updated _loadUserData method to load from Firestore
//   void _loadUserData() async {
//     final user = ref.read(currentUserProvider);
//     if (user != null) {
//       try {
//         // Load additional profile data from Firestore
//         final userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.id)
//             .get();

//         if (userDoc.exists) {
//           final data = userDoc.data() as Map<String, dynamic>;
//           final profile = data['profile'] as Map<String, dynamic>? ?? {};

//           _nameController.text =
//               data['displayName'] ?? user.displayName ?? 'AI Explorer';
//           _emailController.text = user.email ?? '';
//           _bioController.text =
//               profile['bio'] ?? 'Exploring the world through AI vision';
//         } else {
//           // Fallback to Firebase Auth data
//           _nameController.text = user.displayName ?? 'AI Explorer';
//           _emailController.text = user.email ?? '';
//           _bioController.text = 'Exploring the world through AI vision';
//         }
//       } catch (e) {
//         debugPrint('Error loading user data from Firestore: $e');
//         // Fallback to Firebase Auth data
//         _nameController.text = user.displayName ?? 'AI Explorer';
//         _emailController.text = user.email ?? '';
//         _bioController.text = 'Exploring the world through AI vision';
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     _shimmerController.dispose();
//     _nameController.dispose();
//     _emailController.dispose();
//     _bioController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);
//     final isPremium = ref.watch(premiumProvider).isPremium;
//     final analyticsState = ref.watch(analyticsProvider);
//     final historyList = ref.watch(historyProvider);
//     final favoritesList = ref.watch(favoritesProvider);
//     final theme = Theme.of(context);

//     final isGuest = !authState.isAuthenticated;

//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           _buildSliverAppBar(isGuest, isPremium, theme),
//           _buildProfileContent(
//             isGuest,
//             isPremium,
//             analyticsState,
//             historyList,
//             favoritesList,
//             theme,
//           ),
//           _buildAdPreferencesSection(isPremium, theme),
//           const SliverToBoxAdapter(child: SizedBox(height: 100)),
//         ],
//       ),
//     );
//   }

//   Widget _buildSliverAppBar(bool isGuest, bool isPremium, ThemeData theme) {
//     return SliverAppBar(
//       expandedHeight: 300,
//       floating: false,
//       pinned: true,
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       surfaceTintColor: Colors.transparent,
//       // leading: Container(
//       //   margin: const EdgeInsets.all(8),
//       //   decoration: BoxDecoration(
//       //     color: theme.colorScheme.surface.withOpacity(0.9),
//       //     borderRadius: BorderRadius.circular(10),
//       //     boxShadow: AppTheme.getElevationShadow(context, 2),
//       //   ),
//       //   child: IconButton(
//       //     onPressed: () {
//       //       HapticFeedback.lightImpact();
//       //       Navigator.pop(context);
//       //     },
//       //     icon: Icon(
//       //       Icons.arrow_back_rounded,
//       //       color: theme.colorScheme.onSurface,
//       //     ),
//       //   ),
//       // ),
//       actions: [
//         if (!isGuest)
//           Container(
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: _isEditing
//                   ? AppTheme.successColor.withOpacity(0.9)
//                   : theme.colorScheme.primary.withOpacity(0.9),
//               borderRadius: BorderRadius.circular(10),
//               boxShadow: AppTheme.getElevationShadow(context, 2),
//             ),
//             child: TextButton(
//               onPressed: () {
//                 HapticFeedback.lightImpact();
//                 if (_isEditing) {
//                   _saveProfile();
//                 } else {
//                   setState(() => _isEditing = true);
//                 }
//               },
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: Text(
//                 _isEditing ? 'Save' : 'Edit',
//                 style: theme.textTheme.labelLarge?.copyWith(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 theme.colorScheme.primary,
//                 theme.colorScheme.primary.withOpacity(0.8),
//                 theme.colorScheme.secondary.withOpacity(0.6),
//               ],
//             ),
//           ),
//           child: SafeArea(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 40),
//                 _buildProfileAvatar(isGuest, theme),
//                 const SizedBox(height: 20),
//                 _buildProfileInfo(isGuest, isPremium, theme),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileAvatar(bool isGuest, ThemeData theme) {
//     final user = ref.watch(currentUserProvider);
//     // Determine the image provider
//     ImageProvider? imageProvider;
//     if (_selectedImage != null) {
//       imageProvider = FileImage(_selectedImage!);
//     } else if (user?.photoURL != null) {
//       imageProvider = NetworkImage(user!.photoURL!);
//     }

//     return Stack(
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.white, width: 4),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.3),
//                 blurRadius: 20,
//                 spreadRadius: 2,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: CircleAvatar(
//             radius: 60,
//             backgroundColor: theme.colorScheme.surface,
//             backgroundImage: imageProvider,
//             child: imageProvider == null
//                 ? Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           theme.colorScheme.primary.withOpacity(0.8),
//                           theme.colorScheme.secondary.withOpacity(0.8),
//                         ],
//                       ),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.person_rounded,
//                       size: 60,
//                       color: Colors.white,
//                     ),
//                   )
//                 : null,
//           ),
//         ),
//         if (!isGuest && _isEditing)
//           Positioned(
//             bottom: 8,
//             right: 8,
//             child: GestureDetector(
//               onTap: () {
//                 HapticFeedback.lightImpact();
//                 _changeProfilePicture();
//               },
//               child: Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       theme.colorScheme.secondary,
//                       theme.colorScheme.tertiary,
//                     ],
//                   ),
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 3),
//                   boxShadow: AppTheme.getElevationShadow(context, 4),
//                 ),
//                 child: const Icon(
//                   Icons.camera_alt_rounded,
//                   size: 20,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     ).animate().scale(delay: 200.ms).then().shimmer(duration: 2000.ms);
//   }

//   Widget _buildProfileInfo(bool isGuest, bool isPremium, ThemeData theme) {
//     return Consumer(
//       builder: (context, ref, child) {
//         final user = ref.watch(currentUserProvider);

//         return Column(
//           children: [
//             if (isGuest) ...[
//               Text(
//                 'Welcome, Guest!',
//                 style: theme.textTheme.headlineMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ).animate().slideY(begin: 0.3).fadeIn(delay: 400.ms),
//               const SizedBox(height: 8),
//               Text(
//                 'Sign in to unlock all features',
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   color: Colors.white.withOpacity(0.9),
//                 ),
//               ).animate().slideY(begin: 0.3).fadeIn(delay: 600.ms),
//             ] else ...[
//               Text(
//                 _isEditing
//                     ? _nameController.text
//                     : (user?.displayName ?? 'AI Explorer'),
//                 style: theme.textTheme.headlineMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ).animate().slideY(begin: 0.3).fadeIn(delay: 400.ms),
//               const SizedBox(height: 6),
//               Text(
//                 user?.email ?? '',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: Colors.white.withOpacity(0.9),
//                 ),
//               ).animate().slideY(begin: 0.3).fadeIn(delay: 500.ms),
//               if (isPremium) ...[
//                 const SizedBox(height: 16),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     gradient: AppTheme.premiumGradient,
//                     borderRadius: BorderRadius.circular(25),
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppTheme.premiumGold.withOpacity(0.4),
//                         blurRadius: 12,
//                         spreadRadius: 1,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(
//                         Icons.diamond_rounded,
//                         color: Colors.white,
//                         size: 18,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         'PREMIUM',
//                         style: theme.textTheme.labelMedium?.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ).animate().shimmer(duration: 2000.ms).fadeIn(delay: 600.ms),
//               ],
//             ],
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildAdPreferencesSection(bool isPremium, ThemeData theme) {
//     if (isPremium) {
//       return SliverToBoxAdapter(
//         child: Container(
//           margin: const EdgeInsets.all(20),
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 AppTheme.successColor.withOpacity(0.1),
//                 AppTheme.successColor.withOpacity(0.05),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: AppTheme.successColor.withOpacity(0.3),
//             ),
//             boxShadow: AppTheme.getElevationShadow(context, 2),
//           ),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       color: AppTheme.successColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: const Icon(
//                       Icons.check_circle_rounded,
//                       color: AppTheme.successColor,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Text(
//                       'Ad-Free Experience Active',
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'You\'re enjoying an ad-free experience with your premium subscription. No more interruptions while using AI Vision Pro!',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.colorScheme.onSurfaceVariant,
//                   height: 1.5,
//                 ),
//               ),
//             ],
//           ),
//         ).animate(delay: 1200.ms).slideY(begin: 0.3).fadeIn(),
//       );
//     }

//     return SliverToBoxAdapter(
//       child: Container(
//         margin: const EdgeInsets.all(20),
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surface,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: theme.colorScheme.outline.withOpacity(0.2),
//           ),
//           boxShadow: AppTheme.getElevationShadow(context, 2),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 48,
//                   height: 48,
//                   decoration: BoxDecoration(
//                     color: AppTheme.warningColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(
//                     Icons.ads_click_rounded,
//                     color: AppTheme.warningColor,
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Text(
//                     'Ad Preferences',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppTheme.warningColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: AppTheme.warningColor.withOpacity(0.3),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.info_outline_rounded,
//                     color: AppTheme.warningColor,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'Ads help keep AI Vision Pro free for everyone. Upgrade to Premium to remove all ads and unlock advanced features.',
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: theme.colorScheme.onSurface,
//                         height: 1.5,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   HapticFeedback.lightImpact();
//                   Navigator.pushNamed(context, '/premium');
//                 },
//                 icon: const Icon(
//                   Icons.block_rounded,
//                   size: 18,
//                 ),
//                 label: Text(
//                   'Remove Ads - Upgrade to Premium',
//                   style: theme.textTheme.labelLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: theme.colorScheme.error,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ).animate(delay: 1200.ms).slideY(begin: 0.3).fadeIn(),
//     );
//   }

//   Widget _buildProfileContent(
//     bool isGuest,
//     bool isPremium,
//     AnalyticsState analyticsState,
//     List<dynamic> historyList,
//     List<dynamic> favoritesList,
//     ThemeData theme,
//   ) {
//     return SliverList(
//       delegate: SliverChildListDelegate([
//         const SizedBox(height: 20),
//         if (isGuest) ...[
//           _buildGuestPrompt(theme),
//         ] else ...[
//           if (_isEditing) _buildEditForm(theme),
//           _buildStatsOverview(
//               analyticsState, historyList, favoritesList, theme),
//           _buildAchievementsSection(analyticsState, isPremium, theme),
//           _buildActivityInsights(historyList, theme),
//         ],
//         _buildQuickActions(isGuest, isPremium, theme),
//         _buildAccountSection(isGuest, theme),
//       ]),
//     );
//   }

//   Widget _buildGuestPrompt(ThemeData theme) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       child: Container(
//         padding: const EdgeInsets.all(32),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               theme.colorScheme.primary.withOpacity(0.1),
//               theme.colorScheme.secondary.withOpacity(0.1),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//             color: theme.colorScheme.primary.withOpacity(0.2),
//           ),
//           boxShadow: AppTheme.getElevationShadow(context, 8),
//         ),
//         child: Column(
//           children: [
//             Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     theme.colorScheme.primary,
//                     theme.colorScheme.secondary,
//                   ],
//                 ),
//                 shape: BoxShape.circle,
//                 boxShadow: AppTheme.getElevationShadow(context, 4),
//               ),
//               child: const Icon(
//                 Icons.account_circle_rounded,
//                 size: 50,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'Unlock Your AI Journey',
//               style: theme.textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Create an account to save your detection history, earn achievements, access premium features, and track your AI exploration progress.',
//               textAlign: TextAlign.center,
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 color: theme.colorScheme.onSurfaceVariant,
//                 height: 1.6,
//               ),
//             ),
//             const SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   HapticFeedback.lightImpact();
//                   Navigator.pushNamed(context, '/auth');
//                 },
//                 icon: const Icon(Icons.login_rounded, size: 20),
//                 label: Text(
//                   'Sign Up / Sign In',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: theme.colorScheme.primary,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ).animate().slideY(begin: 0.3).fadeIn(),
//     );
//   }

//   Widget _buildEditForm(ThemeData theme) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.edit_rounded,
//                   color: theme.colorScheme.primary,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'Edit Profile',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           TextField(
//             controller: _nameController,
//             style: theme.textTheme.bodyLarge,
//             decoration: InputDecoration(
//               labelText: 'Display Name',
//               hintText: 'Enter your display name',
//               prefixIcon: Icon(
//                 Icons.person_outline_rounded,
//                 color: theme.colorScheme.primary,
//               ),
//               labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
//               hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
//               filled: true,
//               fillColor:
//                   theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: BorderSide.none,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: BorderSide(
//                   color: theme.colorScheme.outline,
//                   width: 1,
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: BorderSide(
//                   color: theme.colorScheme.primary,
//                   width: 2,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           TextField(
//             controller: _bioController,
//             maxLines: 3,
//             style: theme.textTheme.bodyLarge,
//             decoration: InputDecoration(
//               labelText: 'Bio',
//               hintText: 'Tell us about yourself',
//               prefixIcon: Padding(
//                 padding: const EdgeInsets.only(bottom: 40),
//                 child: Icon(
//                   Icons.info_outline_rounded,
//                   color: theme.colorScheme.primary,
//                 ),
//               ),
//               labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
//               hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
//               filled: true,
//               fillColor:
//                   theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: BorderSide.none,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: BorderSide(
//                   color: theme.colorScheme.outline,
//                   width: 1,
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: BorderSide(
//                   color: theme.colorScheme.primary,
//                   width: 2,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ).animate().slideY(begin: 0.3).fadeIn();
//   }

//   Widget _buildStatsOverview(
//     AnalyticsState analyticsState,
//     List<dynamic> historyList,
//     List<dynamic> favoritesList,
//     ThemeData theme,
//   ) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.analytics_rounded,
//                   color: theme.colorScheme.primary,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'Your Statistics',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 2,
//             childAspectRatio: 0.9,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             children: [
//               _buildStatCard(
//                 'Total Scans',
//                 '${historyList.length}',
//                 Icons.camera_alt_rounded,
//                 theme.colorScheme.primary,
//                 theme,
//               ),
//               _buildStatCard(
//                 'Objects Found',
//                 '${analyticsState.totalDetections}',
//                 Icons.category_rounded,
//                 AppTheme.successColor,
//                 theme,
//               ),
//               _buildStatCard(
//                 'Avg Accuracy',
//                 '${(analyticsState.averageConfidence * 100).toInt()}%',
//                 Icons.trending_up_rounded,
//                 AppTheme.warningColor,
//                 theme,
//               ),
//               _buildStatCard(
//                 'Favorites',
//                 '${favoritesList.length}',
//                 Icons.favorite_rounded,
//                 AppTheme.errorColor,
//                 theme,
//               ),
//             ],
//           ),
//         ],
//       ),
//     ).animate(delay: 200.ms).slideY(begin: 0.3).fadeIn();
//   }

//   Widget _buildStatCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//     ThemeData theme,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             color.withOpacity(0.1),
//             color.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: color.withOpacity(0.2),
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             value,
//             style: theme.textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: theme.colorScheme.onSurfaceVariant,
//               fontWeight: FontWeight.w600,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAchievementsSection(
//     AnalyticsState analyticsState,
//     bool isPremium,
//     ThemeData theme,
//   ) {
//     final achievements = _getAchievements(analyticsState, isPremium);
//     final unlockedCount =
//         achievements.where((a) => a['unlocked'] as bool).length;

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: AppTheme.warningColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.emoji_events_rounded,
//                   color: AppTheme.warningColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Text(
//                   'Achievements',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//               ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       theme.colorScheme.primary.withOpacity(0.2),
//                       theme.colorScheme.secondary.withOpacity(0.2),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: theme.colorScheme.primary.withOpacity(0.3),
//                   ),
//                 ),
//                 child: Text(
//                   '$unlockedCount/${achievements.length}',
//                   style: theme.textTheme.labelMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.primary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               childAspectRatio: 0.7,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//             ),
//             itemCount: achievements.length,
//             itemBuilder: (context, index) {
//               final achievement = achievements[index];
//               return _buildAchievementCard(
//                 achievement['title'] as String,
//                 achievement['description'] as String,
//                 achievement['icon'] as IconData,
//                 achievement['unlocked'] as bool,
//                 achievement['color'] as Color,
//                 theme,
//               );
//             },
//           ),
//         ],
//       ),
//     ).animate(delay: 400.ms).slideY(begin: 0.3).fadeIn();
//   }

//   Widget _buildAchievementCard(
//     String title,
//     String description,
//     IconData icon,
//     bool isUnlocked,
//     Color color,
//     ThemeData theme,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         _showAchievementDetail(
//             title, description, icon, isUnlocked, color, theme);
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           gradient: isUnlocked
//               ? LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     color.withOpacity(0.2),
//                     color.withOpacity(0.1),
//                   ],
//                 )
//               : LinearGradient(
//                   colors: [
//                     theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
//                     theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//                   ],
//                 ),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: isUnlocked
//                 ? color.withOpacity(0.3)
//                 : theme.colorScheme.outline.withOpacity(0.2),
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: isUnlocked
//                     ? color.withOpacity(0.2)
//                     : theme.colorScheme.onSurfaceVariant.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(
//                 icon,
//                 size: 18,
//                 color: isUnlocked
//                     ? color
//                     : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: theme.textTheme.bodySmall?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: isUnlocked
//                     ? theme.colorScheme.onSurface
//                     : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (isUnlocked)
//               Container(
//                 margin: const EdgeInsets.only(top: 4),
//                 width: 4,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: color,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActivityInsights(List<dynamic> historyList, ThemeData theme) {
//     if (historyList.isEmpty) return const SizedBox.shrink();

//     // Calculate insights
//     final recentActivity = historyList
//         .where((item) => DateTime.now().difference(item.timestamp).inDays <= 7)
//         .length;

//     final todayActivity = historyList
//         .where((item) => DateTime.now().difference(item.timestamp).inDays == 0)
//         .length;

//     return Container(
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: AppTheme.infoColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.insights_rounded,
//                   color: AppTheme.infoColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'Recent Activity',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildInsightItem(
//                   'Today',
//                   '$todayActivity scans',
//                   Icons.today_rounded,
//                   AppTheme.infoColor,
//                   theme,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildInsightItem(
//                   'This Week',
//                   '$recentActivity scans',
//                   Icons.calendar_today_rounded,
//                   AppTheme.successColor,
//                   theme,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ).animate(delay: 600.ms).slideY(begin: 0.3).fadeIn();
//   }

//   Widget _buildInsightItem(
//     String label,
//     String value,
//     IconData icon,
//     Color color,
//     ThemeData theme,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             color.withOpacity(0.1),
//             color.withOpacity(0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: color.withOpacity(0.2),
//         ),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             value,
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: theme.colorScheme.onSurfaceVariant,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActions(bool isGuest, bool isPremium, ThemeData theme) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.flash_on_rounded,
//                   color: theme.colorScheme.primary,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'Quick Actions',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           if (!isGuest && !isPremium) ...[
//             _buildActionTile(
//               'Upgrade to Premium',
//               'Unlock advanced AI features and analytics',
//               Icons.diamond_rounded,
//               AppTheme.premiumGold,
//               () {
//                 HapticFeedback.lightImpact();
//                 Navigator.pushNamed(context, '/premium');
//               },
//               theme,
//             ),
//             _buildDivider(theme),
//           ],
//           _buildActionTile(
//             'Settings & Preferences',
//             'Customize your app experience',
//             Icons.settings_rounded,
//             AppTheme.infoColor,
//             () {
//               HapticFeedback.lightImpact();
//               Navigator.pushNamed(context, '/settings');
//             },
//             theme,
//           ),
//           _buildDivider(theme),
//           _buildActionTile(
//             'Help & Support',
//             'Get help and contact our support team',
//             Icons.help_center_rounded,
//             AppTheme.successColor,
//             () {
//               HapticFeedback.lightImpact();
//               _openSupport();
//             },
//             theme,
//           ),
//           // _buildDivider(theme),
//           // _buildActionTile(
//           //   'Share App',
//           //   'Tell your friends about AI Vision Pro',
//           //   Icons.share_rounded,
//           //   theme.colorScheme.secondary,
//           //   () {
//           //     HapticFeedback.lightImpact();
//           //     _shareApp();
//           //   },
//           //   theme,
//           // ),
//           // _buildDivider(theme),
//           // _buildActionTile(
//           //   'Rate Us',
//           //   'Rate our app in the store',
//           //   Icons.star_rate_rounded,
//           //   AppTheme.warningColor,
//           //   () {
//           //     HapticFeedback.lightImpact();
//           //     _rateApp();
//           //   },
//           //   theme,
//           // ),
//         ],
//       ),
//     ).animate(delay: 800.ms).slideY(begin: 0.3).fadeIn();
//   }

//   Widget _buildAccountSection(bool isGuest, ThemeData theme) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.tertiary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.security_rounded,
//                   color: theme.colorScheme.tertiary,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'Account & Privacy',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           if (isGuest) ...[
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   HapticFeedback.lightImpact();
//                   Navigator.pushNamed(context, '/auth');
//                 },
//                 icon: const Icon(Icons.login_rounded, size: 20),
//                 label: Text(
//                   'Sign In to Your Account',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: theme.colorScheme.primary,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//               ),
//             ),
//           ] else ...[
//             // _buildActionTile(
//             //   'Privacy Settings',
//             //   'Manage your data and privacy preferences',
//             //   Icons.privacy_tip_rounded,
//             //   AppTheme.warningColor,
//             //   () {
//             //     HapticFeedback.lightImpact();
//             //     _openPrivacySettings();
//             //   },
//             //   theme,
//             // ),
//             // _buildDivider(theme),
//             // _buildActionTile(
//             //   'Export My Data',
//             //   'Download all your account data',
//             //   Icons.download_rounded,
//             //   AppTheme.infoColor,
//             //   () {
//             //     HapticFeedback.lightImpact();
//             //     _exportUserData();
//             //   },
//             //   theme,
//             // ),
//             // _buildDivider(theme),
//             _buildActionTile(
//               'Delete Account',
//               'Permanently delete your account and data',
//               Icons.delete_forever_rounded,
//               AppTheme.errorColor,
//               () {
//                 HapticFeedback.lightImpact();
//                 _showDeleteAccountDialog();
//               },
//               theme,
//             ),
//             _buildDivider(theme),
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: OutlinedButton.icon(
//                 onPressed: () {
//                   HapticFeedback.lightImpact();
//                   _showSignOutDialog();
//                 },
//                 icon: const Icon(
//                   Icons.logout_rounded,
//                   color: AppTheme.errorColor,
//                   size: 20,
//                 ),
//                 label: Text(
//                   'Sign Out',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     color: AppTheme.errorColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: AppTheme.errorColor, width: 2),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     ).animate(delay: 1000.ms).slideY(begin: 0.3).fadeIn();
//   }

//   Widget _buildActionTile(
//     String title,
//     String subtitle,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//     ThemeData theme,
//   ) {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Icon(icon, color: color, size: 24),
//       ),
//       title: Text(
//         title,
//         style: theme.textTheme.titleMedium?.copyWith(
//           fontWeight: FontWeight.w600,
//           color: theme.colorScheme.onSurface,
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: theme.textTheme.bodySmall?.copyWith(
//           color: theme.colorScheme.onSurfaceVariant,
//           height: 1.3,
//         ),
//       ),
//       trailing: Icon(
//         Icons.arrow_forward_ios_rounded,
//         size: 16,
//         color: theme.colorScheme.onSurfaceVariant,
//       ),
//       onTap: onTap,
//     );
//   }

//   Widget _buildDivider(ThemeData theme) {
//     return Divider(
//       height: 24,
//       thickness: 1,
//       color: theme.colorScheme.outline.withOpacity(0.2),
//     );
//   }

//   // Helper Methods
//   List<Map<String, dynamic>> _getAchievements(
//     AnalyticsState analyticsState,
//     bool isPremium,
//   ) {
//     final historyList = ref.watch(historyProvider);
//     final favoritesList = ref.watch(favoritesProvider);

//     return [
//       {
//         'title': 'First Scan',
//         'description': 'Complete your first detection',
//         'icon': Icons.camera_alt_rounded,
//         'unlocked': historyList.isNotEmpty, // Check if any scans exist
//         'color': AppTheme.successColor,
//       },
//       {
//         'title': 'Explorer',
//         'description': 'Scan 50 different objects',
//         'icon': Icons.explore_rounded,
//         'unlocked': historyList.length >= 50, // Based on scan count
//         'color': AppTheme.infoColor,
//       },
//       {
//         'title': 'AI Expert',
//         'description': 'Achieve 90%+ average accuracy',
//         'icon': Icons.psychology_rounded,
//         'unlocked': _calculateAverageAccuracy(historyList) >= 0.9,
//         'color': AppTheme.secondaryColor,
//       },
//       {
//         'title': 'Premium User',
//         'description': 'Upgrade to premium features',
//         'icon': Icons.diamond_rounded,
//         'unlocked': isPremium,
//         'color': AppTheme.premiumGold,
//       },
//       {
//         'title': 'Dedication',
//         'description': 'Use the app for 7 days straight',
//         'icon': Icons.local_fire_department_rounded,
//         'unlocked': _checkDailyStreak(historyList) >= 7,
//         'color': AppTheme.errorColor,
//       },
//       {
//         'title': 'Collector',
//         'description': 'Save 25 items to favorites',
//         'icon': Icons.collections_rounded,
//         'unlocked': favoritesList.length >= 25,
//         'color': AppTheme.warningColor,
//       },
//     ];
//   }

// // Helper method to calculate average accuracy from history
//   double _calculateAverageAccuracy(List<DetectionHistory> history) {
//     if (history.isEmpty) return 0.0;

//     double totalAccuracy = 0.0;
//     int count = 0;

//     for (final item in history) {
//       totalAccuracy += item.averageConfidence;
//       count++;
//     }

//     return count > 0 ? totalAccuracy / count : 0.0;
//   }

// // Helper method to check daily streak
//   int _checkDailyStreak(List<DetectionHistory> history) {
//     if (history.isEmpty) return 0;

//     // Sort by date (most recent first)
//     final sortedHistory = List<DetectionHistory>.from(history)
//       ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

//     int streak = 0;
//     DateTime currentDate = DateTime.now();

//     // Check each day going backwards
//     for (int i = 0; i < 30; i++) {
//       // Check up to 30 days
//       final checkDate = currentDate.subtract(Duration(days: i));
//       final hasActivityOnDate = sortedHistory.any((item) =>
//           item.timestamp.year == checkDate.year &&
//           item.timestamp.month == checkDate.month &&
//           item.timestamp.day == checkDate.day);

//       if (hasActivityOnDate) {
//         streak++;
//       } else if (i > 0) {
//         // Don't break on first day if no activity today
//         break;
//       }
//     }

//     return streak;
//   }

//   // Action Methods
//   void _changeProfilePicture() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       useSafeArea: true,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         margin: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.surface,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: AppTheme.getElevationShadow(context, 8),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Handle
//               Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(top: 12),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),

//               Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Change Profile Picture',
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                     const SizedBox(height: 24),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildImageSourceButton(
//                             'Camera',
//                             Icons.camera_alt_rounded,
//                             () {
//                               Navigator.pop(context);
//                               _pickImage(ImageSource.camera);
//                             },
//                             Theme.of(context),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: _buildImageSourceButton(
//                             'Gallery',
//                             Icons.photo_library_rounded,
//                             () {
//                               Navigator.pop(context);
//                               _pickImage(ImageSource.gallery);
//                             },
//                             Theme.of(context),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildImageSourceButton(
//     String label,
//     IconData icon,
//     VoidCallback onPressed,
//     ThemeData theme,
//   ) {
//     return Container(
//       // height: 80,
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.3),
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: TextButton(
//         onPressed: onPressed,
//         style: TextButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               color: theme.colorScheme.primary,
//               size: 28,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: theme.textTheme.labelLarge?.copyWith(
//                 color: theme.colorScheme.onSurface,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _pickImage(ImageSource source) async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(
//         source: source,
//         imageQuality: 90,
//         maxWidth: 512,
//         maxHeight: 512,
//       );

//       if (image != null) {
//         // Store the selected image temporarily
//         _selectedImage = File(image.path);
//         _hasImageChanged = true;

//         setState(() {}); // Refresh UI to show new image

//         _showSuccessSnackBar('Image selected! Save your profile to upload.');
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to select image: $e');
//     }
//   }

// // New method to upload image to Firebase Storage
//   Future<String> _uploadProfileImage(XFile imageFile) async {
//     try {
//       final user = ref.read(currentUserProvider);
//       if (user == null) throw Exception('User not authenticated');

//       final fileName =
//           'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('profile_images')
//           .child(fileName);

//       final uploadTask = storageRef.putFile(File(imageFile.path));
//       final snapshot = await uploadTask.whenComplete(() => null);

//       if (snapshot.state == TaskState.success) {
//         final downloadURL = await storageRef.getDownloadURL();
//         return downloadURL;
//       } else {
//         throw Exception('Upload failed');
//       }
//     } catch (e) {
//       debugPrint('Error uploading profile image: $e');
//       rethrow;
//     }
//   }

//   void _saveProfile() async {
//     if (!_validateProfileData()) return;

//     _showLoadingDialog('Saving profile...');

//     try {
//       final displayName = _nameController.text.trim();
//       final bio = _bioController.text.trim();
//       String? newPhotoURL;

//       // Upload image if one was selected
//       if (_hasImageChanged && _selectedImage != null) {
//         newPhotoURL = await _uploadAndCompressProfileImage(_selectedImage!);
//       }

//       // Update Firebase Auth profile
//       await ref.read(authProvider.notifier).updateProfile(
//             displayName: displayName,
//             photoURL: newPhotoURL, // Only update if new image was uploaded
//           );

//       // Update Firestore user document
//       final user = ref.read(currentUserProvider);
//       if (user != null) {
//         final updates = {
//           'displayName': displayName,
//           'profile': {'bio': bio},
//           'updatedAt': FieldValue.serverTimestamp(),
//         };

//         if (newPhotoURL != null) {
//           updates['photoURL'] = newPhotoURL;
//         }

//         await _updateUserProfileInFirestore(user.id, updates);
//       }

//       // Reset image change flag
//       _hasImageChanged = false;
//       _selectedImage = null;

//       Navigator.pop(context); // Close loading dialog
//       setState(() => _isEditing = false);
//       _showSuccessSnackBar('Profile updated successfully!');
//     } catch (e) {
//       Navigator.pop(context);
//       _showErrorSnackBar('Failed to update profile: $e');
//     }
//   }

//   Future<String> _uploadAndCompressProfileImage(File imageFile) async {
//     try {
//       final user = ref.read(currentUserProvider);
//       if (user == null) throw Exception('User not authenticated');

//       // Compress the image
//       final compressedImage = await _compressImage(imageFile);

//       final fileName =
//           'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('profile_images')
//           .child(fileName);

//       final uploadTask = storageRef.putFile(compressedImage);
//       final snapshot = await uploadTask.whenComplete(() => null);

//       if (snapshot.state == TaskState.success) {
//         final downloadURL = await storageRef.getDownloadURL();
//         return downloadURL;
//       } else {
//         throw Exception('Upload failed');
//       }
//     } catch (e) {
//       debugPrint('Error uploading profile image: $e');
//       rethrow;
//     }
//   }

// // New method to update Firestore user document
//   Future<void> _updateUserProfileInFirestore(
//       String userId, Map<String, dynamic> updates) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .update(updates);
//     } catch (e) {
//       debugPrint('Error updating user profile in Firestore: $e');
//       rethrow;
//     }
//   }

//   void _showAchievementDetail(
//     String title,
//     String description,
//     IconData icon,
//     bool isUnlocked,
//     Color color,
//     ThemeData theme,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Icon(
//                 icon,
//                 color: color,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 title,
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               description,
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 color: theme.colorScheme.onSurfaceVariant,
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: isUnlocked
//                     ? AppTheme.successColor.withOpacity(0.1)
//                     : theme.colorScheme.surfaceContainerHighest,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: isUnlocked
//                       ? AppTheme.successColor.withOpacity(0.3)
//                       : theme.colorScheme.outline.withOpacity(0.3),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     isUnlocked
//                         ? Icons.check_circle_rounded
//                         : Icons.lock_rounded,
//                     color: isUnlocked
//                         ? AppTheme.successColor
//                         : theme.colorScheme.onSurfaceVariant,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     isUnlocked ? 'Achievement Unlocked!' : 'Achievement Locked',
//                     style: theme.textTheme.labelLarge?.copyWith(
//                       color: isUnlocked
//                           ? AppTheme.successColor
//                           : theme.colorScheme.onSurfaceVariant,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               HapticFeedback.lightImpact();
//               Navigator.pop(context);
//             },
//             child: Text(
//               'Close',
//               style: TextStyle(
//                 color: theme.colorScheme.primary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLoadingDialog(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(
//               color: Theme.of(context).colorScheme.primary,
//               strokeWidth: 3,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               message,
//               style: Theme.of(context).textTheme.titleMedium,
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(
//               Icons.check_circle_rounded,
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.successColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(
//               Icons.error_outline_rounded,
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.errorColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 4),
//       ),
//     );
//   }

//   void _openSupport() async {
//     const url = 'aivisionproapp@gmail.com?subject=Support Request';
//     try {
//       if (await canLaunchUrl(Uri.parse(url))) {
//         await launchUrl(Uri.parse(url));
//       } else {
//         _showErrorSnackBar(
//           'Could not open email client. Please contact https://balanced-meal-app-65cb1.web.app/support',
//         );
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to open support: $e');
//     }
//   }

// // screens/settings_screen.dart


// class SettingsScreen extends ConsumerStatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends ConsumerState<SettingsScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _slideController;
//   late AnimationController _fadeController;

//   // Add service instances
//   late final PushNotificationService _notificationService;
//   late final SoundManager _soundManager;
//   late final HapticFeedbackUtil _hapticService;
//   late final ImageQualityManager _imageQualityManager;
//   late final AutoSaveService _autoSaveService;

//   // Settings State
//   bool _notificationsEnabled = true;
//   bool _soundEnabled = true;
//   bool _hapticEnabled = true;
//   bool _autoSave = true;
//   bool _highQuality = true;
//   String _language = 'English';
//   String _theme = 'System';

//   // App Info
//   String _appVersion = '1.0.0';
//   String _buildNumber = '1';

//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize service instances
//     _notificationService = PushNotificationService();
//     _soundManager = SoundManager();
//     _hapticService = HapticFeedbackUtil();
//     _imageQualityManager = ImageQualityManager();
//     _autoSaveService = AutoSaveService();
//     _initializeAnimations();
//     _loadSettings();
//     _loadAppInfo();
//     _calculateCacheSize();
//   }

//   void _initializeAnimations() {
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _slideController.forward();
//     _fadeController.forward();
//   }

//   void _loadSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       if (mounted) {
//         setState(() {
//           _notificationsEnabled =
//               prefs.getBool('notifications_enabled') ?? true;
//           _soundEnabled = prefs.getBool('sound_enabled') ?? true;
//           _hapticEnabled = prefs.getBool('haptic_enabled') ?? true;
//           _autoSave = prefs.getBool('auto_save') ?? true;
//           _highQuality = prefs.getBool('high_quality') ?? true;
//           _language = prefs.getString('language') ?? 'English';
//           _theme = prefs.getString('theme') ?? 'System';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         _showErrorSnackBar('Failed to load settings: $e');
//       }
//     }
//   }

//   void _loadAppInfo() async {
//     try {
//       final packageInfo = await PackageInfo.fromPlatform();

//       if (mounted) {
//         setState(() {
//           _appVersion = packageInfo.version;
//           _buildNumber = packageInfo.buildNumber;
//         });
//       }
//     } catch (e) {
//       debugPrint('Failed to load app info: $e');
//     }
//   }

//   void _saveSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await Future.wait([
//         prefs.setBool('notifications_enabled', _notificationsEnabled),
//         prefs.setBool('sound_enabled', _soundEnabled),
//         prefs.setBool('haptic_enabled', _hapticEnabled),
//         prefs.setBool('auto_save', _autoSave),
//         prefs.setBool('high_quality', _highQuality),
//         prefs.setString('language', _language),
//         prefs.setString('theme', _theme),
//       ]);

//       // Connect settings to actual services
//       if (_notificationsEnabled != null) {
//         await _notificationService
//             .setNotificationsEnabled(_notificationsEnabled);
//       }

//       if (_soundEnabled != null) {
//         await _soundManager.setSoundEnabled(_soundEnabled);
//       }

//       if (_hapticEnabled != null) {
//         await _hapticService.setHapticEnabled(_hapticEnabled);
//       }

//       if (_highQuality != null) {
//         final isPremium = ref.read(premiumProvider).isPremium;
//         try {
//           await _imageQualityManager.setHighQualityEnabled(
//               _highQuality, isPremium);
//         } catch (e) {
//           // Show premium required dialog
//           _showPremiumRequired();
//           setState(() => _highQuality = false);
//         }
//       }

//       if (_autoSave != null) {
//         await _autoSaveService.setAutoSaveEnabled(_autoSave);
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to save settings: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _slideController.dispose();
//     _fadeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isPremium = ref.watch(premiumProvider).isPremium;

//     if (_isLoading) {
//       return _buildLoadingScreen(theme);
//     }

//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           _buildSliverAppBar(theme),
//           SliverPadding(
//             padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//             sliver: SliverList(
//               delegate: SliverChildListDelegate([
//                 // User Profile Card
//                 _buildUserProfileCard(theme).animate().slideX().fadeIn(),

//                 const SizedBox(height: 24),

//                 // Premium Banner (if not premium)
//                 if (!isPremium) ...[
//                   _buildPremiumBanner(theme)
//                       .animate(delay: 200.ms)
//                       .slideY(begin: 0.3)
//                       .fadeIn(),
//                   const SizedBox(height: 24),
//                 ],

//                 // General Settings
//                 _buildSectionHeader('General', Icons.settings_rounded, theme)
//                     .animate(delay: 300.ms)
//                     .slideX()
//                     .fadeIn(),
//                 const SizedBox(height: 12),
//                 _buildSettingsCard([
//                   _buildSwitchTile(
//                     'Push Notifications',
//                     'Receive updates and alerts',
//                     Icons.notifications_rounded,
//                     _notificationsEnabled,
//                     (value) =>
//                         _updateSetting(() => _notificationsEnabled = value),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildSwitchTile(
//                     'Sound Effects',
//                     'Audio feedback for interactions',
//                     Icons.volume_up_rounded,
//                     _soundEnabled,
//                     (value) => _updateSetting(() => _soundEnabled = value),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildSwitchTile(
//                     'Haptic Feedback',
//                     'Vibration for touch interactions',
//                     Icons.vibration_rounded,
//                     _hapticEnabled,
//                     (value) => _updateSetting(() => _hapticEnabled = value),
//                     theme,
//                   ),
//                 ], theme)
//                     .animate(delay: 400.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 24),

//                 // Camera & Detection Settings
//                 _buildSectionHeader(
//                         'Camera & Detection', Icons.camera_alt_rounded, theme)
//                     .animate(delay: 500.ms)
//                     .slideX()
//                     .fadeIn(),
//                 const SizedBox(height: 12),
//                 _buildSettingsCard([
//                   _buildSwitchTile(
//                     'High Quality Images',
//                     isPremium
//                         ? 'Capture in maximum resolution (Premium)'
//                         : 'Capture in maximum resolution - Premium Required',
//                     Icons.hd_rounded,
//                     isPremium ? _highQuality : false,
//                     (value) {
//                       if (!isPremium && value) {
//                         _showPremiumRequired();
//                         return;
//                       }
//                       _updateSetting(() => _highQuality = value);

//                       // Show helpful feedback
//                       _hapticService.toggleSwitch();
//                       if (value && isPremium) {
//                         _showSuccessSnackBar(
//                             'High quality mode enabled. Images will be larger but more detailed.');
//                       }
//                     },
//                     theme,
//                     badge: isPremium ? null : 'PRO',
//                   ),
//                   _buildDivider(theme),
//                   _buildSwitchTile(
//                     'Auto-save Results',
//                     'Automatically save detections',
//                     Icons.save_rounded,
//                     _autoSave,
//                     (value) => _updateSetting(() => _autoSave = value),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildTapTile(
//                     'Camera Permissions',
//                     'Manage camera and storage access',
//                     Icons.security_rounded,
//                     () => _showPermissionsDialog(),
//                     theme,
//                   ),
//                 ], theme)
//                     .animate(delay: 600.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 24),

//                 // Appearance Settings
//                 _buildSectionHeader('Appearance', Icons.palette_rounded, theme)
//                     .animate(delay: 700.ms)
//                     .slideX()
//                     .fadeIn(),
//                 const SizedBox(height: 12),
//                 _buildSettingsCard([
//                   _buildDropdownTile(
//                     'Theme Mode',
//                     'Choose your preferred appearance',
//                     Icons.brightness_6_rounded,
//                     _theme,
//                     ['System', 'Light', 'Dark'],
//                     (value) => _updateTheme(value!),
//                     theme,
//                   ),
               
//                 ], theme)
//                     .animate(delay: 800.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 24),

//                 // Data & Privacy
//                 _buildSectionHeader(
//                         'Data & Privacy', Icons.privacy_tip_rounded, theme)
//                     .animate(delay: 900.ms)
//                     .slideX()
//                     .fadeIn(),
//                 const SizedBox(height: 12),
//                 _buildSettingsCard([
//                   _buildTapTile(
//                     'Clear Cache',
//                     'Free up ${_getCacheSize()} of storage space',
//                     Icons.cleaning_services_rounded,
//                     () => _clearCache(),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildTapTile(
//                     'Export Data',
//                     'Download your detection history',
//                     Icons.download_rounded,
//                     () => _exportData(),
//                     theme,
//                     badge: isPremium ? null : 'PRO',
//                   ),
//                   _buildDivider(theme),
//                   _buildTapTile(
//                     'Privacy Policy',
//                     'View our privacy practices',
//                     Icons.policy_rounded,
//                     () => _openPrivacyPolicy(),
//                     theme,
//                   ),
//                 ], theme)
//                     .animate(delay: 1000.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 24),

//                 // Support & Feedback
//                 _buildSectionHeader('Support & Feedback',
//                         Icons.support_agent_rounded, theme)
//                     .animate(delay: 1100.ms)
//                     .slideX()
//                     .fadeIn(),
//                 const SizedBox(height: 12),
//                 _buildSettingsCard([
//                   _buildTapTile(
//                     'Help Center',
//                     'Get help and view tutorials',
//                     Icons.help_center_rounded,
//                     () => _openHelpCenter(),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildTapTile(
//                     'Contact Support',
//                     'Chat with our support team',
//                     Icons.chat_rounded,
//                     () => _contactSupport(),
//                     theme,
//                   ),
//                   // _buildDivider(theme),
//                   // _buildTapTile(
//                   //   'Rate App',
//                   //   'Share your experience with others',
//                   //   Icons.star_rate_rounded,
//                   //   () => _rateApp(),
//                   //   theme,
//                   // ),
//                 ], theme)
//                     .animate(delay: 1200.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 24),

//                 // Account Management
//                 _buildSectionHeader(
//                         'Account', Icons.account_circle_rounded, theme)
//                     .animate(delay: 1300.ms)
//                     .slideX()
//                     .fadeIn(),
//                 const SizedBox(height: 12),
//                 _buildSettingsCard([
//                   _buildTapTile(
//                     'Profile Settings',
//                     'Manage your account details',
//                     Icons.person_rounded,
//                     () => Navigator.pushNamed(context, '/profile'),
//                     theme,
//                   ),
//                   _buildDivider(theme),
//                   _buildTapTile(
//                     'Subscription',
//                     isPremium
//                         ? 'Manage your premium subscription'
//                         : 'Upgrade to premium',
//                     Icons.diamond_rounded,
//                     () => Navigator.pushNamed(context, '/premium'),
//                     theme,
//                     textColor: isPremium ? AppTheme.premiumGold : null,
//                   ),
//                   _buildDivider(theme),
//                 ], theme)
//                     .animate(delay: 1400.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 32),

//                 // App Information
//                 _buildAppInfoCard(theme)
//                     .animate(delay: 1500.ms)
//                     .slideY(begin: 0.3)
//                     .fadeIn(),

//                 const SizedBox(height: 20),
//               ]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingScreen(ThemeData theme) {
//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: CircularProgressIndicator(
//                 color: theme.colorScheme.primary,
//                 strokeWidth: 3,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'Loading Settings...',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSliverAppBar(ThemeData theme) {
//     return SliverAppBar(
//       expandedHeight: 120,
//       floating: true,
//       pinned: false,
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       surfaceTintColor: Colors.transparent,
     
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 theme.colorScheme.primary.withOpacity(0.05),
//                 theme.colorScheme.surface,
//               ],
//             ),
//           ),
//           padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Text(
//                 'Settings',
//                 style: theme.textTheme.headlineLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ).animate().slideX().fadeIn(),
//               const SizedBox(height: 4),
//               Text(
//                 'Customize your AI Vision Pro experience',
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   color: theme.colorScheme.onSurfaceVariant,
//                 ),
//               ).animate(delay: 200.ms).slideX().fadeIn(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserProfileCard(ThemeData theme) {
//     final user = ref.watch(currentUserProvider);
//     final isPremium = ref.watch(premiumProvider).isPremium;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             theme.colorScheme.primary.withOpacity(0.1),
//             theme.colorScheme.secondary.withOpacity(0.1),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               gradient: isPremium
//                   ? AppTheme.premiumGradient
//                   : LinearGradient(
//                       colors: [
//                         theme.colorScheme.primary,
//                         theme.colorScheme.secondary,
//                       ],
//                     ),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: (isPremium
//                           ? AppTheme.premiumGold
//                           : theme.colorScheme.primary)
//                       .withOpacity(0.3),
//                   blurRadius: 12,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: user?.photoURL != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(30),
//                     child: Image.network(
//                       user!.photoURL!,
//                       width: 60,
//                       height: 60,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => const Icon(
//                         Icons.person_rounded,
//                         color: Colors.white,
//                         size: 30,
//                       ),
//                     ),
//                   )
//                 : const Icon(
//                     Icons.person_rounded,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         user?.displayName ?? 'Guest User',
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: theme.colorScheme.onSurface,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     if (isPremium)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           gradient: AppTheme.premiumGradient,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(
//                               Icons.diamond_rounded,
//                               color: Colors.white,
//                               size: 12,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               'PRO',
//                               style: theme.textTheme.labelSmall?.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ).animate().shimmer(duration: 2000.ms),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   user?.email ?? 'guest@aivisionpro.com',
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.surface.withOpacity(0.8),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     isPremium ? 'Premium Member' : 'Free User',
//                     style: theme.textTheme.labelMedium?.copyWith(
//                       color: isPremium
//                           ? AppTheme.premiumGold
//                           : theme.colorScheme.primary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPremiumBanner(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppTheme.premiumGold,
//             AppTheme.premiumGold.withOpacity(0.8),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.premiumGold.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: const Icon(
//               Icons.diamond_rounded,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Upgrade to Premium',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Unlock advanced features and unlimited detections',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               HapticFeedback.lightImpact();
//               Navigator.pushNamed(context, '/premium');
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               foregroundColor: AppTheme.premiumGold,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//             child: Text(
//               'Upgrade',
//               style: theme.textTheme.labelLarge?.copyWith(
//                 color: Colors.black,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//       child: Row(
//         children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: theme.colorScheme.primary,
//               size: 18,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             title,
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSettingsCard(List<Widget> children, ThemeData theme) {
//     return Container(
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(children: children),
//     );
//   }

  

//   Widget _buildSwitchTile(
//     String title,
//     String subtitle,
//     IconData icon,
//     bool value,
//     ValueChanged<bool> onChanged,
//     ThemeData theme, {
//     String? badge,
//   }) {
//     return InkWell(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         onChanged(!value);
//       },
//       borderRadius: BorderRadius.circular(20),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Row(
//           children: [
//             Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 color: theme.colorScheme.primary,
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           title,
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: theme.colorScheme.onSurface,
//                           ),
//                         ),
//                       ),
//                       if (badge != null)
//                         Container(
//                           margin: const EdgeInsets.only(left: 8),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             gradient: AppTheme.premiumGradient,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             badge,
//                             style: theme.textTheme.labelSmall?.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 16),
//             Switch.adaptive(
//               value: value,
//               onChanged: (newValue) {
//                 HapticFeedback.lightImpact();
//                 onChanged(newValue);
//               },
//               activeColor: theme.colorScheme.primary,
//               activeTrackColor: theme.colorScheme.primary.withOpacity(0.3),
//               inactiveThumbColor: theme.colorScheme.outline,
//               inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

  

//   Widget _buildDivider(ThemeData theme) {
//     return Container(
//       margin: const EdgeInsets.only(left: 76),
//       height: 1,
//       color: theme.colorScheme.outline.withOpacity(0.2),
//     );
//   }

//   Widget _buildAppInfoCard(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//             theme.colorScheme.surface,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: theme.colorScheme.outline.withOpacity(0.2),
//         ),
//         boxShadow: AppTheme.getElevationShadow(context, 2),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   theme.colorScheme.primary,
//                   theme.colorScheme.secondary,
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: theme.colorScheme.primary.withOpacity(0.3),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.visibility_rounded,
//               size: 40,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'AI Vision Pro',
//             style: theme.textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               'Version $_appVersion ($_buildNumber)',
//               style: theme.textTheme.labelLarge?.copyWith(
//                 color: theme.colorScheme.primary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'Advanced AI-powered object recognition\nwith real-time detection capabilities',
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: theme.colorScheme.onSurfaceVariant,
//               height: 1.5,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildAppInfoButton(
//                 'What\'s New',
//                 Icons.new_releases_rounded,
//                 () => _showWhatsNewDialog(),
//                 theme,
//               ),
//               _buildAppInfoButton(
//                 'About',
//                 Icons.info_rounded,
//                 () => _showAboutDialog(),
//                 theme,
//               ),
//               _buildAppInfoButton(
//                 'Licenses',
//                 Icons.description_rounded,
//                 () => _showLicensesPage(),
//                 theme,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

  


//   double _actualCacheSize = 0.0;

//   String _getCacheSize() {
//     return '${_actualCacheSize.toStringAsFixed(1)} MB';
//   }

//   Future<void> _calculateCacheSize() async {
//     try {
//       final tempDir = await getTemporaryDirectory();
//       final cacheDir = await getApplicationCacheDirectory();

//       double totalSize = 0.0;

//       if (await tempDir.exists()) {
//         totalSize += await _getDirectorySize(tempDir);
//       }

//       if (await cacheDir.exists()) {
//         totalSize += await _getDirectorySize(cacheDir);
//       }

//       setState(() {
//         _actualCacheSize = totalSize / (1024 * 1024);
//       });
//     } catch (e) {
//       debugPrint('Failed to calculate cache size: $e');
//       _actualCacheSize = 0.0;
//     }
//   }

//   Future<double> _getDirectorySize(Directory directory) async {
//     double size = 0.0;
//     try {
//       await for (final entity in directory.list(recursive: true)) {
//         if (entity is File) {
//           size += await entity.length();
//         }
//       }
//     } catch (e) {
//       debugPrint('Error calculating directory size: $e');
//     }
//     return size;
//   }

//   void _showErrorSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(
//                 Icons.error_outline_rounded,
//                 color: Theme.of(context).colorScheme.onError,
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   message,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: AppTheme.errorColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//     }
//   }

  
//   Future<void> _requestPermissions() async {
//     try {
//       final permissions = [
//         Permission.camera,
//         Permission.storage,
//         Permission.microphone,
//       ];

//       final statuses = await permissions.request();

//       final deniedPermissions = statuses.entries
//           .where((entry) =>
//               entry.value.isDenied || entry.value.isPermanentlyDenied)
//           .toList();

//       if (deniedPermissions.isEmpty) {
//         _showSuccessSnackBar('All permissions granted successfully!');
//       } else {
//         final permanentlyDenied =
//             deniedPermissions.any((entry) => entry.value.isPermanentlyDenied);

//         if (permanentlyDenied) {
//           _showPermissionSettingsDialog();
//         } else {
//           _showErrorSnackBar('Some permissions were denied. Please try again.');
//         }
//       }
//     } catch (e) {
//       _showErrorSnackBar('Failed to request permissions: $e');
//     }
//   }

//   void _showPermissionSettingsDialog() {
//     final theme = Theme.of(context);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Open Settings'),
//         content: Text(
//           'Some permissions are permanently denied. Please enable them in Settings to use all features.',
//           style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               openAppSettings();
//             },
//             child: const Text('Open Settings'),
//           ),
//         ],
//       ),
//     );
//   }


//   void _showLicensesPage() {
//     showLicensePage(
//       context: context,
//       applicationName: 'AI Vision Pro',
//       applicationVersion: '$_appVersion+$_buildNumber',
//       applicationIcon: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Theme.of(context).colorScheme.primary,
//               Theme.of(context).colorScheme.secondary,
//             ],
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: const Icon(
//           Icons.visibility_rounded,
//           color: Colors.white,
//           size: 20,
//         ),
//       ),
//     );
//   }

  
  

//   void _exportData() {
//     final isPremium = ref.read(premiumProvider).isPremium;

//     if (!isPremium) {
//       Navigator.pushNamed(context, '/premium');
//       return;
//     }

//     final theme = Theme.of(context);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.colorScheme.surface,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 Icons.download_rounded,
//                 color: theme.colorScheme.primary,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Text(
//               'Export Data',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Choose the format for your detection history export:',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildExportFormatOption(
//                 'PDF Report',
//                 'Complete report with images and analysis',
//                 Icons.picture_as_pdf_rounded,
//                 AppTheme.errorColor,
//                 theme),
//             const SizedBox(height: 12),
//             _buildExportFormatOption(
//                 'CSV Data',
//                 'Spreadsheet format for data analysis',
//                 Icons.table_chart_rounded,
//                 AppTheme.successColor,
//                 theme),
//             const SizedBox(height: 12),
//             _buildExportFormatOption(
//                 'JSON Export',
//                 'Raw data format for developers',
//                 Icons.code_rounded,
//                 AppTheme.infoColor,
//                 theme),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             style: TextButton.styleFrom(
//               foregroundColor: theme.colorScheme.onSurfaceVariant,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExportFormatOption(String title, String description,
//       IconData icon, Color color, ThemeData theme) {
//     return InkWell(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         Navigator.pop(context);
//         _performExport(title);
//       },
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: color.withOpacity(0.3),
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: color, size: 18),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: theme.textTheme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     description,
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: color,
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   }