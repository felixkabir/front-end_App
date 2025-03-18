import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:stivy/views/home/home_screen.dart';
import 'package:stivy/views/pesquisa/search_screen.dart';
import 'package:stivy/views/agencia/agencies_screen.dart';
import 'package:stivy/views/profile/profile.screen.dart';
import 'package:stivy/views/settings/setting_screen.dart';
import 'package:stivy/views/auth/login/login_screen.dart';
import 'package:stivy/Api/ApiConfig.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Chave para o Scaffold

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.isLoggedIn;
    final userId = userProvider.user?.id;
    final userEmail = userProvider.user?.email;

    final List<Widget> _widgetOptions = <Widget>[
      HomeScreen(),
      SearchScreen(),
      AgenciesScreen(),
      ProfileScreen(id: userId ?? ''),
      SettingsScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppHeader(
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        isAgencyAccount: false, 
        onProfileSwitch: () {
        },
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: isLoggedIn &&
                            userProvider.user?.fileKey != null
                        ? NetworkImage(
                            '${ApiConfig.apiBaseUrl}/files/${userProvider.user?.fileKey}')
                        : AssetImage(
                                'https://icons.veryicon.com/png/o/internet--web/prejudice/user-128.png')
                            as ImageProvider,
                    radius: 30,
                  ),
                  SizedBox(height: 10),
                  Text(
                    isLoggedIn
                        ? userProvider.user?.username ?? 'Usuário'
                        : 'Convidado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isLoggedIn)
                    Text(
                      userProvider.user?.email ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context); // Fecha o Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Pesquisar'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context); // Fecha o Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.business),
              title: Text('Agências'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context); // Fecha o Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              onTap: () {
                if (isLoggedIn && userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(id: userId),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                }
                Navigator.pop(context); // Fecha o Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configurações'),
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context); // Fecha o Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sair'),
              onTap: () async {
                final userProvider =
                
                Provider.of<UserProvider>(context, listen: false);
                if (userEmail != null) {
                  await userProvider.logout(userEmail); 
                }

                // Redireciona para a tela de login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false, // Remove todas as rotas anteriores
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pesquisar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Agências',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent, 
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CustomAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final bool isAgencyAccount;
  final VoidCallback onProfileSwitch;

  const CustomAppHeader({
    Key? key,
    required this.onMenuTap,
    required this.isAgencyAccount,
    required this.onProfileSwitch,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.isLoggedIn;
    final userPhotoUrl = userProvider.user?.fileKey;

    return Stack(
      children: [
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: onMenuTap,
          ),
          title: Row(
            children: [
              SizedBox(width: 10),
              Text(
                'Stivy',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                onTap: () {
                  if (isLoggedIn && userProvider.user?.id != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(id: userProvider.user!.id!),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  }
                },
                child: CircleAvatar(
                  backgroundImage: isLoggedIn && userPhotoUrl != null
                      ? NetworkImage(
                          '${ApiConfig.apiBaseUrl}/files/${userPhotoUrl}')
                      : AssetImage(
                              'https://icons.veryicon.com/png/o/internet--web/prejudice/user-128.png')
                          as ImageProvider,
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
              color: Colors.blueAccent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Faça login ou cadastre-se!",
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      "Entrar",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
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
