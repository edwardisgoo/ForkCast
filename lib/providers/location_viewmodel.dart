import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app/services/location_service.dart';

class LocationViewModel extends ChangeNotifier {
  final LocationService _locationService;

  LocationViewModel({required LocationService locationService})
      : _locationService = locationService;

  String _locationMessage = '點擊按鈕獲取您的位置';
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  String get locationMessage => _locationMessage;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isLoading => _isLoading;

  Future<void> fetchLocation() async {
    _locationMessage = '正在獲取位置...';
    _latitude = null;
    _longitude = null;
    _isLoading = true;
    notifyListeners();

    try {
      Position position = await _locationService.getCurrentLocation();
      _latitude = position.latitude;
      _longitude = position.longitude;
      _locationMessage = '緯度: ${position.latitude}\n經度: ${position.longitude}';
    } catch (e) {
      _locationMessage = '獲取位置失敗: ${e.toString()}';
      _latitude = null;
      _longitude = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
