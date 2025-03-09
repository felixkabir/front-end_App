import 'package:flutter/material.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/event/event_model.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Evento'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  '${ApiConfig.apiBaseUrl}/files/${event.user.fileKey}',
                ),
              ),
              title: Text(event.user.username),
              subtitle: Text('Evento: ${event.name}'),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('Data: ${event.startDate} - ${event.endDate}'),
            ),
            Image.network(
              '${ApiConfig.apiBaseUrl}/files/${event.fileKey}',
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}