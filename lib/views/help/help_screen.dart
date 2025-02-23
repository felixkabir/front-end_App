import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      "question": "Como faço para publicar um post?",
      "answer": "Clique no botão 'Publicar' na tela inicial e preencha os campos necessários.",
    },
    {
      "question": "Como editar meu perfil?",
      "answer": "Vá para a tela de perfil e clique no ícone de edição.",
    },
    {
      "question": "Como entrar em contato com o suporte?",
      "answer": "Use o botão 'Contato' abaixo para enviar uma mensagem.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajuda"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de busca
            TextField(
              decoration: InputDecoration(
                hintText: "Pesquisar ajuda...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Lista de FAQs
            Expanded(
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    title: Text(
                      faqs[index]["question"]!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(faqs[index]["answer"]!),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Botão de contato
            ElevatedButton.icon(
              onPressed: () {
                // Lógica para entrar em contato
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Redirecionando para o suporte...")),
                );
              },
              icon: Icon(Icons.contact_support),
              label: Text("Entrar em Contato"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}