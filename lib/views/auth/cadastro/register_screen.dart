import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/gestures.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/views/auth/Login/login_screen.dart';
import 'package:stivy/views/home/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stivy/controllers/storage_controller.dart';
import 'package:http/http.dart' as http;
import 'package:stivy/views/home/mainScreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _selectedRole;
  File? _imageFile;

  final List<Map<String, String>> roles = [
    {'label': 'Amante de Moda', 'value': 'fashion_lover'},
    {'label': 'Modelo Freelancer', 'value': 'model'},
    {'label': 'Fotografo Freelancer', 'value': 'photographer'},
    {'label': 'Designer de Moda', 'value': 'designer'},
    {'label': 'Agencia', 'value': 'agency'},
  ];

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;
  final StorageController _storageData = StorageController();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
Future<void> _registerUser() async {
  if (_usernameController.text.isEmpty ||
      _emailController.text.isEmpty ||
      _passwordController.text.isEmpty ||
      _confirmPasswordController.text.isEmpty ||
      _selectedRole == null ||
      _imageFile == null) {
    Get.snackbar('Erro', 'Por favor, preencha todos os campos e selecione uma imagem.');
    return;
  }

  if (_passwordController.text != _confirmPasswordController.text) {
    Get.snackbar('Erro', 'As senhas não coincidem.');
    return;
  }

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.apiBaseUrl}/users/create'),
    );

    request.fields['username'] = _usernameController.text;
    request.fields['email'] = _emailController.text;
    request.fields['password'] = _passwordController.text;
    request.fields['role'] = _selectedRole!;

    var file = await http.MultipartFile.fromPath('file', _imageFile!.path);
    request.files.add(file);

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var responseMap = jsonDecode(responseData) as Map<String, dynamic>;

      final _userData = {
        ...responseMap, // Copia todos os dados da resposta
        'user': responseMap['user'], // Dados do usuário
        'access_token': responseMap['token'], // Token de acesso
      };

      print('💾 Dados do usuário atualizados: $_userData');

      // Armazena os dados no StorageController
      await _storageData.addStorage("auth", _userData);

      Get.snackbar('Sucesso', 'Usuário cadastrado com sucesso!');
      Get.to(() => MainScreen());
    } else {
      var errorData = await response.stream.bytesToString();
      var errorMap = jsonDecode(errorData) as Map<String, dynamic>;
      final errorMessage = errorMap['message'] ?? 'Falha ao cadastrar usuário.';
      Get.snackbar('Erro', errorMessage);
    }
  } catch (e) {
    // Erro de conexão ou servidor
    print('Erro durante o cadastro: $e');
    Get.snackbar(
      'Erro',
      'Não foi possível conectar ao servidor',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
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
                  ).animate().fadeIn(duration: const Duration(seconds: 1)).scale(delay: const Duration(seconds: 1)),
                ),
                SizedBox(height: 32),
                // Welcome Text
                Text(
                  'Olá! Cadastre-se na \nStivy',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 32),
                // Username Field
                _buildTextField(_usernameController, 'Nome Completo'),
                SizedBox(height: 16),
                // Email Field
                _buildTextField(_emailController, 'Email'),
                SizedBox(height: 16),
                // Role Selection
                _buildDropdown(),
                SizedBox(height: 16),
                // Password Field
                _buildPasswordField(_passwordController, 'Palavra passe', _isPasswordVisible, () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                }),
                SizedBox(height: 16),
                // Confirm Password Field
                _buildPasswordField(_confirmPasswordController, 'Confirmar Palavra passe', _isConfirmPasswordVisible, () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                }),
                SizedBox(height: 16),
                // Image Picker
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    child: Text(
                      _imageFile == null ? 'Selecionar Imagem' : 'Imagem Selecionada',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Register Button
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _registerUser,
                    child: Text(
                      'Cadastrar',
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
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(text: "Já tem uma conta? "),
                        TextSpan(
                          text: "Entrar Agora",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(() => LoginScreen());
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
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint, bool isVisible, VoidCallback toggleVisibility) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text('Selecione seu papel', style: TextStyle(color: Colors.white70)),
          value: _selectedRole,
          dropdownColor: Colors.purple.shade900,
          items: roles.map((role) {
            return DropdownMenuItem(
              value: role['value'],
              child: Text(role['label']!, style: TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRole = value;
            });
          },
        ),
      ),
    );
  }
}