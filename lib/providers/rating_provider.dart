// lib/providers/rating_provider.dart
//
// Simple ChangeNotifier that remembers the most-recent restaurant the
// user navigated to (via right-swipe) and whether we’ve already asked
// for a rating.  Other widgets can:
//
//   • provider.setPending(id: <id>, name: <name>); // mark as waiting to be rated
//   • provider.clearPending();                     // mark as completed / skipped
//   • provider.pending        → bool               // should we show the dialog?
//   • provider.restaurantId   → String?           // null when none
//   • provider.restaurantName → String?           // null when none
//
// Add this provider at the top of the widget-tree (see main.dart).

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ★ persistence

const _kPendingKey = 'rating_pending';
const _kRestaurantKey = 'rating_restaurant';
const _kRestaurantIdKey = 'rating_restaurant_id';

class RatingProvider extends ChangeNotifier {
  RatingProvider() {
    _load(); // hydrate state on start-up
  }

  String? _restaurantId; // Google Places or internal id
  String? _restaurantName; // null → nothing needs rating
  bool _pending = false; // true → show rating dialog

  // ───────── getters ─────────
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  bool get pending => _pending;

  // ───────── public API ─────────
  /// Call this when the user swipes right (navigates to Maps).
  Future<void> setPending({required String id, required String name}) async {
    _restaurantId = id;
    _restaurantName = name;
    _pending = true;
    notifyListeners();
    await _save();
  }

  /// Call this after the user has submitted a rating *or* skipped.
  Future<void> clearPending() async {
    _restaurantId = null;
    _restaurantName = null;
    _pending = false;
    notifyListeners();
    await _save();
  }

  // ───────── persistence helpers ─────────
  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _pending = sp.getBool(_kPendingKey) ?? false;
    _restaurantName = sp.getString(_kRestaurantKey);
    _restaurantId = sp.getString(_kRestaurantIdKey);
    notifyListeners(); // update any listeners on first frame
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kPendingKey, _pending);
    if (_pending && _restaurantName != null && _restaurantId != null) {
      await sp.setString(_kRestaurantKey, _restaurantName!);
      await sp.setString(_kRestaurantIdKey, _restaurantId!);
    } else {
      await sp.remove(_kRestaurantKey);
      await sp.remove(_kRestaurantIdKey);
    }
  }
}
