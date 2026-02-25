import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Wajib tambah intl di pubspec.yaml
import 'package:monitoring_app/widgets/navbar.dart';
import '../../models/booking_model.dart'; // Sesuaikan path model Anda

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
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
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
                      _buildFilterLabel("Status Pesanan"),
                      _buildFilterChips(
                        options: ["Semua", "Pending", "Approved", "Rejected"],
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
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return StreamBuilder<QuerySnapshot>(
      // Mengambil pesanan milik user yang sedang login saja
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Belum ada riwayat pesanan."));
        }

        // Mapping data dari Firebase & Filter Local
        var bookings = snapshot.data!.docs.map((doc) {
          return BookingModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        // LOGIKA FILTER
        if (!selectedWisma.contains("Semua")) {
          bookings = bookings.where((b) => selectedWisma.any((w) => b.itemName.contains(w))).toList();
        }
        if (!selectedKelas.contains("Semua")) {
          bookings = bookings.where((b) => selectedKelas.any((k) => b.itemName.contains(k))).toList();
        }
        if (!selectedStatus.contains("Semua")) {
          bookings = bookings.where((b) => selectedStatus.contains(b.status.name)).toList();
        }

        // Urutkan berdasarkan yang terbaru
        bookings.sort((a, b) => b.start.compareTo(a.start));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];

            // Konfigurasi Status UI
            String statusLabel = "Menunggu";
            Color statusColor = Colors.orange;
            Color bgColor = const Color(0xFFFFF3E0);
            bool isSelesai = false;

            if (booking.status == BookingStatus.approved) {
              statusLabel = "Disetujui";
              statusColor = primaryColor;
              bgColor = const Color(0xFFE0F2F3);
              isSelesai = true;
            } else if (booking.status == BookingStatus.rejected) {
              statusLabel = "Ditolak";
              statusColor = Colors.red;
              bgColor = const Color(0xFFFFEBEE);
            }

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
                      Text(
                        booking.itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(booking.start),
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ID Pesanan: ${booking.id.substring(0, 8).toUpperCase()}",
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
                            "${DateFormat('dd MMM').format(booking.start)} - ${DateFormat('dd MMM yyyy').format(booking.end)}",
                            style: const TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
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
      },
    );
  }
}