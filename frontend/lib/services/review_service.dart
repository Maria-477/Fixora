import 'package:dio/dio.dart';

import '../models/worker_models.dart';
import 'api_client.dart';


class ReviewService {
  final Dio _dio = ApiClient().dio;


  Future<bool> submitReview({
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _dio.post(
        '/reviews',
        data: {
          'booking_id': bookingId,
          'rating': rating,
          'comment': comment,
        },
      );

      return true;
    } on DioException {
      return false;
    }
  }


  Future<List<ReviewInfo>> getWorkerReviews(
    int workerId,
  ) async {
    try {
      final response = await _dio.get(
        '/reviews/worker/$workerId',
      );

      return (response.data['reviews'] as List)
          .map(
            (e) => ReviewInfo.fromJson(e),
          )
          .toList();

    } on DioException {
      return [];
    }
  }
}