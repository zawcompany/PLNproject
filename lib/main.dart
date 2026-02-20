import 'package:flutter/material.dart';
import 'pages/welcome_page.dart'; 
import 'pages/login_page.dart';
import 'pages/regis_page.dart';
import 'pages/karyawan/kdash_wisma.dart';
import 'pages/profil_page.dart';         

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoring App',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF008996),
          primary: const Color(0xFF008996),
        ),
      ),
      // Halaman pertama yang muncul
      home: const WelcomePage(), 

      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/kdash_wisma': (context) => const DashboardPage(), // Halaman Beranda
        '/riwayat': (context) => const Placeholder(),      // Ganti jika sudah ada file riwayat
        '/profil': (context) => const ProfileScreen(),    // Halaman Profil
      },
    );
  }
}