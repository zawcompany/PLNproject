import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:monitoring_app/widgets/navbar.dart'; 
import '../../models/item_model.dart';
import '../../services/database_service.dart';
import '../../models/booking_model.dart';
import 'form_edit_jenis.dart'; 
import '../karyawan/detail.dart'; 

class DashApproval extends StatefulWidget {
  const DashApproval({super.key});

  @override
  State<DashApproval> createState() => _DashApprovalState();
}

class _DashApprovalState extends State<DashApproval> {
  final DatabaseService _db = DatabaseService();
  static const Color primaryTeal = Color(0xFF008996);
  static const Color blueBoxColor = Color(0xffbfe0e6);

  // FUNGSI DIALOG UTAMA: Pilih Wisma atau Kelas
  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pilih Jenis Pesanan", style: TextStyle(fontWeight: FontWeight.bold, color: primaryTeal)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption(
              icon: Icons.home_work_outlined,
              label: "Kamar Wisma",
              onTap: () {
                Navigator.pop(context);
                _showWismaTypeDialog(); // Lanjut ke pilihan Internal/Eksternal
              },
            ),
            const Divider(),
            _buildDialogOption(
              icon: Icons.school_outlined,
              label: "Ruang Kelas",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/kelas_general');
              },
            ),
          ],
        ),
      ),
    );
  }

  // FUNGSI DIALOG KEDUA: Pilih Internal atau Eksternal untuk Wisma
  void _showWismaTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kategori Tamu Wisma", style: TextStyle(fontWeight: FontWeight.bold, color: primaryTeal)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption(
              icon: Icons.badge_outlined,
              label: "Internal (Karyawan/NIP)",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/wisma_int_general');
              },
            ),
            const Divider(),
            _buildDialogOption(
              icon: Icons.public_outlined,
              label: "Eksternal (Umum/NIK)",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/wisma_eks_general');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk item pilihan di dalam Dialog
  Widget _buildDialogOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: primaryTeal.withOpacity(0.1),
        child: Icon(icon, color: primaryTeal, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
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
            _buildTopHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildWelcomeSection(context),
                  const SizedBox(height: 25),
                  
                  _buildRealtimeStats(),

                  // TOMBOL PESAN (Dibawah Box Statistik)
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _showBookingDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                      label: const Text("Buat Pesanan Baru", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  const Divider(color: Colors.black12, thickness: 1),
                  const SizedBox(height: 10),

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

  Widget _buildRealtimeStats() {
    return Row(
      children: [
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
                  title: "Pesanan Masuk",
                  svgPath: "lib/assets/images/rumahdpn.svg",
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
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
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selamat Datang,", style: TextStyle(fontSize: 14, color: Colors.black54)),
            Text("Admin PLN UDPL", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal)),
          ],
        ),
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
      options: CarouselOptions(
        height: 140, 
        viewportFraction: 0.52, 
        enableInfiniteScroll: false, 
        padEnds: false,
        disableCenter: true,
      ),
      items: data.map((item) {
        return GestureDetector(
          onTap: () {
            // NAVIGASI KE DETAIL KHUSUS APPROVAL
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailKelasPage(item: item),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16), 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18), 
              image: DecorationImage(
                image: item.imagePath.startsWith('http') 
                    ? NetworkImage(item.imagePath) as ImageProvider 
                    : AssetImage(item.imagePath), 
                fit: BoxFit.cover
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, 
                  end: Alignment.topCenter, 
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent]
                ),
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.bottomLeft,
              child: Text(
                item.title, 
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
              ),
            ),
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