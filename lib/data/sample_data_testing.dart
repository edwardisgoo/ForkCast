import 'package:flutter_app/models/restaurant_raw.dart';
import 'package:flutter_app/models/openingHours.dart';
import 'package:flutter_app/models/review.dart';

/// 範例餐廳資料，用於測試或展示用
final exampleRestaurant = RestaurantRaw(
  latitude: 25.0330,
  longtitude: 121.5654,
  address: '台北市信義區信義路五段7號（台北101）',
  businessStatus: RestaurantStatus.operational,
  openingHours: [
    TimePeriod.fromStrings('0900', '1800'),
    TimePeriod.fromInts(10, 0, 20, 0),
  ],
  rating: 4.5,
  reviews: [
    Review(rating: 5, time: '1620000000', text: '食物很好吃，服務也很棒！'),
    Review(rating: 4, time: '1620500000', text: '氣氛不錯，景觀超美。'),
  ],
  photos: ['photo1.jpg', 'photo2.jpg'],
  name: '台北101景觀餐廳',
  summary: '位於台北101高樓的景觀餐廳，供應精緻料理與美景。',
  id: 'abc123',
  types: {0, 1}, // 可依照 types.dart 中的定義填寫 index
  url: 'https://maps.google.com/?cid=abc123',
  priceLevel: PriceLevel.expensive,
  curbsidePickup: true,
  delivery: true,
  dineIn: true,
  reservable: true,
  servesBeer: true,
  servesBreakfast: false,
  servesBrunch: true,
  servesDinner: true,
  servesLunch: true,
  servesVegetarianFood: true,
  servesWine: true,
  takeout: true,
  wheelchairAccessibleEntrance: true,
);
