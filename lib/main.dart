import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'pages/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/regis_page.dart';
import 'pages/karyawan/kdash_wisma.dart';
import 'pages/profil_page.dart';
import 'pages/karyawan/riwayat_page.dart';
import 'pages/approval/approval_dash.dart';
import 'pages/approval/riwayat_approval.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        ),
      ),
      home: const WelcomePage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/kdash_wisma': (context) => const DashboardPage(), // Dashboard Karyawan
        '/dash_approval': (context) => DashApproval(),      // Dashboard Approval
        '/riwayat': (context) => const RiwayatPage(),       // Riwayat Karyawan
        '/riwayat_approval': (context) => const RiwayatApprovalPage(), // Tambahkan ini jika belum ada
        '/profil': (context) => const ProfileScreen(),
      },
    );
  }
}