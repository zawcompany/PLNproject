import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monitoring_app/widgets/navbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final Color primaryColor = const Color(0xFF008996);

  Future<void> _launchYouTube() async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=link_video_tutorial_anda');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Konfirmasi Keluar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?", style: TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey, fontSize: 14)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Keluar", style: TextStyle(color: Colors.red, fontSize: 14)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildUserInfo(),
            const SizedBox(height: 30),
            _buildMenuButtons(context),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/kdash_wisma');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/riwayat');
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          height: 220,
          child: SvgPicture.asset(
            'lib/assets/images/header_riwayat.svg',
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
              child: const Icon(Icons.person, size: 60, color: Colors.white),
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'useruser@gmail.com',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Column(
      children: [
        _menuItem(
          Icons.edit_outlined,
          'Edit profil',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const DialogEditProfil(),
            );
          },
        ),
        _menuItem(
          Icons.play_circle_outline,
          'Tutorial Penggunaan Aplikasi',
          onTap: _launchYouTube,
        ),
        _menuItem(
          Icons.logout,
          'Keluar',
          isLogout: true,
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title,
      {required VoidCallback onTap, bool isLogout = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isLogout ? const Color(0xFFE0F2F3) : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
          top: isLogout ? BorderSide(color: Colors.grey.shade200, width: 0.5) : BorderSide.none,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, size: 22, color: isLogout ? const Color(0xFF008996) : Colors.black87),
        title: Text(title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isLogout ? const Color(0xFF008996) : Colors.black87,
            )),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class DialogEditProfil extends StatefulWidget {
  const DialogEditProfil({super.key});

  @override
  State<DialogEditProfil> createState() => _DialogEditProfilState();
}

class _DialogEditProfilState extends State<DialogEditProfil> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(text: "User");
  final TextEditingController _emailController = TextEditingController(text: "useruser@gmail.com");
  final TextEditingController _oldPwController = TextEditingController();
  final TextEditingController _newPwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  File? _image;
  final picker = ImagePicker();
  bool _isObscureNew = true;
  bool _isObscureOld = true;

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: MediaQuery.of(context).size.width * 0.95,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Edit Profil",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF008996)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                
                // Fitur Edit Foto Profil
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFFE0E6E6),
                        backgroundImage: _image != null ? FileImage(_image!) : null,
                        child: _image == null 
                          ? const Icon(Icons.person, size: 45, color: Colors.white) 
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _getImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF008996),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Data Diri"),
                    _buildTextField(_nameController, "Nama Baru", Icons.person_outline),
                    const SizedBox(height: 12),
                    _buildTextField(_emailController, "Email Baru", Icons.email_outlined),
                    
                    const SizedBox(height: 20),
                    _buildLabel("Ganti Password (Opsional)"),
                    _buildTextField(_newPwController, "Password Baru", Icons.lock_open_outlined, isPassword: true, isNew: true),
                    const SizedBox(height: 12),
                    _buildTextField(_confirmPwController, "Konfirmasi Password Baru", Icons.check_circle_outline, isPassword: true, isNew: true),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider(color: Colors.black12),
                    ),
                    
                    _buildLabel("Konfirmasi Perubahan"),
                    _buildTextField(_oldPwController, "Masukkan Password Lama", Icons.lock_outline, isPassword: true, isNew: false),
                  ],
                ),
                
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008996),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isNew = true}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? (isNew ? _isObscureNew : _isObscureOld) : false,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF008996)),
        filled: true,
        fillColor: const Color(0xFFF8FBFB),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E6E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF008996), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(249, 58, 58, 0.711)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(249, 58, 58, 0.711), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (isNew ? _isObscureNew : _isObscureOld) ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    if (isNew) {
                      _isObscureNew = !_isObscureNew;
                    } else {
                      _isObscureOld = !_isObscureOld;
                    }
                  });
                },
              )
            : null,
      ),
      validator: (value) {
        if (label == "Masukkan Password Lama" && (value == null || value.isEmpty)) {
          return "Wajib diisi";
        }
        return null;
      },
    );
  }
}