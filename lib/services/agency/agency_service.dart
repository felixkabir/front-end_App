import 'dart:convert';
import 'dart:io';
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
Future<http.Response> addModel(Map<String, dynamic> modelData, String agencyId, {String userId = '0'}) async {
  final url = '${ApiConfig.apiBaseUrl}/add/$agencyId';


  print('Dados a serem enviados:');
  print(jsonEncode(modelData));

  var request = http.MultipartRequest('POST', Uri.parse(url));

  modelData.forEach((key, value) {
    if (value != null) {
      request.fields[key] = value.toString();
    }
  });

  if (modelData['file'] != null && modelData['file'] is File) {
    var file = modelData['file'] as File;
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // Nome do campo no backend
        file.path,
      ),
    );
  }

  // Envia a requisição
  var response = await request.send();

  // Converte a resposta para http.Response
  var responseData = await http.Response.fromStream(response);

  // Exibe a resposta do servidor
  print('Resposta do servidor:');
  print(responseData.body);

  return responseData;
}
}