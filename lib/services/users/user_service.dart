import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/user/user_model.dart';

class UserService {
  Future<User> fetchUserById(String userId) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.apiBaseUrl}/users/$userId'))
        .timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao carregar usuário');
    }
  }

  Future<List<User>> fetchUsers() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.apiBaseUrl}/users'))
        .timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
    // Decodifica o JSON para uma lista dinâmica
    List<dynamic> jsonList = json.decode(response.body);
    
    // Mapeia a lista dinâmica para uma lista de objetos User
    return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar lista de usuários');
    }
  }

  Future<User> updateUser({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      print('📡 Sending update request for user ID: $userId');
      print('📦 Request data: ${json.encode(userData)}');

      final uri = Uri.parse('${ApiConfig.apiBaseUrl}/users/update/$userId');
      print('🌐 Request URL: $uri');

      final headers = {'Content-Type': 'application/json'};
      print('📋 Request headers: $headers');

      final response =
          await http.put(uri, headers: headers, body: json.encode(userData));

      print('📥 Response status code: ${response.statusCode}');
      print('📄 Response headers: ${response.headers}');
      print('📝 Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final decodedJson = json.decode(response.body);
          print('✅ Successfully parsed JSON response');
          return User.fromJson(decodedJson);
        } catch (parseError) {
          print('❌ JSON parsing error: $parseError');
          print('❌ Failed to parse JSON from response body: ${response.body}');
          throw Exception(
              'Erro ao processar resposta do servidor: $parseError');
        }
      } else {
        print('⚠️ Server returned error status code: ${response.statusCode}');

        // Try to parse error message from response if available
        try {
          final errorJson = json.decode(response.body);
          print('⚠️ Error details from server: $errorJson');

          // Check if there's a specific message field in the error response
          if (errorJson.containsKey('message')) {
            throw Exception(
                'Falha ao atualizar usuário: ${errorJson['message']}');
          }
        } catch (errorParseError) {
          print('❌ Failed to parse error response: $errorParseError');
        }

        throw Exception(
            'Falha ao atualizar usuário. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌❌❌ EXCEPTION: $e');

      if (e is SocketException) {
        print('📶 Network error: No internet connection or server unreachable');
      } else if (e is FormatException) {
        print('🔡 Format error: Invalid data format');
      } else if (e is HttpException) {
        print('🌐 HTTP error: ${e.message}');
      } else if (e is TimeoutException) {
        print('⏱️ Timeout error: Request took too long');
      }

      print('📚 Stack trace:');
      print(StackTrace.current);

      throw Exception('Error updating user: $e');
    }
  }

  Future<void> logout(String id) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.apiBaseUrl}/auth/user/logout/$id'))
        .timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      return json
          .decode(response.body)
          .map((json) => User.fromJson(json))
          .toList();
    } else {
      throw Exception('Falha ao carregar lista de usuários');
    }
  }
}
