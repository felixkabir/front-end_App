import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/controllers/search/search_controller.dart';
import 'package:stivy/models/agency/agency_model.dart';
import 'package:stivy/models/event/event_model.dart';
import 'package:stivy/models/post/post.dart';
import 'package:stivy/models/user/user_model.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:stivy/views/agencia/agency_profile.dart';
import 'package:stivy/views/home/event_details_screen.dart';
import 'package:stivy/views/home/post_details_screen.dart';
import 'package:stivy/widgets/search_details.dart';
import 'package:stivy/views/profile/profile.screen.dart' as profile;

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

  Future<void> _loadData() async {
    try {
      final events = await _searchAllControllerApi.getEvents();
      final posts = await _searchAllControllerApi.getPosts();
      final users = await _searchAllControllerApi.getUsers();
      final models = await _searchAllControllerApi.getModels();
      // final agencies = await _searchAllControllerApi.getAgencies();

      setState(() {
        _searchResults = [
          // ...agencies.map((a) => {'type': 'Agência', 'data': a}),
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

  List<dynamic> get _filteredResults {
    return _searchResults.where((result) {
      final data = result['data'];
      final type = result['type'];

      // Verifica se o resultado corresponde à consulta de pesquisa
      String name = '';
      if (type == 'Evento') {
        name = (data as Event).name;
      } else if (type == 'Publicação') {
        name = (data as Post).content ?? '';
      } else if (type == 'Usuário') {
        name = (data as User).username;
      } else if (type == 'Modelo') {
        // Verifica se o data é realmente uma instância de Model
        if (data is Model) {
          name = data.name;
        } else {
          // Se não for, ignora este resultado
          return false;
        }
      } else if (type == 'Agência') {
        // Verifica se o data é realmente uma instância de Agency
        if (data is Agency) {
          name = data.name;
        } else {
          // Se não for, ignora este resultado
          return false;
        }
      }

      final matchesQuery =
          name.toLowerCase().contains(_searchQuery.toLowerCase());

      // Verifica se o resultado corresponde à categoria selecionada
      final matchesCategory = _selectedCategory == 'Tudo' ||
          (_selectedCategory == 'Eventos' && type == 'Evento') ||
          (_selectedCategory == 'Publicações' && type == 'Publicação') ||
          (_selectedCategory == 'Modelos' && type == 'Modelo') ||
          (_selectedCategory == 'Agências' && type == 'Agência') ||
          (_selectedCategory == 'Usuários' && type == 'Usuário');

      // Verifica se o resultado corresponde aos filtros inteligentes
      final matchesFilters = _selectedFilters.isEmpty ||
          (data['filter'] != null && _selectedFilters.contains(data['filter']));

      return matchesQuery && matchesCategory && matchesFilters;
    }).toList();
  } // Abre o Bottom Sheet com filtros inteligentes

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
                        // Isso vai atualizar a UI principal
                        this.setState(() {});
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

          Expanded(
            child: _filteredResults.isEmpty
                ? Center(
                    child: Text('Nenhum resultado encontrado'),
                  )
                : ListView.builder(
                    itemCount: _filteredResults.length,
                    itemBuilder: (context, index) {
                      final result = _filteredResults[index];
                      final data = result['data'];
                      final type = result['type'];

                      String name = '';
                      String fileKey = '';

                      if (type == 'Evento') {
                        name = (data as Event).name;
                        fileKey = data.fileKey ?? '';
                      } else if (type == 'Publicação') {
                        name = (data as Post).content ?? '';
                        fileKey =
                            data.user?.fileKey ?? data.agency?.fileKey ?? '';
                      } else if (type == 'Usuário') {
                        name = (data as User).username;
                        fileKey = data.fileKey ?? '';
                      } else if (type == 'Modelo') {
                        name = (data as Model).name;
                        fileKey = data.fileKey ?? '';
                      }

                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: fileKey.isNotEmpty
                                ? NetworkImage(
                                    '${ApiConfig.apiBaseUrl}/files/$fileKey',
                                  )
                                : null,
                            child: fileKey.isEmpty ? Icon(Icons.person) : null,
                          ),
                          subtitle: Text(type),
                          title: Text(name),
                          onTap: () {
                            _navigateToResultDetails(result);
                          },
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  void _navigateToResultDetails(Map<String, dynamic> result) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.user?.id;
    final data = result['data'];
    final type = result['type'];

    switch (type) {
      case 'Evento':
        if (data is Event) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(
                event: data,
                eventId: data.id,
                userId: data.userId ?? 'default_user_id',
              ),
            ),
          );
        }
        break;
      case 'Publicação':
        if (data is Post) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailsScreen(
                post: data,
                postId: data.id,
                userId: data.userId ?? '',
                agencyId: data.agency?.id ?? '',
              ),
            ),
          );
        }
        break;
      case 'Usuário':
        if (data is User) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => profile.ProfileScreen(id: data.id),
            ),
          );
        }
        break;
      case 'Modelo':
        if (data is Model) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModeloDetailsScreen(modelo: data),
            ),
          );
        }
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tipo de resultado não suportado: $type')),
        );
    }
  }
}
