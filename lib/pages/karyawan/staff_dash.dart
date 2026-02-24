import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:monitoring_app/widgets/navbar.dart';
import '../../models/item_model.dart';
import '../../data/exsistingdata.dart';
import 'detail.dart';
import 'wisma_int_general.dart'; 
import 'wisma_eks_general.dart';
import 'staff_notif.dart'; // Nama file disesuaikan dengan yang kita buat tadi
import 'kelas_general.dart'; // Nama file formulir kelas general

class DashboardAlternative extends StatefulWidget {
  const DashboardAlternative({super.key});

  @override
  State<DashboardAlternative> createState() => _DashboardAlternativeState();
}

class _DashboardAlternativeState extends State<DashboardAlternative> {
  static const Color primaryTeal = Color(0xFF008996);
  static const Color blueBoxColor = Color(0xffbfe0e6);

  final List<ItemModel> wismaData = LocalData.items
      .where((item) => item.type == ItemType.wisma)
      .toList();

  final List<ItemModel> kelasData = LocalData.items
      .where((item) => item.type == ItemType.kelas)
      .toList();

  // Fungsi Pop-up Pilihan Jenis Pesanan Wisma (General)
  void _showBookingTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Jenis Pesanan", 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text("Silahkan pilih kategori pemesanan untuk wisma:"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormWismaGeneralInternal(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF008996)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Internal", style: TextStyle(color: Color(0xFF008996))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormWismaGeneralEksternal(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008996),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Eksternal", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER
            SizedBox(
              width: double.infinity,
              height: 80,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SvgPicture.asset(
                      'lib/assets/images/header_riwayat.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: blueBoxColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
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
                          Text("Selamat Datang,",
                              style: TextStyle(fontSize: 14, color: Colors.black54)),
                          Text(
                            "PLN UPDL Makassar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryTeal,
                            ),
                          ),
                        ],
                      ),
                      // ICON NOTIFIKASI DENGAN NAVIGASI
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationStaffPage()),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                )
                              ]),
                          child: const Icon(Icons.notifications_none, color: primaryTeal),
                        ),
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
                          title: "Pemesanan Wisma",
                          svgPath: "lib/assets/images/rumahdpn.svg",
                          imageOffset: -12.0,
                          onTap: () => _showBookingTypeDialog(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatBox(
                          bgColor: const Color(0xffffd6d6),
                          title: "Peminjaman Kelas",
                          svgPath: "lib/assets/images/kelas_headerdash.svg",
                          imageOffset: -12.0,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FormKelasGeneral()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Divider(color: Colors.black12, thickness: 1),
                  const SizedBox(height: 10),

                  _buildSectionHeader("Jenis Wisma"),
                  const SizedBox(height: 12),
                  _buildCarousel(wismaData),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.black12, thickness: 1),
                  const SizedBox(height: 10),

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
            Navigator.pushReplacementNamed(context, '/riwayat_staff');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profil');
          }
        },
      ),
    );
  }

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
                      color: Colors.black87),
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
          fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal),
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
                  image: AssetImage(item.imagePath), fit: BoxFit.cover),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 0.6],
                ),
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.bottomLeft,
              child: Text(
                item.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}