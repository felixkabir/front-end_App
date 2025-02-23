import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Configurações de Notificações
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Notificações"),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),
            Divider(),
            // Configurações de Tema
            ListTile(
              leading: Icon(Icons.brightness_6),
              title: Text("Modo Escuro"),
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                  // Lógica para alterar o tema
                },
              ),
            ),
            Divider(),
            // Configurações de Privacidade
            ListTile(
              leading: Icon(Icons.security),
              title: Text("Privacidade e Segurança"),
              onTap: () {
                // Lógica para navegar para a tela de privacidade
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Abrindo configurações de privacidade...")),
                );
              },
            ),
            Divider(),
            // Sobre o App
            ListTile(
              leading: Icon(Icons.info),
              title: Text("Sobre o App"),
              onTap: () {
                // Lógica para mostrar informações sobre o app
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Sobre o App"),
                      content: Text("Stivy v1.0\nDesenvolvido por [Sua Empresa]."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Fechar"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}