import 'package:dio/dio.dart';
import '../models/booking_models.dart';
import 'api_client.dart';


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
      await _dio.post('/bookings', data: {
        'worker_id': workerId,
        'location_id': locationId,
        'service_description': description,
        'scheduled_at': scheduledAt.toIso8601String(),
        'suggested_price': suggestedPrice,
      });
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

  Future<bool> updateStatus(int bookingId, String status) async {
    try {
      await _dio.patch(
        '/bookings/$bookingId/status',
        data: {'status': status},
      );
      return true;
    } on DioException {
      return false;
    }
  }


Future<List<DateTime>> getWorkerBookedSlots(int workerId) async {
  try {
    final response =
        await _dio.get('/bookings/worker/$workerId/slots');

    return (response.data as List)
        .map((e) => DateTime.parse(e))
        .toList();
  } on DioException {
    return [];
  }
}

Future<double?> estimatePrice({
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

    return double.tryParse(
      response.data['suggested_price'].toString(),
    );
  } on DioException {
    return null;
  }
}

}