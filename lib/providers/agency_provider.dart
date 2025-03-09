import 'package:flutter/material.dart';
import 'package:stivy/models/agency/agency_model.dart';

class AgencyProvider with ChangeNotifier {
  List<Agency> _agencies = [];

  List<Agency> get agencies => _agencies;

  void addAgency(Agency newAgency) {
    _agencies.add(newAgency);
    notifyListeners();
  }

  void setAgencies(List<Agency> agencies) {
    _agencies = agencies;
    notifyListeners();
  }

  
}