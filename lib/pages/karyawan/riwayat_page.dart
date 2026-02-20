import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monitoring_app/widgets/navbar.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final Color primaryColor = const Color(0xFF008996);

  // Fungsi untuk memunculkan Dialog Filter
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Filter Riwayat",
            style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterLabel("Jenis Wisma"),
                _buildSimpleDropdown(["Semua Wisma", "Anggrek", "Cempaka", "Bougenville", "Dahlia", "Edelweiss", "Flamboyan", "Gladiol", "Hortensia", "Toddopuli"]),
                const SizedBox(height: 15),
                _buildFilterLabel("Jenis Kelas"),
                _buildSimpleDropdown(["Semua Kelas", "Kelas A", "Kelas B", "Lab B", "Aula", "Kelas Toddopuli"]),
                const SizedBox(height: 15),
                _buildFilterLabel("Status"),
                _buildSimpleDropdown(["Semua Status", "Menunggu Konfirmasi", "Telah Dikonfirmasi"]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Terapkan", style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }

  Widget _buildSimpleDropdown(List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E6E6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items[0],
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 15),
          _buildTitleRow(),
          Expanded(
            child: _buildHistoryList(),
          ),
        ],
      ),
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

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Riwayat Pemesanan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
          ),
          // Tombol Ikon Filter
          GestureDetector(
            onTap: _showFilterDialog,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.filter_list_rounded, color: primaryColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    // Data contoh pemesanan
    final List<Map<String, dynamic>> riwayatItems = [
      {
        "title": "Anggrek",
        "detail": "Kamar No. 12 (Wisma)",
        "date": "12 Feb 2026",
        "bookDate": "25 Feb - 27 Feb 2026",
        "status": "Dikonfirmasi",
        "isSelesai": true
      },
      {
        "title": "Kelas A",
        "detail": "Lantai 2 (Gedung Utama)",
        "date": "10 Feb 2026",
        "bookDate": "01 Mar 2026",
        "status": "Menunggu",
        "isSelesai": false
      },
      {
        "title": "Toddopuli",
        "detail": "Kamar No. 05 (Wisma)",
        "date": "05 Feb 2026",
        "bookDate": "15 Feb - 16 Feb 2026",
        "status": "Dikonfirmasi",
        "isSelesai": true
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: riwayatItems.length,
      itemBuilder: (context, index) {
        final item = riwayatItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFF0F4F4)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(item['date'], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              Text(item['detail'], style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.w500)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFF0F4F4)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: primaryColor),
                      const SizedBox(width: 6),
                      Text(item['bookDate'], style: const TextStyle(fontSize: 11, color: Colors.black87)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item['isSelesai'] ? const Color(0xFFE0F2F3) : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['status'],
                      style: TextStyle(
                        color: item['isSelesai'] ? primaryColor : Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}