import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StorageController extends ChangeNotifier {
  final SharedPreferences _prefs;

  StorageController(this._prefs);

  Future<dynamic> getStorage(String key) async {
    return _prefs.get(key);
  }

 Future<void> addStorage(String key, dynamic value) async {
    final prefs = await _prefs;
    if (value is Map || value is List) {
      await prefs.setString(key, jsonEncode(value));
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }
 

  Future<dynamic> existStorage(String key) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(key);
  }

 Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> truncate_all_storage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  Future<void> removeFavorite(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
    notifyListeners();
  }
}
