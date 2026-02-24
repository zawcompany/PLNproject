import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/navbar.dart';

class RiwayatApprovalPage extends StatefulWidget {
  const RiwayatApprovalPage({super.key});

  @override
  State<RiwayatApprovalPage> createState() => _RiwayatApprovalPageState();
}

class _RiwayatApprovalPageState extends State<RiwayatApprovalPage> {
  final Color primaryColor = const Color(0xFF008996);

  // Filter categories disamakan persis dengan staff riwayat
  List<String> selectedWisma = ["Semua"];
  List<String> selectedKelas = ["Semua"];
  List<String> selectedStatus = ["Semua"];

  // Dropdown title state
  String selectedRiwayatType = "Pemesanan";

  // --- LOGIK FILTER (DIAMBIL DARI STAFF RIWAYAT AGAR TIDAK ERROR) ---
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              title: Text(
                "Filter Approval",
                style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterLabel("Pilih Jenis Wisma"),
                      _buildFilterChips(
                        options: ["Semua", "Anggrek", "Cempaka", "Bougenville", "Dahlia", "Edelweiss", "Flamboyan", "Gladiol", "Hortensia", "Toddopuli"],
                        selectedList: selectedWisma,
                        onSelected: (val) {
                          setDialogState(() => _handleMultiSelect(selectedWisma, val));
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildFilterLabel("Pilih Jenis Kelas"),
                      _buildFilterChips(
                        options: ["Semua", "Kelas A", "Kelas B", "Kelas C", "Aula", "Lab B", "Kelas Toddopuli"],
                        selectedList: selectedKelas,
                        onSelected: (val) {
                          setDialogState(() => _handleMultiSelect(selectedKelas, val));
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildFilterLabel("Status Approval"),
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
                  child: const Text("Terapkan Filter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
      runSpacing: 8,
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
          if (index == 0) Navigator.pushReplacementNamed(context, '/approval_dash');
          if (index == 2) Navigator.pushReplacementNamed(context, '/profil');
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
                  "Riwayat $selectedRiwayatType",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor, size: 20),
              ],
            ),
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
        "requester": "Zahra Amaliah Wildani",
        "date": "12 Feb 2026",
        "bookDate": "25 Feb - 27 Feb 2026",
        "status": "Dikonfirmasi",
        "isSelesai": true
      },
      {
        "title": "Wisma Toddopuli",
        "detail": "Kamar Toddopuli 10",
        "requester": "Ahmad Dhani",
        "date": "10 Feb 2026",
        "bookDate": "01 Mar - 05 Mar 2026",
        "status": "Menunggu",
        "isSelesai": false
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
                color: Colors.black.withValues(alpha: 0.05),
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
                  Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(item['date'], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Oleh: ${item['requester']}",
                style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFF0F4F4)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 14, color: primaryColor),
                          const SizedBox(width: 6),
                          Text(item['bookDate'], style: const TextStyle(fontSize: 11, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                  ElevatedButton(
                    onPressed: () {
                      if (selectedRiwayatType == "Pemesanan") {
                        _showTinjauPemesanan(context);
                      } else {
                        _showTinjauPengaduan(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Tinjau", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTinjauPemesanan(BuildContext context) {
    showDialog(context: context, builder: (context) => const DialogTinjauPemesanan());
  }

  void _showTinjauPengaduan(BuildContext context) {
    showDialog(context: context, builder: (context) => const DialogTinjauPengaduan());
  }
}

// --- POP UP TINJAU PEMESANAN ---
class DialogTinjauPemesanan extends StatelessWidget {
  const DialogTinjauPemesanan({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF008996);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
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
              _rowInfo("Nama Ruangan", "Hortensia 01"),
              _rowInfo("Tanggal", "25 Feb - 27 Feb 2026"),
            ]),
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
                    child: const Text("Tolak", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Terima", style: TextStyle(fontWeight: FontWeight.bold)),
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
    decoration: BoxDecoration(
      color: const Color(0xFFF8FBFB),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEEEEEE)),
    ),
    child: Column(children: children),
  );

  Widget _rowInfo(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

// --- POP UP TINJAU PENGADUAN ---
class DialogTinjauPengaduan extends StatelessWidget {
  const DialogTinjauPengaduan({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF008996);
    return Dialog(
      backgroundColor: Colors.white,
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
              child: const Text(
                "AC di ruangan Kelas A1 tidak dingin dan mengeluarkan bunyi berisik sejak pagi hari.",
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Perbaiki", style: TextStyle(color: Colors.orange)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Konfirmasi"),
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