import 'dart:math';

/// 提供經緯度直線距離計算（單位：公尺）
double calculateDistanceMeters(
  double lat1,
  double lng1,
  double lat2,
  double lng2,
) {
  const double earthRadius = 6371000.0; // 地球半徑（公尺）

  final double dLat = _deg2rad(lat2 - lat1);
  final double dLng = _deg2rad(lng2 - lng1);

  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
          sin(dLng / 2) * sin(dLng / 2);

  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

double _deg2rad(double deg) => deg * (pi / 180);
