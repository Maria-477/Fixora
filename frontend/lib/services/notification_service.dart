import 'package:dio/dio.dart';

import '../models/notification_models.dart';
import 'api_client.dart';

class NotificationService {
  final Dio _dio = ApiClient().dio;

  Future<List<AppNotification>> getMyNotifications() async {
    try {
      final response = await _dio.get('/notifications');

      return (response.data as List)
          .map((e) => AppNotification.fromJson(e))
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      return response.data['unread_count'] ?? 0;
    } on DioException {
      return 0;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _dio.patch('/notifications/$id/read');
    } on DioException {
      // Ignore non-critical failures
    }
  }
}