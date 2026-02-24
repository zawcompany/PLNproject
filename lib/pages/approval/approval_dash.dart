import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:monitoring_app/widgets/navbar.dart'; 
import '../../models/item_model.dart';
import '../../data/exsistingdata.dart';
import 'form_edit_jenis.dart'; 

class DashApproval extends StatefulWidget {
  const DashApproval({super.key});

  @override
  State<DashApproval> createState() => _DashApprovalState();
}

class _DashApprovalState extends State<DashApproval> {
  static const Color primaryTeal = Color(0xFF008996);

  final List<ItemModel> wismaData = LocalData.items
      .where((item) => item.type == ItemType.wisma)
      .toList();
  
  final List<ItemModel> kelasData = LocalData.items
      .where((item) => item.type == ItemType.kelas)
      .toList();

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
                // Header Profil
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Selamat Datang", style: TextStyle(fontSize: 16)),
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
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/notif_approval'); 
                      },
                    icon: const Icon(Icons.notifications_none, size: 28))
                  ],
                ),
                const SizedBox(height: 25),
                
                // Grid Status 
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/riwayat_approval'),
                        child: _buildStatBox(
                          bgColor: const Color(0xffbfe0e6),
                          angka: jumlahPermintaan.toString(),
                          title: "Permintaan",
                          svgPath: "lib/assets/images/rumahdpn.svg",
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/riwayat_approval'),
                        child: _buildStatBox(
                          bgColor: const Color(0xffffd6d6),
                          angka: jumlahPengaduan.toString(),
                          title: "Pengaduan",
                          svgPath: "lib/assets/images/kelaswarning.svg",
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 25),
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
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/riwayat_approval');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profil');
          }
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: primaryTeal
          ),
        ),
        GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.5), 
            builder: (context) => FormEditJenis(
              type: title == "Jenis Wisma" ? ItemType.wisma : ItemType.kelas,
            ),
          );
        },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.edit_outlined, color: primaryTeal, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel(List<ItemModel> data) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 130,
        viewportFraction: 0.8,
        enableInfiniteScroll: false,
        padEnds: false, 
        scrollDirection: Axis.horizontal,
      ),
      items: data.map((item) {
        return Container(
          width: double.infinity,
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
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent
                ],
              ),
            ),
            padding: const EdgeInsets.all(12),
            alignment: Alignment.bottomLeft,
            child: Text(
              item.title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -4, left: 0, right: 0,
            child: SvgPicture.asset(svgPath, height: 70, fit: BoxFit.fitWidth),
          ),
          Center(
            child: Transform.translate(
              offset: const Offset(0, -25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(angka, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.0)),
                  const SizedBox(height: 2),
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}