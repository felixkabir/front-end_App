import 'package:flutter/material.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/views/home/post_details_screen.dart';
import 'package:stivy/views/profile/profile.screen.dart' as profile;
import 'package:stivy/Api/ApiConfig.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({required this.post});

  // Função para formatar a data em um formato amigável
  String _formatDate(DateTime? date) {
    if (date == null) return 'Data não disponível';

    final now = DateTime.now();
    final difference = date.difference(now); // Calcula a diferença

    // Se a data já passou
    if (difference.isNegative) {
      return 'Post já ocorreu';
    }

    // Calcula anos, meses, dias, horas, minutos e segundos
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;
    final days = difference.inDays % 30;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    // Constrói a string de resultado
    String result = '';
    if (years > 0) result += '$years ano${years > 1 ? 's' : ''}, ';
    if (months > 0) result += '$months mês${months > 1 ? 'es' : ''}, ';
    if (days > 0) result += '$days dia${days > 1 ? 's' : ''}, ';
    if (hours > 0) result += '$hours hora${hours > 1 ? 's' : ''}, ';
    if (minutes > 0) result += '$minutes minuto${minutes > 1 ? 's' : ''}, ';
    if (seconds > 0) result += '$seconds segundo${seconds > 1 ? 's' : ''}, ';

    // Remove a vírgula final
    if (result.endsWith(', ')) {
      result = result.substring(0, result.length - 2);
    }

    return result.isEmpty ? 'Post ocorre agora' : 'Faltam $result';
  }

  @override
  Widget build(BuildContext context) {
    void _showOptionsMenu(BuildContext context, Post post) {
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsScreen(
              post: post,
              postId: post.id,
              userId: post.userId!, // Passar o ID do usuário
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => profile.ProfileScreen(id: post.userId!),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                      '${ApiConfig.apiBaseUrl}/files/${post.user?.fileKey}',
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
                            post.user?.username ?? '',
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
                              post.type,
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
                        '${post.createdAt}',
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
                    _showOptionsMenu(context, post);
                  },
                ),
              ],
            ),
          ),

          if (post.content != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                post.content!,
                style: TextStyle(fontSize: 16),
              ),
            ),

          if (post.fileEntities.isNotEmpty)
            Container(
              height: 300,
              child: PageView.builder(
                itemCount: post.fileEntities.length,
                itemBuilder: (context, index) {
                  final file = post.fileEntities[index];
                  return Image.network(
                    '${ApiConfig.apiBaseUrl}/files/${file.fileKey}',
                    fit: BoxFit.cover,
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