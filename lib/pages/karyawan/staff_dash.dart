import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:monitoring_app/widgets/navbar.dart';
import '../../models/item_model.dart';
import '../../data/exsistingdata.dart';
import 'detail.dart';

class DashboardAlternative extends StatefulWidget {
  const DashboardAlternative({super.key});

  @override
  State<DashboardAlternative> createState() => _DashboardAlternativeState();
}

class _DashboardAlternativeState extends State<DashboardAlternative> {
  static const Color primaryTeal = Color(0xFF008996);
  // Warna box biru 
  static const Color blueBoxColor = Color(0xffbfe0e6); 
  
  final List<ItemModel> wismaData = LocalData.items
      .where((item) => item.type == ItemType.wisma)
      .toList();
  
  final List<ItemModel> kelasData = LocalData.items
      .where((item) => item.type == ItemType.kelas)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER SOLID COLOR (Warna sama dengan Box Biru)
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color:primaryTeal, 
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.8),
                    blueBoxColor, 
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // 2. Row Sapaan & Notifikasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Selamat Datang,", style: TextStyle(fontSize: 14, color: Colors.black54)),
                          Text(
                            "PLN UPDL Makassar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryTeal,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                            )
                          ]
                        ),
                        child: const Icon(Icons.notifications_none, color: primaryTeal),
                      )
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 3. Dua Box Status (Booking Wisma & Kelas)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          bgColor: blueBoxColor,
                          title: "Booking Wisma",
                          svgPath: "lib/assets/images/rumahdpn.svg",
                          imageOffset: -12.0, 
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatBox(
                          bgColor: const Color(0xffffd6d6),
                          title: "Booking Kelas",
                          svgPath: "lib/assets/images/kelas_headerdash.svg", 
                          imageOffset: -12.0, 
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Divider(color: Colors.black12, thickness: 1),
                  const SizedBox(height: 10),

                  // 4. Carousel Jenis Wisma
                  _buildSectionHeader("Jenis Wisma"),
                  const SizedBox(height: 12),
                  _buildCarousel(wismaData),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.black12, thickness: 1),
                  const SizedBox(height: 10),

                  // 5. Carousel Jenis Kelas
                  _buildSectionHeader("Jenis Kelas"),
                  const SizedBox(height: 12),
                  _buildCarousel(kelasData),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/riwayat');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profil');
          }
        },
      ),
    );
  }

  // Widget Box Status yang disempurnakan
  Widget _buildStatBox({
    required Color bgColor,
    required String title,
    required String svgPath,
    required double imageOffset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130, 
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
              bottom: imageOffset, 
              left: 0, 
              right: 0,
              child: SvgPicture.asset(
                svgPath, 
                height: 75, 
                fit: BoxFit.contain, 
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  title, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black87
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.bold, 
        color: primaryTeal
      ),
    );
  }

  Widget _buildCarousel(List<ItemModel> data) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 140,
        viewportFraction: 0.6, 
        enableInfiniteScroll: false,
        padEnds: false,
        scrollDirection: Axis.horizontal,
      ),
      items: data.map((item) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailKelasPage(item: item)),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: AssetImage(item.imagePath), 
                fit: BoxFit.cover
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                // Shadow hitam HANYA fokus di area bawah untuk teks
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8), // Hitam pekat di bawah
                    Colors.black.withOpacity(0.2), // Memudar cepat
                    Colors.transparent,           // Bersih dari tengah ke atas
                  ],
                  stops: const [0.0, 0.4, 0.6], // Mengatur bayangan agar tidak naik ke atas
                ),
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.bottomLeft,
              child: Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 12, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}