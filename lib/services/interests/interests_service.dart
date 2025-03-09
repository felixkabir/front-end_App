import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/interest/interests_model.dart';

class InterestService {

  Future<List<Interest>> fetchInterests() async {
    final response = await http.get(Uri.parse('${ApiConfig.apiBaseUrl}/interests'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Interest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load interests');
    }
  }
}