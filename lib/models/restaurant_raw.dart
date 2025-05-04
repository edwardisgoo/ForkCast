import 'package:flutter/material.dart';
import 'package:flutter_app/models/openingHours.dart';
import 'package:flutter_app/models/review.dart';
/*
光齊：針對剛從Googlr Map API讀取下來後的原始資料設計的Data Structure
      經處理後將變成RestaurantInput
*/ 
enum RestaurantStatus {
  operational,
  closedTemporarily,
  closedPermanently
}
enum PriceLevel{
  free,//0
  inexpensive,//1
  moderate,//2
  expensive,//3
  veryExpensive//4
}
class RestaurantRaw {
  const RestaurantRaw({
    /*
    TODO 實作Parser*/ 
  });
  /*
  1.位置相關
  geometry:經緯度座標
  address_components:分段地址
  adr_address:看起來是直接地址 但有亂碼(官方:ADR 微格式表示的地址。)
  formatted_address:人類可讀格式的地址
  plus_code:地理編碼（Open Location Code），可替代地址
  vicinity:精簡地址（如街道名與區域）*/
  final double latitude;//應該直接拿location的值就夠精確了(誤差1.1公分)
  final double longtitude;
  final String address;//只記錄完整地址formatted_address即可
  /*2.營業狀況時間相關
  business_status:營運狀態，OPERATIONAL（營業中）CLOSED_TEMPORARILY（暫時關閉）CLOSED_PERMANENTLY（永久關閉）。
  current_opening_hours:7 天內的營業時間
  opening_hours:一般營業時間
  secondary_opening_hours:次要營業時間（如得來速、外帶等），含特殊日子設定。
  utc_offset:數字	該地點時區與 UTC 的分鐘差，例如 +660、-480。*/
  final RestaurantStatus businessStatus;
  final List<TimePeriod> openingHours;//請參閱models/openingHours.dart紀錄opening_hours
  /*3.評論相關
  rating:
  根據使用者評論的平均評分，範圍 1.0~5.0。
  reviews:
  最多五則評論（預設按相關性排序，可設定為最新排序）。詳見 PlaceReview。
  user_ratings_total:
  數字	評論總數（含文字或無文字）。*/
  final double rating;//1-5之間的浮點數
  final List<Review> reviews;
  /*4.圖片相關
  icon:
  餐廳圖標
  photos:
  店家上傳的相關圖片
  需要api key才能看*/
  final List<String> photos;
  /*5.店家名稱描述相關
  name:
  餐廳名
  editorial_summary:
  地點的文字概述
  place_id:
  地點的globally unique id
  types:描述該地點的類型（如 restaurant、cafe 等）。*/
  final String name;
  final String summary;
  final String id;
  final Set<int> types;//紀錄models/types.dart裡的對應整數index
  /*6.連結相關
  website	選填	字串	官方網站網址（如企業首頁）。
  url:Google 提供的該地點官方網頁連結。應嵌入至應用程式中。*/
  final String url;//只記錄對應的google map連結
  /*7.電話相關
  formatted_phone_number:
  當地格式的電話號碼。
  international_phone_number:
  國際格式電話號碼*/
//暫時不使用?
  /*8.價位相關
  price_level:
  價位等級（0: 免費，1: 便宜，2: 中等，3: 貴，4: 非常貴）。*/
  final PriceLevel priceLevel;
  /*9.布林值補充資訊相關
  curbside_pickup:是否支援路邊取貨。
  delivery:是否支援外送服務。
  dine_in:是否支援內用（室內或戶外）。
  reservable:是否支援預約。
  serves_beer:是否提供啤酒。
  serves_breakfast:是否供應早餐。
  serves_brunch:是否供應早午餐。
  serves_dinner:是否供應晚餐。
  serves_lunch:是否供應午餐。
  serves_vegetarian_food:是否提供素食。
  serves_wine:是否提供葡萄酒
  takeout:是否支援外帶。
  wheelchair_accessible_entrance:是否設有無障礙出入口。*/
  final bool curbsidePickup;
  final bool delivery;
  final bool dineIn;
  final bool reservable;
  final bool servesBeer;
  final bool servesBreakfast;
  final bool servesBrunch;
  final bool servesDinner;
  final bool servesLunch;
  final bool servesVegetarianFood;
  final bool servesWine;
  final bool takeout;
  final bool wheelchairAccessibleEntrance;
}
