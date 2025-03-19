import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar as datas
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/event/event_model.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;
  final String eventId;
  final String? userId;
  final String? agencyId;
  final Function(Event)? onReactionUpdated;

  const EventDetailsScreen({
    required this.event,
    required this.eventId,
    this.userId,
    this.agencyId,
    this.onReactionUpdated,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Data não disponível';

    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return 'Evento já ocorreu';
    }

    // Calcula anos, meses, dias, horas, minutos e segundos
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;
    final days = difference.inDays % 30;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    // Constrói a string de resultado
    String result = '';
    if (years > 0) result += '$years ano${years > 1 ? 's' : ''}, ';
    if (months > 0) result += '$months mês${months > 1 ? 'es' : ''}, ';
    if (days > 0) result += '$days dia${days > 1 ? 's' : ''}, ';
    if (hours > 0) result += '$hours hora${hours > 1 ? 's' : ''}, ';
    if (minutes > 0) result += '$minutes minuto${minutes > 1 ? 's' : ''}, ';
    if (seconds > 0) result += '$seconds segundo${seconds > 1 ? 's' : ''}, ';

    // Remove a vírgula final
    if (result.endsWith(', ')) {
      result = result.substring(0, result.length - 2);
    }

    return result.isEmpty ? 'Evento ocorre agora' : 'Faltam $result';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Evento'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do evento com efeito de fade
            Hero(
              tag: 'event-image-${event.id}',
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      '${ApiConfig.apiBaseUrl}/files/${event.fileKey}',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Informações do evento
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título do evento
                  Text(
                    event.name ?? 'Evento sem nome',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Local do evento
                  if (event.location != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Datas do evento
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Botão de ação (exemplo: participar do evento)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Ação ao clicar no botão (ex: participar do evento)
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Participar do Evento'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}