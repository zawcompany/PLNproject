import 'package:flutter/material.dart';
import 'pages/welcome_page.dart'; 
import 'pages/login_page.dart';
import 'pages/regis_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Welcome UI',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF008996),
          primary: const Color(0xFF008996),
        ),
      ),
      home: const WelcomePage(), 
    );
  }
}