import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'access_token';

  Future<AuthResult> register(RegisterRequest request) {
    return _authService.register(request);
  }

  Future<AuthResult> verifyOtp(String phone, String otp) async {
    final result = await _authService.verifyOtp(phone, otp);

    if (result.success && result.accessToken != null) {
      await _storage.write(
        key: _tokenKey,
        value: result.accessToken,
      );
    }

    return result;
  }

  Future<AuthResult> login(String phone, String password) async {
    final result = await _authService.login(phone, password);

    if (result.success && result.accessToken != null) {
      await _storage.write(
        key: _tokenKey,
        value: result.accessToken,
      );
    }

    return result;
  }

  Future<String?> getStoredToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<void> logout() {
    return _storage.delete(key: _tokenKey);
  }
}