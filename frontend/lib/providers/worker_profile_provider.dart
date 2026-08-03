import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

final workerProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final response = await ApiClient().dio.get('/workers/profile/me');
  return response.data['exists'] == true ? response.data : null;
});