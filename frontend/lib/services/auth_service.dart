import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<AuthResult> register(RegisterRequest request) async {
    try {
      final response =
          await _dio.post('/auth/register', data: request.toJson());

      return AuthResult(
        success: true,
        mockOtp: response.data['mock_otp'],
      );
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _extractError(e),
      );
    }
  }

  Future<AuthResult> verifyOtp(String phone, String otp) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      return AuthResult(
        success: true,
        accessToken: response.data['access_token'],
      );
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _extractError(e),
      );
    }
  }

  Future<AuthResult> login(String phone, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'phone': phone,
          'password': password,
        },
      );

      return AuthResult(
        success: true,
        accessToken: response.data['access_token'],
      );
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        errorMessage: _extractError(e),
      );
    }
  }

  String _extractError(DioException e) {
    if (e.response?.data is Map &&
        e.response?.data['detail'] != null) {
      return e.response!.data['detail'].toString();
    }

    return 'Something went wrong. Please try again.';
  }
}