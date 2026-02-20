import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monitoring_app/widgets/navbar.dart'; 

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  final Color primaryColor = const Color(0xFF008996);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildTitle(),
          Expanded(
            child: _buildHistoryList(),
          ),
        ],
      ),
      // --- PENERAPAN NAVBAR ---
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/kdash_wisma');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profil');
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      height: 220,
      child: SvgPicture.asset(
        'lib/assets/images/header_riwayat.svg', 
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Riwayat",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF008996),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    // Data dummy riwayat contoh
    final List<Map<String, dynamic>> riwayatItems = [
      {"title": "Anggrek", "date": "12 Feb 2026", "status": "Selesai", "isSelesai": true},
      {"title": "Bougenville", "date": "10 Feb 2026", "status": "Selesai", "isSelesai": true},
      {"title": "Kelas A", "date": "08 Feb 2026", "status": "Proses", "isSelesai": false},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: riwayatItems.length,
      itemBuilder: (context, index) {
        final item = riwayatItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['date'],
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: item['isSelesai'] ? const Color(0xFFE0F2F3) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item['status'],
                  style: TextStyle(
                    color: item['isSelesai'] ? primaryColor : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}