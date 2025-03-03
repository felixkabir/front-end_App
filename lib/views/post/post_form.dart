import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:stivy/controllers/event/event_controller.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:stivy/controllers/posts/post_controller.dart';
import 'dart:io';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
final TextEditingController _contentController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();
  final PostController _postController = PostController();
  final EventController _eventController = EventController();
  List<File> _selectedFiles = [];
  bool _isPostingAsAgency = false;
  String? _selectedAgencyId;
  String? _location;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isEvent = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      if (_selectedFiles.length + pickedFiles.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Você só pode selecionar até 5 imagens.')),
        );
        return;
      }

      setState(() {
        _selectedFiles.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  Future<void> _pickSingleImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedFiles = [File(pickedFile.path)];
      });
    }
  }

  Future<void> _submitPost() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;
    final entityType = _isPostingAsAgency ? 'AGENCY' : 'MODEL';
    final entityId = _isPostingAsAgency ? _selectedAgencyId! : userId!;

    if (_isEvent) {
      if (_eventNameController.text.isEmpty || _startDate == null || _endDate == null || _selectedFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, preencha todos os campos do evento.')),
        );
        return;
      }

      await _eventController.createEvent(
        name: _eventNameController.text,
        file: _selectedFiles.first,
        startDate: _startDate!,
        endDate: _endDate!,
        entityId: entityId,
        entityType: entityType,
        location: _location!,
      );
    } else {
      if (_contentController.text.isEmpty || _selectedFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, insira o conteúdo da postagem e selecione imagens.')),
        );
        return;
      }

      await _postController.createPost(
        content: _contentController.text,
        files: _selectedFiles,
        entityId: entityId,
        entityType: entityType,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Postagem criada com sucesso!')),
    );

    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Publicação'),
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _submitPost,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seletor de tipo de postagem (Evento ou Trabalho)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEvent = true;
                        _selectedFiles = []; // Limpa as imagens ao mudar o tipo
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEvent ? Colors.blueAccent : Colors.grey[300],
                      foregroundColor: _isEvent ? Colors.white : Colors.black,
                    ),
                    child: Text('Evento'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEvent = false;
                        _selectedFiles = []; // Limpa as imagens ao mudar o tipo
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isEvent ? Colors.blueAccent : Colors.grey[300],
                      foregroundColor: !_isEvent ? Colors.white : Colors.black,
                    ),
                    child: Text('Trabalho'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Campo de conteúdo ou nome do evento
            if (_isEvent)
              TextField(
                controller: _eventNameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Evento',
                  border: OutlineInputBorder(),
                ),
              )
            else
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Descrição da Publicação',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            SizedBox(height: 20),

            // Datas do evento (se for evento)
            if (_isEvent)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Data de Início: ${_startDate != null ? "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}" : "Selecione"}'),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Data de Término: ${_endDate != null ? "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}" : "Selecione"}'),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context, false),
                      ),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 20),

            // Seletor de agência (se o usuário tiver agências)
            if (user?.agencies != null && user!.agencies!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Postar como:', style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text('Usuário'),
                        selected: !_isPostingAsAgency,
                        onSelected: (selected) {
                          setState(() {
                            _isPostingAsAgency = false;
                          });
                        },
                      ),
                      SizedBox(width: 10),
                      ChoiceChip(
                        label: Text('Agência'),
                        selected: _isPostingAsAgency,
                        onSelected: (selected) {
                          setState(() {
                            _isPostingAsAgency = true;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isPostingAsAgency)
                    DropdownButton<String>(
                      value: _selectedAgencyId,
                      hint: Text('Selecione uma agência'),
                      items: user.agencies!.map((agency) {
                        return DropdownMenuItem(
                          value: agency.id,
                          child: Text(agency.name!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAgencyId = value;
                        });
                      },
                    ),
                  SizedBox(height: 20),
                ],
              ),

            // Seletor de imagens
            Text('Imagens:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            if (_selectedFiles.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedFiles.map((file) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          file,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFiles.remove(file);
                            });
                          },
                          child: Icon(Icons.cancel, color: Colors.red),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isEvent ? _pickSingleImage : _pickImages,
              child: Text(_isEvent ? 'Adicionar Imagem' : 'Adicionar Imagens'),
            ),
          ],
        ),
      ),
    );
  }
}