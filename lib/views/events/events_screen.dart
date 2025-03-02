import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> events = [
    {
      "title": "Fashion Week 2024",
      "date": "15 de Março de 2024",
      "location": "Milan, Itália",
      "description": "Evento de moda internacional com desfiles de grandes marcas.",
      "image": "https://images.unsplash.com/photo-1523381294911-8d3cead13475?ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80",
      "isFeatured": true,
    },
    {
      "title": "Workshop de Fotografia",
      "date": "20 de Abril de 2024",
      "location": "São Paulo, Brasil",
      "description": "Aprenda técnicas avançadas de fotografia com profissionais renomados.",
      "image": "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80",
      "isFeatured": false,
    },
    {
      "title": "Tech Conference 2024",
      "date": "10 de Maio de 2024",
      "location": "San Francisco, EUA",
      "description": "Conferência sobre as últimas tendências em tecnologia e inovação.",
      "image": "https://images.unsplash.com/photo-1498050108023-c5249f4df085?ixlib=rb-1.2.1&auto=format&fit=crop&w=1052&q=80",
      "isFeatured": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Eventos"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Lógica para buscar eventos
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Funcionalidade de busca em desenvolvimento...")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros de categoria
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("Todos"),
                  _buildFilterChip("Moda"),
                  _buildFilterChip("Tecnologia"),
                  _buildFilterChip("Fotografia"),
                  _buildFilterChip("Arte"),
                ],
              ),
            ),
          ),
          // Lista de eventos
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return GestureDetector(
                  onTap: () {
                    // Navegar para detalhes do evento
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Abrindo detalhes do evento: ${event["title"]}")),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagem do evento
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                          child: Image.network(
                            event["image"],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Destaque (se for um evento em destaque)
                        if (event["isFeatured"])
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            margin: EdgeInsets.only(top: 8, left: 8),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Destaque",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // Informações do evento
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event["title"],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    event["date"],
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    event["location"],
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                event["description"],
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 12),
                              // Botão para mais detalhes
                              ElevatedButton(
                                onPressed: () {
                                  // Lógica para mais detalhes
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Abrindo detalhes do evento...")),
                                  );
                                },
                                child: Text("Ver Detalhes"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Botão flutuante para adicionar evento
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para adicionar evento
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Adicionar novo evento...")),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  // Widget para criar chips de filtro
  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        onSelected: (selected) {
          // Lógica para filtrar eventos por categoria
        },
        selected: label == "Todos", // Exemplo: "Todos" selecionado por padrão
        selectedColor: Colors.blueAccent,
        labelStyle: TextStyle(color: Colors.white),
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}