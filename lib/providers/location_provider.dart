import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_morning/models/location_model.dart';
import 'package:good_morning/services/location_service.dart';

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationModel?>((ref) {
      return LocationNotifier();
    });

class LocationNotifier extends StateNotifier<LocationModel?> {
  LocationNotifier() : super(null);

  Future<void> updateLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      state = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      // 에러 처리
      print('위치 정보 업데이트 실패: $e');
    }
  }
}
