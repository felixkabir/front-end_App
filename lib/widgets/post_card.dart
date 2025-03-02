import 'package:flutter/material.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/views/profile/profile.screen.dart' as profile;

import 'package:flutter/material.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/views/profile/profile.screen.dart' as profile;

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({required this.post});

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
                  title: Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
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
                        builder: (context) => profile.ProfileScreen(userId: post.userName),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(post.userImage),
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
                            post.userName,
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
                              post.userType,
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
                        post.timeAgo,
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

          if (post.eventDate.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: post.isPastEvent ? Colors.grey[100] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      post.isPastEvent ? Icons.event_available : Icons.event,
                      color: post.isPastEvent ? Colors.grey[700] : Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.isPastEvent ? 'Evento Passado' : 'Evento Futuro',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: post.isPastEvent ? Colors.grey[700] : Colors.blue,
                          ),
                        ),
                        Text(
                          '${post.eventDate} - ${post.location}',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Content
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                post.content,
                style: TextStyle(fontSize: 16),
              ),
            ),

          // Images
          if (post.images.isNotEmpty)
            Container(
              height: 300,
              child: PageView.builder(
                itemCount: post.images.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    post.images[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

          // Reactions Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildReactionButton(
                  icon: Icons.favorite_border,
                  count: post.likes,
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