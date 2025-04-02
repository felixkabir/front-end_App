import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:stivy/providers/agency_provider.dart';
import 'package:stivy/providers/interest_provider.dart';
import 'package:stivy/providers/user_provider.dart';
import 'package:stivy/services/interests/interests_service.dart'; 
import 'package:stivy/views/initial/splash_screen.dart';

void main() {
  final interestService = InterestService();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AgencyProvider()),
        ChangeNotifierProvider(create: (_) => InterestProvider(interestService)), // Pass the service
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stivy',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: SplashScreen(),
    );
  }
}