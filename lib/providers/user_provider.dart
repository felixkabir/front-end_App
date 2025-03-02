import 'package:flutter/material.dart';
import 'package:stivy/controllers/storage_controller.dart';
import 'package:stivy/models/users/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _hasSeenOnboarding = false;
  final StorageController _storageController = StorageController();

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  UserProvider() {
    _loadUserFromStorage();
    _loadOnboardingStatus();
  }

  Future<void> _loadUserFromStorage() async {
    final userData = await _storageController.getStorage('auth');
    if (userData != null && userData is Map<String, dynamic>) {
      _user = User.fromJson(userData); 
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

  Future<void> setHasSeenOnboarding(bool value) async {
    _hasSeenOnboarding = value;
    await _storageController.addStorage('hasSeenOnboarding', value);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    await _storageController.remove('auth'); // Remove os dados do usuário
    notifyListeners();
  }
}