import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/models/event/event_model.dart'; // Importe o modelo de evento
import 'package:stivy/models/user/user_model.dart';
import 'package:stivy/models/agency/agency_model.dart';
import 'package:stivy/services/events/event.service.dart';
import 'package:stivy/services/users/user_service.dart';
import 'package:stivy/services/agency/agency_service.dart';
import 'package:stivy/views/home/post_details_screen.dart';
import 'package:stivy/views/home/event_details_screen.dart'; // Importe a tela de detalhes do evento
import 'package:stivy/services/posts/posts_service.dart';

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
  late Future<List<Event>> _eventsFuture; // Future para carregar eventos
  final UserService _userService = UserService();
  final AgencyService _agencyService = AgencyService();
  final PostService _postService = PostService();
  final EventService _eventService = EventService(); // Serviço de eventos

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.id.isEmpty) {
      // Se o ID for inválido, defina um estado de erro
      _profileFuture = Future.error('ID do perfil inválido');
      _postsFuture = Future.error('ID do perfil inválido');
      _eventsFuture = Future.error('ID do perfil inválido');
    } else {
      _profileFuture = widget.isAgency
          ? _agencyService.fetchAgencyById(widget.id)
          : _userService.fetchUserById(widget.id);
      _postsFuture = _postService.fetchPostsByUserId(widget.id);
      _eventsFuture = _eventService.fetchEventsByUserId(widget.id); // Busca eventos do usuário
    }
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
            return Center(child: Text('Erro ao carregar perfil: ${profileSnapshot.error}'));
          } else if (!profileSnapshot.hasData || profileSnapshot.data == null) {
            return Center(child: Text('Perfil não encontrado'));
          }

          final profile = profileSnapshot.data;

          return FutureBuilder<List<Post>>(
            future: _postsFuture,
            builder: (context, postsSnapshot) {
              if (postsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (postsSnapshot.hasError) {
                return Center(child: Text('Erro ao carregar posts: ${postsSnapshot.error}'));
              }

              final posts = postsSnapshot.data ?? [];

              return FutureBuilder<List<Event>>(
                future: _eventsFuture,
                builder: (context, eventsSnapshot) {
                  if (eventsSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (eventsSnapshot.hasError) {
                    return Center(child: Text('Erro ao carregar eventos: ${eventsSnapshot.error}'));
                  }

                  final events = eventsSnapshot.data ?? [];

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
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person, size: 40); // Imagem padrão em caso de erro
                            },
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
                                  _buildProfileStat('Eventos', events.length.toString()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Posts Section
                      if (posts.isNotEmpty)
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

                      // Events Section
                      if (events.isNotEmpty)
                        SliverPadding(
                          padding: EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final event = events[index];
                                return EventCard(event: event);
                              },
                              childCount: events.length,
                            ),
                          ),
                        ),

                      // Mensagem se não houver posts ou eventos
                      if (posts.isEmpty && events.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Text('Nenhum post ou evento encontrado'),
                          ),
                        ),
                    ],
                  );
                },
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
            builder: (context) => PostDetailsScreen(post: post, postId: post.id, userId: ""),
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
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image, size: 40); // Imagem padrão em caso de erro
                  },
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

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event, eventId: event.id, userId: event.user.id,),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!, width: 4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.fileKey != null)
              Container(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  '${ApiConfig.apiBaseUrl}/files/${event.fileKey}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.event, size: 40); // Imagem padrão em caso de erro
                  },
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name ?? 'Evento sem nome',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    event.location ?? 'Local não informado',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
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