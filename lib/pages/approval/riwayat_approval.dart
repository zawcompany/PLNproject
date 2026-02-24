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
  final Color softGrey = const Color(0xFF9E9E9E);
  
  String selectedRiwayatType = "Pemesanan";
  String selectedCategory = "Semua"; 
  String selectedStatus = "Semua"; 

  // --- POP UP FILTER UTAMA ---
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStepState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                "Filter Approval",
                style: TextStyle(color: primaryTeal, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Jenis Ruangan", style: TextStyle(fontSize: 12, color: softGrey)),
                  const SizedBox(height: 8),
                  _buildPopupDropdown(['Semua', 'Wisma', 'Kelas'], selectedCategory, (v) {
                    setStepState(() => selectedCategory = v!);
                  }),
                  const SizedBox(height: 16),
                  Text("Status Approval", style: TextStyle(fontSize: 12, color: softGrey)),
                  const SizedBox(height: 8),
                  _buildPopupDropdown(["Semua", "Menunggu", "Disetujui", "Ditolak"], selectedStatus, (v) {
                    setStepState(() => selectedStatus = v!);
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal", style: TextStyle(color: softGrey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal, 
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () {
                    setState(() {}); 
                    Navigator.pop(context);
                  },
                  child: const Text("Terapkan", style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildPopupDropdown(List<String> items, String currentVal, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: currentVal,
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: softGrey),
          items: items.map((e) => DropdownMenuItem(
            value: e, 
            child: Text(e, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400))
          )).toList(),
          onChanged: onChanged,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildTopFilterRow(),
                  const SizedBox(height: 10), 
                  Expanded(child: _buildListRiwayat()),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/approval');
          if (index == 2) Navigator.pushReplacementNamed(context, '/profil');
        },
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      height: 160,
      child: SvgPicture.asset('lib/assets/images/header_riwayat.svg', fit: BoxFit.cover),
    );
  }

  Widget _buildTopFilterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              "Riwayat",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black.withValues(alpha: 0.7)),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (String value) => setState(() => selectedRiwayatType = value),
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              itemBuilder: (context) => [
                const PopupMenuItem(value: "Pemesanan", child: Text("Pemesanan", style: TextStyle(fontSize: 13))),
                const PopupMenuItem(value: "Pengaduan", child: Text("Pengaduan", style: TextStyle(fontSize: 13))),
              ],
              child: Row(
                children: [
                  Text(
                    selectedRiwayatType,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.keyboard_arrow_down, color: primaryTeal, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: _showFilterDialog,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEEEEEE)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.filter_list_rounded, color: primaryTeal, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildListRiwayat() {
    return ListView.builder(
      itemCount: 4,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        bool isWaiting = index == 0;
        return _buildCardItem(isWaiting);
      },
    );
  }

  // --- CARD ITEM DENGAN TOMBOL ICON (BUKAN BUTTON PRIMITIF) ---
  Widget _buildCardItem(bool isWaiting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5F5F5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _statusBadge(isWaiting ? "Menunggu" : "Disetujui"),
                    const SizedBox(width: 8),
                    Text(
                      selectedRiwayatType == "Pemesanan" ? "ID #2941" : "Lap #882",
                      style: TextStyle(color: softGrey, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  selectedRiwayatType == "Pemesanan" ? "Wisma Bougenville 1.1" : "AC Rusak - Kelas A1",
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedRiwayatType == "Pemesanan" ? "Pemesan: Zahra Amaliah" : "Pelapor: Ahmad Dhani",
                  style: TextStyle(color: softGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          // TOMBOL IKAN TINJAU ELEGAN
          if (isWaiting)
            GestureDetector(
              onTap: () => _showTinjauDialog(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryTeal.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.assignment_turned_in_outlined, color: primaryTeal, size: 22),
              ),
            )
          else
            Icon(Icons.check_circle_outline, color: Colors.green.withValues(alpha: 0.5), size: 22),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = status == "Menunggu" ? Colors.orange : (status == "Disetujui" ? Colors.green : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }

  void _showTinjauDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => selectedRiwayatType == "Pemesanan" 
          ? const DialogTinjauPemesanan() 
          : const DialogTinjauPengaduan(),
    );
  }
}

// --- POP UP TINJAU: DIBUAT MIRIP FORM PEMESANAN ---
class DialogTinjauPemesanan extends StatelessWidget {
  const DialogTinjauPemesanan({super.key});
  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF008996);
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tinjau Pemesanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20)),
              ],
            ),
            const Divider(height: 30),
            _sectionTitle("Informasi Pemesan"),
            _infoBox([
              _rowInfo("Nama Lengkap", "Zahra Amaliah Wildani"),
              _rowInfo("NIK / NIP", "202201400xx"),
              _rowInfo("Instansi", "Hasanuddin University"),
            ]),
            const SizedBox(height: 20),
            _sectionTitle("Detail Ruangan"),
            _infoBox([
              _rowInfo("Jenis", "Wisma"),
              _rowInfo("Nama Ruangan", "Bougenville 1.1"),
              _rowInfo("Tanggal", "25 Feb - 27 Feb 2026"),
            ]),
            const SizedBox(height: 20),
            _sectionTitle("Dokumen Lampiran"),
            const SizedBox(height: 8),
            Row(
              children: [
                _filePreview("Surat Tugas", Icons.description_outlined),
                const SizedBox(width: 12),
                _filePreview("Bukti Bayar", Icons.account_balance_wallet_outlined),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Tolak", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Terima", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF008996)));

  Widget _infoBox(List<Widget> children) => Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF8FBFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Column(children: children),
  );

  Widget _rowInfo(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 12, color: Colors.grey)), Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]));

  Widget _filePreview(String label, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFEEEEEE)), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF008996)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );
}

// --- POP UP TINJAU PENGADUAN ---
class DialogTinjauPengaduan extends StatelessWidget {
  const DialogTinjauPengaduan({super.key});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tinjau Pengaduan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("Keluhan / Masalah:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
              child: const Text("AC di ruangan Kelas A1 tidak dingin dan mengeluarkan bunyi berisik sejak pagi hari.", style: TextStyle(fontSize: 13, height: 1.5)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color: Colors.orange), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Perbaiki", style: TextStyle(color: Colors.orange)))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008996), padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Konfirmasi", style: TextStyle(color: Colors.white)))),
              ],
            )
          ],
        ),
      ),
    );
  }
}