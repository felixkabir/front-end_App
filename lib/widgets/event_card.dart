import 'package:flutter/material.dart';
import 'package:stivy/models/event/event_model.dart';
import 'package:stivy/views/profile/profile.screen.dart' as profile;
import 'package:stivy/Api/ApiConfig.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    void _showOptionsMenu(BuildContext context, Event event) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Editar'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Excluir'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 4),
          bottom: BorderSide(color: Colors.grey[300]!, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => profile.ProfileScreen(id: event.userId),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                      '${ApiConfig.apiBaseUrl}/files/${event.user.fileKey}',
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            event.user.username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Evento',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Criado em: ${event.createdAt.toString()}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    _showOptionsMenu(context, event);
                  },
                ),
              ],
            ),
          ),

          if (event.name != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Nome do Evento: ${event.name}',
                style: TextStyle(fontSize: 16),
              ),
            ),

          if (event.location != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Local: ${event.location}',
                style: TextStyle(fontSize: 16),
              ),
            ),

          if (event.fileKey != null)
            Container(
              height: 200,
              child: Image.network(
                '${ApiConfig.apiBaseUrl}/files/${event.fileKey}',
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildReactionButton(
                  icon: Icons.favorite_border,
                  count: 1,
                  onTap: () {},
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.person_add_outlined),
                  label: Text('Contactar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}