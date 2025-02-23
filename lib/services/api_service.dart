import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stivy/models/agency/agency_model.dart';

class ApiService {
  static Future<List<AgencyModel>> fetchAgencies() async {
    final response = await http.get(Uri.parse('https://srv706707.hstgr.cloud/api/v1/agencies'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AgencyModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load agencies');
    }
  }
}