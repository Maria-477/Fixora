import 'package:dio/dio.dart';

import '../models/worker_models.dart';
import 'api_client.dart';

class WorkerService {
  final Dio _dio = ApiClient().dio;

  Future<ExtractedProfile?> extractProfile(String transcript) async {
    try {
      final response = await _dio.post(
        '/workers/extract-profile',
        data: {
          'transcript': transcript,
        },
      );

      return ExtractedProfile.fromJson(response.data);
    } on DioException {
      return null;
    }
  }

  Future<bool> saveProfile({
    required String fullName,
    required String city,
    required int experienceYears,
    required String bio,
    String? skillName,
  }) async {
    try {
      await _dio.post(
        '/workers/profile',
        data: {
          'full_name': fullName,
          'city': city,
          'experience_years': experienceYears,
          'bio': bio,
          'skill_name': skillName,
        },
      );

      return true;
    } on DioException {
      return false;
    }
  }

  Future<WorkerDetails?> getWorkerDetails(int workerId) async {
  try {
    final response = await _dio.get('/workers/$workerId');
    return WorkerDetails.fromJson(response.data);
  } on DioException {
    return null;
  }
 }
}