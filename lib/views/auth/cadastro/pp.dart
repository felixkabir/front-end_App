import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:stivy/Api/ApiConfig.dart';
import 'package:stivy/models/user/user_model.dart';
import 'package:stivy/providers/interest_provider.dart';
import 'package:stivy/views/auth/login/login_screen.dart';

enum RegistrationStep {
  personalInfo,
  accountInfo,
  interests,
  profilePicture,
  review
}
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  RegistrationStep _currentStep = RegistrationStep.personalInfo;
  Gender _selectedGender = Gender.OTHER;
  UserType _selectedUserType = UserType.OTHER;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  File? _imageFile;
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Provider.of<InterestProvider>(context, listen: false).fetchInterests();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ... (seus métodos _pickImage, _clearForm, validações permanecem iguais)

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _clearForm() {
    setState(() {
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _imageFile = null;
      Provider.of<InterestProvider>(context, listen: false)
          .clearSelectedInterests();
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  bool _isValidName(String name) {
    return name.length > 3;
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final interestProvider =
        Provider.of<InterestProvider>(context, listen: false);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.apiBaseUrl}/users/create'),
      );

      request.fields['username'] = _usernameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['gender'] = _selectedGender.apiValue;
      request.fields['password'] = _passwordController.text;
      request.fields['type'] = _selectedUserType.apiValue;
      request.fields['interest_types'] = jsonEncode(interestProvider
          .selectedInterests
          .map((i) => i.interestType)
          .toList());

      if (_imageFile != null) {
        var file = await http.MultipartFile.fromPath('file', _imageFile!.path);
        request.files.add(file);
      }

      var response = await request.send().timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        await response.stream.bytesToString();
        Get.snackbar('Sucesso', 'Usuário cadastrado com sucesso!',
            backgroundColor: Colors.greenAccent);
        _clearForm();
        Get.offAll(() => LoginScreen());
      } else {
        var errorData = await response.stream.bytesToString();
        var errorMap = jsonDecode(errorData) as Map<String, dynamic>;
        final errorMessage =
            errorMap['message'] ?? 'Falha ao cadastrar usuário.';
        Get.snackbar('Erro', errorMessage);
      }
    } catch (e) {
      print('Erro durante o cadastro: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível conectar ao servidor',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _nextStep() {
    if (_currentStep == RegistrationStep.personalInfo &&
        !_validatePersonalInfo()) {
      return;
    } else if (_currentStep == RegistrationStep.accountInfo &&
        !_validateAccountInfo()) {
      return;
    } else if (_currentStep == RegistrationStep.interests &&
        Provider.of<InterestProvider>(context, listen: false)
            .selectedInterests
            .isEmpty) {
      Get.snackbar('Atenção', 'Selecione pelo menos um interesse');
      return;
    }

    setState(() {
      if (_currentStep.index < RegistrationStep.values.length - 1) {
        _currentStep = RegistrationStep.values[_currentStep.index + 1];
        _pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep.index > 0) {
        _currentStep = RegistrationStep.values[_currentStep.index - 1];
        _pageController.previousPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  bool _validatePersonalInfo() {
    if (_usernameController.text.isEmpty ||
        !_isValidName(_usernameController.text)) {
      Get.snackbar('Atenção', 'Nome deve ter mais de 3 caracteres');
      return false;
    }
    if (_selectedGender == Gender.OTHER) {
      Get.snackbar('Atenção', 'Selecione seu gênero');
      return false;
    }
    if (_selectedUserType == UserType.OTHER) {
      Get.snackbar('Atenção', 'Selecione seu tipo de usuário');
      return false;
    }
    return true;
  }

  bool _validateAccountInfo() {
    if (!_isValidEmail(_emailController.text)) {
      Get.snackbar('Atenção', 'Por favor, insira um email válido');
      return false;
    }
    if (!_isValidPassword(_passwordController.text)) {
      Get.snackbar('Atenção', 'A senha não atende os requisitos mínimos');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar('Atenção', 'As senhas não coincidem');
      return false;
    }
    return true;
  }

  Widget _buildStepIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: RegistrationStep.values.map((step) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentStep == step
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep != RegistrationStep.personalInfo)
            ElevatedButton(
              onPressed: _previousStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Voltar'),
            )
          else
            SizedBox(width: 100),
          ElevatedButton(
            onPressed: _currentStep == RegistrationStep.review
                ? _registerUser
                : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              _currentStep == RegistrationStep.review ? 'Finalizar' : 'Próximo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showMultiSelectDialog(InterestProvider interestProvider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Selecione seus interesses'),
          backgroundColor: Colors.purple.shade800,
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: interestProvider.interests.length,
              itemBuilder: (ctx, index) {
                final interest = interestProvider.interests[index];
                return CheckboxListTile(
                  title: Text(
                    interest.name,
                    style: TextStyle(color: Colors.white),
                  ),
                  value: interestProvider.selectedInterests.contains(interest),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        interestProvider.addSelectedInterest(interest);
                      } else {
                        interestProvider.removeSelectedInterest(interest);
                      }
                    });
                  },
                  activeColor: Colors.pinkAccent,
                  checkColor: Colors.white,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  title: Text(
                    'Cadastro',
                    style: TextStyle(color: Colors.white),
                  ),
                  centerTitle: true,
                ),
                _buildStepIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildPersonalInfoStep(),
                      _buildAccountInfoStep(),
                      _buildInterestsStep(),
                      _buildProfilePictureStep(),
                      _buildReviewStep(),
                    ],
                  ),
                ),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AnimationConfiguration.toStaggeredList(
          duration: Duration(milliseconds: 500),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            Text(
              'Informações Pessoais',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32),
            _buildTextField(
              _usernameController,
              'Nome Completo',
              validator: (value) {
                if (value == null || value.isEmpty || !_isValidName(value)) {
                  return 'Nome deve ter mais de 3 caracteres';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            _buildGenderDropdown(),
            SizedBox(height: 24),
            _buildUserTypeDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AnimationConfiguration.toStaggeredList(
          duration: Duration(milliseconds: 500),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            Text(
              'Informações da Conta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32),
            _buildTextField(
              _emailController,
              'Email',
              validator: (value) {
                if (value == null || value.isEmpty || !_isValidEmail(value)) {
                  return 'Por favor, insira um email válido';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24),
            _buildPasswordField(
              _passwordController,
              'Senha',
              _isPasswordVisible,
              () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    !_isValidPassword(value)) {
                  return 'Senha deve ter 8+ caracteres com letras, números e símbolos';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            _buildPasswordField(
              _confirmPasswordController,
              'Confirmar Senha',
              _isConfirmPasswordVisible,
              () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsStep() {
    final interestProvider = Provider.of<InterestProvider>(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seus Interesses',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Selecione pelo menos um interesse para personalizar sua experiência',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 32),
          if (interestProvider.interests.isEmpty)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            _buildInterestsGrid(interestProvider),
        ],
      ),
    );
  }

  Widget _buildInterestsGrid(InterestProvider interestProvider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: interestProvider.interests.map((interest) {
        final isSelected =
            interestProvider.selectedInterests.contains(interest);

        return ChoiceChip(
          label: Text(
            interest.name,
            style: TextStyle(
              color: isSelected ? Colors.purple.shade900 : Colors.white,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                interestProvider.addSelectedInterest(interest);
              } else {
                interestProvider.removeSelectedInterest(interest);
              }
            });
          },
          backgroundColor: Colors.transparent,
          selectedColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildProfilePictureStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Foto de Perfil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Adicione uma foto para que outros usuários possam te reconhecer',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 32),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: _imageFile == null
                    ? Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: Colors.white.withOpacity(0.5),
                      )
                    : ClipOval(
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _pickImage,
              child: Text(
                _imageFile == null ? 'Selecionar Foto' : 'Trocar Foto',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final interestProvider = Provider.of<InterestProvider>(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revise seus dados',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 32),
          _buildReviewItem('Nome', _usernameController.text),
          _buildReviewItem('Email', _emailController.text),
          _buildReviewItem('Gênero', _selectedGender.displayName),
          _buildReviewItem('Tipo de Usuário', _selectedUserType.displayName),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Interesses:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interestProvider.selectedInterests.map((interest) {
              return Chip(
                label: Text(
                  interest.name,
                  style: TextStyle(color: Colors.purple.shade900),
                ),
                backgroundColor: Colors.white,
              );
            }).toList(),
          ),
          SizedBox(height: 24),
          if (_imageFile != null)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(
            color: Colors.white.withOpacity(0.2),
            height: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              errorStyle: TextStyle(color: Colors.yellowAccent),
            ),
            validator: validator,
            keyboardType: keyboardType,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    bool isVisible,
    VoidCallback toggleVisibility, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: !isVisible,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              errorStyle: TextStyle(color: Colors.yellowAccent),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white.withOpacity(0.7),
                ),
                onPressed: toggleVisibility,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
 
  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<Gender>(
        value: _selectedGender,
        hint: Text(
          'selecione seu gênero',
          style: TextStyle(color: Colors.white70),
        ),
        dropdownColor: Colors.purple.shade800,
        style: TextStyle(color: Colors.white),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
        isExpanded: true,
        underline: SizedBox(),
        items: Gender.values.map((Gender gender) {
          return DropdownMenuItem<Gender>(
            value: gender,
            child: Text(
              gender.displayName,
              style: TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (Gender? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedGender = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildUserTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<UserType>(
        value: _selectedUserType,
        hint: Text(
          'selecione seu tipo',
          style: TextStyle(color: Colors.white70),
        ),
        dropdownColor: Colors.purple.shade800,
        style: TextStyle(color: Colors.white),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
        isExpanded: true,
        underline: SizedBox(),
        items: UserType.values.map((UserType type) {
          return DropdownMenuItem<UserType>(
            value: type,
            child: Text(
              type.displayName,
              style: TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (UserType? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedUserType = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildMultiSelectInterests(InterestProvider interestProvider) {
    if (interestProvider.interests.isEmpty) {
      return Center(
        child: Text(
          'Carregando interesses...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecione seus interesses',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () {
              _showMultiSelectDialog(interestProvider);
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      interestProvider.selectedInterests.isEmpty
                          ? 'Nenhum interesse selecionado'
                          : interestProvider.selectedInterests
                              .map((i) => i.name)
                              .join(', '),
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
