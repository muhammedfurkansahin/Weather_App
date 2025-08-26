import 'package:flutter/services.dart';
import 'dart:convert';

class WidgetService {
  static const MethodChannel _channel = MethodChannel('favorites_widget');

  static Future<void> updateWidget(List<String> favorites) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'favorites': jsonEncode(favorites),
      });
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  static Future<void> addFavorite(String cityName) async {
    try {
      await _channel.invokeMethod('addFavorite', {
        'cityName': cityName,
      });
    } catch (e) {
      print('Error adding favorite to widget: $e');
    }
  }

  static Future<void> removeFavorite(String cityName) async {
    try {
      await _channel.invokeMethod('removeFavorite', {
        'cityName': cityName,
      });
    } catch (e) {
      print('Error removing favorite from widget: $e');
    }
  }
}