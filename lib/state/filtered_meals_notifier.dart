import 'package:flutter/material.dart';
import 'package:flutter_app/models/meal.dart';
import 'filters_notifier.dart'; // For Filter enum

class FilteredMealsNotifier extends ChangeNotifier {
  List<Meal> filteredMeals = [];

  void updateFilteredMeals(List<Meal> meals, Map<Filter, bool> filters) {
    filteredMeals = meals.where((meal) {
      if (filters[Filter.glutenFree]! && !meal.isGlutenFree) return false;
      if (filters[Filter.lactoseFree]! && !meal.isLactoseFree) return false;
      if (filters[Filter.vegetarian]! && !meal.isVegetarian) return false;
      if (filters[Filter.vegan]! && !meal.isVegan) return false;
      return true;
    }).toList();
    notifyListeners();
  }
}
