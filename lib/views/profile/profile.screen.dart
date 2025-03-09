import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/models/user/user_model.dart';
import 'package:stivy/models/agency/agency_model.dart';
import 'package:stivy/services/users/user_service.dart';
import 'package:stivy/services/agency/agency_service.dart';
import 'package:stivy/views/home/post_details_screen.dart';
import 'package:stivy/services/posts/posts_service.dart'; // Adicione o serviço de posts

class ProfileScreen extends StatefulWidget {
  final String id;
  final bool isAgency;

  const ProfileScreen({required this.id, this.isAgency = false});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<dynamic> _profileFuture;
  late Future<List<Post>> _postsFuture;
  final UserService _userService = UserService();
  final AgencyService _agencyService = AgencyService();
  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
    _profileFuture = widget.isAgency
        ? _agencyService.fetchAgencyById(widget.id)
        : _userService.fetchUserById(widget.id);
    _postsFuture = _postService.fetchPostsByUserId(widget.id); // Busca posts do usuário/agência
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<dynamic>(
        future: _profileFuture,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (profileSnapshot.hasError) {
            return Center(child: Text('Erro ao carregar perfil'));
          } else if (!profileSnapshot.hasData) {
            return Center(child: Text('Nenhum dado encontrado'));
          }

          final profile = profileSnapshot.data;

          return FutureBuilder<List<Post>>(
            future: _postsFuture,
            builder: (context, postsSnapshot) {
              if (postsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (postsSnapshot.hasError) {
                return Center(child: Text('Erro ao carregar posts'));
              } else if (!postsSnapshot.hasData || postsSnapshot.data!.isEmpty) {
                return Center(child: Text('Nenhum post encontrado'));
              }

              final posts = postsSnapshot.data!;

              return CustomScrollView(
                slivers: [
                  // Profile Header
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.network(
                        '${ApiConfig.apiBaseUrl}/files/${profile.fileKey}',
                        fit: BoxFit.cover,
                      ),
                    ),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Profile Info
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(
                                  '${ApiConfig.apiBaseUrl}/files/${profile.fileKey}',
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile is User ? profile.username : profile.name,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      profile is User ? 'Usuário' : 'Agência',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            profile is User
                                ? 'Email: ${profile.email}'
                                : 'Contato: ${profile.contact}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildProfileStat('Posts', posts.length.toString()),
                              _buildProfileStat('Seguidores', '10.2K'),
                              _buildProfileStat('Seguindo', '384'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Staggered Grid of Posts
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                      itemBuilder: (context, index) {
                        bool isLarge = index % 3 == 0;
                        return ProfilePostCard(
                          post: posts[index],
                          isLarge: isLarge,
                        );
                      },
                      itemCount: posts.length,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileStat(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class ProfilePostCard extends StatelessWidget {
  final Post post;
  final bool isLarge;

  const ProfilePostCard({
    required this.post,
    required this.isLarge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsScreen(post: post, postId: post.id, userId: "",),
          ),
        );
      },
      child: Container(
        height: isLarge ? 280 : 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  '${ApiConfig.apiBaseUrl}/files/${post.fileEntities[0].fileKey}',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.type == 'EVENT')
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Evento',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  SizedBox(height: 4),
                  Text(
                    post.content ?? '',
                    maxLines: isLarge ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isLarge ? 16 : 14,
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
}