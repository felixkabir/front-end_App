import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/agency/agency_model.dart';
import 'package:stivy/services/agency/agency_service.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AgencyProfileScreen extends StatefulWidget {
  final String id; // ID da agência
  final String userId; // ID do usuário logado

  AgencyProfileScreen({required this.id, required this.userId});

  @override
  _AgencyProfileScreenState createState() => _AgencyProfileScreenState();
}

class _AgencyProfileScreenState extends State<AgencyProfileScreen>
    with SingleTickerProviderStateMixin {
  late Future<Agency> _agencyFuture;
  final AgencyService _agencyService = AgencyService();
  bool _isOwner = false;
  Agency? _agency;
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _agencyFuture = _agencyService.fetchAgencyById(widget.id);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addModel(
      Map<String, dynamic> modelData, http.MultipartFile file) async {
    print('ID da agência (widget.id): ${widget.id}');
    print('ID da agência (_agency!.id): ${_agency?.id}');

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.apiBaseUrl}/models/add/${_agency!.id}'),
      );

      request.fields['name'] = modelData['name'];
      request.fields['height'] = modelData['height'];
      request.fields['waist'] = modelData['waist'];
      request.fields['shoes'] = modelData['shoes'];
      request.fields['contact'] = modelData['contact'];
      request.fields['agencyId'] = modelData['agencyId'];

      request.files.add(file);

      print('Enviando requisição para ${request.url}');
      print('Campos enviados: ${request.fields}');
      print('Arquivo anexado: ${file.filename}');

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Modelo adicionado com sucesso!');
        setState(() {
          _agencyFuture = _agencyService.fetchAgencyById(widget.id);
        });
      } else {
        String responseBody = await response.stream.bytesToString();
        print('Erro ao adicionar modelo. Status Code: ${response.statusCode}');
        print('Resposta do servidor: $responseBody');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar o modelo: $responseBody')),
        );
      }
    } catch (e, stackTrace) {
      print('Exceção capturada: $e');
      print('StackTrace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar o modelo: $e')),
      );
    }
  }

  void _showEditAgencyDialog(BuildContext context, Agency agency) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: agency.name);
    final _contactController = TextEditingController(text: agency.contact);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Agência'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(labelText: 'Contato'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o contato';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final updateData = {
                    'name': _nameController.text,
                    'contact': _contactController.text,
                  };

                  try {
                    await _agencyService.updateAgency(
                        agencyId: agency.id, agencyData: updateData);
                    Navigator.pop(context);
                    setState(() {
                      _agencyFuture = _agencyService.fetchAgencyById(widget.id);
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Erro ao atualizar a agência: $e')),
                    );
                  }
                }
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditModelDialog(BuildContext context, dynamic model) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: model.name);
    final _heightController = TextEditingController(text: model.height);
    final _waistController = TextEditingController(text: model.waist);
    final _shoesController = TextEditingController(text: model.shoes);
    final _contactController = TextEditingController(text: model.contact);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Modelo'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _heightController,
                  decoration: InputDecoration(labelText: 'Altura (cm)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a altura';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _waistController,
                  decoration: InputDecoration(labelText: 'Cintura (cm)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a cintura';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _shoesController,
                  decoration: InputDecoration(labelText: 'Calçado'),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o número do calçado';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(labelText: 'Contato'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o contato';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final updateData = {
                    'name': _nameController.text,
                    'height': _heightController.text,
                    'waist': _waistController.text,
                    'shoes': _shoesController.text,
                    'contact': _contactController.text,
                  };

                  try {
                    await _agencyService.updateModel(model.id, updateData);
                    Navigator.pop(context);
                    setState(() {
                      _agencyFuture = _agencyService.fetchAgencyById(widget.id);
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao atualizar o modelo: $e')),
                    );
                  }
                }
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

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
      key: _scaffoldKey,
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
          _agency = agency;
          _isOwner = userProvider.user?.id == agency.creator.id;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 220.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      agency.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              '${ApiConfig.apiBaseUrl}/files/${agency.fileKey}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[300]),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.error),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    if (_isOwner)
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Editar perfil da agência
                        },
                      ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contato',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  agency.contact,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            if (!_isOwner)
                              ElevatedButton.icon(
                                onPressed: () => _contactAgency(agency.contact),
                                icon: Icon(Icons.phone),
                                label: Text('Contactar'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 3,
                      tabs: [
                        Tab(text: 'MODELOS'),
                        Tab(text: 'POSTS'),
                        Tab(text: 'EVENTOS'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildModelsTab(agency.models, _isOwner),
                _buildPostsTab(agency.Post, _isOwner),
                _buildEventsTab(agency.Post, _isOwner),
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
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
    );
  }

  Widget _buildModelsTab(List<dynamic> models, bool isOwner) {
    return models.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhum modelo encontrado.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                if (isOwner)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_agency != null) {
                          _showAddModelDialog(context, _agency!);
                        }
                      },
                      child: Text('Adicionar Modelo'),
                    ),
                  ),
              ],
            ),
          )
        : GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              return _buildModelCard(model, isOwner);
            },
          );
  }

  Widget _buildModelCard(dynamic model, bool isOwner) {
    return GestureDetector(
      onTap: () {
        _showModelDetailsModal(context, model);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Imagem do modelo
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: '${ApiConfig.apiBaseUrl}/files/${model.fileKey}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[300]),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.error),
                  ),
                ),
              ),
              // Gradiente de fundo para melhorar legibilidade do texto
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Nome do modelo
              Positioned(
                bottom: isOwner ? 40 : 16,
                left: 12,
                right: 12,
                child: Text(
                  model.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isOwner)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Row(
                    // Use Row para alinhar os botões horizontalmente
                    mainAxisSize: MainAxisSize
                        .min, // Para ocupar apenas o espaço necessário
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          _showEditModelDialog(context, model);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          // Mostrar diálogo de confirmação
                          _showDeleteConfirmationDialog(
                            context: context,
                            itemType: 'modelo',
                            onConfirm: () async {
                              try {
                                await _agencyService.deleteModel(model.id, widget.id, widget.userId);
                                setState(() {
                                  _agencyFuture =
                                      _agencyService.fetchAgencyById(widget.id);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Modelo excluído com sucesso!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Erro ao excluir o modelo: $e')),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsTab(List<dynamic> posts, bool isOwner) {
    return posts.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhum post encontrado.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPostCard(post, isOwner);
            },
          );
  }

  Widget _buildPostCard(dynamic post, bool isOwner) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post['file_entity'] != null && post['file_entity'].isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl:
                      '${ApiConfig.apiBaseUrl}/files/${post['file_entity'][0]['fileKey']}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[300]),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.error),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        post['content'] ?? 'Sem título',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isOwner)
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmationDialog(
                            context: context,
                            itemType: 'post',
                            onConfirm: () {
                              // Implementar exclusão de post
                            },
                          );
                        },
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  post['content'] ?? 'Sem descrição',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Publicado em ${_formatDate(post['created_at'])}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab(List<dynamic> events, bool isOwner) {
    // Filtragem de eventos (neste caso, assumindo que todos os posts podem ser eventos)
    // Em uma implementação real, você deve ter uma maneira de distinguir eventos de posts normais

    return events.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhum evento encontrado.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventCard(event, isOwner);
            },
          );
  }

  Widget _buildEventCard(dynamic event, bool isOwner) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: () {
          _showEventDetailsModal(context, event);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event['file_entity'] != null && event['file_entity'].isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl:
                            '${ApiConfig.apiBaseUrl}/files/${event['file_entity'][0]['fileKey']}',
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[300]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Evento',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event['content'] ?? 'Evento sem título',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isOwner)
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(
                              context: context,
                              itemType: 'evento',
                              onConfirm: () {
                                // Implementar exclusão de evento
                              },
                            );
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        _formatDate(event['created_at']),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    event['content'] ?? 'Sem descrição',
                    style: TextStyle(fontSize: 16),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modal para exibir detalhes do modelo
  void _showModelDetailsModal(BuildContext context, dynamic model) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      controller: controller,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 400,
                                width: double.infinity,
                                child: CachedNetworkImage(
                                  imageUrl:
                                      '${ApiConfig.apiBaseUrl}/files/${model.fileKey}',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Center(child: Icon(Icons.error)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model.name,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    _buildModelDetail(
                                        'Altura', '${model.height} cm'),
                                    _buildModelDetail(
                                        'Cintura', '${model.waist} kg'),
                                    _buildModelDetail(
                                        'contacto', model.contact),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  // Modal para exibir detalhes do evento
  void _showEventDetailsModal(BuildContext context, dynamic event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: [
                        if (event['file_entity'] != null &&
                            event['file_entity'].isNotEmpty)
                          Container(
                            height: 250,
                            width: double.infinity,
                            child: CachedNetworkImage(
                              imageUrl:
                                  '${ApiConfig.apiBaseUrl}/files/${event['file_entity'][0]['fileKey']}',
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Center(child: Icon(Icons.error)),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['content'] ?? 'Evento sem título',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 18, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Text(
                                    _formatDate(event['created_at']),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Descrição',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                event['content'] ?? 'Sem descrição',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  // Método para formatar datas
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Data desconhecida';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Data inválida';
    }
  }

  // Método para construir itens de detalhes do modelo
  Widget _buildModelDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Diálogo para adicionar conteúdo
  void _showAddContentDialog(BuildContext context, Agency agency) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Conteúdo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person_add),
                title: Text('Adicionar Modelo'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddModelDialog(context, agency);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Modal multistep para adicionar modelo
  void _showAddModelDialog(BuildContext context, Agency agency) {
    final modelData = {
      'name': '',
      'height': '',
      'waist': '',
      'shoes': '',
      'contact': '',
      'fileKey': null,
      'agencyId': agency.id, // Usar o ID da agência passada como parâmetro
    };

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    File? selectedImage;
    int currentStep = 0;
    final int totalSteps = 3;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Adicionar Modelo - Passo ${currentStep + 1} de $totalSteps',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StepProgressIndicator(
                          totalSteps: totalSteps,
                          currentStep: currentStep + 1,
                          selectedColor: Theme.of(context).primaryColor,
                          unselectedColor: Colors.grey[300]!,
                          padding: 0,
                        ),
                        SizedBox(height: 16),
                        // Diferentes conteúdos para cada etapa
                        if (currentStep == 0)
                          // Passo 1: Informações básicas
                          Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Nome do Modelo',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira o nome do modelo';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  modelData['name'] = value!;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Altura (cm)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira a altura';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  modelData['height'] = value!;
                                },
                              ),
                            ],
                          )
                        else if (currentStep == 1)
                          // Passo 2: Medidas e contato
                          Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Cintura (cm)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira a cintura';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  modelData['waist'] = value!;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Calçado',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira o número do calçado';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  modelData['shoes'] = value!;
                                },
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Contato',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira o contato';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  modelData['contact'] = value!;
                                },
                              ),
                            ],
                          )
                        else if (currentStep == 2)
                          // Passo 3: Foto
                          Column(
                            children: [
                              if (selectedImage != null)
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: FileImage(selectedImage!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.photo_camera,
                                          size: 64, color: Colors.grey[500]),
                                      SizedBox(height: 12),
                                      Text(
                                        'Nenhuma foto selecionada',
                                        style:
                                            TextStyle(color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery);

                                  if (image != null) {
                                    setState(() {
                                      selectedImage = File(image.path);
                                    });
                                  }
                                },
                                icon: Icon(Icons.photo_library),
                                label: Text('Selecionar Foto'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 48),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                if (currentStep > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentStep--;
                      });
                    },
                    child: Text('Voltar'),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    if (currentStep < totalSteps - 1) {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        setState(() {
                          currentStep++;
                        });
                      }
                    } else {
                      // Última etapa - submissão
                      if (selectedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Por favor, selecione uma foto')),
                        );
                        return;
                      }

                      formKey.currentState!.save();

                      // Fechar o diálogo
                      Navigator.pop(context);

                      // Mostrar indicador de progresso
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Adicionando modelo...'),
                              ],
                            ),
                          );
                        },
                      );

                      try {
                        if (selectedImage != null) {
                          var file = await http.MultipartFile.fromPath(
                              'file', selectedImage!.path);
                          // Não armazene o arquivo no modelData
                          // modelData['fileKey'] = file; // Remova esta linha

                          await _addModel(
                              modelData, file); // Passe o arquivo diretamente

                          Navigator.pop(context);

                          // Mostrar mensagem de sucesso
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Modelo adicionado com sucesso!')),
                          );
                        } else {
                          // Fechar diálogo de progresso
                          Navigator.pop(context);

                          // Mostrar erro
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Erro ao fazer upload da imagem')),
                          );
                        }
                      } catch (e) {
                        // Fechar diálogo de progresso
                        Navigator.pop(context);

                        // Mostrar erro
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Erro ao adicionar modelo: $e')),
                        );
                      }
                    }
                  },
                  child: Text(
                      currentStep < totalSteps - 1 ? 'Próximo' : 'Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Diálogo de confirmação de exclusão
  void _showDeleteConfirmationDialog({
    required BuildContext context,
    required String itemType,
    required Function onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Tem certeza que deseja excluir este $itemType?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: Text('Excluir'),
              style: ElevatedButton.styleFrom(),
            ),
          ],
        );
      },
    );
  }
}

// Delegate para manter a TabBar visível durante a rolagem
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
