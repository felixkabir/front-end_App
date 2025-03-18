import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/agency/agency_model.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:stivy/services/agency/agency_service.dart';
import 'package:stivy/views/agencia/agency_profile.dart';
import 'package:stivy/views/create/create_agency.dart';
import 'package:stivy/views/profile/profile.screen.dart' as profile;

class AgenciesScreen extends StatefulWidget {
  @override
  _AgenciesScreenState createState() => _AgenciesScreenState();
}

class _AgenciesScreenState extends State<AgenciesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AgencyService _agencyService = AgencyService();
  late Future<List<Agency>> _agenciesFuture;
  String _searchQuery = '';
  String? _userAgencyId;
  String _selectedFilter = 'Todas';
  String _selectedSort = 'Nome';

  @override
  void initState() {
    super.initState();
    _loadAgencies();
  }

  // Method to load agencies that can be called whenever we need to refresh
  void _loadAgencies() {
    setState(() {
      _agenciesFuture = _agencyService.fetchAllAgencies();
    });
  }

  void _refreshAgencies() {
    setState(() {
      _agenciesFuture = _agencyService.fetchAllAgencies();
    });
  }
  Future<List<Agency>> get _filteredAgencies {
    return _agenciesFuture.then((agencies) {
      return agencies.where((agency) {
        final matchesQuery =
            agency.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesFilter = _selectedFilter == 'Todas' ||
            agency.location != null &&
                agency.location!.contains(_selectedFilter);
        return matchesQuery && matchesFilter;
      }).toList();
    });
  }

  Future<List<Agency>> get _sortedAgencies {
    return _filteredAgencies.then((agencies) {
      switch (_selectedSort) {
        case 'Nome':
          return agencies..sort((a, b) => a.name.compareTo(b.name));
        case 'Avaliação':
          return agencies
            ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        case 'Modelos':
          return agencies
            ..sort(
                (a, b) => (b.modelsCount ?? 0).compareTo(a.modelsCount ?? 0));
        default:
          return agencies;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.user?.id;
    final userAgencies = userProvider.user?.agencies;

    final hasAgency = userAgencies != null && userAgencies.isNotEmpty;
    final agencyId = hasAgency ? userAgencies.first.id : null;

    return Scaffold(
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
            child: FutureBuilder<List<Agency>>(
              future: _sortedAgencies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar agências'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Nenhuma agência encontrada'));
                }

                final agencies = snapshot.data!;

                return GridView.builder(
                  padding: EdgeInsets.all(4),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: agencies.length,
                  itemBuilder: (context, index) {
                    final agency = agencies[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgencyProfileScreen(
                              id: agency.id,
                              userId: userId!,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 0,
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
                                child: Image(
                                  image: NetworkImage(
                                      '${ApiConfig.apiBaseUrl}/files/${agency.fileKey}'),
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
                                    agency.contact,
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
                                        agency.rating?.toString() ?? '0',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(width: 16),
                                      Icon(Icons.people,
                                          color: Colors.grey, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        agency.modelsCount?.toString() ?? '0',
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (userId != null) {
            if (hasAgency) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AgencyProfileScreen(
                    id: agencyId!,
                    userId: userId,
                  ),
                ),
              );
            } else {
              // Navega para a tela de criação de agência
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateAgencyScreen(userId: userId,
              onAgencyCreated: _refreshAgencies),
                ),
              ).then((result) { 
                if (result == true) { 
                  _loadAgencies(); 
                  Provider.of<UserProvider>(context, listen: false).refreshUser();
                }
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Usuário não logado')),
            );
          }
        },
        child: Icon(hasAgency ? Icons.person : Icons.add), // Ícone dinâmico
      ),
    );
  }
}