import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:monitoring_app/widgets/navbar.dart';
import '../../models/booking_model.dart';
import '../../models/complaint_model.dart';
import '../../models/user_session.dart';
import '../../services/database_service.dart';

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
  String selectedRiwayatType = "Pemesanan";

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<String> statusOptions = selectedRiwayatType == "Pemesanan"
                ? ["Semua", "Menunggu Persetujuan", "Diterima", "Ditolak"]
                : ["Semua", "Perlu Perbaikan", "Dalam Perbaikan", "Menunggu Validasi", "Selesai"];

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
                    _buildChips(["Semua", "Kelas A", "Kelas B", "Lab B", "Aula", "Kelas Toddopuli"], selectedKelas, setDialogState),
                    const SizedBox(height: 20),
                    _buildFilterLabel("Status"),
                    _buildChips(statusOptions, selectedStatus, setDialogState),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => setDialogState(() {
                          selectedWisma = ["Semua"];
                          selectedKelas = ["Semua"];
                          selectedStatus = ["Semua"];
                        }),
                    child: const Text("Reset", style: TextStyle(color: Colors.red))),
                ElevatedButton(
                  onPressed: () { setState(() {}); Navigator.pop(context); },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: const Text("Terapkan", style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
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
          if (index == 0) Navigator.pushReplacementNamed(context, '/staff_dash');
          if (index == 2) Navigator.pushReplacementNamed(context, '/profil');
        },
      ),
    );
  }

  Widget _buildHeader() => SizedBox(width: double.infinity, height: 120, child: SvgPicture.asset('lib/assets/images/header_riwayat.svg', fit: BoxFit.cover));

  Widget _buildTitleRow() {
    String currentRole = UserSession.role.toLowerCase();
    bool canSeeComplaint = currentRole.contains("teknisi") || currentRole == "approval";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          canSeeComplaint
              ? PopupMenuButton<String>(
                  onSelected: (v) => setState(() { selectedRiwayatType = v; selectedStatus = ["Semua"]; }),
                  itemBuilder: (c) => [
                    const PopupMenuItem(value: "Pemesanan", child: Text("Pemesanan")),
                    const PopupMenuItem(value: "Pengaduan", child: Text("Pengaduan")),
                  ],
                  child: Row(
                    children: [
                      Text("Riwayat $selectedRiwayatType", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                      Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor)
                    ],
                  ),
                )
              : Text("Riwayat Pemesanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
          IconButton(onPressed: _showFilterDialog, icon: Icon(Icons.filter_list_rounded, color: primaryColor)),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
    String currentRole = UserSession.role.toLowerCase();
    String? categoryFilter;
    if (currentRole == "teknisi_kelistrikan") categoryFilter = "listrik";
    else if (currentRole == "teknisi_lapangan") categoryFilter = "lapangan";

    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream.list([
        FirebaseFirestore.instance.collection('bookings').where('userId', isEqualTo: currentUserId).snapshots(),
        FirebaseFirestore.instance.collection('complaints').snapshots(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final complaintDocs = snapshot.data![1] as QuerySnapshot;
        List<dynamic> allItems = [];

        if (selectedRiwayatType == "Pemesanan") {
          allItems = (snapshot.data![0] as QuerySnapshot).docs.map((doc) => BookingModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
        } else {
          allItems = complaintDocs.docs
              .map((doc) => ComplaintModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .where((cp) => categoryFilter == null || cp.category == categoryFilter)
              .toList();
        }

        allItems = allItems.where((item) {
          String name = (item is BookingModel) ? item.itemName : (item as ComplaintModel).roomName;
          String statusStr = (item is BookingModel) ? item.status.name : "";
          if (item is ComplaintModel) statusStr = complaintDocs.docs.firstWhere((d) => d.id == item.id).get('status');

          bool matchesWisma = selectedWisma.contains("Semua")
              ? !["Kelas A", "Kelas B", "Lab B", "Aula", "Kelas Toddopuli"].any((k) => name.toLowerCase().contains(k.toLowerCase()))
              : selectedWisma.any((w) => name.toLowerCase().contains(w.toLowerCase()));
          bool matchesKelas = selectedKelas.contains("Semua")
              ? ["Kelas A", "Kelas B", "Lab B", "Aula", "Kelas Toddopuli"].any((k) => name.toLowerCase().contains(k.toLowerCase()))
              : selectedKelas.any((k) => name.toLowerCase().contains(k.toLowerCase()));

          bool statusMatch = false;
          if (selectedStatus.contains("Semua")) {
            statusMatch = true;
          } else {
            if (selectedRiwayatType == "Pemesanan") {
              if (selectedStatus.contains("Menunggu Persetujuan") && statusStr == 'pending') statusMatch = true;
              if (selectedStatus.contains("Diterima") && statusStr == 'approved') statusMatch = true;
              if (selectedStatus.contains("Ditolak") && statusStr == 'rejected') statusMatch = true;
            } else {
              if (selectedStatus.contains("Perlu Perbaikan") && statusStr == 'pending') statusMatch = true;
              if (selectedStatus.contains("Dalam Perbaikan") && statusStr == 'repairing') statusMatch = true;
              if (selectedStatus.contains("Menunggu Validasi") && statusStr == 'waitingApproval') statusMatch = true;
              if (selectedStatus.contains("Selesai") && statusStr == 'resolved') statusMatch = true;
            }
          }
          return (matchesWisma || matchesKelas) && statusMatch;
        }).toList();

        if (allItems.isEmpty) return const Center(child: Text("Tidak ada data riwayat"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: allItems.length,
          itemBuilder: (context, index) {
            final item = allItems[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFF0F4F4)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: item is BookingModel ? _buildBookingCard(item) : _buildComplaintCard(item as ComplaintModel),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    // LOGIKA PARSING NOMOR KAMAR
    String itemName = booking.itemName.replaceAll('_', ' ').toUpperCase();
    String roomNumbers = booking.roomIds.map((id) {
      String cleanedId = id.replaceAll('_', ' ').toUpperCase();
      cleanedId = cleanedId
          .replaceAll('WISMA', '')
          .replaceAll(itemName.replaceAll('WISMA', '').trim(), '')
          .trim();
      return cleanedId;
    }).where((s) => s.isNotEmpty).join(', ');

    String displayTitle = roomNumbers.isEmpty ? itemName : "$itemName $roomNumbers";

    return InkWell(
      onTap: () {
        showDialog(context: context, builder: (context) => DialogTinjauPemesananStaff(booking: booking));
      },
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column( crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    displayTitle, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(DateFormat('dd MMM yyyy').format(booking.start), style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusBadge(booking.status.name, isBooking: true),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(ComplaintModel complaint) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column( crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(complaint.roomName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(DateFormat('dd MMM yyyy').format(complaint.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Text(complaint.description, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Divider(height: 24),
          Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('complaints').doc(complaint.id).snapshots(),
                  builder: (context, snapshot) {
                    String status = snapshot.hasData && snapshot.data!.exists ? snapshot.data!.get('status') : complaint.status.name;
                    return _buildStatusBadge(status, isBooking: false);
                  }),
              IconButton(
                onPressed: () {
                  showDialog(context: context, builder: (context) => DialogTinjauPengaduanStaff(complaint: complaint));
                },
                icon: Icon(Icons.arrow_forward_ios_rounded, color: primaryColor, size: 14),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, {required bool isBooking}) {
    String label = ""; Color color = Colors.orange;
    if (isBooking) {
      switch (status) {
        case 'pending': label = "MENUNGGU"; color = Colors.orange; break;
        case 'approved': label = "DITERIMA"; color = const Color(0xFF008996); break;
        case 'rejected': label = "DIALIHKAN/DITOLAK"; color = Colors.red; break;
        default: label = status.toUpperCase();
      }
    } else {
      switch (status) {
        case 'pending': label = "PERLU PERBAIKAN"; color = Colors.red; break;
        case 'repairing': label = "DALAM PERBAIKAN"; color = Colors.orange; break;
        case 'waitingApproval': label = "MENUNGGU PERSETUJUAN"; color = Colors.blue; break;
        case 'resolved': label = "SELESAI"; color = const Color(0xFF008996); break;
        default: label = status.toUpperCase();
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFilterLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));

  Widget _buildChips(List<String> options, List<String> selectedList, StateSetter setDialogState) {
    return Wrap( spacing: 6,
        children: options.map((opt) {
          final isSel = selectedList.contains(opt);
          return FilterChip(
            label: Text(opt, style: TextStyle(fontSize: 10, color: isSel ? Colors.white : Colors.black87)),
            selected: isSel, selectedColor: const Color(0xFF008996), checkmarkColor: Colors.white,
            onSelected: (v) => setDialogState(() {
              if (opt == "Semua") {
                if (v) { selectedList.clear(); selectedList.add("Semua"); }
              } else {
                selectedList.remove("Semua");
                v ? selectedList.add(opt) : selectedList.remove(opt);
                if (selectedList.isEmpty) selectedList.add("Semua");
              }
            }),
          );
        }).toList());
  }
}

class DialogTinjauPemesananStaff extends StatelessWidget {
  final BookingModel booking;
  const DialogTinjauPemesananStaff({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('bookings').doc(booking.id).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
          
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List? redirectedRooms = data['redirectedTo'];

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("Detail Pemesanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 20)),
                ]),
                const Divider(height: 30),
                
                if (booking.status == BookingStatus.rejected) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("STATUS: DIALIHKAN / DITOLAK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                        const SizedBox(height: 4),
                        Text(booking.rejectReason ?? "Tidak ada alasan spesifik.", style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                        if (redirectedRooms != null && redirectedRooms.isNotEmpty) ...[
                          const Divider(height: 20),
                          const Text("Kamar Pengganti Anda:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF008996))),
                          const SizedBox(height: 4),
                          Text(
                            redirectedRooms.join(", ").replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                _infoRow("Item", booking.itemName.replaceAll('_', ' ').toUpperCase()),
                _infoRow("Tanggal Mulai", DateFormat('dd MMM yyyy').format(booking.start)),
                _infoRow("Status", booking.status.name.toUpperCase()),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class DialogTinjauPengaduanStaff extends StatefulWidget {
  final ComplaintModel complaint;
  const DialogTinjauPengaduanStaff({super.key, required this.complaint});

  @override
  State<DialogTinjauPengaduanStaff> createState() => _DialogTinjauPengaduanStaffState();
}

class _DialogTinjauPengaduanStaffState extends State<DialogTinjauPengaduanStaff> {
  final DatabaseService db = DatabaseService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _processUpload(List<File> files) async {
    setState(() => _isLoading = true);
    try {
      List<String> imageUrls = [];

      for (File file in files) {
        String? url = await db.uploadFile(file, 'complaints_proof');
        if (url != null) imageUrls.add(url);
      }

      if (imageUrls.isNotEmpty) {
        await FirebaseFirestore.instance.collection('complaints').doc(widget.complaint.id).update({
          'status': 'waitingApproval',
          'completionProof': imageUrls.first, 
          'allProofImages': imageUrls,       
          'finishedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.of(context).pop(); 
          Navigator.of(context).pop(); 
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Berhasil mengirim bukti. Menunggu validasi admin."),
              backgroundColor: Color(0xFF008996),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error upload: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showUploadDialog() {
    List<File> selectedFiles = []; 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Bukti Perbaikan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Pilih beberapa foto bukti (Otomatis Kompres)", style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 15),
                  Container(
                    height: 120, width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: selectedFiles.isEmpty
                        ? InkWell(
                            onTap: () async {
                              final List<XFile> images = await _picker.pickMultiImage(imageQuality: 50);
                              if (images.isNotEmpty) {
                                setDialogState(() => selectedFiles.addAll(images.map((e) => File(e.path))));
                              }
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 32),
                                Text("Pilih Foto", style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(8),
                            itemCount: selectedFiles.length + 1,
                            itemBuilder: (context, index) {
                              if (index == selectedFiles.length) {
                                return IconButton(
                                  icon: const Icon(Icons.add_circle, color: Color(0xFF008996)),
                                  onPressed: () async {
                                    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 50);
                                    if (images.isNotEmpty) {
                                      setDialogState(() => selectedFiles.addAll(images.map((e) => File(e.path))));
                                    }
                                  },
                                );
                              }
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(image: FileImage(selectedFiles[index]), fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0, right: 8,
                                    child: GestureDetector(
                                      onTap: () => setDialogState(() => selectedFiles.removeAt(index)),
                                      child: Container(
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: (selectedFiles.isEmpty || _isLoading) ? null : () => _processUpload(selectedFiles),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008996)),
                child: _isLoading 
                  ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Kirim", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isTeknisi = UserSession.role.toLowerCase().contains("teknisi");
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tinjau Pengaduan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            Text("Lokasi: ${widget.complaint.roomName}"),
            const SizedBox(height: 10),
            Text("Masalah: ${widget.complaint.description}"),
            const SizedBox(height: 30),
            if (isTeknisi)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('complaints').doc(widget.complaint.id).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  String status = snapshot.data!.get('status');
                  
                  if (status == 'pending') {
                    return _buildActionButton("Klik Perbaiki", Colors.orange, () async {
                      setState(() => _isLoading = true);
                      await db.startRepair(widget.complaint.id, widget.complaint.roomId, widget.complaint.roomName);
                      if (mounted) setState(() => _isLoading = false);
                    });
                  } else if (status == 'repairing') {
                    return _buildActionButton("Selesai", const Color(0xFF008996), _showUploadDialog);
                  } else if (status == 'waitingApproval') {
                    return const Center(child: Text("Menunggu Persetujuan...", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)));
                  }
                  return const Center(child: Text("Selesai", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)));
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, Color color, VoidCallback onPressed) {
    return SizedBox( width: double.infinity, height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: _isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
          : Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}