// models/auth_state.dart
import 'app_user.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool hasCompletedOnboarding;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.hasCompletedOnboarding = false,
  });

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? hasCompletedOnboarding,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
