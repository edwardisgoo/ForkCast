import 'package:flutter/foundation.dart'; // 必須引入這行才能使用 ChangeNotifier

class UnwantedList extends ChangeNotifier {
  List<String> unwantedIds;

  UnwantedList({required this.unwantedIds});

  /// Replaces the current unwanted ids with [ids].
  ///
  /// This clears any existing ids and then populates the list with the
  /// provided values, notifying listeners afterwards. It allows other
  /// providers (for example a persistent blacklist provider) to keep the
  /// temporary unwanted list in sync.
  void replaceAll(List<String> ids) {
    unwantedIds
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }

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
