import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  final List<Map<String, String>> events = [
    {
      "title": "Fashion Week 2024",
      "date": "15 de Março de 2024",
      "location": "Milan, Itália",
      "description": "Evento de moda internacional com desfiles de grandes marcas.",
    },
    {
      "title": "Workshop de Fotografia",
      "date": "20 de Abril de 2024",
      "location": "São Paulo, Brasil",
      "description": "Aprenda técnicas avançadas de fotografia com profissionais renomados.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Eventos"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Botão para adicionar evento
            ElevatedButton.icon(
              onPressed: () {
                // Lógica para adicionar evento
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Adicionar novo evento...")),
                );
              },
              icon: Icon(Icons.add),
              label: Text("Adicionar Evento"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            SizedBox(height: 20),
            // Lista de eventos
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            events[index]["title"]!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Data: ${events[index]["date"]!}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            "Local: ${events[index]["location"]!}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          SizedBox(height: 12),
                          Text(events[index]["description"]!),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}