import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

class PortfolioService {
  final Dio _dio = ApiClient().dio;

  Future<bool> uploadImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });
      await _dio.post('/portfolio/upload', data: formData);
      return true;
    } on DioException {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getMyImages() async {
    try {
      final response = await _dio.get('/portfolio/my-images');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException {
      return [];
    }
  }
}