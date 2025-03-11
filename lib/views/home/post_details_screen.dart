import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importe o pacote url_launcher
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/views/profile/profile.screen.dart';

class PostDetailsScreen extends StatelessWidget {
  final Post post;
  final String postId;
  final String userId;

  const PostDetailsScreen({required this.post, required this.postId, required this.userId});

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

  // Função para abrir o e-mail
  void _contactUser(BuildContext context, String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Contato sobre a publicação',
        'body': 'Olá, gostaria de entrar em contato sobre a sua publicação...',
      },
    );

    // Tenta abrir o link no navegador se não houver um aplicativo de e-mail
    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      // Abre o link em um navegador
      if (await canLaunch(emailUri.toString())) {
        await launch(emailUri.toString(), forceSafariVC: false); // forceSafariVC: false abre no navegador padrão
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir o e-mail.'),
          ),
        );
      }
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
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  '${ApiConfig.apiBaseUrl}/files/${post.user!.fileKey!}',
                ),
              ),
              title: Text(post.user!.username!),
              subtitle: Text(post.user!.email!),
              trailing: IconButton(
                icon: Icon(Icons.email, color: Colors.blue),
                onPressed: () => _contactUser(context, post.user!.email!), // Passa o context aqui
              ),
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
                    final imageUrl = '${ApiConfig.apiBaseUrl}/files/${file.fileKey}';
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
            if (post.type != null)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('Data: ${post.createdAt}'),
              ),
            // Likes Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red),
                  SizedBox(width: 8),
                  Text('${post.fileEntities.length} curtidas'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}