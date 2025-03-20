import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stivy/controllers/reaction/reaction_controller.dart';
import 'package:stivy/models/event/event_model.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:stivy/views/auth/login/login_screen.dart';
import 'package:stivy/views/profile/profile.screen.dart' as profile;
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/views/home/event_details_screen.dart';

class EventCard extends StatefulWidget {
  final Event event;

  const EventCard({
    Key? key,
    required this.event,
  });

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final ReactionController _reactionController = ReactionController();
  String _currentUserId = '';
  bool _hasReacted = false;
  int _reactionCount = 0;
  bool _isProcessingReaction = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _updateReactionState();
  }

  @override
  void didUpdateWidget(EventCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.reactions != widget.event.reactions) {
      _updateReactionState();
    }
  }

  Future<void> _getCurrentUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user != null) {
      setState(() {
        _currentUserId = user.id;
        _updateReactionState();
      });
    }
  }

  void _updateReactionState() {
    final hasReacted = widget.event.reactions.any(
      (reaction) =>
          reaction.userId == _currentUserId &&
          reaction.eventId == widget.event.id,
    );

    setState(() {
      _hasReacted = hasReacted;
      _reactionCount = widget.event.reactions.length;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Data não disponível';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 10) {
      return 'Agora mesmo';
    } else if (difference.inSeconds > 10 && difference.inSeconds < 60) {
      return '${difference.inSeconds}s atrás';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return '$months mês${months > 1 ? 'es' : ''} atrás';
    } else {
      final years = difference.inDays ~/ 365;
      return '$years ano${years > 1 ? 's' : ''} atrás';
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login necessário'),
          content: Text('Você precisa estar logado para reagir a este post.'),
          actions: <Widget>[
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Fazer Login'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleReaction() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.isLoggedIn;

    if (!isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }
    if (_isProcessingReaction || _currentUserId.isEmpty) return;

    setState(() {
      _isProcessingReaction = true;
    });

    try {
      if (_hasReacted) {
        await _reactionController.removeReactionToEvent(
          widget.event.id,
          _currentUserId,
        );

        setState(() {
          _hasReacted = false;
          _reactionCount = _reactionCount > 0 ? _reactionCount - 1 : 0;
        });
      } else {
        final reaction = await _reactionController.reactToEvent(
          userId: _currentUserId,
          eventId: widget.event.id,
        );

        if (reaction != null && reaction.id.isNotEmpty) {
          setState(() {
            _hasReacted = true;
            _reactionCount += 1;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao reagir: $e')),
      );
    } finally {
      setState(() {
        _isProcessingReaction = false;
      });
    }
  }

  void _showOptionsMenu(BuildContext context, Event event) {
    final bool isEventOwner = _currentUserId == event.userId;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              if (isEventOwner) ...[
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
              ] else ...[
                ListTile(
                  leading: Icon(Icons.report),
                  title: Text('Reportar'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implementar funcionalidade de reportar
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
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
                        '${ApiConfig.apiBaseUrl}/files/${widget.event.user?.fileKey ?? widget.event.agency?.fileKey ?? 'default_image_key'}',
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
                              widget.event.user?.username ??
                                  widget.event.agency?.name ??
                                  'Nome não disponível',
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
                          _formatDate(widget.event.createdAt),
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
                      _showOptionsMenu(context, widget.event);
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
                    icon: _hasReacted ? Icons.favorite : Icons.favorite_border,
                    color: _hasReacted ? Colors.red : Colors.grey[700],
                    count: _reactionCount,
                    isProcessing: _isProcessingReaction,
                    onTap: _handleReaction,
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    required bool isProcessing,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          isProcessing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _hasReacted ? Colors.red : Colors.grey,
                    ),
                  ),
                )
              : Icon(icon, size: 20, color: color),
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
