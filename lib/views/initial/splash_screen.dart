import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:stivy/views/auth/login/login_screen.dart';
import 'package:stivy/views/initial/onboarding_screen.dart';
import 'package:stivy/views/home/mainScreen.dart';

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

    await Future.delayed(Duration(seconds: 2));

    if (userProvider.isLoggedIn) {
      Get.off(() => MainScreen());
    } else {
      if (userProvider.hasSeenOnboarding) {
        Get.off(() => LoginScreen());
      } else {
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
              ),
              SizedBox(height: 20),
              Text(
                'Moda e Eventos de Moda',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}