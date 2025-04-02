import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stivy/controllers/reaction/reaction_controller.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:stivy/views/auth/login/login_screen.dart';
import 'package:stivy/views/home/post_details_screen.dart';
import 'package:stivy/views/profile/profile.screen.dart' as profile;
import 'package:stivy/Api/ApiConfig.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final Function(Post)? onReactionUpdated;

  PostCard({required this.post, this.onReactionUpdated});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with AutomaticKeepAliveClientMixin {
  final ReactionController _reactionController = ReactionController();
  String _currentUserId = '';
  bool _hasReacted = false;
  int _reactionCount = 0;
  bool _isProcessingReaction = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _updateReactionState();
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.reactions != widget.post.reactions) {
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
    final hasReacted = widget.post.reactions.any(
      (reaction) => reaction.userId == _currentUserId && reaction.postId == widget.post.id,
    );

    setState(() {
      _hasReacted = hasReacted;
      _reactionCount = widget.post.reactions.length;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Data não disponível';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Agora mesmo';
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
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
        await _reactionController.removeReactionToPost(
          widget.post.id,
          _currentUserId,
        );

        setState(() {
          _hasReacted = false;
          _reactionCount = _reactionCount > 0 ? _reactionCount - 1 : 0;
        });
      } else {
        final reaction = await _reactionController.reactToPost(
          userId: _currentUserId,
          postId: widget.post.id,
        );

        if (reaction != null && reaction.id.isNotEmpty) {
          setState(() {
            _hasReacted = true;
            _reactionCount += 1;
          });
        }
      }

      widget.onReactionUpdated?.call(widget.post);
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    void _showOptionsMenu(BuildContext context, Post post) {
      final bool isPostOwner = _currentUserId == post.userId;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Wrap(
              children: <Widget>[
                if (isPostOwner) ...[
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Editar'),
                    onTap: () {
                      Navigator.pop(context);
                      // Implementar funcionalidade de edição
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Excluir'),
                    onTap: () {
                      Navigator.pop(context);
                      // Implementar funcionalidade de exclusão
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsScreen(
              post: widget.post,
              postId: widget.post.id,
              userId: widget.post.userId ?? '',
              agencyId: widget.post.agency?.id ?? '',
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.post.userId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => profile.ProfileScreen(id: widget.post.userId!),
                        ),
                      );
                    }
                  },
                  child: Hero(
                    tag: 'profile-${widget.post.id}', 
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: widget.post.user?.fileKey != null
                          ? NetworkImage(
                              '${ApiConfig.apiBaseUrl}/files/${widget.post.user?.fileKey ?? widget.post.agency?.fileKey ?? 'default_image_key'}',
                            )
                          : null,
                      child: widget.post.user?.fileKey == null
                          ? Icon(Icons.person)
                          : null,
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
                            widget.post.user?.username ?? widget.post.agency?.name ?? 'Usuário Desconhecido',
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
                              widget.post.type == "USER" 
                                  ? 'Modelo'
                                  : widget.post.type == "AGENCY"
                                      ? 'Agência'
                                      : 'Desconhecido',
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
                        _formatDate(widget.post.createdAt),
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
                    _showOptionsMenu(context, widget.post);
                  },
                ),
              ],
            ),
          ),
          if (widget.post.content != null && widget.post.content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.post.content!,
                style: TextStyle(fontSize: 16),
              ),
            ),
          if (widget.post.fileEntities.isNotEmpty)
            Container(
              height: 300,
              child: PageView.builder(
                itemCount: widget.post.fileEntities.length,
                itemBuilder: (context, index) {
                  final file = widget.post.fileEntities[index];
                  return Stack(
                    children: [
                      Image.network(
                        '${ApiConfig.apiBaseUrl}/files/${file.fileKey}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}/${widget.post.fileEntities.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
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