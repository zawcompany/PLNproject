import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini
import 'package:firebase_auth/firebase_auth.dart'; // Tambahkan ini
import '../../models/item_model.dart';
import '../../models/room_model.dart';
import '../../models/booking_model.dart'; // Tambahkan ini
import '../../services/database_service.dart'; // Tambahkan ini

class FormKelasGeneral extends StatefulWidget {
  const FormKelasGeneral({super.key});

  @override
  State<FormKelasGeneral> createState() => _FormKelasGeneralState();
}

class _FormKelasGeneralState extends State<FormKelasGeneral> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService(); // Inisialisasi Service
  
  static const Color primaryTeal = Color(0xFF008996);
  // static const Color softTeal = Color(0xFFE8F1F3);
  static const Color softred = Color(0xffffd6d6);

  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final nipController = TextEditingController();
  final perempuanController = TextEditingController(text: '0');
  final lakiController = TextEditingController(text: '0');

  DateTimeRange? selectedDate;
  File? suratTugas;
  List<RoomModel> selectedRooms = [];
  bool _isSubmitting = false; // State loading

  @override
  void dispose() {
    namaController.dispose();
    nikController.dispose();
    nipController.dispose();
    perempuanController.dispose();
    lakiController.dispose();
    super.dispose();
  }

  // Cek ketersediaan berdasarkan status di database
  bool isRoomAvailable(RoomModel room) {
    return room.condition == RoomCondition.kosong;
  }

  // FUNGSI UTAMA: SIMPAN KE FIREBASE & UPDATE STATUS KELAS
  Future<void> _submitGeneralKelasBooking() async {
    if (selectedRooms.isEmpty || suratTugas == null) return;
    
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "User tidak ditemukan";

      final snapshot = await FirebaseFirestore.instance.collection('items').get();
      final allItems = snapshot.docs.map((doc) => ItemModel.fromMap(doc.id, doc.data())).toList();

      // LOOPING UNTUK MEMBUAT DOKUMEN BOOKING TERPISAH PER KAMAR
      for (var room in selectedRooms) {
        final newBooking = BookingModel(
          // Tambahkan suffix ID kamar agar ID booking di Firestore unik
          id: "${DateTime.now().millisecondsSinceEpoch}_${room.id}", 
          userId: user.uid,
          userName: namaController.text.trim(),
          roomIds: [room.id], // Hanya simpan 1 ID kamar
          itemName: room.name, // Nama item langsung nama kamarnya (A1, A2, dsb)
          start: selectedDate!.start,
          end: selectedDate!.end,
          totalPayment: 0,
          status: BookingStatus.pending,
          paymentProof: suratTugas!.path,
          nik: nikController.text.trim(),
          nip: nipController.text.trim(),
          guestCount: (int.tryParse(lakiController.text) ?? 0) + (int.tryParse(perempuanController.text) ?? 0),
          userType: 'internal',
        );

        // Update status kamar spesifik ini di koleksi items
        final parentItem = allItems.firstWhere((item) => item.rooms.any((r) => r.id == room.id));
        await _db.updateRoomCondition(parentItem.id, room.name, RoomCondition.terisi);

        // Simpan dokumen booking individual ke koleksi bookings
        await FirebaseFirestore.instance.collection('bookings').doc(newBooking.id).set(newBooking.toMap());
      }

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showKelasSelection() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih tanggal terlebih dahulu!", style: TextStyle(color: Colors.black)),
          backgroundColor: softred,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return StreamBuilder<List<ItemModel>>(
              stream: _db.getItems(), // Ambil data real-time
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final allKelasItems = snapshot.data!.where((item) => item.type == ItemType.kelas).toList();
                const specialRooms = ["Aula", "Lab B", "Kelas Toddopuli"];
                final regulerKelas = allKelasItems.where((item) => !specialRooms.contains(item.title)).toList();
                final otherRoomsList = allKelasItems
                    .where((item) => specialRooms.contains(item.title))
                    .expand((item) => item.rooms)
                    .toList();

                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  backgroundColor: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.meeting_room_rounded, color: primaryTeal, size: 22),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Pilih Ruang Kelas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text("Pilih satu atau beberapa kelas", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...regulerKelas.map((item) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: item.rooms.map((room) {
                                          return _buildRoomChip(room, item.title, setDialogState);
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                }),
                                if (otherRoomsList.isNotEmpty) ...[
                                  const Text("Kelas Lainnya", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: otherRoomsList.map((room) {
                                      return _buildRoomChip(room, "Kelas Lainnya", setDialogState);
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTeal,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Selesai", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            );
          },
        );
      },
    );
  }

  Widget _buildRoomChip(RoomModel room, String categoryTitle, StateSetter setDialogState) {
    final bool available = isRoomAvailable(room);
    final bool isSelected = selectedRooms.any((r) => r.id == room.id);
    
    String displayNumber = categoryTitle == "Kelas Lainnya" 
        ? room.name 
        : room.name.replaceAll(categoryTitle, "").trim();

    return FilterChip(
      label: Text(displayNumber),
      selected: isSelected,
      onSelected: available ? (bool selected) {
        setDialogState(() {
          if (selected) {
            selectedRooms.add(room);
          } else {
            selectedRooms.removeWhere((r) => r.id == room.id);
          }
        });
        setState(() {}); 
      } : null,
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? Colors.white : (available ? Colors.black87 : Colors.grey),
      ),
      selectedColor: primaryTeal,
      checkmarkColor: Colors.white,
      backgroundColor: available ? Colors.grey[100] : Colors.grey[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
                ),
                const SizedBox(height: 24),
                const Text("Permohonan Terkirim!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  "Permohonan peminjaman kelas berhasil dikirim dan status ruangan telah diperbarui.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Tutup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: SvgPicture.asset('lib/assets/images/header_riwayat.svg', fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 15, left: 15,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        radius: 18, backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_back, color: Colors.black, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Formulir Pinjam Kelas General", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text("Lengkapi data untuk peminjaman beberapa ruang kelas sekaligus", style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField("Nama Lengkap", namaController, Icons.person_outline),
                      _buildField("Nomor Induk Kependudukan (NIK)", nikController, Icons.badge_outlined, TextInputType.number),
                      _buildField("Nomor Induk Pegawai (NIP)", nipController, Icons.work_outline, TextInputType.number),
                      
                      const SizedBox(height: 10),
                      const Text("Jumlah Tamu", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildField("Perempuan", perempuanController, Icons.female_outlined, TextInputType.number)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildField("Laki-laki", lakiController, Icons.male_outlined, TextInputType.number)),
                        ],
                      ),

                      _buildDateRangeField(),
                      
                      const SizedBox(height: 20),
                      const Text("Ruang Kelas yang dipilih", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      
                      InkWell(
                        onTap: _showKelasSelection,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.meeting_room_outlined, color: Colors.grey, size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedRooms.isEmpty ? "Klik untuk memilih kelas" : selectedRooms.map((r) => r.name).join(", "),
                                  style: TextStyle(fontSize: 14, color: selectedRooms.isEmpty ? Colors.grey : Colors.black),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                      _buildUploadBox("Unggah Surat Tugas", suratTugas != null, _pickSurat),

                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity, height: 55,
                        child: ElevatedButton(
                          onPressed: (selectedRooms.isNotEmpty && suratTugas != null && !_isSubmitting) 
                            ? _submitGeneralKelasBooking 
                            : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isSubmitting 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Konfirmasi Pinjam Kelas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper tetap sama secara visual
  Widget _buildField(String label, TextEditingController controller, IconData icon, [TextInputType type = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller, keyboardType: type,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: Colors.grey),
              filled: true, fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Periode Pelatihan / Kegiatan", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context, firstDate: DateTime.now(), lastDate: DateTime(2030),
              builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: primaryTeal)), child: child!),
            );
            if (picked != null) setState(() { selectedDate = picked; selectedRooms.clear(); });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                const SizedBox(width: 12),
                Text(selectedDate == null ? "Pilih Tanggal" : "${DateFormat('dd/MM/yyyy').format(selectedDate!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDate!.end)}"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox(String label, bool isFileSelected, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity, height: 55,
            decoration: BoxDecoration(color: isFileSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
            child: Icon(isFileSelected ? Icons.check_circle : Icons.file_upload_outlined, color: isFileSelected ? Colors.green : Colors.grey),
          ),
        ),
      ],
    );
  }

  Future<void> _pickSurat() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => suratTugas = File(picked.path));
  }
}