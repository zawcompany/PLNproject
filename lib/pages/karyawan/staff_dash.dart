import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:monitoring_app/widgets/navbar.dart';
import '../../models/item_model.dart';
import '../../services/database_service.dart';
import 'detail.dart';
import 'wisma_int_general.dart'; 
import 'wisma_eks_general.dart';
import 'kelas_general.dart'; 

class DashboardAlternative extends StatefulWidget {
  const DashboardAlternative({super.key});

  @override
  State<DashboardAlternative> createState() => _DashboardAlternativeState();
}

class _DashboardAlternativeState extends State<DashboardAlternative> {
  static const Color primaryTeal = Color(0xFF008996);
  static const Color blueBoxColor = Color(0xffbfe0e6);
  
  final DatabaseService _db = DatabaseService();

  void _showBookingTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          // Memperlebar dialog secara horizontal
          width: MediaQuery.of(context).size.width * 0.9, 
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Garis handle kecil di atas agar terlihat seperti modal kekinian
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Pilih Kategori Tamu",
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 18,
                  color: primaryTeal
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tentukan jenis wisma sesuai kebutuhan Anda",
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              
              // Tombol Siswa (Internal) - Dibuat Full Width & Lebih Tinggi
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); 
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FormWismaGeneralInternal()));
                  },
                  // icon: const Icon(Icons.school_outlined, size: 20),
                  label: const Text("Siswa Pembelajaran", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryTeal,
                    side: const BorderSide(color: primaryTeal, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Tombol Beyond KwH (Eksternal) - Dibuat Full Width & Lebih Tinggi
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FormWismaGeneralEksternal()));
                  },
                  // icon: const Icon(Icons.public_outlined, color: Colors.white, size: 20),
                  label: const Text("Beyond KwH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 10), 
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: StreamBuilder<List<ItemModel>>(
        stream: _db.getItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryTeal));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Gagal memuat data"));
          }

          final allItems = snapshot.data ?? [];
          final wismaData = allItems.where((item) => item.type == ItemType.wisma).toList();
          final kelasData = allItems.where((item) => item.type == ItemType.kelas).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP HEADER
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
                            color: blueBoxColor.withValues(alpha: 0.5),
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

                      const SizedBox(height: 25),

                      // Box Status
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
          );
        },
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
              color: Colors.black.withValues(alpha: 0.05),
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
        height: 135, 
        viewportFraction: 0.52, 
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
              borderRadius: BorderRadius.circular(18), 
              image: DecorationImage(
                image: item.imagePath.startsWith('http') 
                    ? NetworkImage(item.imagePath) as ImageProvider 
                    : AssetImage(item.imagePath), 
                fit: BoxFit.cover
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.bottomLeft,
              child: Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
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