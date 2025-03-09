import 'package:flutter/material.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/services/posts/posts_service.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  final PostService _PostService = PostService();

  List<Post> get Posts => _posts;

  Future<void> fetchPosts() async {
    try {
      _posts = await _PostService.fetchPosts();
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao carregar Postos: $e');
    }
  }

  Future<void> addPost(Post newPost) async {
    _posts.add(newPost);
    notifyListeners();
  }
}