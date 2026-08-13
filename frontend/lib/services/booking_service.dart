import 'package:dio/dio.dart';

import '../models/booking_models.dart';
import 'api_client.dart';

class PriceEstimate {
  final double suggestedPrice;
  final String? skill;
  final String urgencyLevel;
  final String urgencyLabel;
  final List<String> riskNotes;

  PriceEstimate({
    required this.suggestedPrice,
    this.skill,
    required this.urgencyLevel,
    required this.urgencyLabel,
    required this.riskNotes,
  });

  factory PriceEstimate.fromJson(Map<String, dynamic> json) {
    return PriceEstimate(
      suggestedPrice:
          double.tryParse(json['suggested_price'].toString()) ?? 0,
      skill: json['skill'],
      urgencyLevel: json['urgency_level'],
      urgencyLabel: json['urgency_label'],
      riskNotes: List<String>.from(json['risk_notes'] ?? []),
    );
  }
}

class BookingService {
  final Dio _dio = ApiClient().dio;

  Future<bool> createBooking({
    required int workerId,
    required int locationId,
    required String description,
    required DateTime scheduledAt,
    double? suggestedPrice,
  }) async {
    try {
      await _dio.post(
        '/bookings',
        data: {
          'worker_id': workerId,
          'location_id': locationId,
          'service_description': description,
          'scheduled_at': scheduledAt.toIso8601String(),
          'suggested_price': suggestedPrice,
        },
      );

      return true;
    } on DioException {
      return false;
    }
  }

  Future<List<Booking>> getMyBookings() async {
    try {
      print('Calling GET /bookings/my');

      final response = await _dio.get('/bookings/my');

      print(response.data);

      return (response.data as List)
          .map((e) => Booking.fromJson(e))
          .toList();
    } catch (e, st) {
      print(e);
      print(st);
      return [];
    }
  }

  Future<bool> updateStatus(
    int bookingId,
    String status,
  ) async {
    try {
      await _dio.patch(
        '/bookings/$bookingId/status',
        data: {
          'status': status,
        },
      );

      return true;
    } on DioException {
      return false;
    }
  }

  Future<List<DateTime>> getWorkerBookedSlots(
    int workerId,
  ) async {
    try {
      final response = await _dio.get(
        '/bookings/worker/$workerId/slots',
      );

      return (response.data as List)
          .map((e) => DateTime.parse(e))
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<PriceEstimate?> estimatePrice({
    required int workerId,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '/bookings/estimate-price',
        data: {
          'worker_id': workerId,
          'service_description': description,
        },
      );

      return PriceEstimate.fromJson(response.data);
    } on DioException {
      return null;
    }
  }
}