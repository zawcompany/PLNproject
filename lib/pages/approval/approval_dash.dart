import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:monitoring_app/widgets/navbar.dart'; 
import '../../models/item_model.dart'; 

class DashApproval extends StatefulWidget {
  const DashApproval({super.key});

  @override
  State<DashApproval> createState() => _DashApprovalState();
}

class _DashApprovalState extends State<DashApproval> {
  static const Color primaryTeal = Color(0xFF008996);

  // Data Dummy
  final List<Map<String, String>> wismaTypes = [
    {"title": "Cempaka", "img": "lib/assets/images/cempaka.png"},
    {"title": "Flamboyan", "img": "lib/assets/images/flamboyan.png"},
    {"title": "Gladiol", "img": "lib/assets/images/gladiol.png"},
    {"title": "Edelweiss", "img": "lib/assets/images/edelweiss.png"},
    {"title": "Bougenville", "img": "lib/assets/images/bougenville.png"},
  ];

  final List<Map<String, String>> kelasTypes = [
    {"title": "Kelas A", "img": "lib/assets/images/kelas_a.png"},
    {"title": "Kelas B", "img": "lib/assets/images/kelas_b.png"},
    {"title": "Aula", "img": "lib/assets/images/aula.png"},
  ];

  @override
  Widget build(BuildContext context) {
    int jumlahPermintaan = 5;
    int jumlahPengaduan = 5;

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Selamat Datang, User", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text(
                          "PLN UDPL Makassar",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.notifications_none, size: 28)
                  ],
                ),

                const SizedBox(height: 25),

                // grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        bgColor: const Color(0xffbfe0e6),
                        angka: jumlahPermintaan.toString(),
                        title: "Permintaan",
                        svgPath: "lib/assets/images/rumahdpn.svg",
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildStatBox(
                        bgColor: const Color(0xffffd6d6),
                        angka: jumlahPengaduan.toString(),
                        title: "Pengaduan",
                        svgPath: "lib/assets/images/kelaswarning.svg",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
                const Divider(color: Colors.black12, thickness: 1),
                const SizedBox(height: 15),

                // bagian wisma
                _buildSectionHeader("Jenis Wisma"),
                const SizedBox(height: 10),
                _buildCarousel(wismaTypes),

                const SizedBox(height: 25),

                // bagian kelas
                _buildSectionHeader("Jenis Kelas"),
                const SizedBox(height: 10),
                _buildCarousel(kelasTypes),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) Navigator.pushReplacementNamed(context, '/profil');
          if (index == 1) Navigator.pushReplacementNamed(context, '/riwayat');
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal),
        ),
        const Icon(Icons.add_circle, color: primaryTeal, size: 28),
      ],
    );
  }

  Widget _buildCarousel(List<Map<String, String>> data) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        viewportFraction: 0.9, 
        enableInfiniteScroll: false, 
        enlargeCenterPage: false, 
        padEnds: false, 
      ),
      items: data.map((item) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(right: 10), 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(image: AssetImage(item['img']!), fit: BoxFit.cover),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.all(15),
            alignment: Alignment.bottomLeft,
            child: Text(
              item['title']!,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatBox({
    required Color bgColor,
    required String angka,
    required String title,
    required String svgPath,
  }) {
    return Container(
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -4,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              svgPath,
              height: 70,
              fit: BoxFit.fitWidth,
            ),
          ),
          Center(
            child: Transform.translate(
              offset: const Offset(0, -25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    angka,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.0),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}