import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Carregar preferência de tema
  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
    });
  }

  // Salvar preferência de tema
  void _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Configurações de Notificações
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.notifications, color: Colors.blueAccent),
                title: Text("Notificações"),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: Colors.blueAccent,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Configurações de Tema
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.brightness_6, color: Colors.blueAccent),
                title: Text("Modo Escuro"),
                trailing: Switch(
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                      _saveThemePreference(value);
                      // Aplicar o tema
                      if (value) {
                        // Tema escuro
                        // Implemente a lógica para mudar o tema aqui
                      } else {
                        // Tema claro
                        // Implemente a lógica para mudar o tema aqui
                      }
                    });
                  },
                  activeColor: Colors.blueAccent,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Configurações de Privacidade
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.security, color: Colors.blueAccent),
                title: Text("Privacidade e Segurança"),
                onTap: () {
                  // Navegar para a tela de privacidade
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Abrindo configurações de privacidade...")),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // Sobre o App
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.info, color: Colors.blueAccent),
                title: Text("Sobre o App"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // Feedback
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.feedback, color: Colors.blueAccent),
                title: Text("Enviar Feedback"),
                onTap: () {
                  // Lógica para enviar feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Redirecionando para o formulário de feedback...")),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // Logout
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.blueAccent),
                title: Text("Sair"),
                onTap: () {
                  // Lógica para logout
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Sair"),
                        content: Text("Tem certeza que deseja sair?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () {
                              // Lógica para logout
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Você saiu da sua conta.")),
                              );
                            },
                            child: Text("Sair", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Página "Sobre o App"
class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sobre o App"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png", // Substitua pelo caminho da sua logo
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              "Stivy v1.0",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Desenvolvido por Stelvia Firmino",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Stivy é uma plataforma para conectar pessoas e compartilhar experiências. "
              "Nosso objetivo é proporcionar uma experiência única e envolvente.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para visitar o site
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Redirecionando para o site...")),
                );
              },
              child: Text("Visitar Site"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}