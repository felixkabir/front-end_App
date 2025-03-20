import 'dart:convert';

import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/services/events/event.service.dart';
import 'package:stivy/models/event/event_model.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/models/user/user_model.dart';
import 'package:stivy/services/posts/posts_service.dart';
import 'package:http/http.dart' as http;
import 'package:stivy/services/users/user_service.dart';

class SearchAllController {
  final EventService _eventService = EventService();
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  Future<List<Event>> getEvents() async {
    return await _eventService.fetchEvents();
  }

  Future<List<Post>> getPosts() async {
    return await _postService.fetchPosts();
  }

  Future<List<User>> getUsers() async {
    return await _userService.fetchUsers();
  }

  Future<List<dynamic>> getModels() async {
    final response = await http.get(Uri.parse('${ApiConfig.apiBaseUrl}/models'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar modelos');
    }
  }
}