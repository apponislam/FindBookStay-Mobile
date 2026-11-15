import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/auth_state.dart';
import '../controllers/auth_controller.dart';

/// Provider for [AuthRemoteDataSource]
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(dioClient: dioClient);
});

/// Provider for [AuthRepository]
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    tokenStorage: tokenStorage,
  );
});

/// Modern Riverpod NotifierProvider for [AuthController]
final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Convenience provider for current [UserModel]
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authControllerProvider).user;
});

/// Convenience provider checking if user is actively authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isAuthenticated;
});

/// Convenience provider checking if session is Guest
final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isGuest;
});

/// Convenience provider for current [AuthStatus]
final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authControllerProvider).status;
});

/// Convenience provider for current auth error message
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).errorMessage;
});
