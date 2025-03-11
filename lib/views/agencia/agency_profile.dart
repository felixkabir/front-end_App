import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/agency/agency_model.dart';
import 'package:stivy/services/agency/agency_service.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AgencyProfileScreen extends StatefulWidget {
  final String id; // ID da agência
  final String userId; // ID do usuário logado

  AgencyProfileScreen({required this.id, required this.userId});

  @override
  _AgencyProfileScreenState createState() => _AgencyProfileScreenState();
}

class _AgencyProfileScreenState extends State<AgencyProfileScreen> {
  late Future<Agency> _agencyFuture;
  final AgencyService _agencyService = AgencyService();
  bool _isOwner =
      false; // Variável para controlar se o usuário é o proprietário
  Agency? _agency; // Variável para armazenar a agência carregada

  @override
  void initState() {
    super.initState();
    _agencyFuture = _agencyService.fetchAgencyById(widget.id);
  }

  // Função para contatar a agência
  void _contactAgency(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível realizar a chamada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: FutureBuilder<Agency>(
        future: _agencyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar a agência'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Agência não encontrada'));
          }

          final agency = snapshot.data!;
          _agency = agency; // Armazena a agência carregada
          _isOwner = userProvider.user?.id ==
              agency.creator.id; // Define se o usuário é o proprietário

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho da Agência
                _buildAgencyHeader(agency, _isOwner),
                SizedBox(height: 20),

                // Seção de Modelos
                _buildModelsSection(agency.models, _isOwner),
                SizedBox(height: 20),

                // Seção de Posts
                _buildPostsSection(agency.Post, _isOwner),
                SizedBox(height: 20),

                // Seção de Trabalhos e Eventos
                _buildWorksAndEventsSection(agency, _isOwner),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _isOwner && _agency != null
          ? FloatingActionButton(
              onPressed: () {
                _showAddContentDialog(context, _agency!);
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _addModel(Map<String, dynamic> modelData) async {
    try {
      final response = await _agencyService.addModel(modelData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Modelo adicionado com sucesso!')),
        );
        setState(() {
          _agencyFuture = _agencyService.fetchAgencyById(widget.id);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar o modelo')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar o modelo: $e')),
      );
    }
  }

  // Diálogo para adicionar conteúdo (modelo, post, trabalho ou evento)
  void _showAddContentDialog(BuildContext context, Agency agency) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Conteúdo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showAddModelDialog(context, agency);
                },
                child: Text('Adicionar Modelo'),
              ),
              ListTile(
                leading: Icon(Icons.work),
                title: Text('Adicionar Trabalho/Evento'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgencyHeader(Agency agency, bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            '${ApiConfig.apiBaseUrl}/files/${agency.fileKey}',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 16),
        Text(
          agency.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          agency.contact,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16),
        if (!isOwner)
          ElevatedButton(
            onPressed: () => _contactAgency(agency.contact),
            child: Text('Contactar Agência'),
          ),
        if (isOwner)
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  _showAddModelDialog(context, agency);
                },
                child: Text('Adicionar Modelo'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildModelsSection(List<dynamic> models, bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modelos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        if (models.isEmpty) Text('Nenhum modelo encontrado.'),
        if (models.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              print('$model');
              return Card(
                elevation: 2,
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
                          '${ApiConfig.apiBaseUrl}/files/${model.fileKey}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        model.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isOwner)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Eliminar o modelo
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildPostsSection(List<dynamic> posts, bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Posts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        if (posts.isEmpty) Text('Nenhum post encontrado.'),
        if (posts.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.fileKey != null)
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          '${ApiConfig.apiBaseUrl}/files/${post.fileKey}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 150,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        post.description ?? 'Sem descrição',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (isOwner)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Eliminar o post
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildWorksAndEventsSection(Agency agency, bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trabalhos e Eventos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        if (agency.Post.isEmpty) Text('Nenhum trabalho ou evento encontrado.'),
        if (agency.Post.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: agency.Post.length,
            itemBuilder: (context, index) {
              final workOrEvent = agency.Post[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(workOrEvent.title),
                  subtitle: Text(workOrEvent.description),
                  trailing: isOwner
                      ? IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {},
                        )
                      : null,
                ),
              );
            },
          ),
        if (isOwner)
          ElevatedButton(
            onPressed: () {
              // Adicionar trabalho/evento
            },
            child: Text('Adicionar Trabalho/Evento'),
          ),
      ],
    );
  }

  void _showAddModelDialog(BuildContext context, Agency agency) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _heightController = TextEditingController();
    final _waistController = TextEditingController();
    final _shoesController = TextEditingController();
    final _contactController = TextEditingController();
    String? _fileKey;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Modelo'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome do modelo';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _heightController,
                    decoration: InputDecoration(labelText: 'Altura'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a altura do modelo';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _waistController,
                    decoration: InputDecoration(labelText: 'Cintura'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a cintura do modelo';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _shoesController,
                    decoration: InputDecoration(labelText: 'Calçado'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o número do calçado do modelo';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _contactController,
                    decoration: InputDecoration(labelText: 'Contato'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o contato do modelo';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Implementar lógica de upload de imagem
                      // _fileKey = await _uploadImage();
                    },
                    child: Text('Upload de Imagem'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newModel = {
                    'name': _nameController.text,
                    'height': _heightController.text,
                    'waist': _waistController.text,
                    'shoes': _shoesController.text,
                    'contact': _contactController.text,
                    'file_key': _fileKey,
                    'agencyId': agency.id,
                  };

                  // Chamar a função para adicionar o modelo
                  await _addModel(newModel);

                  Navigator.pop(context);
                }
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }
}
