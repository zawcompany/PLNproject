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

  List<String> selectedWisma = ["Semua"];
  List<String> selectedKelas = ["Semua"];
  List<String> selectedStatus = ["Semua"];

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              title: Text(
                "Filter Riwayat",
                style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KATEGORI WISMA
                      _buildFilterLabel("Pilih Jenis Wisma"),
                      _buildFilterChips(
                        options: ["Semua", "Anggrek", "Cempaka", "Bougenville", "Dahlia", "Edelweiss", "Flamboyan", "Gladiol", "Hortensia", "Toddopuli"],
                        selectedList: selectedWisma,
                        onSelected: (val) {
                          setDialogState(() => _handleMultiSelect(selectedWisma, val));
                        },
                      ),
                      const SizedBox(height: 24), // Jarak antar kategori lebih lebar

                      // KATEGORI KELAS
                      _buildFilterLabel("Pilih Jenis Kelas"),
                      _buildFilterChips(
                        options: ["Semua", "Kelas A", "Kelas B", "Kelas C", "Aula", "Lab B", "Kelas Toddopuli"],
                        selectedList: selectedKelas,
                        onSelected: (val) {
                          setDialogState(() => _handleMultiSelect(selectedKelas, val));
                        },
                      ),
                      const SizedBox(height: 24),

                      // KATEGORI STATUS
                      _buildFilterLabel("Status Pesanan"),
                      _buildFilterChips(
                        options: ["Semua", "Menunggu Konfirmasi", "Disetujui", "Ditolak"],
                        selectedList: selectedStatus,
                        onSelected: (val) {
                          setDialogState(() => _handleMultiSelect(selectedStatus, val));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: () {
                    setState(() {}); 
                    Navigator.pop(context);
                  },
                  child: const Text("Terapkan Filter", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Logika untuk menangani pilihan ganda
  void _handleMultiSelect(List<String> list, String value) {
    if (value == "Semua") {
      list.clear();
      list.add("Semua");
    } else {
      list.remove("Semua");
      if (list.contains(value)) {
        list.remove(value);
        if (list.isEmpty) list.add("Semua");
      } else {
        list.add(value);
      }
    }
  }

  Widget _buildFilterLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildFilterChips({
    required List<String> options,
    required List<String> selectedList,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8, // Jarak antar baris chip lebih rapi
      children: options.map((option) {
        final bool isSelected = selectedList.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          showCheckmark: false,
          labelStyle: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          selectedColor: primaryColor,
          backgroundColor: const Color(0xFFF0F4F4),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: isSelected ? primaryColor : Colors.transparent),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
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
            Navigator.pushReplacementNamed(context, '/staff_dash');
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
      height: 120,
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
    final List<Map<String, dynamic>> riwayatItems = [
      {
        "title": "Wisma Hortensia",
        "detail": "Kamar VIP Hortensia 01",
        "date": "12 Feb 2026",
        "bookDate": "25 Feb - 27 Feb 2026",
        "status": "Dikonfirmasi",
        "isSelesai": true
      },
      {
        "title": "Wisma Toddopuli",
        "detail": "Kamar Toddopuli 10",
        "date": "10 Feb 2026",
        "bookDate": "01 Mar - 05 Mar 2026",
        "status": "Menunggu",
        "isSelesai": false
      },
      {
        "title": "Wisma Anggrek",
        "detail": "Kamar Anggrek 05",
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
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    item['date'],
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item['detail'],
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                      Text(
                        item['bookDate'],
                        style: const TextStyle(fontSize: 11, color: Colors.black87),
                      ),
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