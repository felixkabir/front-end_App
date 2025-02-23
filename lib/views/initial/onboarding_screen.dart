import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stivy/views/auth/login/login_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OnboardingScreen extends StatelessWidget {
  final PageController _pageController = PageController();
  final List<List<Color>> gradients = [
    [Color(0xFFFF6B6B), Color(0xFFFF8E53)], // Vermelho vibrante para rosa
    [Color(0xFF4E65FF), Color(0xFF92EFFD)], // Azul elétrico para azul claro
    [Color(0xFF6B4DFF), Color(0xFFB966FF)], // Roxo profundo para lilás
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: 3,
        itemBuilder: (context, index) {
          return _buildPage(
            gradientColors: gradients[index],
            title: index == 0
                ? 'Bem-vindo a Stivy'
                : index == 1
                    ? 'Crie sua Agência'
                    : 'Conecte-se',
            description: index == 0
                ? 'Descubra as últimas tendências da moda.'
                : index == 1
                    ? 'Cadastre sua agência e gerencie modelos e fotógrafos.'
                    : 'Encontre modelos, fotógrafos e designers.',
            index: index,
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [Color(0xFF6B4DFF), Color(0xFFB966FF)],
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Get.off(() => LoginScreen());
          },
          backgroundColor: Colors.transparent,
          elevation: 8,
          child: Icon(Icons.arrow_forward, color: Colors.white),
        ).animate().fade(duration: 500.ms).moveY(begin: 20, end: 0),
      ),
    );
  }

  Widget _buildPage({
    required List<Color> gradientColors,
    required String title,
    required String description,
    required int index,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      padding: EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(index)
                .animate()
                .fade(duration: 800.ms)
                .scaleXY(begin: 0.5, end: 1.2),
            SizedBox(height: 50),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        title,
                        textStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        speed: Duration(milliseconds: 100),
                      ),
                    ],
                    isRepeatingAnimation: false,
                  ).animate().fade(duration: 1000.ms).slideX(begin: -1, end: 0),
                  SizedBox(height: 20),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ).animate().fade(duration: 1200.ms).slideX(begin: 1, end: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(int index) {
    IconData iconData = index == 0
        ? Icons.trending_up
        : index == 1
            ? Icons.business
            : Icons.connect_without_contact;

    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 80,
        color: Colors.white,
      ),
    );
  }
}