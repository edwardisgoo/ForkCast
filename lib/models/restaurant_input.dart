import 'package:flutter/material.dart';
import 'package:flutter_app/models/openingHours.dart';
import 'package:flutter_app/models/types.dart';
import 'package:flutter_app/models/review.dart';
import 'package:flutter_app/models/restaurant_raw.dart';
import 'package:flutter_app/models/utils/distance_cal.dart';
import 'package:flutter_app/models/utils/ocr.dart';

/*
光齊：針對呼叫fetchRestaurant時所需Input設計的Data Structure
*/
class RestaurantInput {
  const RestaurantInput({
    required this.distance,
    required this.opening,
    required this.rating,
    required this.reviews,
    required this.photoImformation,
    required this.name,
    required this.summary,
    required this.types,
    required this.priceInformation,
    required this.extraInformation,
  });
  //1.位置相關
  final double distance; //單位公尺
  //2.營業狀況時間相關
  final bool opening; //在查詢時間是否營業中
  //*3.評論相關
  final double rating; //1-5之間的浮點數
  final List<Review> reviews;
  //4.圖片相關
  final String photoImformation;
  //5.店家名稱描述相關
  final String name;
  final String summary;
  final String types; //條列types的文字
  //6.連結相關
  //7.電話相關
//暫時不使用?
  //8.價位相關
  final String priceInformation; //描述價格的文字
  //9.布林值補充資訊相關
  final String extraInformation;

  //RestaurantRaw->RestaurantInput轉換函數
  factory RestaurantInput.fromRaw(
    RestaurantRaw raw,
    HourMin queryTime,//使用者查詢的時間
    double queryLat,//使用者所在位置的精度
    double queryLng,//使用者所在位置的緯度
  ) {
    // 計算直線距離 (Haversine Formula 簡化版，單位：公尺)
    final double distance = calculateDistanceMeters(
      raw.latitude,
      raw.longtitude,
      queryLat,
      queryLng,
    );

    // 判斷是否營業中
    final bool isOpen = raw.openingHours.any((pair) {
      final open = pair.start;
      final close = pair.end;
      final openMinutes = open.hour * 60 + open.minute;
      final closeMinutes = close.hour * 60 + close.minute;
      final queryMinutes = queryTime.hour * 60 + queryTime.minute;

      // 包含跨午夜的情況
      if (closeMinutes < openMinutes) {
        return queryMinutes >= openMinutes || queryMinutes <= closeMinutes;
      } else {
        return queryMinutes >= openMinutes && queryMinutes <= closeMinutes;
      }
    });

    // Types 轉文字
    final String typeStrings = raw.types
    .map((index) => typeMap[typeMap.keys.elementAt(index)] ?? '未知')
    .toList()
    .join(' / ');

    // 處理價位
    final String priceInfo = {
      PriceLevel.free: '免費',
      PriceLevel.inexpensive: '便宜',
      PriceLevel.moderate: '中等',
      PriceLevel.expensive: '貴',
      PriceLevel.veryExpensive: '非常貴',
    }[raw.priceLevel]!;

    // 處理照片資訊(暫時先用有無照片 後續再來實作OCR讀菜單)
    final String photoInfo = ocrImageProcess(raw.photos);

    // 合成 extraInformation
    final List<String> extras = [];
    if (raw.curbsidePickup) extras.add('路邊取貨');
    if (raw.delivery) extras.add('外送');
    if (raw.dineIn) extras.add('內用');
    if (raw.reservable) extras.add('可預約');
    if (raw.servesBeer) extras.add('提供啤酒');
    if (raw.servesBreakfast) extras.add('早餐');
    if (raw.servesBrunch) extras.add('早午餐');
    if (raw.servesDinner) extras.add('晚餐');
    if (raw.servesLunch) extras.add('午餐');
    if (raw.servesVegetarianFood) extras.add('素食');
    if (raw.servesWine) extras.add('葡萄酒');
    if (raw.takeout) extras.add('外帶');
    if (raw.wheelchairAccessibleEntrance) extras.add('無障礙入口');
    final extraInfo = extras.join(' / ');

    return RestaurantInput(
      distance: distance,
      opening: isOpen,
      rating: raw.rating,
      reviews: raw.reviews,
      photoImformation: photoInfo,
      name: raw.name,
      summary: raw.summary,
      types: typeStrings,
      priceInformation: priceInfo,
      extraInformation: extraInfo,
    );
  }
}
