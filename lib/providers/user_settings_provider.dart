import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/query.dart';
import 'package:flutter_app/models/userSetting.dart';

class UserSettingsProvider extends ChangeNotifier {
  Query _currentQuery;
  UserSetting _currentUserSetting;

  // Initialize with default values or load from storage in a real app
  UserSettingsProvider()
      : _currentQuery = Query(
          minPrice: 0,
          maxPrice: 500, // Default max price
          minDistance: 0,
          maxDistance: 2000, // Default max distance in meters
          requirement: "",
          note: "",
        ),
        _currentUserSetting = UserSetting(
          sortedPreference: ["價格", "距離", "評價"], // Default preferences
        );

  // Getters for Query fields
  int get minPrice => _currentQuery.minPrice;
  int get maxPrice => _currentQuery.maxPrice;
  double get minDistance => _currentQuery.minDistance;
  double get maxDistance => _currentQuery.maxDistance;
  String get requirement => _currentQuery.requirement;
  String get note => _currentQuery.note;

  // Getters for UserSetting fields
  List<String> get sortedPreference => _currentUserSetting.sortedPreference;

  // Get the full Query object
  Query get currentQuery => _currentQuery;
  // Get the full UserSetting object
  UserSetting get currentUserSetting => _currentUserSetting;


  // Updaters for Query fields
  void updateMinPrice(int value) {
    _currentQuery = _currentQuery.copyWith(minPrice: value);
    notifyListeners();
  }

  void updateMaxPrice(int value) {
    _currentQuery = _currentQuery.copyWith(maxPrice: value);
    notifyListeners();
  }

  void updateMinDistance(double value) {
    _currentQuery = _currentQuery.copyWith(minDistance: value);
    notifyListeners();
  }

  void updateMaxDistance(double value) {
    _currentQuery = _currentQuery.copyWith(maxDistance: value);
    notifyListeners();
  }

  void updateRequirement(String value) {
    _currentQuery = _currentQuery.copyWith(requirement: value);
    notifyListeners();
  }

  void updateNote(String value) {
    _currentQuery = _currentQuery.copyWith(note: value);
    notifyListeners();
  }

  void updateQuery(Query newQuery) {
    _currentQuery = newQuery;
    notifyListeners();
  }

  // Updaters for UserSetting fields
  void updateSortedPreference(List<String> prefs) {
    _currentUserSetting = _currentUserSetting.copyWith(sortedPreference: prefs);
    notifyListeners();
  }

  void updateUserSetting(UserSetting newUserSetting) {
    _currentUserSetting = newUserSetting;
    notifyListeners();
  }
}
