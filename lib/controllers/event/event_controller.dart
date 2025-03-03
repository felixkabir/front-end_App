import 'dart:io';
import 'package:stivy/services/events/event.service.dart';
import 'package:stivy/models/event/event_model.dart';

class EventController {
  final EventService _eventService = EventService();

  Future<List<Event>> getEvents() async {
    return await _eventService.fetchEvents();
  }


  Future<void> createEvent({
    required String name,
    required File file,
    required DateTime startDate,
    required DateTime endDate,
    required String entityId,
    required String entityType,
    required String location,
  }) async {
    await _eventService.createEvent(
      name: name,
      file: file,
      startDate: startDate,
      endDate: endDate,
      entityId: entityId,
      entityType: entityType,
      location: location,
    );
  }  
}