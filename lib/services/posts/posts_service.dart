import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:stivy/models/post/post.dart';
import 'package:stivy/Api/ApiConfig.dart';

class PostService {
  final String baseUrl = '${ApiConfig.apiBaseUrl}/posts';

  Future<List<Post>> fetchPosts() async {
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.get(url).timeout(Duration(seconds: 30));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((post) => Post.fromJson(post)).toList();
      } else {
        throw Exception('Falha ao carregar posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar posts: $e');
    }
  }

  Future<Post> fetchPostById(int id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.apiBaseUrl}/posts/$id')).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return Post.fromJson(data);
      } else {
        throw Exception('Falha ao carregar post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar post: $e');
    }
  }

  Future<List<Post>> fetchPostsByUserId(String id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.apiBaseUrl}/posts/user/$id')).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((post) => Post.fromJson(post)).toList();
      } else {
        throw Exception('Falha ao carregar posts do usuário: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar posts do usuário: $e');
    }
  }

  Future<void> createPost({
    required String content,
    required List<File> files,
    required String entityId,
    required String entityType,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/create/$entityId?type=$entityType'),
      );

      // Adiciona o campo de conteúdo
      request.fields['content'] = content;

      // Adiciona os arquivos
      for (var file in files) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
          ),
        );
      }

      for (var file in request.files) {
        print(' - ${file.field}: ${file.filename}');
      }

      var response = await request.send().timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        print('Post criado com sucesso!');
      } else {
        throw Exception('Falha ao criar post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar post: $e');
    }
  }
}