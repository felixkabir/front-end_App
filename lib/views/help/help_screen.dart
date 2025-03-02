import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      "question": "Como faço para publicar um post?",
      "answer": "Clique no botão 'Publicar' na tela inicial e preencha os campos necessários.",
      "category": "Posts",
    },
    {
      "question": "Como editar meu perfil?",
      "answer": "Vá para a tela de perfil e clique no ícone de edição.",
      "category": "Perfil",
    },
    {
      "question": "Como entrar em contato com o suporte?",
      "answer": "Use o botão 'Contato' abaixo para enviar uma mensagem.",
      "category": "Suporte",
    },
    {
      "question": "Como participar de eventos?",
      "answer": "Navegue até a seção de eventos e inscreva-se nos eventos disponíveis.",
      "category": "Eventos",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajuda"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título e descrição
              Text(
                "Precisa de ajuda?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Encontre respostas para suas dúvidas ou entre em contato conosco.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),

              // Campo de busca
              TextField(
                decoration: InputDecoration(
                  hintText: "Pesquisar ajuda...",
                  prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Categorias de ajuda
              Text(
                "Categorias",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildCategoryButton("Posts", Icons.post_add),
                  _buildCategoryButton("Perfil", Icons.person),
                  _buildCategoryButton("Eventos", Icons.event),
                  _buildCategoryButton("Suporte", Icons.support_agent),
                ],
              ),
              SizedBox(height: 20),

              // Perguntas frequentes
              Text(
                "Perguntas Frequentes",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              ...faqs.map((faq) {
                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      faq["question"]!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          faq["answer"]!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              SizedBox(height: 20),

              // Botão de contato
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Lógica para entrar em contato
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Redirecionando para o suporte...")),
                    );
                  },
                  icon: Icon(Icons.contact_support),
                  label: Text("Entrar em Contato"),
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

  Widget _buildCategoryButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        // Lógica para filtrar por categoria
      },
      icon: Icon(icon, color: Colors.blueAccent),
      label: Text(
        label,
        style: TextStyle(color: Colors.blueAccent),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.blueAccent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}