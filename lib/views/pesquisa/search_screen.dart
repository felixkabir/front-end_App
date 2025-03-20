import 'package:flutter/material.dart';
import 'package:stivy/controllers/search/search_controller.dart';
import 'package:stivy/models/event/event_model.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/models/user/user_model.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchAllController _searchAllControllerApi = SearchAllController();
  String _searchQuery = '';
  String _selectedCategory = 'Tudo';
  List<String> _selectedFilters = [];
  List<dynamic> _searchResults = [];

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Carregar dados da API
  Future<void> _loadData() async {
    try {
      final events = await _searchAllControllerApi.getEvents();
      final posts = await _searchAllControllerApi.getPosts();
      final users = await _searchAllControllerApi.getUsers();
      final models = await _searchAllControllerApi.getModels();

      setState(() {
        _searchResults = [
          ...events.map((e) => {'type': 'Evento', 'data': e}),
          ...posts.map((p) => {'type': 'Publicação', 'data': p}),
          ...users.map((u) => {'type': 'Usuário', 'data': u}),
          ...models.map((m) => {'type': 'Modelo', 'data': m}),
        ];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
  }

  // Filtra os resultados com base na consulta, categoria e filtros
  List<dynamic> get _filteredResults {
  return _searchResults.where((result) {
    final data = result['data'];
    final type = result['type'];

    // Verifica se o resultado corresponde à consulta de pesquisa
    final matchesQuery = (data['name'] ?? data['username'] ?? '')
        .toString()
        .toLowerCase()
        .contains(_searchQuery.toLowerCase());

    // Verifica se o resultado corresponde à categoria selecionada
    final matchesCategory = _selectedCategory == 'Tudo' ||
        type == _selectedCategory;

    // Verifica se o resultado corresponde aos filtros inteligentes
    final matchesFilters = _selectedFilters.isEmpty ||
        (data['filter'] != null && _selectedFilters.contains(data['filter']));

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

          // Botão de filtros inteligentes
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _openFilterBottomSheet,
              child: Text('Filtros Inteligentes'),
            ),
          ),

          // Resultados da pesquisa
          Expanded(
            child: ListView.builder(
              itemCount: _filteredResults.length,
              itemBuilder: (context, index) {
                final result = _filteredResults[index];
                final data = result['data'];
                final type = result['type'];

                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        data['file_url'] ?? 'https://via.placeholder.com/150',
                      ),
                    ),
                    title: Text(data['name'] ?? 'Sem nome'),
                    subtitle: Text(type),
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
    final data = result['data'];
    final type = result['type'];

    switch (type) {
      case 'Evento':
        // Navegar para a tela de detalhes do evento
        break;
      case 'Publicação':
        // Navegar para a tela de detalhes da publicação
        break;
      case 'Usuário':
        // Navegar para a tela de perfil do usuário
        break;
      case 'Modelo':
        // Navegar para a tela de perfil do modelo
        break;
    }
  }
}