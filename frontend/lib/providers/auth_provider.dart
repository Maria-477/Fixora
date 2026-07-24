import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_models.dart';
import '../models/user_models.dart';
import '../repositories/auth_repository.dart';
import '../services/user_service.dart';

enum AuthStatus { unknown, unauthenticated, authenticating, authenticated }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final UserMe? user;

  AuthState({required this.status, this.errorMessage, this.user});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo = AuthRepository();
  final UserService _userService = UserService();

  AuthNotifier() : super(AuthState(status: AuthStatus.unknown)) {
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final token = await _repo.getStoredToken();
    if (token == null) {
      state = AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    final user = await _userService.getMe();
    state = user != null
        ? AuthState(status: AuthStatus.authenticated, user: user)
        : AuthState(status: AuthStatus.unauthenticated);
  }

  Future<AuthResult> register(RegisterRequest request) {
    return _repo.register(request);
  }

  Future<void> verifyOtp(String phone, String otp) async {
    state = AuthState(status: AuthStatus.authenticating);
    final result = await _repo.verifyOtp(phone, otp);
    if (!result.success) {
      state = AuthState(status: AuthStatus.unauthenticated, errorMessage: result.errorMessage);
      return;
    }
    final user = await _userService.getMe();
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> login(String phone, String password) async {
    state = AuthState(status: AuthStatus.authenticating);
    final result = await _repo.login(phone, password);
    if (!result.success) {
      state = AuthState(status: AuthStatus.unauthenticated, errorMessage: result.errorMessage);
      return;
    }
    final user = await _userService.getMe();
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());