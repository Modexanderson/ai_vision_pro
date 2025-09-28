import 'package:firebase_storage/firebase_storage.dart';
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
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding =
          prefs.getBool('onboarding_completed') ?? false;

      User? firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser != null) {
        try {
          await _createOrUpdateUserDocument(firebaseUser);
          final appUser = await _buildAppUserFromFirebase(firebaseUser);
          await _cacheUserData(appUser);

          state = state.copyWith(
            user: appUser,
            isAuthenticated: true,
            isLoading: false,
            hasCompletedOnboarding: hasCompletedOnboarding,
          );
        } catch (e) {
          debugPrint('Error creating/updating user doc during init: $e');
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to initialize user data: ${e.toString()}',
          );
        }
      } else {
        _firebaseAuth.authStateChanges().listen((User? user) async {
          if (user != null) {
            try {
              await _createOrUpdateUserDocument(user);
              final appUser = await _buildAppUserFromFirebase(user);
              await _cacheUserData(appUser);

              state = state.copyWith(
                user: appUser,
                isAuthenticated: true,
                isLoading: false,
                hasCompletedOnboarding: hasCompletedOnboarding,
              );
            } catch (e) {
              debugPrint('Error creating/updating user doc on auth change: $e');
              state = state.copyWith(
                isLoading: false,
                error: 'Failed to sync user data: ${e.toString()}',
              );
            }
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
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize authentication: ${e.toString()}',
      );
    }
  }

  // Enhanced method to build AppUser with Firestore data
  Future<AppUser> _buildAppUserFromFirebase(User firebaseUser) async {
    try {
      // Get additional user data from Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      String provider = 'email';
      if (firebaseUser.providerData.isNotEmpty) {
        switch (firebaseUser.providerData.first.providerId) {
          case 'google.com':
            provider = 'google';
            break;
          case 'apple.com':
            provider = 'apple';
            break;
          case 'password':
            provider = 'email';
            break;
        }
      }
      if (firebaseUser.isAnonymous) provider = 'anonymous';

      // Create base AppUser
      var appUser = AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        isAnonymous: firebaseUser.isAnonymous,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        lastSignIn: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
        provider: provider,
      );

      // If Firestore document exists, merge additional data
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        // Override with Firestore data if available
        appUser = AppUser(
          id: appUser.id,
          email: appUser.email,
          displayName: data['displayName'] ?? appUser.displayName,
          photoURL: data['photoURL'] ?? appUser.photoURL,
          isAnonymous: appUser.isAnonymous,
          createdAt: appUser.createdAt,
          lastSignIn: appUser.lastSignIn,
          provider: appUser.provider,
        );
      }

      return appUser;
    } catch (e) {
      debugPrint('Error building AppUser: $e');
      // Fallback to basic AppUser if Firestore fails
      return AppUser.fromFirebaseUser(firebaseUser);
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
        await userRef.set(
            {
              ...userData,
              'createdAt': FieldValue.serverTimestamp(),
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
            },
            SetOptions(
                merge: true)); // Use merge to avoid overwriting existing data
        debugPrint('Created new user document for ${firebaseUser.uid}');
      } else {
        await userRef.update(userData);
        debugPrint('Updated user document for ${firebaseUser.uid}');
      }
    } catch (e) {
      debugPrint(
          'Failed to create/update user document: $e - User: ${firebaseUser.uid}');
      // Re-throw to ensure the error is visible in the state
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final UserCredential result =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
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
      debugPrint(_getErrorMessage(e.code));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
      debugPrint('An unexpected error occurred: ${e.toString()}');
    }
  }

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
        await result.user!.sendEmailVerification();
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
      debugPrint(_getErrorMessage(e.code));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
      debugPrint('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result =
          await _firebaseAuth.signInWithCredential(credential);

      if (result.user != null) {
        final isNewUser = result.additionalUserInfo?.isNewUser ?? false;
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
      debugPrint('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> signInWithApple() async {
    if (!Platform.isIOS) {
      state = state.copyWith(
        error: 'Apple Sign In is only available on iOS devices',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        state = state.copyWith(
          isLoading: false,
          error: 'Apple Sign In is not available on this device',
        );
        return;
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential result =
          await _firebaseAuth.signInWithCredential(oAuthCredential);

      if (result.user != null) {
        if (appleCredential.givenName != null &&
            result.user!.displayName == null) {
          final displayName =
              '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
                  .trim();
          await result.user!.updateDisplayName(displayName);
        }

        final isNewUser = result.additionalUserInfo?.isNewUser ?? false;
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
      debugPrint('Apple sign in failed: ${e.toString()}');
    }
  }

  Future<void> signInAnonymously() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final UserCredential result = await _firebaseAuth.signInAnonymously();

      if (result.user != null) {
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
      debugPrint('Anonymous sign in failed: ${e.toString()}');
    }
  }

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
      debugPrint(
        _getErrorMessage(e.code),
      );
    }
  }

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

  // Enhanced updateProfile method
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    File? photoFile,
    String? bio,
    Map<String, dynamic>? additionalData,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _firebaseAuth.currentUser!;

      String? finalPhotoURL = photoURL;

      // Upload photo if file is provided
      if (photoFile != null) {
        finalPhotoURL = await _uploadProfileImage(photoFile, user.uid);
      }

      // Update Firebase Auth profile
      if (displayName != null || finalPhotoURL != null) {
        await user.updateDisplayName(displayName);
        if (finalPhotoURL != null) {
          await user.updatePhotoURL(finalPhotoURL);
        }
      }

      // Prepare Firestore update data
      Map<String, dynamic> firestoreUpdates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) {
        firestoreUpdates['displayName'] = displayName;
      }

      if (finalPhotoURL != null) {
        firestoreUpdates['photoURL'] = finalPhotoURL;
      }

      if (bio != null) {
        firestoreUpdates['profile.bio'] = bio;
      }

      if (additionalData != null) {
        firestoreUpdates.addAll(additionalData);
      }

      // Update Firestore document
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(firestoreUpdates);

      // Reload user and update state
      await user.reload();
      final updatedUser = _firebaseAuth.currentUser!;
      final appUser = await _buildAppUserFromFirebase(updatedUser);
      await _cacheUserData(appUser);

      state = state.copyWith(
        user: appUser,
        isLoading: false,
      );

      debugPrint('Profile updated successfully');
    } catch (e) {
      debugPrint('Failed to update profile: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Method to upload profile image to Firebase Storage
  Future<String> _uploadProfileImage(File imageFile, String userId) async {
    try {
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('profile_images').child(fileName);

      // Delete old profile image if exists
      try {
        final oldImageRef = _storage.ref().child('profile_images');
        final listResult = await oldImageRef.listAll();

        for (final item in listResult.items) {
          if (item.name.startsWith('profile_$userId')) {
            await item.delete();
            debugPrint('Deleted old profile image: ${item.name}');
          }
        }
      } catch (e) {
        debugPrint('Could not delete old profile images: $e');
        // Continue anyway, old images won't break anything
      }

      // Upload new image
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask.whenComplete(() => null);

      if (snapshot.state == TaskState.success) {
        final downloadURL = await storageRef.getDownloadURL();
        debugPrint('Profile image uploaded successfully: $downloadURL');
        return downloadURL;
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      rethrow;
    }
  }

  // Method to update user profile data in Firestore only
  Future<void> updateUserProfileData(Map<String, dynamic> updates) async {
    if (state.user == null) return;

    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(state.user!.id).update(updates);

      // Refresh user data
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final appUser = await _buildAppUserFromFirebase(currentUser);
        await _cacheUserData(appUser);

        state = state.copyWith(user: appUser);
      }

      debugPrint('User profile data updated successfully');
    } catch (e) {
      debugPrint('Error updating user profile data: $e');
      rethrow;
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);

      state = state.copyWith(hasCompletedOnboarding: true);
    } catch (e) {
      debugPrint('Failed to mark onboarding as completed: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

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

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

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
