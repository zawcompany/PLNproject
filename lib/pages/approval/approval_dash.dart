import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambah ini
import 'package:monitoring_app/widgets/navbar.dart'; 
import '../../models/item_model.dart';
import '../../services/database_service.dart'; // Tambah ini
import '../../models/booking_model.dart'; // Tambah ini
import 'form_edit_jenis.dart'; 

class DashApproval extends StatefulWidget {
  const DashApproval({super.key});

  @override
  State<DashApproval> createState() => _DashApprovalState();
}

class _DashApprovalState extends State<DashApproval> {
  final DatabaseService _db = DatabaseService(); // Inisialisasi Service
  static const Color primaryTeal = Color(0xFF008996);
  static const Color blueBoxColor = Color(0xffbfe0e6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP HEADER (Layout Tetap)
            _buildTopHeader(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildWelcomeSection(context),

                  const SizedBox(height: 25),

                  // 1. STATISTIK REAL-TIME
                  _buildRealtimeStats(),
                  
                  const SizedBox(height: 30),
                  const Divider(color: Colors.black12, thickness: 1),
                  const SizedBox(height: 10),

                  // 2. CAROUSEL DATA DARI DATABASE
                  StreamBuilder<List<ItemModel>>(
                    stream: _db.getItems(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      
                      final wismaData = snapshot.data!.where((item) => item.type == ItemType.wisma).toList();
                      final kelasData = snapshot.data!.where((item) => item.type == ItemType.kelas).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("Jenis Wisma"), 
                          const SizedBox(height: 12),
                          _buildCarousel(wismaData),

                          const SizedBox(height: 20),
                          const Divider(color: Colors.black12, thickness: 1),
                          const SizedBox(height: 10), 

                          _buildSectionHeader("Jenis Kelas"),
                          const SizedBox(height: 12),
                          _buildCarousel(kelasData),
                        ],
                      );
                    },
                  ),
                  
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
            Navigator.pushReplacementNamed(context, '/riwayat_approval');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profil');
          }
        },
      ),
    );
  }

  // WIDGET BARU: Ambil angka statistik langsung dari Firebase
  Widget _buildRealtimeStats() {
    return Row(
      children: [
        // Hitung Permintaan (Booking Pending)
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('bookings')
                .where('status', isEqualTo: BookingStatus.pending.name).snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/riwayat_approval'),
                child: _buildStatBox(
                  bgColor: blueBoxColor,
                  angka: count.toString(),
                  title: "Permintaan",
                  svgPath: "lib/assets/images/rumahdpn.svg",
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        // Hitung Pengaduan (Complaints Pending)
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('complaints')
                .where('status', isEqualTo: 'pending').snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/riwayat_approval'),
                child: _buildStatBox(
                  bgColor: const Color(0xffffd6d6),
                  angka: count.toString(),
                  title: "Pengaduan",
                  svgPath: "lib/assets/images/kelaswarning.svg",
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Header, Welcome, dan Carousel Helper tetap sama strukturnya agar UI tidak berubah
  Widget _buildTopHeader() {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: Stack(
        children: [
          Positioned.fill(child: SvgPicture.asset('lib/assets/images/header_riwayat.svg', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: blueBoxColor.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selamat Datang,", style: TextStyle(fontSize: 14, color: Colors.black54)),
            Text("PLN UDPL Makassar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal)),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/notif_approval'),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
            child: const Icon(Icons.notifications_none, color: primaryTeal),
          ),
        )
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal)),
        IconButton(
          onPressed: () {
            showDialog(context: context, builder: (context) => FormEditJenis(
              type: title == "Jenis Wisma" ? ItemType.wisma : ItemType.kelas,
            ));
          },
          icon: const Icon(Icons.edit_outlined, color: primaryTeal, size: 18),
        ),
      ],
    );
  }

  Widget _buildCarousel(List<ItemModel> data) {
    return CarouselSlider(
      options: CarouselOptions(height: 140, viewportFraction: 0.6, enableInfiniteScroll: false, padEnds: false),
      items: data.map((item) {
        return Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: item.imagePath.startsWith('http') 
                  ? NetworkImage(item.imagePath) as ImageProvider 
                  : AssetImage(item.imagePath), 
              fit: BoxFit.cover
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent]),
            ),
            padding: const EdgeInsets.all(12),
            alignment: Alignment.bottomLeft,
            child: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatBox({required Color bgColor, required String angka, required String title, required String svgPath}) {
    return Container(
      height: 130, 
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Stack(
        children: [
          Positioned(bottom: -5, left: 0, right: 0, child: SvgPicture.asset(svgPath, height: 70, fit: BoxFit.contain)),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(angka, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.0)),
                  const SizedBox(height: 2),
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}