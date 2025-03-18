import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:provider/provider.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:stivy/views/auth/login/login_screen.dart';
import 'package:stivy/views/home/mainScreen.dart';
import 'package:stivy/views/initial/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserState();
  }

  Future<void> _checkUserState() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Aguarde 2 segundos para exibir a tela de splash
    await Future.delayed(Duration(seconds: 2));

    // Verifique se o usuário está logado
    if (userProvider.isLoggedIn) {
      // Se estiver logado, vá para a HomePage
      Get.off(() => MainScreen());
    } else {
      // Se não estiver logado, verifique se já viu o onboarding
      if (userProvider.hasSeenOnboarding) {
        // Se já viu o onboarding, vá para a tela de Login
        Get.off(() => LoginScreen());
      } else {
        // Se não viu o onboarding, vá para a tela de Onboarding
        Get.off(() => OnboardingScreen());
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 200,
                height: 200,
              )
                  .animate()
                  .fadeIn(duration: const Duration(seconds: 1))
                  .scale(delay: const Duration(milliseconds: 500)),
              SizedBox(height: 20),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Moda e Eventos de Moda',
                      speed: Duration(milliseconds: 100),
                    ),
                  ],
                  repeatForever: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}