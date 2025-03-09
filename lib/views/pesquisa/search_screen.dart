import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tudo'; // Categoria selecionada
  List<String> _selectedFilters = []; // Filtros selecionados no Bottom Sheet

  // Lista de categorias para filtro
  final List<String> _categories = [
    'Tudo',
    'Agências',
    'Modelos',
    'Serviços',
    'Eventos',
    'Publicações',
  ];

  // Filtros inteligentes
  final List<Map<String, String>> _smartFilters = [
    {'label': 'Amante de Moda', 'value': 'fashion_lover'},
    {'label': 'Modelo Freelancer', 'value': 'model'},
    {'label': 'Fotógrafo Freelancer', 'value': 'photographer'},
    {'label': 'Designer de Moda', 'value': 'designer'},
    {'label': 'Agência', 'value': 'agency'},
  ];

  // Dados de exemplo para resultados de pesquisa
  final List<Map<String, dynamic>> _searchResults = [
    {
      'type': 'Agência',
      'name': 'Fashion Agency Pro',
      'image': 'https://i.pravatar.cc/150?img=1',
      'filter': 'agency',
    },
    {
      'type': 'Modelo',
      'name': 'Isabella Model',
      'image': 'https://i.pravatar.cc/150?img=2',
      'filter': 'model',
    },
    {
      'type': 'Serviço',
      'name': 'Fotógrafo Profissional',
      'image': 'https://i.pravatar.cc/150?img=3',
      'filter': 'photographer',
    },
    {
      'type': 'Evento',
      'name': 'Fashion Week 2024',
      'image': 'https://i.pravatar.cc/150?img=4',
      'filter': 'fashion_lover',
    },
    {
      'type': 'Publicação',
      'name': 'Novo Look Verão 2024',
      'image': 'https://i.pravatar.cc/150?img=5',
      'filter': 'designer',
    },
  ];

  // Filtra os resultados com base na consulta, categoria e filtros inteligentes
  List<Map<String, dynamic>> get _filteredResults {
    return _searchResults.where((result) {
      final matchesQuery = result['name']
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Tudo' ||
          result['type'] == _selectedCategory;
      final matchesFilters = _selectedFilters.isEmpty ||
          _selectedFilters.contains(result['filter']);
      return matchesQuery && matchesCategory && matchesFilters;
    }).toList();
  }

  // Abre o Bottom Sheet com filtros inteligentes
  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrar por:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  ..._smartFilters.map((filter) {
                    return CheckboxListTile(
                      title: Text(filter['label']!),
                      value: _selectedFilters.contains(filter['value']),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedFilters.add(filter['value']!);
                          } else {
                            _selectedFilters.remove(filter['value']!);
                          }
                        });
                      },
                    );
                  }).toList(),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {}); // Atualiza a interface
                      },
                      child: Text('Aplicar Filtros'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Campo de pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filtros de categoria
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Resultados da pesquisa
          Expanded(
            child: ListView.builder(
              itemCount: _filteredResults.length,
              itemBuilder: (context, index) {
                final result = _filteredResults[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(result['image']),
                    ),
                    title: Text(result['name']),
                    subtitle: Text(result['type']),
                    onTap: () {
                      _navigateToResultDetails(result);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Navega para a tela de detalhes do resultado
  void _navigateToResultDetails(Map<String, dynamic> result) {
    switch (result['type']) {
      case 'Agência':
        // Navegar para a tela de perfil da agência
        break;
      case 'Modelo':
        // Navegar para a tela de perfil do modelo
        break;
      case 'Serviço':
        // Navegar para a tela de detalhes do serviço
        break;
      case 'Evento':
        // Navegar para a tela de detalhes do evento
        break;
      case 'Publicação':
        // Navegar para a tela de detalhes da publicação
        break;
    }
  }
}