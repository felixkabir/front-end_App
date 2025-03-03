import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:stivy/views/auth/login/login_screen.dart';

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
    final user = userProvider.user;

    return Stack(
      children: [
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: onMenuTap,
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
                onTap: () {
                  if (isLoggedIn && user != null) {
                    // Navegue para o perfil do usuário
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                },
                child: CircleAvatar(
                  backgroundImage: isLoggedIn && user?.fileKey != null
                      ? NetworkImage('${ApiConfig.apiBaseUrl}/files/${user?.fileKey}')
                      : AssetImage('https://icons.veryicon.com/png/o/internet--web/prejudice/user-128.png') as ImageProvider,
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