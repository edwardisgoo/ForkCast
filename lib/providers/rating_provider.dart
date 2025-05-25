// lib/providers/rating_provider.dart
//
// Simple ChangeNotifier that remembers the most-recent restaurant the
// user navigated to (via right-swipe) and whether we’ve already asked
// for a rating.  Other widgets can:
//
//   • provider.setPending(<restaurant name>);   // mark as waiting to be rated
//   • provider.clearPending();                  // mark as completed / skipped
//   • provider.pending        → bool            // should we show the dialog?
//   • provider.restaurantName → String?        // null when none
//
// Add this provider at the top of the widget-tree (see main.dart).

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ★ persistence

const _kPendingKey = 'rating_pending';
const _kRestaurantKey = 'rating_restaurant';

class RatingProvider extends ChangeNotifier {
  RatingProvider() {
    _load(); // hydrate state on start-up
  }

  String? _restaurantName; // null → nothing needs rating
  bool _pending = false; // true → show rating dialog

  // ───────── getters ─────────
  String? get restaurantName => _restaurantName;
  bool get pending => _pending;

  // ───────── public API ─────────
  /// Call this when the user swipes right (navigates to Maps).
  Future<void> setPending(String name) async {
    _restaurantName = name;
    _pending = true;
    notifyListeners();
    await _save();
  }

  /// Call this after the user has submitted a rating *or* skipped.
  Future<void> clearPending() async {
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
    notifyListeners(); // update any listeners on first frame
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kPendingKey, _pending);
    if (_pending && _restaurantName != null) {
      await sp.setString(_kRestaurantKey, _restaurantName!);
    } else {
      await sp.remove(_kRestaurantKey);
    }
  }
}
