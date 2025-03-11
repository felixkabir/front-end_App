import 'dart:io';

import 'package:stivy/services/posts/posts_service.dart';
import 'package:stivy/models/post/post.dart';

class PostController {
  final PostService _postService = PostService();

  Future<List<Post>> getPosts() async {
    return await _postService.fetchPosts();
  }
  
  Future<void> createPost({
    required String content,
    required List<File> files,
    required String entityId,
    required String entityType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _postService.createPost(
      content: content,
      files: files,
      entityId: entityId,
      entityType: entityType,
    );


  }

}