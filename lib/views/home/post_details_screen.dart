import 'package:flutter/material.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/views/profile/profile.screen.dart';

class PostDetailsScreen extends StatelessWidget {
  final Post post;

  const PostDetailsScreen({required this.post});

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
          'Detalhes do Post',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  '${ApiConfig.apiBaseUrl}/files/${post.agencyId}',
                ),
              ),
              title: Text(post.type),
              subtitle: Text(post.type),
            ),
            // Post Content
            if (post.content != null)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(post.content!),
              ),
            // Post Images
            if (post.fileEntities.isNotEmpty)
              SizedBox(
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
            // Event Info
            if (post.type != null)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('Evento: ${post.createdAt}'),
              ),
            // Likes Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red),
                  SizedBox(width: 8),
                  Text('${post.agencyId} curtidas'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}