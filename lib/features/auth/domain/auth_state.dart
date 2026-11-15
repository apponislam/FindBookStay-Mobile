import '../data/models/user_model.dart';

/// Enum representing the high-level authentication lifecycle status.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Immutable state holder for authentication and session status.
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({required this.status, this.user, this.errorMessage});

  factory AuthState.initial() =>
      const AuthState(status: AuthStatus.initial, user: UserModel.guest);

  factory AuthState.loading([UserModel? currentUser]) => AuthState(
    status: AuthStatus.loading,
    user: currentUser ?? UserModel.guest,
  );

  factory AuthState.authenticated(UserModel user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  factory AuthState.unauthenticated() => const AuthState(
    status: AuthStatus.unauthenticated,
    user: UserModel.guest,
  );

  factory AuthState.error(String message, [UserModel? previousUser]) =>
      AuthState(
        status: AuthStatus.error,
        user: previousUser ?? UserModel.guest,
        errorMessage: message,
      );

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null && !user!.isGuest;
  bool get isGuest => !isAuthenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error && errorMessage != null;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user == other.user &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => status.hashCode ^ user.hashCode ^ errorMessage.hashCode;

  @override
  String toString() =>
      'AuthState(status: $status, user: ${user?.email}, error: $errorMessage)';
}
