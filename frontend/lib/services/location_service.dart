import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'api_client.dart';

enum LocationSaveResult { success, serviceDisabled, permissionDenied, permissionDeniedForever, serverError }

class LocationService {
  final Dio _dio = ApiClient().dio;

  Future<LocationSaveResult> saveCurrentLocation({
    required String addressLine,
    required String city,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationSaveResult.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return LocationSaveResult.permissionDeniedForever;
    if (permission == LocationPermission.denied) return LocationSaveResult.permissionDenied;

    try {
      final position = await Geolocator.getCurrentPosition();
      await _dio.post('/locations/me', data: {
        'address_line': addressLine,
        'city': city,
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
      return LocationSaveResult.success;
    } catch (e) {
      return LocationSaveResult.serverError;
    }
  }
}