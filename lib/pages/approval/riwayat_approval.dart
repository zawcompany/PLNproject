import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monitoring_app/widgets/navbar.dart';

class RiwayatApprovalPage extends StatefulWidget {
  const RiwayatApprovalPage({super.key});

  @override
  State<RiwayatApprovalPage> createState() => _RiwayatApprovalPageState();
}

class _RiwayatApprovalPageState extends State<RiwayatApprovalPage> {
  final Color primaryColor = const Color(0xFF008996);
  String activeTab = "Pemesanan";

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Filter Approval",
            style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterLabel("Status Approval"),
              _buildSimpleDropdown(["Semua Status", "Menunggu Konfirmasi", "Disetujui", "Ditolak"]),
              const SizedBox(height: 15),
              _buildFilterLabel("Urutkan Berdasarkan"),
              _buildSimpleDropdown(["Terbaru", "Terlama"]),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () => Navigator.pop(context),
              child: const Text("Terapkan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      );

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
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) {},
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
          _buildTabSwitcher(),
          const SizedBox(height: 10),
          _buildTitleRow(),
          Expanded(
            child: activeTab == "Pemesanan" ? _buildBookingList() : _buildComplaintList(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/dash_approval');
          if (index == 2) Navigator.pushReplacementNamed(context, '/profil');
        },
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: SvgPicture.asset('lib/assets/images/header_riwayat.svg', fit: BoxFit.cover),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _tabButton("Pemesanan"),
          const SizedBox(width: 10),
          _tabButton("Pengaduan"),
        ],
      ),
    );
  }

  Widget _tabButton(String label) {
    bool isActive = activeTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? primaryColor : const Color(0xFFF0F4F4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Daftar $activeTab", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            color: primaryColor,
            onPressed: _showFilterDialog,
          )
        ],
      ),
    );
  }

  Widget _buildBookingList() {
    final List<Map<String, dynamic>> items = [
      {
        "user": "Andi Wijaya",
        "room": "Anggrek - Kamar 01",
        "date": "12 Jan - 15 Jan 2026",
        "status": "Menunggu",
      },
      {
        "user": "Siti Aminah",
        "room": "Kelas A - Lt. 2",
        "date": "20 Jan 2026",
        "status": "Disetujui",
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['user'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    _buildStatusBadge(item['status']),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item['room'], style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(item['date'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const Divider(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showDetailPopup(item);
                    },
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                    label: const Text("Lihat Detail & Dokumen"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplaintList() {
    return const Center(child: Text("Belum ada riwayat pengaduan."));
  }

  Widget _buildStatusBadge(String status) {
    Color color = const Color.fromARGB(255, 238, 218, 121);
    if (status == "Disetujui") color = const Color.fromARGB(255, 60, 150, 63);
    if (status == "Ditolak") color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // FIXED: Using withValues instead of withOpacity
        color: color.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showDetailPopup(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: [
              // FIXED: Removed 'const' from BoxDecoration because color or borderRadius can vary
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Text("Detail Pemesanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 20),
              _detailRow("Pemesan", item['user']),
              _detailRow("Lokasi", item['room']),
              _detailRow("Tanggal", item['date']),
              const Divider(height: 30),
              const Text("Dokumen Pendukung", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text("Surat Tugas.pdf", style: TextStyle(fontSize: 13)),
                trailing: TextButton(onPressed: () {}, child: const Text("Buka")),
                tileColor: const Color(0xFFF8FBFB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 30),
              if (item['status'] == "Menunggu")
                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Tolak", style: TextStyle(color: Colors.white)))),
                    const SizedBox(width: 10),
                    Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text("Setujui", style: TextStyle(color: Colors.white)))),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        ),
      );
}