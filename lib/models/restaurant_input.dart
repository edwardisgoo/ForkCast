import 'package:flutter_app/models/openingHours.dart';
import 'package:flutter_app/models/types.dart';
import 'package:flutter_app/models/review.dart';
import 'package:flutter_app/models/utils/distance_cal.dart';
import 'package:flutter_app/models/utils/ocr.dart';

/*
光齊：針對呼叫fetchRestaurant時所需Input設計的Data Structure
*/
class RestaurantInput {
  const RestaurantInput({
    required this.id,
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
  final String id;
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

}
