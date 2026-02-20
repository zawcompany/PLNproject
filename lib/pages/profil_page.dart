import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // Tambahkan package url_launcher
import '../widgets/navbar.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryColor = const Color(0xFF008996);
  String name = "User";
  String email = "useruser@gmail.com";
  String role = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data();
          setState(() {
            name = data?['name'] ?? name;
            email = data?['email'] ?? email;
            role = (data?['role'] ?? "").toString().toLowerCase().trim();
          });
        }
      } catch (e) {
        debugPrint("Error loading user data: $e");
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  // Fungsi untuk membuka YouTube
  Future<void> _launchTutorial() async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=your_video_id'); // Ganti dengan link Anda
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // LOGIKA RUTE DINAMIS BERDASARKAN ROLE
  void _handleNavigation(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(
        context, 
        role == 'approval' ? '/approval' : '/kdash_wisma'
      );
    } else if (index == 1) {
      Navigator.pushReplacementNamed(
        context, 
        role == 'approval' ? '/riwayat_approval' : '/riwayat' 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 15),
                  _buildUserInfo(),
                  const SizedBox(height: 30),
                  _buildMenuButtons(),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      height: 220, // Disamakan ukurannya dengan RiwayatPage (220)
      child: SvgPicture.asset(
        'lib/assets/images/header_riwayat.svg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Color(0xFFE0E6E6),
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 15),
        Text(
          name, 
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: primaryColor
          )
        ),
        Text(email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
  Widget _buildMenuButtons() {
    return Column(
      children: [
        _menuItem(Icons.edit_outlined, "Edit Profil", onTap: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => const DialogEditProfil(),
          );

          if (result == true) {
            _loadUserData(); 
          }
        }),
        _menuItem(Icons.play_circle_outline, "Tutorial Penggunaan Aplikasi", onTap: _launchTutorial),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Divider(color: Color(0xFFF0F4F4)),
        ),
        _menuItem(Icons.logout_rounded, "Keluar", isLogout: true, onTap: () {
          _showLogoutConfirm();
        }),
      ],
    );
  }

  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin keluar?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _logout();
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {required VoidCallback onTap, bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isLogout ? const Color(0xFFFFEBEE) : const Color(0xFFF8FBFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F4F4)),
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : primaryColor),
        title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black87, fontWeight: FontWeight.w500, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

// --- BAGIAN DIALOG EDIT PROFIL ---

class DialogEditProfil extends StatefulWidget {
  const DialogEditProfil({super.key});

  @override
  State<DialogEditProfil> createState() => _DialogEditProfilState();
}

class _DialogEditProfilState extends State<DialogEditProfil> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _oldPwController = TextEditingController();
  final TextEditingController _newPwController = TextEditingController();

  File? _image;
  bool _isObscureNew = true;
  bool _isObscureOld = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
  }

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Edit Profil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF008996))),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                _buildAvatarPicker(),
                const SizedBox(height: 20),
                _buildTextField(_nameController, "Nama Baru", Icons.person_outline),
                const SizedBox(height: 10),
                _buildTextField(_emailController, "Email Baru", Icons.email_outlined),
                const Divider(height: 40),
                _buildTextField(_newPwController, "Password Baru (Opsional)", Icons.lock_open, isPassword: true, isNew: true),
                const SizedBox(height: 10),
                _buildTextField(_oldPwController, "Password Lama (Konfirmasi)", Icons.lock, isPassword: true, isNew: false),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008996),
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  // Di dalam class _DialogEditProfilState, pada bagian onPressed tombol Simpan:
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          // 1. Update di Firestore
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .update({
                            'name': _nameController.text,
                            'email': _emailController.text,
                          });

                          // 2. (Opsional) Update display name di Firebase Auth
                          await user.updateDisplayName(_nameController.text);

                          if (!mounted) return;
                          Navigator.pop(context, true); // Kirim 'true' sebagai tanda data berubah
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Profil berhasil diperbarui!")),
                          );
                        }
                      } catch (e) {
                        debugPrint("Gagal update profil: $e");
                      }
                    }
                  },
                  child: const Text("Simpan", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: _image != null ? FileImage(_image!) : null,
          child: _image == null ? const Icon(Icons.person, size: 40) : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: _getImage,
            child: const CircleAvatar(
              radius: 15,
              backgroundColor: Color(0xFF008996),
              child: Icon(Icons.camera_alt, size: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isNew = true}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? (isNew ? _isObscureNew : _isObscureOld) : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF008996)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon((isNew ? _isObscureNew : _isObscureOld) ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() {
                  if (isNew) {
                    _isObscureNew = !_isObscureNew;
                  } else {
                    _isObscureOld = !_isObscureOld;
                  }
                }),
              )
            : null,
      ),
      validator: (val) => (label.contains("Lama") && (val == null || val.isEmpty)) ? "Wajib diisi" : null,
    );
  }
}