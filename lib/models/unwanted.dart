import 'package:flutter/foundation.dart'; // 必須引入這行才能使用 ChangeNotifier

class UnwantedList extends ChangeNotifier {
  List<String> unwantedIds;

  UnwantedList({required this.unwantedIds});

  void addToUnwanted(String placeId) {
    if (!unwantedIds.contains(placeId)) {
      unwantedIds.add(placeId);
      notifyListeners(); // <- 這樣才會被識別
    }
  }

  void removeFromUnwanted(String placeId) {
    unwantedIds.remove(placeId);
    notifyListeners();
  }

  bool isUnwanted(String placeId) {
    return unwantedIds.contains(placeId);
  }
}
