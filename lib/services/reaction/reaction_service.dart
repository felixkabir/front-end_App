import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/reaction/reaction_model.dart';

class ReactionService {
  final String baseUrl = ApiConfig.apiBaseUrl;

  Future<ReactionModel> createReactionToPost({
    required String userId,
    String? postId,
    String? eventId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/reaction/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'postId': postId,
        'eventId': eventId,
      }),
    );

    if (response.statusCode == 200) {
      return ReactionModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create reaction');
    }
  }

  Future<ReactionModel> createReactionToEvent({
    required String userId,
    String? postId,
    String? eventId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events/reaction/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'postId': postId,
        'eventId': eventId,
      }),
    );

    if (response.statusCode == 200) {
      return ReactionModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create reaction');
    }
  }

  Future<Map<String, dynamic>> deleteReactionToPost(String userId, String postId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/reaction/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'postId': postId,
      }),
    );

    print("Response status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      // Decodifica o corpo da resposta JSON
      final responseData = jsonDecode(response.body);
      return responseData; // Retorna o JSON decodificado
    } else {
      throw Exception('Failed to delete reaction: ${response.body}');
    }
  }

  Future<void> deleteReactionToEvent(String reactionId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/event/reaction/$reactionId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete reaction');
    }
  }
}
