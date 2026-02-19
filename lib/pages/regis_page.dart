import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const Color primaryTeal = Color(0xFF008996);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

          // gambar
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

          // container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.68,
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Daftar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryTeal,
                      ),
                    ),

                    const Text(
                      "Lengkapi data berikut untuk membuat akun",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),

                    const SizedBox(height: 30),

                    // nama
                    const Text("Nama", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildTextField(
                      prefixIcon: Icons.person_outline,
                    ),

                    const SizedBox(height: 20),

                    // email
                    const Text("Email", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildTextField(
                      prefixIcon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 20),

                    // password
                    const Text("Password", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildTextField(
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      isConfirm: false,
                    ),

                    const SizedBox(height: 20),

                    // konfirmasi password
                    const Text("Konfirmasi Password",
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildTextField(
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      isConfirm: true,
                    ),

                    const SizedBox(height: 30),

                    // button daftar
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
                        onPressed: () {},
                        child: const Text(
                          "Daftar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // footer
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Sudah punya akun? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context, MaterialPageRoute(
                              builder: (context) => const LoginPage(),));
                            },
                            child: const Text(
                              "Masuk",
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

  Widget _buildTextField({
    required IconData prefixIcon,
    bool isPassword = false,
    bool isConfirm = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        obscureText: isPassword
            ? (isConfirm ? _obscureConfirm : _obscurePassword)
            : false,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(prefixIcon, color: Colors.grey),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (isConfirm ? _obscureConfirm : _obscurePassword)
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isConfirm) {
                        _obscureConfirm = !_obscureConfirm;
                      } else {
                        _obscurePassword = !_obscurePassword;
                      }
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
