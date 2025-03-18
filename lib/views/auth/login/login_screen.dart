import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/controllers/storage_controller.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:stivy/views/auth/cadastro/register_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stivy/views/home/mainScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  late final StorageController _storageStorage; 


  @override
  void initState() {
    super.initState();
    _initializeStorageController(); 
  }

  Future<void> _initializeStorageController() async {
    final prefs = await SharedPreferences.getInstance();
    _storageStorage = StorageController(prefs); 
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email';
    }
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
        Uri.parse('${ApiConfig.apiBaseUrl}/auth/user/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Login bem-sucedido: $responseData');

        final userData = responseData['user'];

        if (userData['agencies'] == null) {
          userData['agencies'] = [];
        }

        if (userData['interests'] == null) {
          userData['interests'] = [];
        }

        final _userData = {
          ...responseData, // Copia todos os dados da resposta
          'user': userData, // Dados do usuário
          'access_token': responseData['token'], // Token de acesso
        };

        print("Passou aqui : ${responseData}");
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userData); // Atualiza o estado do usuário
        await _storageStorage.addStorage("auth", _userData);

        Get.to(() => MainScreen());
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Erro no login';
        Get.snackbar(
          'Erro',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Erro durante o login: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível fazer o login. Tente novamente mais tarde.',
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
                  // No LoginScreen
                  TextButton(
                    onPressed: () {
                      Provider.of<UserProvider>(context, listen: false)
                          .setGuestMode(true);
                      Get.off(() => MainScreen());
                    },
                    child: Text(
                      'Entrar como Visitante',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
