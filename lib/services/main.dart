import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/models/openingHours.dart';
import 'package:flutter_app/models/restaurant_output.dart';
import 'package:flutter_app/models/userSetting.dart';
import 'package:flutter_app/models/query.dart';
import 'package:flutter_app/services/fetch_restaurant.dart';
import 'package:flutter_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) {
      rethrow;
    }
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Fetch Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RestaurantTestPage(),
    );
  }
}

class RestaurantTestPage extends StatefulWidget {
  @override
  _RestaurantTestPageState createState() => _RestaurantTestPageState();
}

class _RestaurantTestPageState extends State<RestaurantTestPage> {
  bool _isLoading = false;
  String _resultText = '';
  List<RestaurantOutput> _restaurants = [];

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

  Future<void> _testFetchRestaurant() async {
    setState(() {
      _isLoading = true;
      _resultText = 'Loading...';
      _restaurants = [];
    });

    try {
      final result = await fetchRestaurant(
        _queryTime,
        _queryLat,
        _queryLng,
        _extraPreference,
        _userSetting,
      );

      final List<RestaurantOutput> restaurants =
          List<RestaurantOutput>.from(result['result'] ?? []);

      setState(() {
        _restaurants = restaurants;
        _resultText = _buildResultText(restaurants);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _resultText =
            '錯誤: ${e.toString()}\n\n請檢查:\n1. Cloud Function 是否正確部署\n2. Firebase 項目設置\n3. 函數區域設置\n4. 網路連接';
        _isLoading = false;
      });
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
      final input = r.input; // 使用 input 而不是 raw

      buffer.writeln('=== 餐廳 ${i + 1} ===');
      buffer.writeln('ID!!!!:');
      buffer.writeln(input.id != '' ? '  ${input.id}' : '  （無資料）');
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

      // 顯示用戶評論
      if (input.reviews.isNotEmpty) {
        buffer.writeln('⭐ 用戶評論:');
        for (int j = 0; j < input.reviews.length && j < 3; j++) {
          // 只顯示前3個評論
          final review = input.reviews[j];
          buffer
              .writeln('  ${review.rating}⭐ (${review.time}): ${review.text}');
        }
        if (input.reviews.length > 3) {
          buffer.writeln('  ... 還有 ${input.reviews.length - 3} 個評論');
        }
        buffer.writeln('');
      }

      // 顯示照片資訊
      if (input.photoImformation.isNotEmpty) {
        buffer.writeln('📷 照片資訊: ${input.photoImformation}');
        buffer.writeln('');
      }

      buffer.writeln('${'=' * 30}\n');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Restaurant Fetch Test')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('測試參數:',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('位置: ($_queryLat, $_queryLng)',
                          style: TextStyle(fontSize: 18)),
                      Text(
                          '查詢時間: ${_queryTime.hour}:${_queryTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 18)),
                      Text(
                          '價格範圍: \$${_extraPreference.minPrice} - \$${_extraPreference.maxPrice}',
                          style: TextStyle(fontSize: 18)),
                      Text(
                          '距離範圍: ${_extraPreference.minDistance}m - ${_extraPreference.maxDistance}m',
                          style: TextStyle(fontSize: 18)),
                      Text('需求: ${_extraPreference.requirement}',
                          style: TextStyle(fontSize: 18)),
                      Text('備註: ${_extraPreference.note}',
                          style: TextStyle(fontSize: 18)),
                      Text('偏好排序: ${_userSetting.sortedPreference.join(' > ')}',
                          style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _testFetchRestaurant,
                  child: _isLoading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('測試中...'),
                          ],
                        )
                      : Text('開始測試 fetchRestaurant'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('測試結果:',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                        _resultText.isEmpty ? '點擊上方按鈕開始測試' : _resultText,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
