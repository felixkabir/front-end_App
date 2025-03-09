import 'package:flutter/material.dart';
import 'package:stivy/models/interest/interests_model.dart';
import 'package:stivy/services/interests/interests_service.dart';

class InterestProvider with ChangeNotifier {
  final InterestService _interestService = InterestService();
  List<Interest> _interests = [];
  Interest? _selectedInterest;

  List<Interest> get interests => _interests;
  Interest? get selectedInterest => _selectedInterest;

  Future<void> fetchInterests() async {
    try {
      _interests = await _interestService.fetchInterests();
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar interesses: $e');
    }
  }

  void selectInterest(Interest interest) {
    _selectedInterest = interest;
    notifyListeners();
  }

  void clearSelectedInterest() {
    _selectedInterest = null;
    notifyListeners();
  }
}