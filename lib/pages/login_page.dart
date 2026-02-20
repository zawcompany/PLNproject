import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'lupa_pw_page.dart';
import 'regis_page.dart';
import 'karyawan/kdash_wisma.dart';
import '../../models/user_session.dart'; // Sesuaikan path file user_session Anda

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  
  // 1. Tambahkan Controller untuk mengambil teks dari input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Bersihkan controller saat widget dihapus dari memori
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
          Positioned(
            top: size.height * 0.05,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              "lib/assets/images/welcome_pict.svg",
              width: size.width,
              fit: BoxFit.contain,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.6, 
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Masuk",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryTeal,
                      ),
                    ),
                    const Text(
                      "Gunakan akun terdaftar untuk mengakses sistem.",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // Input Email
                    const Text("Email", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController, // Hubungkan controller
                      hintText: "Masukkan email",
                      prefixIcon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 20),

                    // Input Password
                    const Text("Password", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: "Masukkan password",
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    // Lupa Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Lupa password",
                          style: TextStyle(color: primaryTeal),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tombol Masuk
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          // 2. Logika Navigasi & Role
                          String email = _emailController.text.toLowerCase();

                          if (email.contains("admin") || email.contains("approver")) {
                            UserSession.role = "approval"; // Set ke role approval
                            Navigator.pushReplacementNamed(context, '/dash_approval');
                          } else {
                            UserSession.role = "karyawan"; // Set ke role karyawan
                            Navigator.pushReplacementNamed(context, '/kdash_wisma');
                          }
                        },
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Footer Daftar
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Belum punya akun? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                            child: const Text(
                              "Daftar",
                              style: TextStyle(
                                color: primaryTeal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  // 3. Perbarui fungsi buildTextField untuk menerima controller
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller, 
        obscureText: isPassword ? _obscureText : false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(prefixIcon, color: Colors.grey),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}