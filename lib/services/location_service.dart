import 'package:geolocator/geolocator.dart'; // 導入 geolocator 套件
import 'package:flutter/foundation.dart'; // 導入 kDebugMode

/*
用於取得使用者經緯度位置的服務
*/

class LocationService extends ChangeNotifier {
  /// 檢查位置服務是否可用。
  /// 如果位置服務被禁用，則返回 false。
  Future<bool> _isLocationServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 位置服務被禁用。
      if (kDebugMode) {
        print('Location services are disabled.');
      }
      return false;
    }
    return true;
  }

  /// 檢查應用程式是否被授予位置權限。
  /// 如果權限被拒絕，則嘗試請求權限。
  Future<LocationPermission> _checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      if (kDebugMode) {
        print('Location permissions are denied. Requesting...');
      }
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 權限再次被拒絕。
        if (kDebugMode) {
          print('Location permissions are permanently denied.');
        }
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 權限被永久拒絕，無法請求。
      if (kDebugMode) {
        print(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return permission;
  }

  /// 取得使用者當前經緯度位置。
  ///
  /// 如果位置服務不可用或權限被拒絕，則拋出異常。
  /// 返回一個包含經緯度的 [Position] 物件。
  Future<Position> getCurrentLocation() async {
    // 1. 檢查位置服務是否啟用
    bool serviceEnabled = await _isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 如果位置服務被禁用，可以提示使用者開啟
      throw Exception(
          'Location services are disabled. Please enable them in your device settings.');
    }

    // 2. 檢查並請求權限
    LocationPermission permission = await _checkAndRequestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // 權限問題已經在 _checkAndRequestPermission 中處理並拋出異常
      // 這裡再次拋出以確保調用者知道
      throw Exception('Location permissions are not granted.');
    }

    // 3. 獲取當前位置
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // 設置所需精度
        // timeLimit: Duration(seconds: 10), // 可選：獲取位置的超時時間
      );
      if (kDebugMode) {
        print('Current Location: ${position.latitude}, ${position.longitude}');
      }
      return position;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current location: $e');
      }
      throw Exception('Failed to get current location: $e');
    }
  }

  /// 監聽位置變化（可選）。
  ///
  /// 返回一個 [Stream<Position>]，當位置發生變化時會發出新的位置。
  Stream<Position> getLocationStream() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // 每移動 100 米更新一次位置
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
