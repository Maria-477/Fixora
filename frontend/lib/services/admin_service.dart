import 'package:dio/dio.dart';

import '../models/admin_models.dart';
import 'api_client.dart';

class AdminService {
  final Dio _dio = ApiClient().dio;

  Future<AdminSummary?> getSummary() async {
    try {
      final response = await _dio.get('/admin/summary');
      return AdminSummary.fromJson(response.data);
    } on DioException {
      return null;
    }
  }

  Future<List<PendingVerification>> getPendingVerifications() async {
    try {
      final response = await _dio.get('/admin/verifications/pending');

      return (response.data as List)
          .map((e) => PendingVerification.fromJson(e))
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<bool> reviewVerification(
    int verificationId,
    bool approve,
  ) async {
    try {
      await _dio.patch(
        '/admin/verifications/$verificationId',
        queryParameters: {
          'approve': approve,
        },
      );

      return true;
    } on DioException {
      return false;
    }
  }
}