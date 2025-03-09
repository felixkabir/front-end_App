import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/agency/agency_model.dart';

class AgencyService {

  Future<Agency> fetchAgencyById(String agencyId) async {
    final response = await http.get(Uri.parse('${ApiConfig.apiBaseUrl}/agency/$agencyId')).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      return Agency.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao carregar agência');
    }
  }
  
  Future<List<Agency>> fetchAllAgencies() async {
    final response = await http.get(Uri.parse('${ApiConfig.apiBaseUrl}/agency')).timeout(Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);  
      return data.map((json) => Agency.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar agências');
    
    }
    }
}