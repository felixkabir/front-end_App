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
      final response = await http
          .get(Uri.parse('${ApiConfig.apiBaseUrl}/posts/$id'))
          .timeout(Duration(seconds: 30));

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
      final response = await http
          .get(Uri.parse('${ApiConfig.apiBaseUrl}/posts/user/$id'))
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((post) => Post.fromJson(post)).toList();
      } else {
        throw Exception(
            'Falha ao carregar posts do usuário: ${response.statusCode}');
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
      // Log dos dados antes de enviar
      print('Dados antes de enviar:');
      print(' - Conteúdo: $content');
      print(' - Entity ID: $entityId');
      print(' - Entity Type: $entityType');
      print(' - Arquivos:');
      for (var file in files) {
        print('   - ${file.path}');
      }

      // Validar dados
      if (content.isEmpty) {
        throw Exception('O conteúdo do post não pode estar vazio.');
      }
      if (files.isEmpty) {
        throw Exception('Pelo menos um arquivo deve ser enviado.');
      }

      // Criar a requisição
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/create/$entityId?type=$entityType'),
      );

      // Adicionar campos
      request.fields['content'] = content;

      // Adicionar arquivos
      for (var file in files) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
          ),
        );
      }

      // Log dos arquivos que serão enviados
      print('Arquivos a serem enviados:');
      for (var file in request.files) {
        print(' - ${file.field}: ${file.filename}');
      }

      // Enviar a requisição
      var response = await request.send().timeout(Duration(seconds: 30));

      // Verificar o status da resposta
      if (response.statusCode == 200) {
        print('Post criado com sucesso!');
      } else {
        // Capturar a resposta de erro
        String responseBody = await response.stream.bytesToString();
        print('Falha ao criar post: ${response.statusCode}');
        print('Resposta do servidor: $responseBody');

        throw Exception(
            'Falha ao criar post: ${response.statusCode} - $responseBody');
      }
    } catch (e, stackTrace) {
      // Capturar e logar qualquer exceção
      print('Exceção capturada: $e');
      print('StackTrace: $stackTrace');

      // Lançar a exceção para ser tratada pelo chamador
      throw Exception('Erro ao criar post: $e');
    }
  }
}
