import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stivy/models/agency/agency_model.dart';

class ApiService {
  static const String apiBaseUrl = 'https://stivy-backend-an2z.onrender.com';
  
  static Future<List<AgencyModel>> fetchAgencies() async {
    final response = await http.get(Uri.parse('https://srv706707.hstgr.cloud/api/v1/agencies'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);  
      return data.map((json) => AgencyModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load agencies');
    }
  }

  static Future<void> createAgency({
    required String userId,
    required String name,
    required String contact,
    required String imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/agency/create/$userId'), 
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'name': name,
        'contact': contact,
        'file_url': imageUrl,
      }),
    );

    if (response.statusCode == 200) {
      // Sucesso
      print('Agência cadastrada com sucesso!');
    } else {
      // Erro
      throw Exception('Falha ao cadastrar agência');
    }
  }
}