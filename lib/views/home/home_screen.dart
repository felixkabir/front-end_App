import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stivy/models/event/event_model.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:stivy/views/auth/login/login_screen.dart';
import 'package:stivy/controllers/posts/post_controller.dart';
import 'package:stivy/controllers/event/event_controller.dart';
import 'package:stivy/widgets/custom_app_header.dart'; // Importe o CustomAppHeader
import 'package:stivy/views/post/post_form.dart';
import 'package:stivy/widgets/event_card.dart';
import 'package:stivy/widgets/post_card.dart'; // Importe a tela de criação de post

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostController _postController = PostController();
  final EventController _eventController = EventController();
  List<Post> posts = [];
  List<Event> events = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final fetchedPosts = await _postController.getPosts();
      final fetchedEvents = await _eventController.getEvents();
      setState(() {
        posts = fetchedPosts;
        events = fetchedEvents;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.isLoggedIn;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? _buildShimmerLoading()
                : hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Erro ao carregar dados.'),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        children: [
                          if (posts.isEmpty && events.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child:
                                    Text('Nenhum post ou evento encontrado.'),
                              ),
                            ),
                          if (posts.isNotEmpty)
                            Column(
                              children: posts
                                  .map((post) => PostCard(post: post))
                                  .toList(),
                            ),
                          if (events.isNotEmpty)
                            Column(
                              children: events
                                  .map((event) => EventCard(event: event))
                                  .toList(),
                            ),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
              onPressed: () {
                // Navegar para a tela de criação de publicação
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePostScreen()),
                );
              },
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Colors.blueAccent,
            )
          : null, // Se o usuário não estiver logado, não exibe o botão
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5, // Número de itens de skeleton
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: EdgeInsets.all(8),
            child: Container(
              height: 200,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
