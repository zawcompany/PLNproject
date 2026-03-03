import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/booking_model.dart';
import '../../models/complaint_model.dart';
import '../../models/room_model.dart';
import '../../services/database_service.dart';
import '../../widgets/navbar.dart';

class RiwayatApprovalPage extends StatefulWidget {
  const RiwayatApprovalPage({super.key});

  @override
  State<RiwayatApprovalPage> createState() => _RiwayatApprovalPageState();
}

class _RiwayatApprovalPageState extends State<RiwayatApprovalPage> {
  final Color primaryColor = const Color(0xFF008996);

  List<String> selectedWisma = ["Semua"];
  List<String> selectedKelas = ["Semua"];
  List<String> selectedStatus = ["Semua"];
  String selectedRiwayatType = "Pemesanan";

  bool isSelectionMode = false;
  List<String> selectedItemIds = [];

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<String> statusOptions = selectedRiwayatType == "Pemesanan"
                ? ["Semua", "Menunggu Persetujuan", "Diterima", "Ditolak"]
                : ["Semua", "Perlu Perbaikan", "Dalam Perbaikan", "Selesai"];

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text("Filter Riwayat $selectedRiwayatType", 
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
                    _buildChips(["Semua", "Kelas A", "Kelas B", "Lab A", "Lab B", "Lab C", "Aula", "Kelas Toddopuli"], selectedKelas, setDialogState),
                    const SizedBox(height: 20),
                    _buildFilterLabel("Status"),
                    _buildChips(statusOptions, selectedStatus, setDialogState),
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
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text("Terapkan", style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteSelectedItems() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text("Hapus ${selectedItemIds.length} data riwayat terpilih?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      String collection = selectedRiwayatType == "Pemesanan" ? 'bookings' : 'complaints';
      
      for (String id in selectedItemIds) {
        batch.delete(FirebaseFirestore.instance.collection(collection).doc(id));
      }
      
      await batch.commit();
      if (!mounted) return;
      
      setState(() {
        isSelectionMode = false;
        selectedItemIds.clear();
      });
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Berhasil menghapus riwayat")));
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
                if (v) {
                  selectedList.clear();
                  selectedList.add("Semua");
                } else {
                  selectedList.remove("Semua"); 
                }
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

  int getStatusPriority(dynamic item) {
    String status;
    if (item is BookingModel) {
      status = item.status.name;
    } else {
      status = (item as ComplaintModel).status.name;
    }
    switch (status) {
      case 'pending': return 1;
      case 'repairing': return 2;
      case 'approved':
      case 'resolved': return 3;
      case 'rejected': return 4;
      default: return 5;
    }
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
      floatingActionButton: isSelectionMode && selectedItemIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelectedItems,
              backgroundColor: Colors.red,
              icon: const Icon(Icons.delete, color: Colors.white),
              label: Text("Hapus (${selectedItemIds.length})", style: const TextStyle(color: Colors.white)),
            )
          : null,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/approval_dash');
          if (index == 2) Navigator.pushReplacementNamed(context, '/profil');
        },
      ),
    );
  }

  Widget _buildHistoryList() {
    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream.list([
        FirebaseFirestore.instance.collection('bookings').snapshots(),
        FirebaseFirestore.instance.collection('complaints').snapshots(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final bookingDocs = snapshot.data![0] as QuerySnapshot;
        final complaintDocs = snapshot.data![1] as QuerySnapshot;

        List<dynamic> allItems = [];
        if (selectedRiwayatType == "Pemesanan") {
          allItems = bookingDocs.docs.map((doc) => BookingModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
        } else {
          allItems = complaintDocs.docs.map((doc) => ComplaintModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
        }

        final listKeywordsKelas = ["Kelas A", "Kelas B", "Lab B", "Aula", "Kelas Toddopuli"];

        allItems = allItems.where((item) {
        String name = (item is BookingModel) ? item.itemName : (item as ComplaintModel).roomName;
        String status = (item is BookingModel) ? item.status.name : (item as ComplaintModel).status.name;

        //Logika Filter Wisma
        bool matchesWisma = false;
        if (selectedWisma.isEmpty) {
          matchesWisma = false; 
        } else if (selectedWisma.contains("Semua")) {
          matchesWisma = !listKeywordsKelas.any((k) => name.toLowerCase().contains(k.toLowerCase()));
        } else {
          matchesWisma = selectedWisma.any((w) => name.toLowerCase().contains(w.toLowerCase()));
        }

        //Logika Filter Kelas
        bool matchesKelas = false;
        if (selectedKelas.isEmpty) {
          matchesKelas = false; 
        } else if (selectedKelas.contains("Semua")) {
          matchesKelas = listKeywordsKelas.any((k) => name.toLowerCase().contains(k.toLowerCase()));
        } else {
          matchesKelas = selectedKelas.any((k) => name.toLowerCase().contains(k.toLowerCase()));
        }

        bool categoryMatch = matchesWisma || matchesKelas;

        // Logika Filter Status 
        bool statusMatch = false;
        if (selectedStatus.contains("Semua") || selectedStatus.isEmpty) {
          statusMatch = true;
        } else {
          if (selectedRiwayatType == "Pemesanan") {
            if (selectedStatus.contains("Menunggu Persetujuan") && status == 'pending') statusMatch = true;
            if (selectedStatus.contains("Diterima") && status == 'approved') statusMatch = true;
            if (selectedStatus.contains("Ditolak") && status == 'rejected') statusMatch = true;
          } else {
            if (selectedStatus.contains("Perlu Perbaikan") && status == 'pending') statusMatch = true;
            if (selectedStatus.contains("Dalam Perbaikan") && status == 'repairing') statusMatch = true;
            if (selectedStatus.contains("Selesai") && status == 'resolved') statusMatch = true;
          }
        }

        return categoryMatch && statusMatch;
      }).toList();

        allItems.sort((a, b) {
          int priorityA = getStatusPriority(a);
          int priorityB = getStatusPriority(b);
          if (priorityA != priorityB) return priorityA.compareTo(priorityB);
          DateTime timeA = (a is BookingModel) ? a.start : (a as ComplaintModel).createdAt;
          DateTime timeB = (b is BookingModel) ? b.start : (b as ComplaintModel).createdAt;
          return timeB.compareTo(timeA);
        });

        if (allItems.isEmpty) return const Center(child: Text("Tidak ada data riwayat"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: allItems.length,
          itemBuilder: (context, index) {
            final item = allItems[index];
            bool isSelected = selectedItemIds.contains(item.id);
            bool canBeDeleted = false;
            if (item is BookingModel) {
              canBeDeleted = item.status == BookingStatus.approved || item.status == BookingStatus.rejected;
            } else if (item is ComplaintModel) {
              canBeDeleted = item.status == ComplaintStatus.resolved;
            }

            return GestureDetector(
              onTap: isSelectionMode ? () {
                if (canBeDeleted) {
                  setState(() {
                    if (isSelected) {
                      selectedItemIds.remove(item.id);
                    } else {
                      selectedItemIds.add(item.id);
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data yang sedang diproses tidak dapat dihapus"), duration: Duration(seconds: 1)));
                }
              } : null,
              child: Opacity(
                opacity: isSelectionMode && !canBeDeleted ? 0.5 : 1.0,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isSelected ? Colors.red : const Color(0xFFF0F4F4), width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      if (isSelectionMode) ...[
                        const SizedBox(width: 16),
                        Icon(!canBeDeleted ? Icons.lock_outline : (isSelected ? Icons.check_box : Icons.check_box_outline_blank), color: isSelected ? Colors.red : Colors.grey),
                      ],
                      Expanded(child: item is BookingModel ? _buildBookingCard(item) : _buildComplaintCard(item as ComplaintModel)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(booking.itemName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(DateFormat('dd MMM yyyy').format(booking.start), style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Text("Oleh: ${booking.userName}", style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(booking.status.name, isBooking: true),
              if (!isSelectionMode) IconButton(onPressed: () => _showTinjauPemesanan(booking), icon: Icon(Icons.arrow_forward_ios_rounded, color: primaryColor, size: 14)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildComplaintCard(ComplaintModel complaint) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(complaint.roomName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(DateFormat('dd MMM yyyy').format(complaint.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          const Text("Laporan Pengaduan", style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(complaint.status.name, isBooking: false),
              if (!isSelectionMode) IconButton(onPressed: () => _showTinjauPengaduan(complaint), icon: Icon(Icons.arrow_forward_ios_rounded, color: primaryColor, size: 14)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, {required bool isBooking}) {
    String label = "";
    Color color = Colors.orange;
    if (isBooking) {
      switch (status) {
        case 'pending': label = "MENUNGGU"; color = Colors.orange; break;
        case 'approved': label = "DITERIMA"; color = primaryColor; break;
        case 'rejected': label = "DITOLAK"; color = Colors.red; break;
        default: label = status.toUpperCase();
      }
    } else {
      switch (status) {
        case 'pending': label = "PERLU PERBAIKAN"; color = Colors.red; break;
        case 'repairing': label = "DALAM PERBAIKAN"; color = Colors.orange; break;
        case 'resolved': label = "SELESAI"; color = primaryColor; break;
        case 'waitingApproval': label = "MENUNGGU PERSETUJUAN"; color = Colors.blue; break;
        default: label = status.toUpperCase();
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  void _showTinjauPemesanan(BookingModel booking) {
    showDialog(context: context, builder: (context) => DialogTinjauPemesanan(booking: booking));
  }

  void _showTinjauPengaduan(ComplaintModel complaint) {
    showDialog(context: context, builder: (context) => DialogTinjauPengaduan(complaint: complaint));
  }

  Widget _buildHeader() => SizedBox(width: double.infinity, height: 120, child: SvgPicture.asset('lib/assets/images/header_riwayat.svg', fit: BoxFit.cover));

  Widget _buildTitleRow() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PopupMenuButton<String>(
          onSelected: (v) {
            setState(() { selectedRiwayatType = v; selectedStatus = ["Semua"]; isSelectionMode = false; selectedItemIds.clear(); });
          },
          itemBuilder: (c) => [
            const PopupMenuItem(value: "Pemesanan", child: Text("Pemesanan")),
            const PopupMenuItem(value: "Pengaduan", child: Text("Pengaduan")),
          ],
          child: Row(children: [Text("Riwayat $selectedRiwayatType", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)), const Icon(Icons.keyboard_arrow_down_rounded)]),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() { isSelectionMode = !isSelectionMode; selectedItemIds.clear(); }),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isSelectionMode ? Colors.red.withValues(alpha: 0.1) : primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(isSelectionMode ? Icons.close : Icons.delete_outline, color: isSelectionMode ? Colors.red : primaryColor, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: _showFilterDialog, icon: Icon(Icons.filter_list_rounded, color: primaryColor)),
          ],
        ),
      ],
    ),
  );
}

// --- DIALOG TINJAU PEMESANAN ---
class DialogTinjauPemesanan extends StatefulWidget {
  final BookingModel booking;
  const DialogTinjauPemesanan({super.key, required this.booking});

  @override
  State<DialogTinjauPemesanan> createState() => _DialogTinjauPemesananState();
}

class _DialogTinjauPemesananState extends State<DialogTinjauPemesanan> {
  final DatabaseService db = DatabaseService();
  bool _isProcessing = false;

  // FUNGSI CHECKOUT MANUAL
  Future<void> _handleManualCheckout() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Checkout"),
        content: const Text("Apakah Anda yakin ingin menyelesaikan pesanan ini sekarang? Kamar akan otomatis tersedia kembali."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ya, Checkout", style: TextStyle(color: Color(0xFF008996)))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() => _isProcessing = true);
      try {
        final snapshot = await FirebaseFirestore.instance.collection('items').get();
        
        // Loop Room IDs yang ada di booking ini untuk di-reset ke 'kosong'
        for (var roomId in widget.booking.roomIds) {
          for (var doc in snapshot.docs) {
            List rooms = doc.data()['rooms'] ?? [];
            int idx = rooms.indexWhere((r) => r['id'] == roomId);
            if (idx != -1) {
              rooms[idx]['condition'] = 'kosong';
              await FirebaseFirestore.instance.collection('items').doc(doc.id).update({'rooms': rooms});
            }
          }
        }
        
        // Tandai booking sebagai isRead false agar staff tahu ada update (opsional)
        await FirebaseFirestore.instance.collection('bookings').doc(widget.booking.id).update({
          'isRead': false,
          // 'status': 'completed' // Jika ingin ganti status booking juga bisa di-uncomment
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil Checkout. Kamar kini tersedia.")));
        }
      } catch (e) {
        debugPrint("Error Checkout: $e");
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  Widget _rowInfo(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey))),
        const SizedBox(width: 10),
        Expanded(flex: 1, child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), softWrap: true)),
      ],
    ),
  );

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF008996))),
  );

  Widget _buildFilePreview(String? path, String label) {
    if (path == null || path.isEmpty) return Text("Tidak ada $label", style: const TextStyle(fontSize: 10, color: Colors.grey));
    bool isNetwork = path.startsWith('http');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: isNetwork 
            ? Image.network(path, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Text("Gagal memuat gambar"))
            : Image.file(File(path), height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Text("Dokumen tersimpan secara lokal")),
        ),
      ],
    );
  }

  void _showRejectDialog() {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setPopUpState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Konfirmasi Penolakan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Tulis alasan di sini...", 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12)
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: _isProcessing ? null : () => Navigator.pop(context), child: const Text("Batal")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _isProcessing ? null : () async {
                  setPopUpState(() => _isProcessing = true);
                  final navigator = Navigator.of(context);
                  try {
                    String alasan = reasonController.text.trim();
                    if (alasan.isEmpty) alasan = "Tidak ada alasan spesifik.";
                    await db.rejectBooking(widget.booking.id, "rejected", alasan, widget.booking.roomIds);
                    await FirebaseFirestore.instance.collection('bookings').doc(widget.booking.id).update({'rejectReason': alasan, 'isRead': false});
                    
                    final snapshot = await FirebaseFirestore.instance.collection('items').get();
                    for (var roomId in widget.booking.roomIds) {
                      for (var doc in snapshot.docs) {
                        List rooms = doc.data()['rooms'] ?? [];
                        int idx = rooms.indexWhere((r) => r['id'] == roomId);
                        if (idx != -1) {
                          rooms[idx]['condition'] = 'kosong';
                          await FirebaseFirestore.instance.collection('items').doc(doc.id).update({'rooms': rooms});
                        }
                      }
                    }
                    if (mounted) { navigator.pop(); navigator.pop(); }
                  } catch (e) { debugPrint("Gagal: $e"); }
                  finally { if (mounted) setPopUpState(() => _isProcessing = false); }
                },
                child: _isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Tolak", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('bookings').doc(widget.booking.id).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final String kategoriTamu = data['user_type'] ?? "eksternal"; 
          final bool isWisma = !widget.booking.itemName.toLowerCase().contains("kelas") && !widget.booking.itemName.toLowerCase().contains("aula");
          final String? lampiran = data['paymentProof'];
          final String? rejectReason = data['rejectReason'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Tinjau Pemesanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20))]),
                  const Divider(height: 30),
                  
                  if (widget.booking.status == BookingStatus.rejected) ...[
                    _sectionHeader("STATUS: DITOLAK"),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.2))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Alasan Penolakan:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                          const SizedBox(height: 4),
                          Text(rejectReason ?? "Tidak ada alasan spesifik.", style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    const Divider(height: 32),
                  ],

                  _rowInfo("Tipe", isWisma ? "Wisma (${kategoriTamu.toUpperCase()})" : "Ruangan/Kelas"),
                  _sectionHeader("DATA PEMESAN"),
                  _rowInfo("Nama", widget.booking.userName),
                  _rowInfo("NIK", data['nik'] ?? "-"),
                  if (kategoriTamu == "internal" || !isWisma) _rowInfo("NIP", data['nip'] ?? "-"),
                  if (isWisma && kategoriTamu == "eksternal") ...[
                    _rowInfo("Alamat", data['address'] ?? "-"),
                    _rowInfo("NPWP", data['npwp'] ?? "-"),
                  ],
                  _sectionHeader("DETAIL PESANAN"),
                  _rowInfo("Item", widget.booking.itemName),
                  _rowInfo("Kamar/Kelas", widget.booking.roomIds.join(", ").replaceAll('_', ' ').toUpperCase()),
                  _rowInfo("Total Bayar", "Rp ${widget.booking.totalPayment.toInt()}"),
                  const SizedBox(height: 10),
                  _sectionHeader("DOKUMEN LAMPIRAN"),
                  _buildFilePreview(lampiran, isWisma && kategoriTamu == "eksternal" ? "Bukti Pembayaran" : "Surat Tugas"),
                  const SizedBox(height: 32),

                  // LOGIKA TOMBOL ACTION
                  if (widget.booking.status == BookingStatus.pending)
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: _showRejectDialog, style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Tolak", style: TextStyle(color: Colors.red)))),
                        const SizedBox(width: 12),
                        Expanded(child: ElevatedButton(onPressed: () async { 
                          final navigator = Navigator.of(context);
                          await db.approveBooking(widget.booking.id); 
                          await FirebaseFirestore.instance.collection('bookings').doc(widget.booking.id).update({'isRead': false});
                          if (mounted) navigator.pop(); 
                        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008996), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Terima", style: TextStyle(color: Colors.white)))),
                      ],
                    )
                  else if (widget.booking.status == BookingStatus.approved)
                    // TOMBOL CHECKOUT MANUAL JIKA SUDAH APPROVED
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _handleManualCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: _isProcessing 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                        label: const Text("Checkout Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}

// Cari class DialogTinjauPengaduan di file riwayat_approval.dart
class DialogTinjauPengaduan extends StatefulWidget {
  final ComplaintModel complaint;
  const DialogTinjauPengaduan({super.key, required this.complaint});

  @override
  State<DialogTinjauPengaduan> createState() => _DialogTinjauPengaduanState();
}

class _DialogTinjauPengaduanState extends State<DialogTinjauPengaduan> {
  final DatabaseService db = DatabaseService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tinjau Pengaduan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20)),
              ],
            ),
            const Divider(height: 30),
            
            // --- TAMPILKAN FOTO BUKTI DARI TEKNISI ---
            if (widget.complaint.status.name == 'waitingApproval' || widget.complaint.status == ComplaintStatus.resolved) 
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('complaints').doc(widget.complaint.id).get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    String? proofUrl = snapshot.data!.get('completionProof');
                    if (proofUrl != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Bukti Perbaikan:", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(proofUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),

            const Text("Masalah:", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(widget.complaint.description, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 32),
            
            // --- LOGIKA TOMBOL PERSETUJUAN APPROVAL ---
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('complaints').doc(widget.complaint.id).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                
                String statusStr = snapshot.data!.get('status');

                // Jika teknisi sudah kirim bukti, maka tombol muncul di sisi Approval
                if (statusStr == 'waitingApproval') {
                  return Row(
                    children: [
                      // Tombol Tolak (Kembalikan ke Dalam Perbaikan)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () async {
                            setState(() => _isLoading = true);
                            await FirebaseFirestore.instance.collection('complaints').doc(widget.complaint.id).update({
                              'status': 'repairing',
                              'rejectReason': 'Bukti kurang jelas atau perbaikan belum selesai'
                            });
                            if (mounted) Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: const Text("Tolak", style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Tombol Setuju (Status jadi Selesai/Resolved)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () async {
                            setState(() => _isLoading = true);
                            // Menggunakan fungsi resolveComplaint yang sudah ada di DatabaseService
                            await db.resolveComplaint(widget.complaint.id, "Selesai", widget.complaint.roomId);
                            if (mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF008996),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: const Text("Setujui", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  );
                } else if (statusStr == 'repairing') {
                  return const Center(child: Text("Teknisi sedang melakukan perbaikan...", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)));
                } else if (statusStr == 'resolved') {
                  return const Center(child: Text("Pengaduan Selesai", style: TextStyle(color: Color(0xFF008996), fontWeight: FontWeight.bold)));
                } else {
                  return const Center(child: Text("Menunggu teknisi mengambil tindakan", style: TextStyle(fontSize: 11, color: Colors.grey)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}