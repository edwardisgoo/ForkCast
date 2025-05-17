/*

光齊：測試fetch_restaurant能正確呼叫cloud function的測試app
*/
import 'package:flutter/material.dart';
import 'package:flutter_app/models/restaurant_raw.dart';
import 'package:flutter_app/models/restaurant_input.dart';
import 'package:flutter_app/models/restaurant_output.dart';
import 'package:flutter_app/models/review.dart';
import 'package:flutter_app/models/types.dart';
import 'package:flutter_app/models/query.dart';
import 'package:flutter_app/models/userSetting.dart';
import 'package:flutter_app/services/fetch_restaurant.dart';
import 'package:flutter_app/models/openingHours.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/firebase_options.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<List<RestaurantRaw>> loadJsonAndProcess() async {
  final jsonString = await rootBundle.loadString('assets/input2.json');
  final jsonData = json.decode(jsonString);

  final List<dynamic> restaurants = jsonData['restaurants'];

  final List<RestaurantRaw> results = restaurants.map<RestaurantRaw>((r) {
    print('In loadJsonAndProcess.');
    print('r.keys:${r.keys}');
    return RestaurantRaw(
      latitude: 0.0, // 資料中無地理座標
      longtitude: 0.0,
      address: "", // 資料中無地址
      businessStatus: r['opening'] == true
          ? RestaurantStatus.operational
          : RestaurantStatus.closedPermanently,
      openingHours: [], // 未提供具體時段資訊
      rating: (r['rating'] as num).toDouble(),
      reviews: (r['reviews'] as List)
          .map((rev) => Review(
                rating: rev['rating'].toDouble(),
                time: '0',
                text: rev['text'],
              ))
          .toList(),
      photos: [], // 資料只說有提供照片，無實際 URL
      name: r['name'],
      summary: r['summary'],
      id: r['name'].hashCode.toString(), // 可自訂唯一 ID 方式
      types: {75}, //_parseTypes(r['types']),//r['types'],
      url: "", // 資料中無 URL
      priceLevel: _parsePriceLevel(r['priceInformation']),
      curbsidePickup: _containsExtra(r['extraInformation'], ['路邊取餐']),
      delivery: _containsExtra(r['extraInformation'], ['外送']),
      dineIn: _containsExtra(r['extraInformation'], ['內用']),
      reservable: _containsExtra(r['extraInformation'], ['預約', '包廂']),
      servesBeer: _containsExtra(r['extraInformation'], ['啤酒', '酒水']),
      servesBreakfast: _containsExtra(r['extraInformation'], ['早餐']),
      servesBrunch: _containsExtra(r['extraInformation'], ['早午餐']),
      servesDinner: _containsExtra(r['extraInformation'], ['晚餐']),
      servesLunch: _containsExtra(r['extraInformation'], ['午餐']),
      servesVegetarianFood: _containsExtra(r['extraInformation'], ['素', '全素']),
      servesWine: _containsExtra(r['extraInformation'], ['紅酒', '白酒', '配酒']),
      takeout: _containsExtra(r['extraInformation'], ['外帶', '外送']),
      wheelchairAccessibleEntrance:
          _containsExtra(r['extraInformation'], ['無障礙']),
    );
  }).toList();

  print('Parsed restaurant: ${restaurants}');
  return results;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadJsonAndProcess();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Finder',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RestaurantHomePage(),
    );
  }
}

class RestaurantHomePage extends StatefulWidget {
  const RestaurantHomePage({super.key});

  @override
  State<RestaurantHomePage> createState() => _RestaurantHomePageState();
}

class _RestaurantHomePageState extends State<RestaurantHomePage> {
  String resultMessage = "尚未查詢";
  List<RestaurantOutput> resultList = [];

  void callFetchRestaurant() async {
    try {
      // 建立假資料 RestaurantRaw（實際應該是從 Google Maps API 取得）
      final raw = await loadJsonAndProcess();

      final query = Query(
        minPrice: 1,
        maxPrice: 3,
        minDistance: 0,
        maxDistance: 3000,
        requirement: "壽司",
        note: "安靜環境",
      );

      final setting = UserSetting(
        sortedPreference: ["distance", "rating"],
      );

      final response = await fetchRestaurant(
        raw,
        HourMin('1200'),
        25.0340,
        121.5645,
        query,
        setting,
      );

      setState(() {
        resultList = List<RestaurantOutput>.from(response['result']);
        resultMessage = "成功呼叫 Firebase，共有 ${resultList.length} 筆結果";
      });
    } catch (e) {
      setState(() {
        resultMessage = "呼叫失敗: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('餐廳推薦系統')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: callFetchRestaurant,
              child: const Text("查詢餐廳"),
            ),
            const SizedBox(height: 20),
            Text(resultMessage),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: resultList.length,
                itemBuilder: (context, index) {
                  final item = resultList[index];
                  return Card(
                    elevation: 2,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.raw.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text("推薦原因: ${item.reason}"),
                          Text("匹配分數: ${item.matchScore.toStringAsFixed(2)}"),
                          Text("價格分數: ${item.priceScore.toStringAsFixed(2)}"),
                          Text(
                              "距離分數: ${item.distanceScore.toStringAsFixed(2)}"),
                          Text("評價分數: ${item.ratingScore.toStringAsFixed(2)}"),
                          Text(
                              "偏好分數: ${item.preferenceScore.toStringAsFixed(2)}"),
                          Text(
                              "需求分數: ${item.requirementScore.toStringAsFixed(2)}"),
                          if (item.shortIntroduction.isNotEmpty)
                            Text("簡介: ${item.shortIntroduction}"),
                          if (item.priceReason.isNotEmpty)
                            Text("價格理由: ${item.priceReason}"),
                          if (item.flavorReason.isNotEmpty)
                            Text("口味理由: ${item.flavorReason}"),
                          if (item.menu.isNotEmpty) Text("菜單: ${item.menu}"),
                          if (item.reviews.isNotEmpty)
                            Text("評論: ${item.reviews}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Set<int> _parseTypes(List<String> rawTypes) {
  final List<String> typeKeys = typeMap.keys.toList(); // 取得有順序的 keys
  final Set<int> indices = {};

  for (final type in rawTypes) {
    final index = typeKeys.indexOf(type);
    if (index != -1) {
      indices.add(index);
    }
  }

  return indices;
}

PriceLevel _parsePriceLevel(String price) {
  switch (price) {
    case '免費':
      return PriceLevel.free;
    case '中等':
      return PriceLevel.moderate;
    case '貴':
      return PriceLevel.expensive;
    case '非常貴':
      return PriceLevel.veryExpensive;
    case '便宜':
      return PriceLevel.inexpensive;
    default:
      return PriceLevel.moderate;
  }
}

bool _containsExtra(String? extra, List<String> keywords) {
  if (extra == null) return false;
  return keywords.any((k) => extra.contains(k));
}
