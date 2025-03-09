import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/event/event_model.dart';

class EventService {
  final String baseUrl = '${ApiConfig.apiBaseUrl}/events/all';

  Future<List<Event>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(Duration(seconds: 30));
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
        Uri.parse('${ApiConfig.apiBaseUrl}/events/create/$entityId'),
      );

      String formatDate(DateTime date) {
        return "${date.toIso8601String()}Z";
      }
      request.fields['name'] = name;
      request.fields['location'] = location;
      request.fields['entity_type'] = entityType; // Adicionando entityType se for necessário
      request.fields['start_date'] = formatDate(startDate);
      request.fields['end_date'] = formatDate(endDate);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      var response = await request.send().timeout(Duration(seconds: 30));
      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        print('Evento criado com sucesso!');
      } else {
        throw Exception('Falha ao criar evento: ${response.statusCode}, $responseBody');
      }
    } catch (e) {
      print('Erro ao criar evento: $e');
      throw Exception('Erro ao criar evento: $e');
    }
  }
}