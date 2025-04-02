import 'package:flutter/material.dart';
import 'package:stivy/models/interest/interests_model.dart';
import 'package:stivy/services/interests/interests_service.dart';

class InterestProvider with ChangeNotifier {
  final InterestService _interestService;
  List<Interest> _interests = [];
  List<Interest> _selectedInterests = [];

  InterestProvider(this._interestService);

  List<Interest> get interests => _interests;
  List<Interest> get selectedInterests => _selectedInterests;

  Future<void> fetchInterests() async {
    try {
      final List<Interest> fetchedInterests = await _interestService.fetchInterests();
      _interests = List<Interest>.from(fetchedInterests);

      if (_interests.isEmpty) {
        _interests = [
          Interest(
            id: '1',
            name: 'Moda',
            interestType: 'FASHION',
            createdAt: "2013-01-01",
            users: null,
          ),
          Interest(
            id: '2',
            name: 'Fotografia',
            interestType: 'PHOTOGRAPHY',
            createdAt: "2013-01-01",
            users: null,
          ),
          Interest(
            id: '3',
            name: 'Modelagem',
            interestType: 'MODELING',
            createdAt: "2013-01-01",
            users: null,
          ),
          Interest(
            id: '4',
            name: 'Design',
            interestType: 'DESIGN',
            createdAt: "2013-01-01",
            users: null,
          ),
        ];
      }
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar interesses: $e');
    }
  }

  void addSelectedInterest(Interest interest) {
    if (!_selectedInterests.contains(interest)) {
      _selectedInterests.add(interest);
      notifyListeners();
    }
  }

  void removeSelectedInterest(Interest interest) {
    _selectedInterests.remove(interest);
    notifyListeners();
  }

  void toggleInterestSelection(Interest interest) {
    if (_selectedInterests.contains(interest)) {
      removeSelectedInterest(interest);
    } else {
      addSelectedInterest(interest);
    }
  }

  void clearSelectedInterests() {
    _selectedInterests.clear();
    notifyListeners();
  }

  bool isSelected(Interest interest) {
    return _selectedInterests.contains(interest);
  }
}