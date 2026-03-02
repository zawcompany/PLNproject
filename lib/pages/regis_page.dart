import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  // controller
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // state
  String _selectedRole = 'karyawan';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // fungsi registrasi
  Future<void> registerUser() async {

    // validasi field kosong
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showErrorSnackBar("Semua field wajib diisi");
      return;
    }

    // validasi konfirmasi password
    if (_passwordController.text != _confirmController.text) {
      _showErrorSnackBar("Konfirmasi password tidak sama");
      return;
    }

    // validasi panjang password
    if (_passwordController.text.length < 6) {
      _showErrorSnackBar("Password minimal 6 karakter");
      return;
    }

    try {
      setState(() => _isLoading = true);

      // register ke firebase auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // simpan profil ke firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // navigasi setelah register
      Navigator.pushNamedAndRemoveUntil(
          context, '/staff_dash', (route) => false);

      // if (_selectedRole == 'approval') {
      //   Navigator.pushNamedAndRemoveUntil(context, '/approval_dash', (route) => false);
      // } else {
      //   Navigator.pushNamedAndRemoveUntil(context, '/staff_dash', (route) => false);
      // }

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.message ?? "Terjadi kesalahan pendaftaran");
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // snackbar error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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

          // ilustrasi atas
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

          // container form register
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.73,
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
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // title
                    const Text(
                      "Daftar",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Silakan lengkapi data diri Anda.",
                      style: TextStyle(
                          fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // input nama
                    _labelField("Nama Lengkap"),
                    _buildTextField(
                        prefixIcon: Icons.person_outline,
                        controller: _nameController),

                    const SizedBox(height: 16),

                    // input email
                    _labelField("Email"),
                    _buildTextField(
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController),

                    const SizedBox(height: 16),

                    // input password
                    _labelField("Password"),
                    _buildTextField(
                        prefixIcon: Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true),

                    const SizedBox(height: 16),

                    // input konfirmasi password
                    _labelField("Konfirmasi Password"),
                    _buildTextField(
                        prefixIcon: Icons.lock_reset_outlined,
                        controller: _confirmController,
                        isPassword: true,
                        isConfirm: true),

                    const SizedBox(height: 30),

                    // tombol daftar
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed:
                            _isLoading ? null : registerUser,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Daftar Sekarang",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // redirect ke login
                    Center(
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Sudah punya akun? ",
                            style:
                                TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushReplacementNamed(
                                    context, '/login'),
                            child: const Text(
                              "Masuk",
                              style: TextStyle(
                                  color: primaryTeal,
                                  fontWeight:
                                      FontWeight.bold),
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

  // label field
  Widget _labelField(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 13),
        ),
      );

  // dropdown role
  Widget _buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey,
          ),
          items: const [
            DropdownMenuItem(
                value: 'karyawan',
                child: Text("Karyawan")),
            DropdownMenuItem(
                value: 'approval',
                child: Text("Approval")),
          ],
          onChanged: (val) =>
              setState(() => _selectedRole = val!),
        ),
      ),
    );
  }

  // textfield reusable
  Widget _buildTextField({
    required IconData prefixIcon,
    required TextEditingController controller,
    bool isPassword = false,
    bool isConfirm = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword
            ? (isConfirm
                ? _obscureConfirm
                : _obscurePassword)
            : false,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon:
              Icon(prefixIcon, color: Colors.grey, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (isConfirm
                            ? _obscureConfirm
                            : _obscurePassword)
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => setState(() {
                    if (isConfirm) {
                      _obscureConfirm =
                          !_obscureConfirm;
                    } else {
                      _obscurePassword =
                          !_obscurePassword;
                    }
                  }),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}