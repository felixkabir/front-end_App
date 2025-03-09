import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/user/user_model.dart';

class UserService {

  Future<User> fetchUserById(String userId) async {
    final response = await http.get(Uri.parse('${ApiConfig.apiBaseUrl}/$userId')).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao carregar usuário');
    }
  }
  
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('${ApiConfig.apiBaseUrl}/users')).timeout(Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      return json.decode(response.body).map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar lista de usuários');
    }
  }  

  Future<void> logout(String id) async {
    final response = await http.get(Uri.parse('${ApiConfig.apiBaseUrl}/auth/user/logout/$id')).timeout(Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      return json.decode(response.body).map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar lista de usuários');
    }

  }

}