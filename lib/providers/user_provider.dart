import 'package:flutter/material.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/controllers/storage_controller.dart';
import 'package:stivy/models/user/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _hasSeenOnboarding = false;
  final StorageController _storageController = StorageController();

  User? get user => _user;
  bool _isLoggedIn = false;
  bool get isLoggedIn => _user != null;
  bool _isGuestMode = false;

  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isGuestMode => _isGuestMode;

  UserProvider() {
    loadUserFromStorage();
    _loadOnboardingStatus();
  }


  void setGuestMode(bool isGuest) {
    _isGuestMode = isGuest;
    notifyListeners();
  }


Future<void> refreshUser() async {
  try {
    // Assuming you have a method to fetch current user data
    // final userData = await _userService.fetchCurrentUser();
    
    // Update the user in the provider
    // _user = userData;
    notifyListeners();
  } catch (e) {
    print('Error refreshing user data: $e');
  }
}
  Future<void> loadUserFromStorage() async {
    final authData = await _storageController.getStorage("auth");

    if (authData != null && authData['user'] != null && authData['access_token'] != null) {
      _user = authData['user'];
      _isLoggedIn = true;
      notifyListeners();
    } else {
      _user = null;
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<void> _loadOnboardingStatus() async {
    final hasSeenOnboarding = await _storageController.getStorage('hasSeenOnboarding');
    if (hasSeenOnboarding is bool) {
      _hasSeenOnboarding = hasSeenOnboarding;
      notifyListeners();
    }
  }

  Future<void> login(User user) async {
    _user = user;
    await _storageController.addStorage('auth', user.toJson()); // Salva no storage
    notifyListeners();
  }

  void setUser(Map<String, dynamic> userData) {
    _user = User.fromJson(userData);
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    _hasSeenOnboarding = value;
    await _storageController.addStorage('hasSeenOnboarding', value);
    notifyListeners();
  }


Future<void> logout(String userEmail) async {
  if (_user != null) {
    try {
      print("$_user");
      print("$userEmail");
      final body = jsonEncode({'email': userEmail});
      final response = await http.put(
        Uri.parse('${ApiConfig.apiBaseUrl}/auth/user/logout'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        _user = null;
        await _storageController.remove('auth');
        notifyListeners();
      } else {
        throw Exception('Failed to log out: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }
  }
}