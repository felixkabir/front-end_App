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

  Future<List<Event>> fetchEventsByUserId(String id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.apiBaseUrl}/events/user/all/$id')).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((event) => Event.fromJson(event)).toList();
      } else {
        throw Exception('Falha ao carregar Events do usuário: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar Events do usuário: $e');
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
      'POST', // Corrigido para 'POST' (o método HTTP deve ser em maiúsculas)
      Uri.parse('${ApiConfig.apiBaseUrl}/events/create/$entityId'),
    );

    // Função para formatar datas no formato ISO 8601
    String formatDate(DateTime date) {
      return "${date.toIso8601String()}Z";
    }

    // Adiciona os campos ao corpo da requisição
    request.fields['name'] = name;
    request.fields['location'] = location;
    request.fields['entity_type'] = entityType;
    request.fields['start_date'] = formatDate(startDate);
    request.fields['end_date'] = formatDate(endDate);

    // Adiciona o arquivo à requisição
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // Nome do campo do arquivo
        file.path, // Caminho do arquivo
      ),
    );

    // Exibe os detalhes da requisição antes de enviar
    print('Detalhes da Requisição:');
    print('URL: ${request.url}');
    print('Método: ${request.method}');
    print('Cabeçalhos: ${request.headers}');
    print('Campos: ${request.fields}');
    print('Arquivos: ${request.files.map((file) => file.field + ": " + file.filename!).toList()}');

    // Envia a requisição
    var response = await request.send().timeout(Duration(seconds: 30));

    // Captura o corpo da resposta
    var responseBody = await response.stream.bytesToString();

    // Exibe o status da resposta e o corpo
    print('Status da Resposta: ${response.statusCode}');
    print('Corpo da Resposta: $responseBody');

    // Verifica o status da resposta
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