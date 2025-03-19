import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/providers/interest_provider.dart';
import 'package:stivy/views/auth/Login/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:stivy/models/interest/interests_model.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    // Busca os interesses ao inicializar a tela
    Provider.of<InterestProvider>(context, listen: false).fetchInterests();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

void _clearForm(){
  setState(() {
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _imageFile = null;
  });
}
  // Função para validar o email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@gmail.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Função para validar a senha
  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  // Função para validar o nome
  bool _isValidName(String name) {
    return name.length > 3;
  }

  Future<void> _registerUser() async {
    final interestProvider =
        Provider.of<InterestProvider>(context, listen: false);

    // Validações
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        interestProvider.selectedInterest == null ||
        _imageFile == null) {
      Get.snackbar('Erro',
          'Por favor, preencha todos os campos e selecione uma imagem.');
      return;
    }

    if (!_isValidName(_usernameController.text)) {
      Get.snackbar('Erro', 'O nome deve ter mais de 3 letras.');
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      Get.snackbar('Erro', 'Por favor, insira um email válido.');
      return;
    }

    if (!_isValidPassword(_passwordController.text)) {
      Get.snackbar('Erro',
          'A senha deve conter pelo menos 8 caracteres, incluindo letras, números e caracteres especiais.');
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
      request.fields['interest_types'] =
          jsonEncode([interestProvider.selectedInterest!.interestType]);

      var file = await http.MultipartFile.fromPath('file', _imageFile!.path);
      request.files.add(file);

      var response = await request.send().timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        await response.stream.bytesToString();
        Get.snackbar('Sucesso', 'Usuário cadastrado com sucesso!',
            backgroundColor: Colors.greenAccent);
            _clearForm();
        Get.to(() => LoginScreen());
      } else {
        var errorData = await response.stream.bytesToString();
        var errorMap = jsonDecode(errorData) as Map<String, dynamic>;
        final errorMessage =
            errorMap['message'] ?? 'Falha ao cadastrar usuário.';
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
    final interestProvider = Provider.of<InterestProvider>(context);

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
                  )
                      .animate()
                      .fadeIn(duration: const Duration(seconds: 1))
                      .scale(delay: const Duration(seconds: 1)),
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
                _buildTextField(_usernameController, 'Nome Completo'),
                SizedBox(height: 16),
                _buildTextField(_emailController, 'Email'),
                SizedBox(height: 16),
                _buildInterestDropdown(interestProvider),
                SizedBox(height: 16),
                _buildPasswordField(
                    _passwordController, 'Palavra passe', _isPasswordVisible,
                    () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                }),
                SizedBox(height: 16),
                _buildPasswordField(_confirmPasswordController,
                    'Confirmar Palavra passe', _isConfirmPasswordVisible, () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                }),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    child: Text(
                      _imageFile == null
                          ? 'Selecionar Imagem'
                          : 'Imagem Selecionada',
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

  Widget _buildPasswordField(TextEditingController controller, String hint,
      bool isVisible, VoidCallback toggleVisibility) {
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

  Widget _buildInterestDropdown(InterestProvider interestProvider) {
    if (interestProvider.interests.isEmpty) {
      return Center(
        child: Text(
          'Carregando interesses...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final uniqueInterests = interestProvider.interests.toSet().toList();
    final selectedInterest = interestProvider.selectedInterest;
    final isValidSelectedInterest = selectedInterest != null &&
        uniqueInterests.any((interest) => interest == selectedInterest);

    return DropdownButtonFormField<Interest>(
      value: isValidSelectedInterest ? selectedInterest : null,
      hint: Text(
        'Selecione um interesse',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      items: uniqueInterests.map((Interest interest) {
        return DropdownMenuItem(
          value: interest,
          child: Text(
            interest.name,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        );
      }).toList(),
      onChanged: (Interest? value) {
        interestProvider.selectInterest(value!);
      },
      alignment: Alignment.center,
      dropdownColor: Colors.purple.shade800,
      icon: Icon(
        Icons.arrow_drop_down,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }
}