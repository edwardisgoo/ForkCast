import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/query.dart';

class UserSetting extends ChangeNotifier {
  List<String> sortedPreference;
  double minCost;
  double maxCost;
  double minDist;
  double maxDist;
  String requirements;
  String notes;

  UserSetting({
    List<String>? sortedPreference,
    this.minCost = 0.0,
    this.maxCost = 1000.0,
    this.minDist = 0.0,
    this.maxDist = 1000.0,
    this.requirements = '',
    this.notes = '',
  }) : sortedPreference = sortedPreference ?? [];

  // 更新 sortedPreference（覆蓋整份）
  void updatePreferences(List<String> newPreferences) {
    sortedPreference = List.from(newPreferences);
    notifyListeners();
  }

  // 新增一個偏好（如果還沒存在）
  void addPreference(String preference) {
    if (!sortedPreference.contains(preference)) {
      sortedPreference.add(preference);
      notifyListeners();
    }
  }

  // 移除特定偏好
  void removePreference(String preference) {
    sortedPreference.remove(preference);
    notifyListeners();
  }

  // 清空所有偏好
  void clearPreferences() {
    sortedPreference.clear();
    notifyListeners();
  }

  // 更新其他欄位的方法
  void updateMinCost(double value) {
    minCost = value;
    notifyListeners();
  }

  void updateMaxCost(double value) {
    maxCost = value;
    notifyListeners();
  }

  void updateMinDist(double value) {
    minDist = value;
    notifyListeners();
  }

  void updateMaxDist(double value) {
    maxDist = value;
    notifyListeners();
  }

  void updateRequirements(String value) {
    requirements = value;
    notifyListeners();
  }

  void updateNotes(String value) {
    notes = value;
    notifyListeners();
  }

  // 一次更新全部設定（若你要從表單整體儲存設定）
  void updateAll({
    List<String>? newPreferences,
    double? newMinCost,
    double? newMaxCost,
    double? newMinDist,
    double? newMaxDist,
    String? newRequirements,
    String? newNotes,
  }) {
    if (newPreferences != null) sortedPreference = List.from(newPreferences);
    if (newMinCost != null) minCost = newMinCost;
    if (newMaxCost != null) maxCost = newMaxCost;
    if (newMinDist != null) minDist = newMinDist;
    if (newMaxDist != null) maxDist = newMaxDist;
    if (newRequirements != null) requirements = newRequirements;
    if (newNotes != null) notes = newNotes;
    notifyListeners();
  }

  Query get query => Query(
        minPrice: minCost.round(),
        maxPrice: maxCost.round(),
        minDistance: minDist,
        maxDistance: maxDist,
        requirement: requirements,
        note: notes,
      );
}
