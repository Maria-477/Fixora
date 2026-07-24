import 'package:dio/dio.dart';
import '../models/user_models.dart';
import 'api_client.dart';

class UserService {
  final Dio _dio = ApiClient().dio;

  Future<UserMe?> getMe() async {
    try {
      final response = await _dio.get('/users/me');
      return UserMe.fromJson(response.data);
    } on DioException {
      return null;
    }
  }
}