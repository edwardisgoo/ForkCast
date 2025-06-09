import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/restaurant_output.dart';

/// Holds the restaurant the user most recently selected (via right swipe).
/// Unlike [RatingProvider], this provider is not persisted because the
/// information is only needed while the app is running.
class SelectedRestaurantProvider extends ChangeNotifier {
  RestaurantOutput? _restaurant;

  RestaurantOutput? get restaurant => _restaurant;

  void setRestaurant(RestaurantOutput restaurant) {
    _restaurant = restaurant;
    notifyListeners();
  }

  void clear() {
    _restaurant = null;
    notifyListeners();
  }
}
