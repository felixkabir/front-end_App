import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/agency/agency_model.dart';

class AgencyService {
  Future<Agency> fetchAgencyById(String agencyId) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.apiBaseUrl}/agency/$agencyId'))
        .timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      return Agency.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao carregar agência');
    }
  }

  Future<List<Agency>> fetchAllAgencies() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.apiBaseUrl}/agency'))
        .timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Agency.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar agências');
    }
  }

  Future<http.Response> addModel(
      Map<String, dynamic> modelData, String agencyId,
      {String userId = '0'}) async {
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

  Future<Agency> updateAgency({
    required String agencyId,
    required Map<String, dynamic> agencyData,
  }) async {
    try {
      print('📡 Sending update request for user ID: $agencyId');
      print('📦 Request data: ${json.encode(agencyData)}');

      final uri = Uri.parse('${ApiConfig.apiBaseUrl}/agency/update/$agencyId');
      print('🌐 Request URL: $uri');

      final headers = {'Content-Type': 'application/json'};
      print('📋 Request headers: $headers');

      final response =
          await http.put(uri, headers: headers, body: json.encode(agencyData));

      print('📥 Response status code: ${response.statusCode}');
      print('📄 Response headers: ${response.headers}');
      print('📝 Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final decodedJson = json.decode(response.body);
          print('✅ Successfully parsed JSON response');
          return Agency.fromJson(decodedJson);
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

  Future<void> updateModel(String id, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.apiBaseUrl}/models/update/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        print('Modelo atualizado com sucesso!');
      } else {
        throw Exception('Erro ao atualizar o modelo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar o modelo: $e');
    }
  }

  Future<void> deleteModel(String id, String agencyId, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.apiBaseUrl}/models/delete/$agencyId/$userId/$id'),
      );

      if (response.statusCode == 200) {
        print('Modelo excluído com sucesso!');
      } else {
        throw Exception('Erro ao excluir o modelo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao excluir o modelo: $e');
    }
  }
}
