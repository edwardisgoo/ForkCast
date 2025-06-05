import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // 確保導入 Geolocator 的 Position 類型
import 'package:flutter_app/services/location_service.dart'; // 導入您自己定義的 LocationService

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Test App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final LocationService _locationService = LocationService(); // 實例化您的 LocationService
  String _locationMessage = '點擊按鈕獲取您的位置'; // 初始顯示文字
  double? _latitude;
  double? _longitude;

  // 獲取位置的方法
  Future<void> _fetchLocation() async {
    setState(() {
      _locationMessage = '正在獲取位置...'; // 點擊後更新文字
      _latitude = null;
      _longitude = null;
    });

    try {
      // 呼叫 LocationService 中的 getCurrentLocation()
      Position position = await _locationService.getCurrentLocation();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationMessage = '緯度: ${position.latitude}\n經度: ${position.longitude}';
      });
    } catch (e) {
      // 捕獲錯誤並顯示錯誤訊息
      setState(() {
        _locationMessage = '獲取位置失敗: ${e.toString()}';
        _latitude = null;
        _longitude = null;
      });
      // 可以在這裡顯示一個 SnackBar 或 Dialog 來提示用戶
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('錯誤: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('位置測試'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 顯示位置訊息的文字行
              Text(
                _locationMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              // 按鈕
              ElevatedButton(
                onPressed: _fetchLocation, // 按鈕點擊時呼叫 _fetchLocation 方法
                child: const Text('獲取我的位置'),
              ),
              if (_latitude != null && _longitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    '您的位置：($_latitude, $_longitude)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}