import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_page.dart';
import 'regis_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const Color primaryTeal = Color(0xFF008996);

  @override
  Widget build(BuildContext context) {
    // Menggunakan MediaQuery untuk responsivitas layout
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // Kita gunakan Stack untuk menumpuk gambar latar dan kotak putih di bawah
        child: Stack(
          children: [
            // --- BAGIAN ATAS: HEADER & GAMBAR ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Teks
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Halo!",
                        style: TextStyle(
                          fontSize: 28, // Ukuran sedikit diperbesar agar lebih tegas
                          fontWeight: FontWeight.bold,
                          color: primaryTeal,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Selamat datang di PLN UPDL Makassar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Gambar Ilustrasi
                // Menggunakan Container agar bisa mengontrol BoxFit dengan lebih presisi
                SizedBox(
                  width: size.width,
                  height: size.height * 0.38, 
                  child: SvgPicture.asset(
                    "lib/assets/images/welcome_pluskotak.svg",
                    width: size.width,
                    // BoxFit.contain mencegah gambar terpotong di layar HP yang pendek
                    fit: BoxFit.contain, 
                  ),
                ),
              ],
            ),

            // --- BAGIAN BAWAH: BOTTOM SHEET (BOX PUTIH) ---
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                // Ukuran box disesuaikan agar proporsional di berbagai ukuran layar
                height: size.height * 0.35, 
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 25,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    // Tombol Masuk
                    _buildButton(
                      context: context,
                      text: "Masuk", 
                      bgColor: primaryTeal, 
                      textColor: Colors.white, 
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "atau",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),

                    // Tombol Daftar
                    _buildButton(
                      context: context,
                      text: "Daftar", 
                      bgColor: Colors.white, 
                      textColor: primaryTeal, 
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      }, 
                      isOutlined: true,
                    ),
                    // Memberikan jarak aman di bawah (terutama untuk iPhone tanpa tombol home)
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Refactor widget tombol agar kode lebih bersih dan mudah dikelola
  Widget _buildButton({
    required BuildContext context,
    required String text, 
    required Color bgColor, 
    required Color textColor, 
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56, // Standar tinggi tombol aksesibilitas
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: isOutlined ? 0 : 2,
          // Menambahkan border jika tombol bersifat Outlined
          side: isOutlined ? BorderSide(color: textColor, width: 1.5) : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}