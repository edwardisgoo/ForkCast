import 'dart:convert';
import 'dart:io';

import './sample_data_testing.dart'; // 匯入 exampleRestaurant
import '../models/restaurant_input.dart';
import '../models/openingHours.dart';

void main() async {
  // 模擬查詢時間（例如：上午 10:30）
  final queryTime = HourMin('1030');

  // 模擬使用者位置（例如：台北市市政府捷運站）
  final userLat = 25.0400;
  final userLng = 121.5675;

  // 將 RestaurantRaw 轉換為 RestaurantInput
  final input = RestaurantInput.fromRaw(
    exampleRestaurant,
    queryTime,
    userLat,
    userLng,
  );

  // 轉換為 JSON 格式
  final jsonOutput = jsonEncode(input.toJson());

  // 輸出到 lib/data/output.json
  final outputFile = File('lib/data/output.json');
  await outputFile.writeAsString(jsonOutput);

  print('JSON 已輸出至 lib/data/output.json');
}
