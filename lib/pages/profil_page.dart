import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widget/navbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final Color primaryColor = const Color(0xFF008996);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView( // Menggunakan Scroll agar aman di layar kecil
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildUserInfo(),
            const SizedBox(height: 30),
            _buildMenuButtons(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2, 
        onTap: (index) {
          if (index == 0) {
            // Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
             // Navigator.pushNamed(context, '/history');
          }
        },
      ),
    );
  }

  // Header SVG
  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          height: 220,
          child: SvgPicture.asset(
            'assets/header_profile.svg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: -50,
          child: CircleAvatar(
            radius: 65,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: const [
        SizedBox(height: 55),
        Text(
          'User',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          'useruser@gmail.com',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMenuButtons() {
    return Column(
      children: [
        _menuItem(Icons.edit_outlined, 'Edit profil'),
        _menuItem(Icons.play_circle_outline, 'Tutorial Penggunaan Aplikasi'),
        _menuItem(Icons.logout, 'Keluar', isLogout: true),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, {bool isLogout = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isLogout ? const Color(0xFFE0F2F3) : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
          top: isLogout ? BorderSide(color: Colors.grey.shade200, width: 0.5) : BorderSide.none,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}