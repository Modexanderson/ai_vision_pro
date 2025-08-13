// models/app_user.dart

// User Model
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime lastSignIn;
  final String provider; // 'email', 'google', 'apple', 'anonymous'

  AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoURL,
    required this.isAnonymous,
    required this.createdAt,
    required this.lastSignIn,
    required this.provider,
  });

  factory AppUser.fromFirebaseUser(User user) {
    String provider = 'email';
    if (user.providerData.isNotEmpty) {
      switch (user.providerData.first.providerId) {
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
    if (user.isAnonymous) provider = 'anonymous';

    return AppUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      isAnonymous: user.isAnonymous,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastSignIn: user.metadata.lastSignInTime ?? DateTime.now(),
      provider: provider,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
      'lastSignIn': lastSignIn.toIso8601String(),
      'provider': provider,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastSignIn: DateTime.parse(json['lastSignIn']),
      provider: json['provider'] ?? 'email',
    );
  }
}
