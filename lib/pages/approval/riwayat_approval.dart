import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/navbar.dart';

class RiwayatApprovalPage extends StatefulWidget {
  const RiwayatApprovalPage({super.key});

  @override
  State<RiwayatApprovalPage> createState() => _RiwayatApprovalPageState();
}

class _RiwayatApprovalPageState extends State<RiwayatApprovalPage> {
  final Color primaryTeal = const Color(0xFF008996);
  
  // State Filters
  String selectedRiwayatType = "Pemesanan";
  String selectedCategory = "Semua";
  String selectedStatus = "Semua"; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildMainFilter(), // Dropdown Pemesanan/Pengaduan
                  const SizedBox(height: 15),
                  _buildSubFilters(), // Dropdown Tipe & Status
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFF0F4F4)),
                  Expanded(
                    child: _buildListRiwayat(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/approval');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profil');
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 160, 
          child: SvgPicture.asset(
            'lib/assets/images/header_riwayat.svg',
            fit: BoxFit.cover,
          ),
        ),
        const Positioned(
          bottom: 25,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Riwayat",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Panel Persetujuan Admin",
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRiwayatType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: ["Pemesanan", "Pengaduan"].map((String val) {
            return DropdownMenuItem(
              value: val,
              child: Text("Riwayat $val", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              selectedRiwayatType = val!;
              selectedCategory = "Semua"; 
            });
          },
        ),
      ),
    );
  }

  Widget _buildSubFilters() {
    return Row(
      children: [
        Expanded(
          child: _buildDropDownChip(
            label: selectedCategory,
            items: ["Semua", "Wisma", "Kelas"],
            onChanged: (val) => setState(() => selectedCategory = val!),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDropDownChip(
            label: selectedStatus,
            items: ["Semua", "Menunggu", "Disetujui", "Ditolak"],
            onChanged: (val) => setState(() => selectedStatus = val!),
          ),
        ),
      ],
    );
  }

  Widget _buildDropDownChip({required String label, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          items: items.map((String v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildListRiwayat() {
    return ListView.builder(
      itemCount: 4, 
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      itemBuilder: (context, index) {
        bool isWaiting = index == 0; 
        return _buildCardItem(isWaiting);
      },
    );
  }

  Widget _buildCardItem(bool isWaiting) {
    String title = selectedRiwayatType == "Pemesanan" ? "Wisma Bougenville 1.1" : "AC Rusak - Kelas A1";
    String subtitle = selectedRiwayatType == "Pemesanan" ? "Peminjam: Zahra Amaliah" : "Pelapor: Ahmad Dhani";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF0F4F4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              _statusBadge(isWaiting ? "Menunggu" : "Disetujui"),
            ],
          ),
          if (isWaiting) ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () => _showTinjauDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text("Tinjau Sekarang", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = status == "Menunggu" ? Colors.amber : (status == "Disetujui" ? Colors.green : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showTinjauDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => selectedRiwayatType == "Pemesanan" 
          ? const DialogTinjauPemesanan() 
          : const DialogTinjauPengaduan(),
    );
  }
}

class DialogTinjauPemesanan extends StatelessWidget {
  const DialogTinjauPemesanan({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF008996);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Detail Pemesanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal)),
            const SizedBox(height: 15),
            _detailRow("Nama Pemesan", "Zahra Amaliah"),
            _detailRow("Instansi", "Hasanuddin University"),
            _detailRow("Tanggal", "25 - 27 Feb 2026"),
            _detailRow("Jumlah Tamu", "4 Orang"),
            const SizedBox(height: 15),
            const Text("Lampiran Berkas", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                _fileIcon("Surat Tugas"),
                const SizedBox(width: 15),
                _fileIcon("Bukti Bayar"),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Tolak", style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                    child: const Text("Terima", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _fileIcon(String label) {
    return Column(
      children: [
        const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}

class DialogTinjauPengaduan extends StatelessWidget {
  const DialogTinjauPengaduan({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF008996);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tinjau Pengaduan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal)),
            const SizedBox(height: 15),
            const Text("Isi Keluhan:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 5),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
              child: const Text("AC di ruangan Kelas A1 tidak dingin dan mengeluarkan bunyi berisik sejak pagi hari.", style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Perbaiki", style: TextStyle(color: Colors.orange)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                    child: const Text("Konfirmasi", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}