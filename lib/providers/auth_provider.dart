import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../models/app_user.dart';
import '../models/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _initialize();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Check if user data exists in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding =
          prefs.getBool('onboarding_completed') ?? false;
      final userDataString = prefs.getString('cached_user_data');

      // Listen to auth state changes
      _firebaseAuth.authStateChanges().listen((User? firebaseUser) async {
        if (firebaseUser != null) {
          final appUser = AppUser.fromFirebaseUser(firebaseUser);
          await _cacheUserData(appUser);

          state = state.copyWith(
            user: appUser,
            isAuthenticated: true,
            isLoading: false,
            hasCompletedOnboarding: hasCompletedOnboarding,
          );
        } else {
          await _clearCachedUserData();
          state = state.copyWith(
            user: null,
            isAuthenticated: false,
            isLoading: false,
            hasCompletedOnboarding: hasCompletedOnboarding,
          );
        }
      });

      // If we have cached user data but no Firebase user, try to restore session
      if (userDataString != null && _firebaseAuth.currentUser == null) {
        // The auth state listener will handle the rest
      }

      state = state.copyWith(
        isLoading: false,
        hasCompletedOnboarding: hasCompletedOnboarding,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize authentication: ${e.toString()}',
      );
    }
  }

  Future<void> _cacheUserData(AppUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user_data', user.toJson().toString());
      await prefs.setBool('user_authenticated', true);
    } catch (e) {
      debugPrint('Failed to cache user data: $e');
    }
  }

  Future<void> _clearCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_user_data');
      await prefs.setBool('user_authenticated', false);
    } catch (e) {
      debugPrint('Failed to clear cached user data: $e');
    }
  }

  // Create or update user document in Firestore
  Future<void> _createOrUpdateUserDocument(User firebaseUser,
      {bool isNewUser = false}) async {
    try {
      final userRef = _firestore.collection('users').doc(firebaseUser.uid);
      final userDoc = await userRef.get();

      final userData = {
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'displayName': firebaseUser.displayName,
        'photoURL': firebaseUser.photoURL,
        'phoneNumber': firebaseUser.phoneNumber,
        'isEmailVerified': firebaseUser.emailVerified,
        'isAnonymous': firebaseUser.isAnonymous,
        'lastSignIn': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!userDoc.exists || isNewUser) {
        // Create new user document
        await userRef.set({
          ...userData,
          'createdAt': FieldValue.serverTimestamp(),
          // Add any additional default fields for new users
          'preferences': {
            'theme': 'system',
            'notifications': true,
            'language': 'en',
          },
          'profile': {
            'bio': '',
            'location': '',
            'website': '',
          },
          'stats': {
            'totalScans': 0,
            'totalImages': 0,
            'favoriteCount': 0,
          },
        });
        debugPrint('Created new user document for ${firebaseUser.uid}');
      } else {
        // Update existing user document
        await userRef.update(userData);
        debugPrint('Updated user document for ${firebaseUser.uid}');
      }
    } catch (e) {
      debugPrint('Failed to create/update user document: $e');
      // Don't throw here as authentication should still succeed
      // You might want to show a warning to the user
    }
  }

  // Email & Password Sign In
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final UserCredential result =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Update user document in Firestore
        await _createOrUpdateUserDocument(result.user!);

        final appUser = AppUser.fromFirebaseUser(result.user!);
        await _cacheUserData(appUser);

        state = state.copyWith(
          user: appUser,
          isAuthenticated: true,
          isLoading: false,
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e.code),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Email & Password Registration
  Future<void> registerWithEmailAndPassword(
      String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Send email verification
        await result.user!.sendEmailVerification();

        // Create user document in Firestore (new user)
        await _createOrUpdateUserDocument(result.user!, isNewUser: true);

        final appUser = AppUser.fromFirebaseUser(result.user!);
        await _cacheUserData(appUser);

        state = state.copyWith(
          user: appUser,
          isAuthenticated: true,
          isLoading: false,
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e.code),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result =
          await _firebaseAuth.signInWithCredential(credential);

      if (result.user != null) {
        // Check if this is a new user
        final isNewUser = result.additionalUserInfo?.isNewUser ?? false;

        // Create or update user document in Firestore
        await _createOrUpdateUserDocument(result.user!, isNewUser: isNewUser);

        final appUser = AppUser.fromFirebaseUser(result.user!);
        await _cacheUserData(appUser);

        state = state.copyWith(
          user: appUser,
          isAuthenticated: true,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Google sign in failed: ${e.toString()}',
      );
    }
  }

  // Apple Sign In
  Future<void> signInWithApple() async {
    if (!Platform.isIOS) {
      state = state.copyWith(
        error: 'Apple Sign In is only available on iOS devices',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if Apple Sign In is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        state = state.copyWith(
          isLoading: false,
          error: 'Apple Sign In is not available on this device',
        );
        return;
      }

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final UserCredential result =
          await _firebaseAuth.signInWithCredential(oAuthCredential);

      if (result.user != null) {
        // Update display name if provided by Apple and not already set
        if (appleCredential.givenName != null &&
            result.user!.displayName == null) {
          final displayName =
              '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
                  .trim();
          await result.user!.updateDisplayName(displayName);
        }

        // Check if this is a new user
        final isNewUser = result.additionalUserInfo?.isNewUser ?? false;

        // Create or update user document in Firestore
        await _createOrUpdateUserDocument(result.user!, isNewUser: isNewUser);

        final appUser = AppUser.fromFirebaseUser(result.user!);
        await _cacheUserData(appUser);

        state = state.copyWith(
          user: appUser,
          isAuthenticated: true,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Apple sign in failed: ${e.toString()}',
      );
    }
  }

  // Anonymous Sign In (Guest Mode)
  Future<void> signInAnonymously() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final UserCredential result = await _firebaseAuth.signInAnonymously();

      if (result.user != null) {
        // Create user document in Firestore for anonymous user
        await _createOrUpdateUserDocument(result.user!, isNewUser: true);

        final appUser = AppUser.fromFirebaseUser(result.user!);
        await _cacheUserData(appUser);

        state = state.copyWith(
          user: appUser,
          isAuthenticated: true,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Anonymous sign in failed: ${e.toString()}',
      );
    }
  }

  // Convert Anonymous to Permanent Account
  Future<void> linkEmailPassword(String email, String password) async {
    if (state.user == null || !state.user!.isAnonymous) {
      state = state.copyWith(error: 'No anonymous user to link');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      final UserCredential result =
          await _firebaseAuth.currentUser!.linkWithCredential(credential);

      if (result.user != null) {
        // Update user document - convert from anonymous to permanent
        await _createOrUpdateUserDocument(result.user!, isNewUser: false);

        final appUser = AppUser.fromFirebaseUser(result.user!);
        await _cacheUserData(appUser);

        state = state.copyWith(
          user: appUser,
          isAuthenticated: true,
          isLoading: false,
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e.code),
      );
    }
  }

  // Sign Out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);

      await _clearCachedUserData();

      state = state.copyWith(
        user: null,
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sign out: ${e.toString()}',
      );
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e.code),
      );
    }
  }

  // Update Profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _firebaseAuth.currentUser!;

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Reload user data
      await user.reload();
      final updatedUser = _firebaseAuth.currentUser!;

      // Update Firestore document
      await _createOrUpdateUserDocument(updatedUser);

      final appUser = AppUser.fromFirebaseUser(updatedUser);
      await _cacheUserData(appUser);

      state = state.copyWith(
        user: appUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile: ${e.toString()}',
      );
    }
  }

  // Mark Onboarding as Completed
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);

      state = state.copyWith(hasCompletedOnboarding: true);
    } catch (e) {
      debugPrint('Failed to mark onboarding as completed: $e');
    }
  }

  // Clear Error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been temporarily disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      case 'invalid-credential':
        return 'The provided credential is invalid or expired.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

// Provider instances
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

// Helper providers
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).hasCompletedOnboarding;
});

final isGuestUserProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAnonymous ?? false;
});
