import 'package:flutter/material.dart';
/*
光齊：針對呼叫fetchRestaurant時所需Output設計的Data Structure
*/ 
class RestaurantOutput {
  const RestaurantOutput({
    required this.indexInList,
    required this.name,
    required this.reason
  });

  final int indexInList;//必須與輸入的List對應 從1開始
  final String name;// Debug用的餐廳名稱
  final String reason;// 簡短推薦原因 
}
