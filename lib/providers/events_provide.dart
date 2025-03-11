import 'package:flutter/material.dart';
import 'package:stivy/controllers/event/event_controller.dart';
import 'package:stivy/models/event/event_model.dart';
import 'package:stivy/services/events/event.service.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  final EventService _eventService = EventService();

  List<Event> get events => _events;

  Future<void> fetchEvents() async {
    try {
      _events = await _eventService.fetchEvents();
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao carregar eventos: $e');
    }
  }
  Future<void> loadEvents() async {
     _events = await EventController().getEvents();
    notifyListeners();
  }
  
  Future<void> addEvent(Event newEvent) async {
    _events.add(newEvent);
    notifyListeners();
  }
}