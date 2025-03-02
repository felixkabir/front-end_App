import 'package:flutter/material.dart';
import 'package:stivy/models/agency/agency_model.dart';
import 'package:stivy/views/profile/profile.screen.dart' as profile;
import 'package:provider/provider.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:stivy/services/api_service.dart';

final List<AgencyModel> sampleAgencies = [
  AgencyModel(
    id: '1',
    name: 'Fashion Agency Pro',
    imageUrl: 'https://i.pravatar.cc/150?img=1',
    location: 'São Paulo, SP',
    rating: 4.5,
    modelsCount: 120,
  ),
  AgencyModel(
    id: '2',
    name: 'Model Agency Elite',
    imageUrl: 'https://i.pravatar.cc/150?img=2',
    location: 'Rio de Janeiro, RJ',
    rating: 4.8,
    modelsCount: 95,
  ),
  AgencyModel(
    id: '3',
    name: 'Fashionista Agency',
    imageUrl: 'https://i.pravatar.cc/150?img=3',
    location: 'Belo Horizonte, MG',
    rating: 4.2,
    modelsCount: 80,
  ),
  AgencyModel(
    id: '4',
    name: 'Top Models Agency',
    imageUrl: 'https://i.pravatar.cc/150?img=4',
    location: 'Curitiba, PR',
    rating: 4.7,
    modelsCount: 110,
  ),
];

class AgenciesScreen extends StatefulWidget {
  @override
  _AgenciesScreenState createState() => _AgenciesScreenState();
}

class _AgenciesScreenState extends State<AgenciesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _userAgencyId = '1'; // ID da agência do usuário (null se não tiver)
  String _selectedFilter = 'Todas'; // Filtro selecionado
  String _selectedSort = 'Nome'; // Ordenação selecionada

  // Filtra as agências com base na consulta de pesquisa e filtros
  List<AgencyModel> get _filteredAgencies {
    return sampleAgencies.where((agency) {
      final matchesQuery =
          agency.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'Todas' ||
          agency.location.contains(_selectedFilter);
      return matchesQuery && matchesFilter;
    }).toList();
  }

  // Ordena as agências com base na seleção do usuário
  List<AgencyModel> get _sortedAgencies {
    switch (_selectedSort) {
      case 'Nome':
        return _filteredAgencies..sort((a, b) => a.name.compareTo(b.name));
      case 'Avaliação':
        return _filteredAgencies
          ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      case 'Modelos':
        return _filteredAgencies
          ..sort((a, b) => b.modelsCount.compareTo(a.modelsCount));
      default:
        return _filteredAgencies;
    }
  }

  void _openAddAgencyModal() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController imageController = TextEditingController();
    final TextEditingController contactController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cadastrar Nova Agência',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome da Agência',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Apenas letras são permitidas';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(
                    labelText: 'URL da foto de capa (PNG, JPG, GIF)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (!value.endsWith('.png') &&
                        !value.endsWith('.jpg') &&
                        !value.endsWith('.gif')) {
                      return 'Formato inválido (use PNG, JPG ou GIF)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: contactController,
                  decoration: InputDecoration(
                    labelText: 'Contato',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
                      return 'Apenas caracteres alfanuméricos são permitidos';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    final userId = userProvider.user?.id;

                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Usuário não logado')),
                      );
                      return;
                    }

                    if (nameController.text.isEmpty ||
                        imageController.text.isEmpty ||
                        contactController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Preencha todos os campos')),
                      );
                      return;
                    }

                    try {
                      print('Dados enviados:');
                      print('userId: $userId');
                      print('name: ${nameController.text}');
                      print('contact: ${contactController.text}');
                      print('imageUrl: ${imageController.text}');

                      await ApiService.createAgency(
                        userId: userId,
                        name: nameController.text,
                        contact: contactController.text,
                        imageUrl: imageController.text,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Agência cadastrada com sucesso!')),
                      );

                      // Fecha o modal
                      Navigator.pop(context);
                    } catch (e) {
                      print('Erro ao cadastrar agência: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Erro ao cadastrar agência: $e')),
                      );
                    }
                  },
                  child: Text('Cadastrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agências'),
        actions: [
          if (_userAgencyId != null)
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                final userAgency = sampleAgencies.firstWhere(
                  (agency) => agency.id == _userAgencyId,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        profile.ProfileScreen(userId: userAgency.id),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar agências...',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    items: [
                      'Todas',
                      'São Paulo, SP',
                      'Rio de Janeiro, RJ',
                      'Belo Horizonte, MG'
                    ].map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedSort,
                    items: ['Nome', 'Avaliação', 'Modelos'].map((sort) {
                      return DropdownMenuItem(
                        value: sort,
                        child: Text(sort),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSort = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(4), // Reduz o padding
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 colunas
                crossAxisSpacing: 5, // Reduz o espaçamento horizontal
                mainAxisSpacing: 5, // Reduz o espaçamento vertical
                childAspectRatio: 0.7, // Proporção dos cards
              ),
              itemCount: _sortedAgencies.length,
              itemBuilder: (context, index) {
                final agency = _sortedAgencies[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            profile.ProfileScreen(userId: agency.id),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 0, // Remove a sombra
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              agency.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agency.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                agency.location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    agency.rating.toString(),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(width: 16),
                                  Icon(Icons.people,
                                      color: Colors.grey, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    agency.modelsCount.toString(),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddAgencyModal,
        child: Icon(Icons.add),
      ),
    );
  }
}
