import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/booking_model.dart';
import '../../models/complaint_model.dart';
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
                    _buildChips(["Semua", "Kelas A", "Kelas B", "Kelas Lab B", "Aula", "Kelas Toddopuli"], selectedKelas, setDialogState),
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
                if (isSel) {
                  selectedList.clear();
                } else {
                  selectedList.clear();
                  selectedList.add("Semua");
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

        final listKeywordsKelas = ["Kelas A", "Kelas B", "Kelas Lab B", "Aula", "Kelas Toddopuli"];

        allItems = allItems.where((item) {
          String name = (item is BookingModel) ? item.itemName : (item as ComplaintModel).roomName;
          String status = (item is BookingModel) ? item.status.name : (item as ComplaintModel).status.name;

          bool matchesWisma = false;
          if (selectedWisma.contains("Semua")) {
            matchesWisma = !listKeywordsKelas.any((k) => name.toLowerCase().contains(k.toLowerCase()));
          } else if (selectedWisma.isNotEmpty) {
            matchesWisma = selectedWisma.any((w) => name.toLowerCase().contains(w.toLowerCase()));
          }

          bool matchesKelas = false;
          if (selectedKelas.contains("Semua")) {
            matchesKelas = listKeywordsKelas.any((k) => name.toLowerCase().contains(k.toLowerCase()));
          } else if (selectedKelas.isNotEmpty) {
            matchesKelas = selectedKelas.any((k) => name.toLowerCase().contains(k.toLowerCase()));
          }

          bool categoryMatch = matchesWisma || matchesKelas;

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
            if (item is BookingModel) return _buildBookingCard(item);
            return _buildComplaintCard(item as ComplaintModel);
          },
        );
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    String cleanWismaName = booking.itemName.replaceAll(RegExp(r'Wisma', caseSensitive: false), '').trim();
    String roomDisplay = booking.roomIds.isNotEmpty 
        ? booking.roomIds.first.replaceAll('_', ' ').toUpperCase() 
        : cleanWismaName.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(roomDisplay, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(DateFormat('dd MMM yyyy').format(booking.start), style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Text("Wisma: $cleanWismaName", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text("Oleh: ${booking.userName}", style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(booking.status.name, isBooking: true),
              IconButton(
                onPressed: () => _showTinjauPemesanan(booking),
                icon: Icon(Icons.arrow_forward_ios_rounded, color: primaryColor, size: 14),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildComplaintCard(ComplaintModel complaint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(complaint.roomName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
              IconButton(
                onPressed: () => _showTinjauPengaduan(complaint),
                icon: Icon(Icons.arrow_forward_ios_rounded, color: primaryColor, size: 14),
              )
            ],
          )
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: const Color(0xFFF0F4F4)),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
  );

  Widget _buildStatusBadge(String status, {required bool isBooking}) {
    String label = "";
    Color color = Colors.orange;

    if (isBooking) {
      switch (status) {
        case 'pending': label = "MENUNGGU PERSETUJUAN"; color = Colors.orange; break;
        case 'approved': label = "DITERIMA"; color = primaryColor; break;
        case 'rejected': label = "DITOLAK"; color = Colors.red; break;
        default: label = status.toUpperCase();
      }
    } else {
      switch (status) {
        case 'pending': label = "PERLU PERBAIKAN"; color = Colors.red; break;
        case 'repairing': label = "DALAM PERBAIKAN"; color = Colors.orange; break;
        case 'resolved': label = "SELESAI"; color = primaryColor; break;
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
            setState(() {
              selectedRiwayatType = v;
              selectedStatus = ["Semua"]; 
            });
          },
          itemBuilder: (c) => [
            const PopupMenuItem(value: "Pemesanan", child: Text("Pemesanan")),
            const PopupMenuItem(value: "Pengaduan", child: Text("Pengaduan")),
          ],
          child: Row(children: [Text("Riwayat $selectedRiwayatType", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)), const Icon(Icons.keyboard_arrow_down_rounded)]),
        ),
        IconButton(onPressed: _showFilterDialog, icon: Icon(Icons.filter_list_rounded, color: primaryColor)),
      ],
    ),
  );
}

