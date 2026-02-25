import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; 
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
            .get(const GetOptions(source: Source.server));

        if (doc.exists && mounted) {
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
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  Future<void> _launchTutorial() async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=your_video_id'); 
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _handleNavigation(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(
        context, 
        role == 'approval' ? '/approval_dash' : '/staff_dash'
      );
    } else if (index == 1) {
      Navigator.pushReplacementNamed(
        context, 
        role == 'approval' ? '/riwayat_approval' : '/riwayat_staff' 
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
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none, 
      children: [
        SizedBox(
          width: double.infinity,
          height: 120, 
          child: SvgPicture.asset(
            'lib/assets/images/header_riwayat.svg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: -120, 
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  // Perbaikan withOpacity ke withValues
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 50, 
              backgroundColor: Color(0xFFE0E6E6),
              child: Icon(Icons.person, size: 65, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        const SizedBox(height: 132), 
        Text(
          name, 
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: primaryColor
          )
        ),
        const SizedBox(height: 4),
        Text(email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildMenuButtons() {
    return Column(
      children: [
        _menuItem(Icons.edit_outlined, "Edit Profil", onTap: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => const DialogEditProfil(),
          );

          if (result == true && mounted) {
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
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists && mounted) {
        setState(() {
          _nameController.text = doc.data()?['name'] ?? "";
          _emailController.text = doc.data()?['email'] ?? "";
          _isFetching = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPwController.dispose();
    _newPwController.dispose();
    super.dispose();
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Edit Profil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    IconButton(
                      onPressed: () => Navigator.pop(context), 
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20)
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFF0F4F4)),
                const SizedBox(height: 20),
                Center(child: _buildAvatarPicker()),
                const SizedBox(height: 30),
                _fieldLabel("Nama Lengkap"),
                _buildTextField(_nameController, "Contoh: user", Icons.person_outline),
                const SizedBox(height: 20),
                _fieldLabel("Email"),
                _buildTextField(_emailController, "user@mail.com", Icons.email_outlined),
                const SizedBox(height: 20),
                _fieldLabel("Password Baru (Opsional)"),
                _buildTextField(_newPwController, "••••••••", Icons.lock_open_outlined, isPassword: true, isNew: true),
                const SizedBox(height: 20),
                _fieldLabel("Konfirmasi Password Lama"),
                _buildTextField(_oldPwController, "Wajib diisi untuk simpan", Icons.lock_outline, isPassword: true, isNew: false),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008996),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      // Simpan navigator sebelum async gap
                      final navigator = Navigator.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );

                        final user = FirebaseAuth.instance.currentUser;
                        final cred = EmailAuthProvider.credential(
                          email: user!.email!,
                          password: _oldPwController.text.trim(),
                        );

                        await user.reauthenticateWithCredential(cred);

                        if (_emailController.text.trim() != user.email) {
                          await user.verifyBeforeUpdateEmail(_emailController.text.trim());
                        }

                        if (_newPwController.text.trim().isNotEmpty) {
                          await user.updatePassword(_newPwController.text.trim());
                        }

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .update({
                          'name': _nameController.text.trim(),
                          'email': _emailController.text.trim(),
                        });

                        if (!mounted) return;
                        
                        // Gunakan instance navigator yang sudah disimpan
                        navigator.pop(); // Tutup Loading
                        navigator.pop(true); // Tutup Dialog & kirim true
                        
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(content: Text("Profil berhasil diperbarui")),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        navigator.pop(); // Tutup Loading
                        
                        String errorMsg = e.toString();
                        if (errorMsg.contains("wrong-password")) {
                          errorMsg = "Password lama salah";
                        }

                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text("Gagal: $errorMsg"), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }

  Widget _buildAvatarPicker() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF0F4F4), width: 2),
          ),
          child: CircleAvatar(
            radius: 45,
            backgroundColor: const Color(0xFFF8FBFB),
            backgroundImage: _image != null ? FileImage(_image!) : null,
            child: _image == null 
              ? const Icon(Icons.person, size: 40, color: Color(0xFF008996)) 
              : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: _getImage,
            child: const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFF008996),
              child: Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, bool isNew = true}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? (isNew ? _isObscureNew : _isObscureOld) : false,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF008996), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FBFB),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFF0F4F4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF008996)),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (isNew ? _isObscureNew : _isObscureOld) ? Icons.visibility_off : Icons.visibility,
                  size: 18, color: Colors.grey,
                ),
                onPressed: () => setState(() {
                  if (isNew) _isObscureNew = !_isObscureNew;
                  else _isObscureOld = !_isObscureOld;
                }),
              )
            : null,
      ),
      validator: (val) {
        if (!isPassword || !isNew) { 
          if (val == null || val.trim().isEmpty) return "Bagian ini wajib diisi";
        }
        return null;
      },
    );
  }
}