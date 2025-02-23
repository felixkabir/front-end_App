import 'package:flutter/material.dart';
import 'package:stivy/views/profile/profile.screen.dart' as profile;
import 'package:stivy/models/post/post.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stivy/views/home/details_screen.dart';
import 'package:stivy/views/settings/setting_screen.dart';
import 'package:stivy/views/help/help_screen.dart';
import 'package:stivy/views/events/events_screen.dart';
import 'package:stivy/views/auth/Login/login_screen.dart';
import 'dart:io';


class CustomAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final bool isAgencyAccount;
  final VoidCallback onProfileSwitch;
  final bool isLoggedIn;
  final VoidCallback onLoginTap;

  const CustomAppHeader({
    Key? key,
    required this.onMenuTap,
    required this.isAgencyAccount,
    required this.onProfileSwitch,
    required this.isLoggedIn,
    required this.onLoginTap,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          title: Text(
            'Stivy',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (isAgencyAccount)
              IconButton(
                icon: Icon(Icons.switch_account, color: Colors.black),
                onPressed: onProfileSwitch,
              ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {},
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/img1.jpg'),
                  radius: 18,
                ),
              ),
            ),
          ],
        ),
        if (!isLoggedIn)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(2),
              color: Colors.greenAccent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Faça login ou cadastre-se!",
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis, // Para evitar estouro de texto
                    ),
                  ),
                  TextButton(
                    onPressed: onLoginTap,
                    child: Text(
                      "Entrar",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAgencyAccount = true;
  bool isLoggedIn = false;

  void _showPostBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PostBottomSheet(
        isAgencyAccount: isAgencyAccount,
        userAgencies: [
          Agency(name: 'Fashion Agency Pro', imageUrl: 'https://i.pravatar.cc/150?img=1'),
          Agency(name: 'Model Agency Elite', imageUrl: 'https://i.pravatar.cc/150?img=2'),
          Agency(name: 'Fashionista Agency', imageUrl: 'https://i.pravatar.cc/150?img=3'),
        ], 
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: CustomAppHeader(
      onMenuTap: () {}, // Remova esta linha, pois não é mais necessária
      isAgencyAccount: isAgencyAccount,
      onProfileSwitch: () {
        setState(() {
          isAgencyAccount = !isAgencyAccount;
        });
      },
      isLoggedIn: isLoggedIn,
      onLoginTap: () {
        setState(() {
          isLoggedIn = true;
        });
      },
    ),
    drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.greenAccent,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Início'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => profile.ProfileScreen(userId: '1'),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Eventos'),
            onTap: () {
              Navigator.pop(context); 
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Ajuda'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sair'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    ),
    body: ListView.builder(
      itemCount: samplePosts.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailsScreen(post: samplePosts[index]),
              ),
            );
          },
          child: PostCard(post: samplePosts[index]),
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _showPostBottomSheet,
      icon: Icon(Icons.add),
      label: Text("Publicar"),
      backgroundColor: Colors.greenAccent,
    ),
  );
}
}

class PostCard extends StatelessWidget {
  final Post post;

   const PostCard({required this.post});