// --- DIALOG TINJAU PEMESANAN ---
class DialogTinjauPemesanan extends StatelessWidget {
  final BookingModel booking;
  const DialogTinjauPemesanan({super.key, required this.booking});

  Widget _rowInfo(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4), 
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        Expanded(child: Text(l, style: const TextStyle(fontSize: 11, color: Colors.grey))), 
        Text(v, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.right)
      ]
    )
  );

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF008996))),
  );

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('bookings').doc(booking.id).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
          
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final String kategoriTamu = data['user_type'] ?? "eksternal"; 
          final bool isWisma = !booking.itemName.toLowerCase().contains("kelas") && !booking.itemName.toLowerCase().contains("aula");

          return SingleChildScrollView(
            child: Padding(
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
                  
                  _rowInfo("Tipe Pesanan", isWisma ? "Wisma (${kategoriTamu.toUpperCase()})" : "Ruangan/Kelas"),

                  _sectionHeader("DATA PEMESAN"),
                  _rowInfo("Nama Lengkap", booking.userName),
                  _rowInfo("NIK", data['nik'] ?? "-"),
                  
                  if (kategoriTamu == "internal" || !isWisma) ...[
                    _rowInfo("NIP", data['nip'] ?? "-"),
                  ],
                  
                  if (isWisma && kategoriTamu == "eksternal") ...[
                    _rowInfo("Alamat", data['address'] ?? "-"),
                    _rowInfo("NPWP", data['npwp'] ?? "-"),
                  ],

                  _sectionHeader("DETAIL PESANAN"),
                  _rowInfo("Item", booking.itemName),
                  _rowInfo("Kamar/Kelas", booking.roomIds.join(", ").replaceAll('_', ' ').toUpperCase()),
                  _rowInfo("Periode", "${DateFormat('dd MMM').format(booking.start)} - ${DateFormat('dd MMM yyyy').format(booking.end)}"),
                  
                  if (isWisma && kategoriTamu == "eksternal") ...[
                    _rowInfo("Tamu Laki-laki", "${data['male_count'] ?? 0}"),
                    _rowInfo("Tamu Perempuan", "${data['female_count'] ?? 0}"),
                  ] else ...[
                    _rowInfo("Jumlah Tamu", "${data['guest_count'] ?? 0}"),
                  ],

                  _sectionHeader("DOKUMEN LAMPIRAN"),
                  if (data['assignment_letter_url'] != null && data['assignment_letter_url'].toString().isNotEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.description, color: Colors.orange),
                      title: const Text("Surat Tugas / Pendaftaran", style: TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () => _launchURL(data['assignment_letter_url']),
                    )
                  else
                    const Text("Tidak ada surat tugas", style: TextStyle(fontSize: 10, color: Colors.grey)),

                  if (data['payment_proof_url'] != null && data['payment_proof_url'].toString().isNotEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.receipt_long, color: Colors.green),
                      title: const Text("Bukti Pembayaran", style: TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () => _launchURL(data['payment_proof_url']),
                    ),

                  const SizedBox(height: 32),
                  if (booking.status == BookingStatus.pending)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await db.rejectBooking(booking.id, "Ditolak", "", booking.roomIds);
                              if (context.mounted) Navigator.pop(context);
                            }, 
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text("Tolak", style: TextStyle(color: Colors.red))
                          )
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await db.approveBooking(booking.id);
                              if (context.mounted) Navigator.pop(context);
                            }, 
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008996), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text("Terima", style: TextStyle(color: Colors.white))
                          )
                        ),
                      ],
                    )
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}

// --- DIALOG TINJAU PENGADUAN ---
class DialogTinjauPengaduan extends StatelessWidget {
  final ComplaintModel complaint;
  const DialogTinjauPengaduan({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
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
            const Text("Masalah:", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(complaint.description, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 32),
            if (complaint.status != ComplaintStatus.resolved)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      Navigator.pop(context);
                      if (complaint.status == ComplaintStatus.pending) {
                        await db.startRepair(complaint.id, "", complaint.roomId);
                      } else {
                        await db.resolveComplaint(complaint.id, "", complaint.roomId);
                      }
                    } catch (e) {
                      debugPrint("Gagal update status: $e");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008996),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: Text(
                    complaint.status == ComplaintStatus.repairing ? "Selesaikan" : "Perbaiki", 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}