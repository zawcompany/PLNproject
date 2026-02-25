import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_app/widgets/navbar.dart';
import '../../models/booking_model.dart';

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

  // State untuk mode hapus
  bool isSelectionMode = false;
  List<String> selectedBookingIds = [];

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text("Filter Riwayat Saya", 
                style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterLabel("Pilih Wisma"),
                    _buildChips(["Semua", "Anggrek", "Cempaka", "Bougenville", "Dahlia", "Edelweiss", "Flamboyan", "Gladiol", "Hortensia", "Toddopuli"], selectedWisma, setDialogState),
                    const SizedBox(height: 20),
                    _buildFilterLabel("Pilih Kelas"),
                    _buildChips(["Semua", "Kelas A", "Kelas B", "Kelas Lab B", "Aula", "Kelas Toddopuli"], selectedKelas, setDialogState),
                    const SizedBox(height: 20),
                    _buildFilterLabel("Status Pesanan"),
                    _buildChips(["Semua", "Menunggu Persetujuan", "Diterima", "Ditolak"], selectedStatus, setDialogState),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      selectedWisma = ["Semua"];
                      selectedKelas = ["Semua"];
                      selectedStatus = ["Semua"];
                    });
                  }, 
                  child: const Text("Reset", style: TextStyle(color: Colors.red))
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); 
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  child: const Text("Terapkan", style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }

  // Fungsi Hapus Massal
  Future<void> _deleteSelectedBookings() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Riwayat"),
        content: Text("Hapus ${selectedBookingIds.length} riwayat yang terpilih?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (String id in selectedBookingIds) {
        batch.delete(FirebaseFirestore.instance.collection('bookings').doc(id));
      }
      await batch.commit();
      setState(() {
        isSelectionMode = false;
        selectedBookingIds.clear();
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil menghapus riwayat")));
    }
  }

  Widget _buildFilterLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
  );

  Widget _buildChips(List<String> options, List<String> selectedList, StateSetter setDialogState) {
    return Wrap(
      spacing: 6,
      runSpacing: 0,
      children: options.map((opt) {
        final isSel = selectedList.contains(opt);
        return FilterChip(
          label: Text(opt, style: TextStyle(fontSize: 10, color: isSel ? Colors.white : Colors.black87)),
          selected: isSel,
          selectedColor: primaryColor,
          checkmarkColor: Colors.white,
          onSelected: (v) {
            setDialogState(() {
              if (opt == "Semua") {
                selectedList.clear();
                selectedList.add("Semua");
              } else {
                selectedList.remove("Semua");
                if (v) {
                  selectedList.add(opt);
                } else {
                  selectedList.remove(opt);
                }
                if (selectedList.isEmpty) selectedList.add("Semua");
              }
            });
          },
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
          Expanded(child: _buildHistoryList()),
        ],
      ),
      // Tombol aksi melayang jika dalam mode seleksi
      floatingActionButton: isSelectionMode && selectedBookingIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelectedBookings,
              backgroundColor: Colors.red,
              icon: const Icon(Icons.delete, color: Colors.white),
              label: Text("Hapus (${selectedBookingIds.length})", style: const TextStyle(color: Colors.white)),
            )
          : null,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/staff_dash');
          if (index == 2) Navigator.pushReplacementNamed(context, '/profil');
        },
      ),
    );
  }

  Widget _buildHeader() => SizedBox(
    width: double.infinity, 
    height: 120, 
    child: SvgPicture.asset('lib/assets/images/header_riwayat.svg', fit: BoxFit.cover)
  );

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
          Row(
            children: [
              // TOMBOL HAPUS (Style sama dengan Filter)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelectionMode = !isSelectionMode;
                    selectedBookingIds.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // Warna merah transparan jika mode hapus aktif, jika tidak maka teal transparan
                    color: isSelectionMode 
                        ? Colors.red.withOpacity(0.1) 
                        : primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSelectionMode ? Icons.close : Icons.delete_outline,
                    color: isSelectionMode ? Colors.red : primaryColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10), // Jarak antar tombol
              // TOMBOL FILTER
              GestureDetector(
                onTap: _showFilterDialog,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.filter_list_rounded, color: primaryColor, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final listKeywordsKelas = ["Kelas A", "Kelas B", "Kelas Lab B", "Aula", "Kelas Toddopuli"];

        var bookings = snapshot.data!.docs.map((doc) => 
          BookingModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)
        ).toList();

        // LOGIKA FILTER
        bookings = bookings.where((item) {
          String name = item.itemName;
          String status = item.status.name;

          bool matchesWisma = false;
          if (selectedWisma.contains("Semua")) {
            matchesWisma = !listKeywordsKelas.any((k) => name.toLowerCase().contains(k.toLowerCase()));
          } else {
            matchesWisma = selectedWisma.any((w) => name.toLowerCase().contains(w.toLowerCase()));
          }

          bool matchesKelas = false;
          if (selectedKelas.contains("Semua")) {
            matchesKelas = listKeywordsKelas.any((k) => name.toLowerCase().contains(k.toLowerCase()));
          } else {
            matchesKelas = selectedKelas.any((k) => name.toLowerCase().contains(k.toLowerCase()));
          }

          bool statusMatch = false;
          if (selectedStatus.contains("Semua")) {
            statusMatch = true;
          } else {
            if (selectedStatus.contains("Menunggu Persetujuan") && status == 'pending') statusMatch = true;
            if (selectedStatus.contains("Diterima") && status == 'approved') statusMatch = true;
            if (selectedStatus.contains("Ditolak") && status == 'rejected') statusMatch = true;
          }

          return (matchesWisma || matchesKelas) && statusMatch;
        }).toList();

        bookings.sort((a, b) => b.start.compareTo(a.start));

        if (bookings.isEmpty) return const Center(child: Text("Tidak ada data riwayat"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: bookings.length,
          itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
        );
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    String statusLabel = "Menunggu";
    Color statusColor = Colors.orange;
    Color bgColor = const Color(0xFFFFF3E0);

    if (booking.status == BookingStatus.approved) {
      statusLabel = "Disetujui";
      statusColor = primaryColor;
      bgColor = const Color(0xFFE0F2F3);
    } else if (booking.status == BookingStatus.rejected) {
      statusLabel = "Ditolak";
      statusColor = Colors.red;
      bgColor = const Color(0xFFFFEBEE);
    }

    bool isSelected = selectedBookingIds.contains(booking.id);

    bool canBeDeleted = booking.status == BookingStatus.approved || 
                      booking.status == BookingStatus.rejected;

    return GestureDetector(
      onTap: isSelectionMode ? () {
        if (canBeDeleted) {
          setState(() {
            if (isSelected) {
              selectedBookingIds.remove(booking.id);
            } else {
              selectedBookingIds.add(booking.id);
            }
          });
        } else {
          // Beri notifikasi jika user mencoba memilih yang masih 'pending'
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pesanan yang masih menunggu tidak dapat dihapus"),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } : null,
      
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.red : const Color(0xFFF0F4F4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            if (isSelectionMode) ...[
              Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: isSelected ? Colors.red : Colors.grey,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.itemName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(DateFormat('dd MMM yyyy').format(booking.start), 
                        style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("ID Pesanan: ${booking.id.split('_').first.toUpperCase()}", 
                    style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
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
                          Text("${DateFormat('dd MMM').format(booking.start)} - ${DateFormat('dd MMM').format(booking.end)}", 
                            style: const TextStyle(fontSize: 11, color: Colors.black87)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                        child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}