  void _showOptionsMenu(BuildContext context, Post post) {
    final bool isOwner = true;
    post.userId == 'currentUserId';

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.bookmark),
                title: Text('Guardar na lista'),
                onTap: () {
                  Navigator.pop(context);
                  // Lógica para guardar o post na lista
                },
              ),
              ListTile(
                leading: Icon(Icons.visibility_off),
                title: Text('Não ver este post'),
                onTap: () {
                  Navigator.pop(context);
                  // Lógica para ocultar o post
                },
              ),
              if (isOwner) ...[
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Editar'),
                  onTap: () {
                    Navigator.pop(context);
                    // Lógica para editar o post
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Eliminar'),
                  onTap: () {
                    Navigator.pop(context);
                    // Lógica para eliminar o post
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 4),
          bottom: BorderSide(color: Colors.grey[300]!, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [ 
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => profile.ProfileScreen(userId: post.userName), // Using userName as userId for demo
                        ),
                      );
                    },
                child:  CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(post.userImage),
                ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              post.userType,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        post.timeAgo,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    _showOptionsMenu(context, post);
                  },
                ),
              ],
            ),
          ),

          // Event Info (if applicable)
          if (post.eventDate.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: post.isPastEvent ? Colors.grey[100] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      post.isPastEvent ? Icons.event_available : Icons.event,
                      color: post.isPastEvent ? Colors.grey[700] : Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.isPastEvent ? 'Evento Passado' : 'Evento Futuro',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: post.isPastEvent ? Colors.grey[700] : Colors.blue,
                          ),
                        ),
                        Text(
                          '${post.eventDate} - ${post.location}',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Content
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                post.content,
                style: TextStyle(fontSize: 16),
              ),
            ),

          // Images
          if (post.images.isNotEmpty)
            Container(
              height: 300,
              child: PageView.builder(
                itemCount: post.images.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    post.images[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

          // Reactions Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildReactionButton(
                  icon: Icons.favorite_border,
                  count: post.likes,
                  onTap: () {},
                ), 
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.person_add_outlined),
                  label: Text('Contactar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class PostBottomSheet extends StatefulWidget {
  final bool isAgencyAccount;
  final List<Agency> userAgencies; // Lista de agências relacionadas ao usuário

  const PostBottomSheet({
    required this.isAgencyAccount,
    required this.userAgencies,
  });

  @override
  _PostBottomSheetState createState() => _PostBottomSheetState();
}

class _PostBottomSheetState extends State<PostBottomSheet> with SingleTickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool isEvent = false;
  bool postAsAgency = false;
  bool isPosting = false;
  Agency? selectedAgency; // Agência selecionada para publicar

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  void _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      if (_selectedImages.length + images.length > 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Você só pode selecionar até 4 imagens.")),
        );
        return;
      }
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitPost() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, insira o conteúdo do post.")),
      );
      return;
    }

    if (postAsAgency && selectedAgency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, selecione uma agência para publicar.")),
      );
      return;
    }

    setState(() {
      isPosting = true;
    });

    try {
      // Simulando o envio do post
      await Future.delayed(Duration(seconds: 2));

      final newPost = {
        "userType": postAsAgency ? "agency" : "user",
        "agency": postAsAgency ? selectedAgency?.name : null,
        "content": _contentController.text,
        "images": _selectedImages.map((img) => img.path).toList(),
        "eventDate": isEvent ? _startDateController.text : '',
        "location": isEvent ? _locationController.text : '',
      };

      print("Enviando post: $newPost");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post publicado com sucesso!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao publicar o post. Tente novamente.")),
      );
    } finally {
      setState(() {
        isPosting = false;
      });
    }
  }

  void _showAgencySelectionPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Selecione uma agência"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.userAgencies.length,
              itemBuilder: (context, index) {
                final agency = widget.userAgencies[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(agency.imageUrl),
                  ),
                  title: Text(agency.name),
                  onTap: () {
                    setState(() {
                      selectedAgency = agency;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animation.value) * 100),
          child: Opacity(
            opacity: _animation.value,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16),
                    Text(
                      "Criar uma publicação",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),

                    if (widget.isAgencyAccount) ...[
                      Text("Publicar como:"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: Text("Usuário"),
                            selected: !postAsAgency,
                            onSelected: (selected) {
                              setState(() {
                                postAsAgency = !selected;
                                selectedAgency = null;
                              });
                            },
                          ),
                          SizedBox(width: 8),
                          ChoiceChip(
                            label: Text("Agência"),
                            selected: postAsAgency,
                            onSelected: (selected) {
                              setState(() {
                                postAsAgency = selected;
                              });
                              if (selected) {
                                _showAgencySelectionPopup();
                              }
                            },
                          ),
                        ],
                      ),
                      if (postAsAgency && selectedAgency != null)
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(selectedAgency!.imageUrl),
                          ),
                          title: Text(selectedAgency!.name),
                          trailing: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                selectedAgency = null;
                              });
                            },
                          ),
                        ),
                      SizedBox(height: 16),
                    ],

                    Text("Tipo de publicação:"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: Text("Post"),
                          selected: !isEvent,
                          onSelected: (selected) {
                            setState(() {
                              isEvent = !selected;
                            });
                          },
                        ),
                        SizedBox(width: 8),
                        ChoiceChip(
                          label: Text("Evento"),
                          selected: isEvent,
                          onSelected: (selected) {
                            setState(() {
                              isEvent = selected;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: "O que deseja compartilhar?",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),

                    if (isEvent) ...[
                      TextField(
                        controller: _startDateController,
                        decoration: InputDecoration(
                          labelText: "Data de início do evento",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _endDateController,
                        decoration: InputDecoration(
                          labelText: "Data de término do evento",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: "Localização",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: Icon(Icons.image),
                      label: Text("Selecionar imagens (${_selectedImages.length}/4)"),
                    ),
                    if (_selectedImages.isNotEmpty)
                      Container(
                        height: 100,
                        margin: EdgeInsets.only(top: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () => _removeImage(index),
                              child: Stack(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(File(_selectedImages[index].path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 12,
                                      child: Icon(Icons.close, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isPosting ? null : _submitPost,
                      child: isPosting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Publicar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),

                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class Agency {
  final String name;
  final String imageUrl;

  Agency({required this.name, required this.imageUrl});
}


final List<Post> samplePosts = [
  Post(
    id: '2',
    userId: '2',
    comments:1 ,
    shares: 3,
    userImage: 'assets/img1.jpg',
    userName: 'Isabella Model',
    userType: 'model',
    timeAgo: '2h ago',
    content: 'Just finished an amazing photoshoot for Summer Collection 2024! 🌟',
    images: ['assets/img2.jpg', 'assets/img1.jpg'],
    likes: 234,
  ),
  Post(
    id: '3',
    userId: '3',
    comments:1 ,
    shares: 3,
    userImage: 'assets/img3.jpg',
    userName: 'Fashion Agency Pro',
    userType: 'agency',
    timeAgo: '5h ago',
    content: 'Looking for models for our upcoming winter collection showcase!',
    images: ['assets/img5.jpg'],
    likes: 567,
    eventDate: 'March 15, 2024',
    location: 'Milan Fashion Studio',
    isPastEvent: false,
  ),
];