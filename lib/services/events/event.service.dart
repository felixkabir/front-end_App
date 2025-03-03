import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/event/event_model.dart';

class EventService {
  final String baseUrl = '${ApiConfig.apiBaseUrl}/events/all';

  Future<List<Event>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      print('URL da requisição de eventos: $baseUrl');
      print('Status code: ${response.statusCode}');
      print('Resposta: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((event) => Event.fromJson(event)).toList();
      } else {
        throw Exception('Falha ao carregar eventos: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar eventos: $e');
      throw Exception('Erro ao buscar eventos: $e');
    }
  }

  
  Future<void> createEvent({
    required String name,
    required String location,
    required File file,
    required DateTime startDate,
    required DateTime endDate,
    required String entityId,
    required String entityType,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/create/$entityId?type=$entityType'),
      );

      // Adiciona os campos do evento
      request.fields['name'] = name;
      request.fields['start_date'] = startDate.toIso8601String();
      request.fields['end_date'] = endDate.toIso8601String();

      // Adiciona o arquivo
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Evento criado com sucesso!');
      } else {
        throw Exception('Falha ao criar evento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar evento: $e');
    }
  }
}