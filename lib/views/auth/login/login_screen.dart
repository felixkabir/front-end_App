import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stivy/views/auth/cadastro/register_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stivy/views/home/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:stivy/services/api_service.dart';
import 'dart:convert' ;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário

  // Função para validar o email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email';
    }
    // Expressão regular para validar o email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um email válido';
    }
    return null;
  }

  // Função para validar a senha
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  // Função para validar o telefone
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu telefone';
    }
    // Verifica se o telefone contém apenas dígitos
    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'O telefone deve conter apenas dígitos';
    }
    if (value.length <= 8) {
      return 'O telefone deve ter mais de 8 dígitos';
    }
    return null;
  }

// Função para realizar o login
Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final Map<String, dynamic> requestBody = {
        'email': email,
        'password': password,
      };

      final response = await http.post(
        Uri.parse('https://stivy-backend-ec0c.onrender.com/auth/user/login'), 
        headers: {
          'Content-Type': 'application/json', 
        },
        body: json.encode(requestBody), // Converte o corpo para JSON
      );

      // Verifica o status da resposta
      if (response.statusCode == 200) {
        // Login bem-sucedido
        final responseData = jsonDecode(response.body);
        print('Login bem-sucedido: $responseData');

        // Exemplo de como acessar os dados do usuário e o token
        final user = responseData['user'];
        final token = responseData['token'];

        print('Usuário: ${user['username']}');
        print('Token: $token');

        // Navega para a tela inicial
        Get.to(() => HomeScreen());
      } else {
        // Erro no login
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Erro no login';
        Get.snackbar(
          'Erro',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Erro de conexão ou servidor
      print('Erro durante o login: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível conectar ao servidor',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade900, Colors.pinkAccent.shade200],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey, // Chave do formulário
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(height: 22),
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 250,
                      height: 250,
                    )
                        .animate()
                        .fadeIn(duration: const Duration(seconds: 1))
                        .scale(delay: const Duration(seconds: 1)),
                  ),
                  SizedBox(height: 20),
                  // Welcome Text
                  Text(
                    'Bem-vindo de volta!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 32),
                  // Email Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      validator: _validateEmail, // Validação do email
                    ),
                  ),
                  SizedBox(height: 16),
                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Palavra passe',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: _validatePassword, // Validação da senha
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Esqueceu palavra passe?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Login Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _login, // Chama a função de login
                      child: Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.white),
                        children: [
                          TextSpan(text: "Não tem uma conta ainda? "),
                          TextSpan(
                            text: "Registar agora",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(() => RegisterScreen());
                              },
                            style: TextStyle(
                              color: Colors.yellowAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}