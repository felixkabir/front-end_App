import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';  

class PrivacyAndSecurityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacidade e Segurança"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sua Privacidade é Importante",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Nós levamos a sua privacidade e segurança a sério. Aqui estão algumas informações sobre como protegemos seus dados:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.lock, color: Colors.blueAccent),
                title: Text("Criptografia de Dados"),
                subtitle: Text(
                  "Todos os seus dados são criptografados para garantir a máxima segurança.",
                ),
              ),
              ListTile(
                leading: Icon(Icons.security, color: Colors.blueAccent),
                title: Text("Proteção Contra Acesso Não Autorizado"),
                subtitle: Text(
                  "Utilizamos medidas avançadas para evitar acesso não autorizado aos seus dados.",
                ),
              ),
              ListTile(
                leading: Icon(Icons.visibility_off, color: Colors.blueAccent),
                title: Text("Nenhum Dado Compartilhado com Terceiros"),
                subtitle: Text(
                  "Seus dados nunca são compartilhados com terceiros sem sua permissão.",
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Para mais informações, leia nossa Política de Privacidade completa.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para abrir a política de privacidade
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Redirecionando para a política de privacidade...")),
                    );
                  },
                  child: Text("Política de Privacidade"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}