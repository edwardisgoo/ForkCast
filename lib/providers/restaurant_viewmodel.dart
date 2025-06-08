import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/openingHours.dart';
import 'package:flutter_app/models/restaurant_output.dart';
import 'package:flutter_app/models/unwanted.dart';
import 'package:flutter_app/models/userSetting.dart';
import 'package:flutter_app/models/query.dart';
import 'package:flutter_app/services/fetch_restaurant.dart';

class RestaurantViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _resultText = '';
  List<RestaurantOutput> _restaurants = [];

  bool get isLoading => _isLoading;
  String get resultText => _resultText;
  List<RestaurantOutput> get restaurants => _restaurants;

  // Default test parameters
  final HourMin _queryTime = HourMin.fromInts(18, 0);
  final double _queryLat = 24.797654607789465;
  final double _queryLng = 120.99796646277547;
  final Query _extraPreference = Query(
    minPrice: 0,
    maxPrice: 300,
    minDistance: 0,
    maxDistance: 300,
    requirement: "炸物",
    note: "可以外帶",
  );
  final UserSetting _userSetting = UserSetting(
    sortedPreference: ["金額", "特殊需求", "人潮", "距離"],
  );

  HourMin get queryTime => _queryTime;
  double get queryLat => _queryLat;
  double get queryLng => _queryLng;
  Query get extraPreference => _extraPreference;
  UserSetting get userSetting => _userSetting;

  Future<void> fetchRestaurants() async {
    _isLoading = true;
    _resultText = 'Loading...';
    _restaurants = [];
    notifyListeners();

    try {
      final result = await fetchRestaurant(
          _queryTime, _queryLat, _queryLng, _extraPreference, _userSetting);

      final List<RestaurantOutput> fetchedRestaurants =
          List<RestaurantOutput>.from(result['result'] ?? []);

      _restaurants = fetchedRestaurants;
      _resultText = _buildResultText(fetchedRestaurants);
    } catch (e) {
      _resultText =
          '錯誤: ${e.toString()}\n\n請檢查:\n1. Cloud Function 是否正確部署\n2. Firebase 項目設置\n3. 函數區域設置\n4. 網路連接';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _buildResultText(List<RestaurantOutput> restaurants) {
    if (restaurants.isEmpty) {
      return '沒有找到符合條件的餐廳';
    }

    StringBuffer buffer = StringBuffer();
    buffer.writeln('找到 ${restaurants.length} 家餐廳:\n');

    for (int i = 0; i < restaurants.length; i++) {
      final r = restaurants[i];
      final input = r.input;

      buffer.writeln('=== 餐廳 ${i + 1} ===');
      buffer.writeln('名稱: ${input.name}');
      buffer.writeln('評分: ${input.rating} ⭐');
      buffer.writeln('距離: ${input.distance.toStringAsFixed(0)}m');
      buffer.writeln('營業中: ${input.opening ? "是" : "否"}');
      buffer.writeln('類型: ${input.types}');
      buffer.writeln('價格資訊: ${input.priceInformation}');
      buffer.writeln('摘要: ${input.summary}');
      if (input.extraInformation.isNotEmpty) {
        buffer.writeln('額外資訊: ${input.extraInformation}');
      }
      buffer.writeln('');

      buffer.writeln('📊 推薦分數:');
      buffer.writeln('  總分: ${r.matchScore.toStringAsFixed(2)}');
      buffer.writeln('  價格分數: ${r.priceScore.toStringAsFixed(2)}');
      buffer.writeln('  距離分數: ${r.distanceScore.toStringAsFixed(2)}');
      buffer.writeln('  評分分數: ${r.ratingScore.toStringAsFixed(2)}');
      buffer.writeln('  偏好分數: ${r.preferenceScore.toStringAsFixed(2)}');
      buffer.writeln('  需求分數: ${r.requirementScore.toStringAsFixed(2)}');
      buffer.writeln('');

      buffer.writeln('💭 推薦原因:');
      buffer.writeln('  ${r.reason}');
      buffer.writeln('');

      buffer.writeln('📝 簡短介紹:');
      buffer.writeln(r.shortIntroduction.isNotEmpty
          ? '  ${r.shortIntroduction}'
          : '  （無資料）');
      buffer.writeln('');
      buffer.writeln('📝!!! 完整介紹:');
      buffer.writeln(r.fullIntroduction.isNotEmpty
          ? '  ${r.fullIntroduction}'
          : '  （無資料）');
      buffer.writeln('');

      buffer.writeln('🍽️ 菜單資訊:');
      buffer.writeln(r.menu.isNotEmpty ? '  ${r.menu}' : '  （無資料）');
      buffer.writeln('');

      buffer.writeln('💬 評論摘要:');
      buffer.writeln(r.reviews.isNotEmpty ? '  ${r.reviews}' : '  （無資料）');
      buffer.writeln('');

      buffer.writeln('📌 評分細項分析:');
      if (r.reasons.isNotEmpty) {
        r.reasons.forEach((key, value) {
          buffer.writeln('  $key: $value');
        });
      } else {
        buffer.writeln('  （無資料）');
      }
      buffer.writeln('');

      if (input.reviews.isNotEmpty) {
        buffer.writeln('⭐ 用戶評論:');
        for (int j = 0; j < input.reviews.length && j < 3; j++) {
          final review = input.reviews[j];
          buffer
              .writeln('  ${review.rating}⭐ (${review.time}): ${review.text}');
        }
        if (input.reviews.length > 3) {
          buffer.writeln('  ... 還有 ${input.reviews.length - 3} 個評論');
        }
        buffer.writeln('');
      }

      if (input.photoImformation.isNotEmpty) {
        buffer.writeln('📷 照片資訊: ${input.photoImformation}');
        buffer.writeln('');
      }
      buffer.writeln('${'=' * 30}\n');
    }
    return buffer.toString();
  }
}
