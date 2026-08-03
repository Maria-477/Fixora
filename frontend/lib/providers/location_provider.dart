import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

final locationProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  try {
    final response = await ApiClient().dio.get('/locations/me');
    return response.data;
  } catch (e) {
    return null;
  }
});