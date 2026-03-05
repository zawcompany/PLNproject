import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/item_model.dart';
import '../../models/room_model.dart';
import '../../models/booking_model.dart';
import '../../services/database_service.dart';

class FormKelasGeneral extends StatefulWidget {
  const FormKelasGeneral({super.key});

  @override
  State<FormKelasGeneral> createState() => _FormKelasGeneralState();
}

class _FormKelasGeneralState extends State<FormKelasGeneral> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService();

  static const Color primaryTeal = Color(0xFF008996);

  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final nipController = TextEditingController();
  final totalPesertaController = TextEditingController(text: '0');

  DateTimeRange? selectedDate;
  File? suratTugas;
  
  List<RoomModel> selectedRooms = []; 
  List<RoomModel> recommendedRooms = []; 
  bool _isSubmitting = false;

  final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    totalPesertaController.addListener(_updateRecommendations);
  }

  @override
  void dispose() {
    namaController.dispose();
    nikController.dispose();
    nipController.dispose();
    totalPesertaController.dispose();
    super.dispose();
  }

  void _updateRecommendations() async {
    if (selectedDate == null) return;
    final int totalTamu = int.tryParse(totalPesertaController.text) ?? 0;

    if (totalTamu == 0) {
      if (mounted) setState(() { recommendedRooms = []; selectedRooms = []; });
      return;
    }

    final snapshot = await FirebaseFirestore.instance.collection('items').get();
    final allKelas = snapshot.docs
        .map((doc) => ItemModel.fromMap(doc.id, doc.data()))
        .where((item) => item.type == ItemType.kelas)
        .toList();

    List<RoomModel> availableRooms = [];
    for (var kelas in allKelas) {
      availableRooms.addAll(kelas.rooms.where((r) => r.condition == RoomCondition.kosong));
    }

    availableRooms.sort((a, b) => b.capacity.compareTo(a.capacity));
    List<RoomModel> tempRec = [];
    int sisaTamu = totalTamu;
    for (var i = 0; i < availableRooms.length && sisaTamu > 0; i++) {
      var room = availableRooms[i];
      tempRec.add(room);
      sisaTamu -= room.capacity;
    }

    if (mounted) {
      setState(() {
        recommendedRooms = tempRec;
        if (selectedRooms.isEmpty) selectedRooms = List.from(tempRec);
      });
    }
  }

  Widget _buildRecommendationInfo() {
    if (selectedDate == null || recommendedRooms.isEmpty) return const SizedBox.shrink();
    final int totalTamu = int.tryParse(totalPesertaController.text) ?? 0;
    int totalKapasitasUser = 0;
    for (var r in selectedRooms) { totalKapasitasUser += r.capacity; }

    bool isWarning = totalKapasitasUser < totalTamu && selectedRooms.isNotEmpty;
    Color boxColor = isWarning ? Colors.red : primaryTeal;

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: boxColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: boxColor.withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isWarning ? Icons.warning_amber_rounded : Icons.auto_awesome_rounded, color: boxColor, size: 18),
              const SizedBox(width: 8),
              Text(isWarning ? "Kapasitas Tidak Cukup!" : "Rekomendasi Sistem", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: boxColor)),
            ],
          ),
          const SizedBox(height: 8),
          if (isWarning) ...[
            Text("Total kapasitas ($totalKapasitasUser) tidak cukup untuk $totalTamu orang.",
              style: const TextStyle(fontSize: 11, color: Colors.red, height: 1.4, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
          ],
          Text("Saran: ${recommendedRooms.map((r) => r.name).join(', ')}",
            style: TextStyle(fontSize: 12, color: isWarning ? Colors.black54 : Colors.black87, height: 1.4)),
        ],
      ),
    );
  }

  void _showManualKelasSelection() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih tanggal terlebih dahulu!")));
      return;
    }
    List<RoomModel> tempSelected = List.from(selectedRooms);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => StreamBuilder<List<ItemModel>>(
          stream: _db.getItems(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final allKelas = snapshot.data!.where((item) => item.type == ItemType.kelas).toList();
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pilih Ruang Kelas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const Divider(height: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: allKelas.map((item) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 8),
                              Wrap(spacing: 8, children: item.rooms.map((room) {
                                final bool isAvail = room.condition == RoomCondition.kosong;
                                final bool isSelected = tempSelected.any((r) => r.id == room.id);
                                return FilterChip(
                                  label: Text("${room.name} (${room.capacity})", style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
                                  selected: isSelected,
                                  onSelected: isAvail ? (selected) {
                                    setDialogState(() {
                                      if (selected) {
                                        tempSelected.add(room);
                                      } else {
                                        tempSelected.removeWhere((r) => r.id == room.id);
                                      }
                                    });
                                  } : null,
                                  selectedColor: primaryTeal,
                                  checkmarkColor: Colors.white,

                                  backgroundColor: Colors.white, 
                                  disabledColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                );
                              }).toList()),
                              const SizedBox(height: 20),
                            ],
                          )).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(child: SizedBox(height: 48, child: OutlinedButton(
                        onPressed: () => setDialogState(() => tempSelected.clear()),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text("Reset", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))))),
                      const SizedBox(width: 12),
                      Expanded(child: SizedBox(height: 48, child: ElevatedButton(
                        onPressed: () { setState(() => selectedRooms = List.from(tempSelected)); Navigator.pop(context); },
                        style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text("Selesai", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
                    ])
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submitGeneralKelasBooking() async {
    final int totalTamu = int.tryParse(totalPesertaController.text) ?? 0;
    if (selectedDate == null || selectedRooms.isEmpty || suratTugas == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi semua data!")));
       return;
    }
    
    int totalKapasitasDipilih = selectedRooms.fold(0, (acc, item) => acc + item.capacity);
    if (totalKapasitasDipilih < totalTamu) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kapasitas tidak mencukupi!"), backgroundColor: Colors.red));
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        final snapshot = await FirebaseFirestore.instance.collection('items').get();
        final allItems = snapshot.docs.map((doc) => ItemModel.fromMap(doc.id, doc.data())).toList();

        for (var room in selectedRooms) {
          final newBooking = BookingModel(
            id: "${DateTime.now().millisecondsSinceEpoch}_${room.id}",
            userId: user!.uid,
            userName: namaController.text.trim(),
            roomIds: [room.id],
            itemName: room.name,
            start: selectedDate!.start,
            end: selectedDate!.end,
            totalPayment: 0,
            status: BookingStatus.pending,
            paymentProof: suratTugas!.path,
            userType: 'internal',
            nik: nikController.text.trim(),
            nip: nipController.text.trim(),
            guestCount: totalTamu,
            createdAt: DateTime.now(),
          );
          
          final parent = allItems.firstWhere((item) => item.rooms.any((r) => r.id == room.id));
          await _db.updateRoomCondition(parent.id, room.name, RoomCondition.terisi);
          await FirebaseFirestore.instance.collection('bookings').doc(newBooking.id).set(newBooking.toMap());
        }
        if (!mounted) return;
        _showSuccessDialog();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
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
              _buildTopBanner(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Formulir Pinjam Kelas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text("Lengkapi data dan pilih ruangan tersedia", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 24),
                      
                      _buildField("Nama Penanggung Jawab", namaController, Icons.person_outline),
                      const SizedBox(height: 20),
                      _buildField("Nomor NIK", nikController, Icons.badge_outlined, type: TextInputType.number),
                      const SizedBox(height: 20),
                      _buildField("Nomor NIP", nipController, Icons.work_outline, type: TextInputType.number),
                      const SizedBox(height: 20),

                      const Text("Jumlah Peserta", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildField("", totalPesertaController, Icons.groups_outlined, type: TextInputType.number),
                      const SizedBox(height: 20),

                      const Text("Periode Kegiatan", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _buildDateRangeField(),
                      const SizedBox(height: 20),

                      const Text("Ruang Kelas yang dipilih", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _buildManualSelector(),
                      _buildRecommendationInfo(),
                      const SizedBox(height: 20),

                      const Text("Surat Tugas", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _buildUploadBox("Unggah Dokumen", suratTugas != null, _pickSurat),

                      const SizedBox(height: 40),
                      _buildSubmitButton(),
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

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType type = TextInputType.text, bool isOptional = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: type,
          onTap: () { if (controller.text == '0') controller.clear(); },
          validator: (value) => (isOptional || (value != null && value.trim().isNotEmpty)) ? null : "Wajib diisi",
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: Colors.grey),
            filled: true, fillColor: const Color(0xFFF8F9F9),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeField() {
    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2030),
          builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: primaryTeal)), child: child!));
        if (picked != null) { setState(() => selectedDate = picked); _updateRecommendations(); }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8F9F9), borderRadius: BorderRadius.circular(12), 
          border: Border.all(color: selectedDate == null && _isSubmitting ? Colors.red : const Color(0xFFEEEEEE))),
        child: Row(children: [
          const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Text(selectedDate == null ? "Pilih Tanggal" : "${DateFormat('dd MMM').format(selectedDate!.start)} - ${DateFormat('dd MMM yyyy').format(selectedDate!.end)}"),
        ]),
      ),
    );
  }

  Widget _buildManualSelector() {
    return InkWell(
      onTap: _showManualKelasSelection,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8F9F9), borderRadius: BorderRadius.circular(12), 
          border: Border.all(color: selectedRooms.isEmpty && _isSubmitting ? Colors.red : const Color(0xFFEEEEEE))),
        child: Row(children: [
          const Icon(Icons.meeting_room_outlined, color: Colors.grey, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(selectedRooms.isEmpty ? "Klik untuk memilih ruangan" : selectedRooms.map((r) => r.name).join(", "),
            style: TextStyle(color: selectedRooms.isEmpty ? Colors.grey : Colors.black))),
          const Icon(Icons.edit_note_rounded, color: primaryTeal, size: 22),
        ]),
      ),
    );
  }

  Widget _buildUploadBox(String label, bool isFileSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(color: isFileSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF8F9F9), borderRadius: BorderRadius.circular(12), 
          border: Border.all(color: !isFileSelected && _isSubmitting ? Colors.red : (isFileSelected ? Colors.green : const Color(0xFFEEEEEE)))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(isFileSelected ? Icons.check_circle_rounded : Icons.cloud_upload_outlined, color: isFileSelected ? Colors.green : Colors.grey),
          const SizedBox(width: 12),
          Text(isFileSelected ? "Dokumen Terlampir" : label, style: TextStyle(color: isFileSelected ? Colors.green : Colors.grey, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
      onPressed: _isSubmitting ? null : _submitGeneralKelasBooking,
      style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, disabledBackgroundColor: Colors.grey[200], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("Konfirmasi Pinjam Kelas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ));
  }

  Widget _buildTopBanner() {
    return Stack(children: [
      SizedBox(width: double.infinity, height: 120, child: SvgPicture.asset('lib/assets/images/header_riwayat.svg', fit: BoxFit.cover)),
      Positioned(top: 20, left: 15, child: InkWell(onTap: () => Navigator.pop(context),
        child: const CircleAvatar(radius: 20, backgroundColor: Colors.white, child: Icon(Icons.arrow_back, color: Colors.black, size: 20)))),
    ]);
  }

  void _showSuccessDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
        const SizedBox(height: 24),
        const Text("Berhasil!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
          onPressed: () { Navigator.pop(context); Navigator.pop(context, true); },
          style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text("Tutup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
      ])),
    ));
  }

  Future<void> _pickSurat() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => suratTugas = File(picked.path));
  }
}