import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/views/profile/profile.screen.dart';
import 'package:stivy/controllers/reaction/reaction_controller.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:provider/provider.dart';

class PostDetailsScreen extends StatefulWidget {
  final Post post;
  final String postId;
  final String? agencyId;
  final String? userId;
  final Function(Post)? onReactionUpdated; // Callback para atualizar a reação

  const PostDetailsScreen({
    required this.post,
    required this.postId,
    this.userId,
    this.agencyId,
    this.onReactionUpdated,
  });

  @override
  _PostDetailsScreenState createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final ReactionController _reactionController = ReactionController();
  bool _hasReacted = false;
  int _reactionCount = 0;
  bool _isProcessingReaction = false;

  @override
  void initState() {
    super.initState();
    _updateReactionState();
  }

  void _updateReactionState() {
    setState(() {
      _hasReacted = widget.post.hasUserReacted(widget.userId!);
      _reactionCount = widget.post.reactionCount;
    });
  }

  Future<void> _handleReaction() async {
    if (_isProcessingReaction ||
        widget.userId == null ||
        widget.userId!.isEmpty) {
      return;
    }

    setState(() {
      _isProcessingReaction = true;
    });

    try {
      if (_hasReacted) {
        await _reactionController.removeReactionToPost(
          widget.post.id,
          widget.userId!,
        );

        setState(() {
          _hasReacted = false;
          _reactionCount = _reactionCount > 0 ? _reactionCount - 1 : 0;
        });
      } else {
        final reaction = await _reactionController.reactToPost(
          userId: widget.userId!,
          postId: widget.post.id,
        );

        if (reaction != null && reaction.id.isNotEmpty) {
          setState(() {
            _hasReacted = true;
            _reactionCount += 1;
          });
        }
      }

      // Atualiza o post com a nova reação
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

  void _openFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Hero(
              tag: imageUrl,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _contactUser(BuildContext context, String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Contato sobre a publicação',
        'body': 'Olá, gostaria de entrar em contato sobre a sua publicação...',
      },
    );

    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível abrir o e-mail.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalhes da Publicação',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            // Verifique se o usuário ou a agência não são nulos antes de acessar suas propriedades
            ListTile(
              leading: CircleAvatar(
                backgroundImage: widget.post.user?.fileKey != null
                    ? NetworkImage(
                        '${ApiConfig.apiBaseUrl}/files/${widget.post.user!.fileKey}',
                      )
                    : AssetImage('assets/default_profile.png') as ImageProvider,
                child: widget.post.user?.fileKey == null
                    ? Icon(Icons.person)
                    : null,
              ),
              title: Text(
                widget.post.user?.username ??
                    widget.post.agency?.name ??
                    'Nome não disponível',
              ),
              subtitle: Text(
                widget.post.user?.email ??
                    widget.post.agency?.contact ??
                    'Contato não disponível',
              ),
              trailing: IconButton(
                icon: Icon(Icons.email, color: Colors.blue),
                onPressed: () {
                  final email =
                      widget.post.user?.email ?? widget.post.agency?.contact;
                  if (email != null) {
                    _contactUser(context, email);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Contato não disponível')),
                    );
                  }
                },
              ),
            ),
            // Post Content
            if (widget.post.content != null)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(widget.post.content!),
              ),
            // Post Images
            if (widget.post.fileEntities.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: widget.post.fileEntities.length,
                  itemBuilder: (context, index) {
                    final file = widget.post.fileEntities[index];
                    final imageUrl =
                        '${ApiConfig.apiBaseUrl}/files/${file.fileKey}';
                    return GestureDetector(
                      onTap: () => _openFullScreenImage(context, imageUrl),
                      child: Hero(
                        tag: imageUrl,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            // Post Info
            if (widget.post.type != null)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('Data: ${widget.post.createdAt}'),
              ),
            // Likes Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _hasReacted ? Icons.favorite : Icons.favorite_border,
                      color: _hasReacted ? Colors.red : Colors.grey,
                    ),
                    onPressed: _handleReaction,
                  ),
                  SizedBox(width: 8),
                  Text('$_reactionCount curtidas'),
                ],
              ),
            ),
            // Contact Button
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _contactUser(
                  context,
                  widget.post.user?.email ??
                      widget.post.agency?.contact ??
                      'Nome não disponível',
                ),
                icon: Icon(Icons.email),
                label: Text('Contactar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
