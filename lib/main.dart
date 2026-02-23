import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), 
        Locale('en', 'US'), 
      ],
      locale: const Locale('id', 'ID'), 
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF008996),
        ),
      ),
      // home: const WelcomePage(),
      home: const DashApproval(),
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