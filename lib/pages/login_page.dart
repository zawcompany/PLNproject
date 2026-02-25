import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import '../../data/exsistingdata.dart';
import 'lupa_pw_page.dart';
import 'regis_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginUser() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSnackBar("Email dan Password tidak boleh kosong", Colors.orange);
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Proses Sign In
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final db = DatabaseService();
      await db.seedDataAndInitialComplaints(LocalData.items);

      String uid = userCredential.user!.uid;

      // Ambil data user dari Firestore untuk cek Role
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        throw Exception("Profil user tidak ditemukan di database.");
      }

      String role = userDoc['role'];

      if (!mounted) return;

      // Navigasi & Hapus History (User tidak bisa 'back' ke halaman login setelah masuk)
      if (role == "approval") {
        Navigator.pushNamedAndRemoveUntil(context, '/approval_dash', (route) => false);
      } else if (role == "karyawan") {
        Navigator.pushNamedAndRemoveUntil(context, '/staff_dash', (route) => false);
      } else {
        _showSnackBar("Role akun tidak dikenali. Hubungi Admin.", Colors.red);
      }

    } on FirebaseAuthException catch (e) {
      String errorMsg = "Terjadi kesalahan login";
      if (e.code == 'user-not-found') errorMsg = "Email tidak terdaftar";
      else if (e.code == 'wrong-password') errorMsg = "Password salah";
      else if (e.code == 'invalid-email') errorMsg = "Format email salah";
      
      _showSnackBar(errorMsg, Colors.redAccent);
    } catch (e) {
      _showSnackBar("Sistem Error: ${e.toString()}", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const Color primaryTeal = Color(0xFF008996);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Ilustrasi di bagian atas
          Positioned(
            top: size.height * 0.05,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              "lib/assets/images/welcome_pict.svg",
              width: size.width,
              height: size.height * 0.3,
              fit: BoxFit.contain,
            ),
          ),
          
          // Container Form Login
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.65,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Masuk",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Silakan masuk untuk melanjutkan reservasi.",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 35),

                    _buildLabel("Email"),
                    _buildTextField(
                      controller: _emailController,
                      hintText: "Masukkan email Anda",
                      prefixIcon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 20),

                    _buildLabel("Password"),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: "Masukkan password Anda",
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                          );
                        },
                        child: const Text("Lupa password?", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w600)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tombol Masuk
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : loginUser,
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Belum punya akun? ", style: TextStyle(color: Colors.grey)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                            child: const Text("Daftar Sekarang", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscureText : false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(prefixIcon, color: Colors.grey, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey, size: 20),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}