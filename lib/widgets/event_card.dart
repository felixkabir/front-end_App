import 'package:flutter/material.dart';
import 'package:stivy/controllers/reaction/reaction_controller.dart';
import 'package:stivy/models/event/event_model.dart';
import 'package:stivy/views/profile/profile.screen.dart' as profile;
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/views/home/event_details_screen.dart';

class EventCard extends StatefulWidget {
  final Event event;

  const EventCard({required this.event});

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final ReactionController _reactionController = ReactionController();
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
  }

  void _handleLike() async {
    try {
      if (_isLiked) {
        // Remove a reação (deslike)
        await _reactionController.removeReaction(widget.event.id);
        setState(() {
          _isLiked = false;
          _likeCount--;
        });
      } else {
        // Adiciona a reação (like)
        await _reactionController.reactToEvent(
          userId: widget.event.userId!,
          eventId: widget.event.id,
        );
        setState(() {
          _isLiked = true;
          _likeCount++;
        });
      }
    } catch (e) {
      // Mostre uma mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao reagir: ${e.toString()}')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(
            event: widget.event,
            eventId: widget.event.id,
            userId: widget.event.userId ?? 'default_user_id',
          ),
        ),
      );
    },
    child: Container(
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
                        builder: (context) => profile.ProfileScreen(
                          id: widget.event.userId ?? 'default_user_id',
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                      '${ApiConfig.apiBaseUrl}/files/${widget.event.user?.fileKey ?? 'default_image_key'}',
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
                            widget.event.user?.username ?? widget.event.agency?.name ?? 'Nome não disponível',
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
                        widget.event.createdAt?.toString() ?? 'Data não disponível',
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
                    // Mostrar menu de opções
                  },
                ),
              ],
            ),
          ),
          if (widget.event.name != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Nome do Evento: ${widget.event.name}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          if (widget.event.location != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Local: ${widget.event.location}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          if (widget.event.fileKey != null)
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: Image.network(
                '${ApiConfig.apiBaseUrl}/files/${widget.event.fileKey}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text('Erro ao carregar a imagem'),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildReactionButton(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  count: _likeCount,
                  onTap: _handleLike,
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
          Icon(icon, size: 20, color: _isLiked ? Colors.red : Colors.grey[700]),
          SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: _isLiked ? Colors.red : Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
