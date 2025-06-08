import 'package:flutter/foundation.dart'; // 必須引入這行才能使用 ChangeNotifier
import 'package:flutter_app/models/restaurant_output.dart';

class FetchedResults extends ChangeNotifier {
  List<RestaurantOutput> _fetchedResults = [];

  // Getter：讓外部可以讀取 fetchedResults
  List<RestaurantOutput> get fetchedResults => _fetchedResults;

  // Setter：設定新的資料並通知監聽者
  void setFetchedResults(List<RestaurantOutput> results) {
    _fetchedResults = results;
    notifyListeners();
  }

  // 若你想新增單筆資料，也可以提供這樣的函數
  void addResult(RestaurantOutput result) {
    _fetchedResults.add(result);
    notifyListeners();
  }

  // 若需要清空資料
  void clearResults() {
    _fetchedResults.clear();
    notifyListeners();
  }
}
