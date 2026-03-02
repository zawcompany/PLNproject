import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambah ini
import '../../models/item_model.dart';
import '../../models/room_model.dart';
import '../../models/booking_model.dart'; // Tambah ini
import '../../services/database_service.dart'; // Tambah ini

class FormKelasPage extends StatefulWidget {
  final RoomModel room;
  final ItemModel item;

  const FormKelasPage({
    super.key,
    required this.room,
    required this.item,
  });

  @override
  State<FormKelasPage> createState() => _FormKelasPageState();
}

class _FormKelasPageState extends State<FormKelasPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService(); 
  bool _isSubmitting = false; 

  // static const Color softTeal = Color(0xFFE8F1F3);
  static const Color primaryTeal = Color(0xFF008996);

  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final nipController = TextEditingController();
  final tamuController = TextEditingController(text: '0');

  DateTimeRange? selectedDate;
  File? suratTugas;
  RoomModel? recommendedRoom;

  @override
  void dispose() {
    namaController.dispose();
    nikController.dispose();
    nipController.dispose();
    tamuController.dispose();
    super.dispose();
  }

  void _checkCapacity(String value) {
    int inputTamu = int.tryParse(value) ?? 0;

    if (inputTamu > widget.room.capacity) {
      try {
        final alternative = widget.item.rooms.firstWhere(
          (r) =>
              r.capacity >= inputTamu &&
              r.name != widget.room.name &&
              r.condition == RoomCondition.kosong, // Sesuaikan dengan enum terbaru
        );
        setState(() => recommendedRoom = alternative);
      } catch (e) {
        setState(() => recommendedRoom = null);
      }
    } else {
      setState(() => recommendedRoom = null);
    }
  }

  // FUNGSI SIMPAN DATA KE FIREBASE
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && selectedDate != null) {
      setState(() => _isSubmitting = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw "User tidak terautentikasi";

        final newBooking = BookingModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.uid,
          userName: namaController.text.trim(),
          roomIds: [widget.room.id],
          itemName: widget.item.title,
          start: selectedDate!.start,
          end: selectedDate!.end,
          totalPayment: 0,
          status: BookingStatus.pending,
          paymentProof: suratTugas?.path,
          nik: nikController.text.trim(),
          nip: nipController.text.trim(),
          guestCount: int.tryParse(tamuController.text) ?? 0,
          userType: 'internal',
        );

        await _db.createBooking(newBooking, widget.item.id);

        if (!mounted) return;
        _showSuccessDialog();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim: $e"), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
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
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Berhasil Dikirim!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 12),
                Text(
                  "Permohonan peminjaman ruang kelas telah berhasil dikirim. Silakan cek status reservasi Anda secara berkala.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
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
                      elevation: 0,
                    ),
                    child: const Text("Tutup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
              // Custom Top Bar 
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 70, 
                    child: SvgPicture.asset(
                      'lib/assets/images/header_riwayat.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "Reservasi Ruang Kelas",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      const Text(
                        "Isi data untuk peminjaman ruangan kelas",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 25),
                      
                      _buildField(
                        label: "Nama Lengkap",
                        controller: namaController,
                        icon: Icons.person_outline,
                      ),
                      _buildField(
                        label: "Nomor Induk Kependudukan (NIK)",
                        controller: nikController,
                        icon: Icons.badge_outlined,
                        type: TextInputType.number,
                      ),
                      _buildField(
                        label: "Nomor Induk Pegawai (NIP)",
                        controller: nipController,
                        icon: Icons.work_outline,
                        type: TextInputType.number,
                      ),
                      
                      _buildUploadBox("Unggah Surat Tugas", suratTugas != null, _pickSurat),
                      
                      const SizedBox(height: 30),
                      _buildField(
                        label: "Jumlah Tamu (Kapasitas: ${widget.room.capacity})",
                        controller: tamuController,
                        icon: Icons.groups_outlined,
                        type: TextInputType.number,
                        onChanged: _checkCapacity,
                      ),
                      
                      if (recommendedRoom != null) _buildRecommendationCard(),
                      
                      _buildDateRangeField(),
                      const SizedBox(height: 40),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isSubmitting 
                            ? const SizedBox(
                                height: 20, 
                                width: 20, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : const Text(
                                "Pesan Sekarang",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType type = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: type,
            onChanged: onChanged,
            onTap: () {
              if (controller.text == '0') {
                controller.clear();
              }
            },
            validator: (value) =>
                (value == null || value.isEmpty) ? "Wajib diisi" : null,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox(String label, bool isFileSelected, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
                color: isFileSelected
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(isFileSelected ? Icons.check_circle : Icons.file_upload_outlined,
                    color: isFileSelected ? Colors.green : Colors.grey[600],
                    size: 24),
                if (isFileSelected)
                  const Positioned(
                      right: 16,
                      child: Text("Terpilih ✔",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.amber, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Kapasitas penuh! Kami rekomendasikan: ${recommendedRoom!.name} (Kapasitas: ${recommendedRoom!.capacity})",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormKelasPage(
                      room: recommendedRoom!, 
                      item: widget.item,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, elevation: 0),
              child: const Text("Pindah ke Kelas Rekomendasi", 
                style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDateRangeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Periode Peminjaman",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        InkWell(
          onTap: _pickDateRange,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.grey[600], size: 18),
                const SizedBox(width: 12),
                Text(selectedDate == null
                    ? "Pilih Tanggal"
                    : "${DateFormat('dd/MM/yyyy').format(selectedDate!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDate!.end)}"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickSurat() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => suratTugas = File(picked.path));
  }
}