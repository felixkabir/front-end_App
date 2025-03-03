import 'package:flutter/material.dart';
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
                  'https://stivy-backend-ec0c.onrender.com/files/${event.user.fileKey}',
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
              'https://stivy-backend-ec0c.onrender.com/files/${event.fileKey}',
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}