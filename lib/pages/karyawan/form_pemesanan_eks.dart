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

class FormWismaEksternalPage extends StatefulWidget {
  final RoomModel room;
  final ItemModel item;

  const FormWismaEksternalPage({
    super.key,
    required this.room,
    required this.item,
  });

  @override
  State<FormWismaEksternalPage> createState() => _FormWismaEksternalPageState();
}

class _FormWismaEksternalPageState extends State<FormWismaEksternalPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService(); // Inisialisasi Service

  static const Color softTeal = Color(0xFFE8F1F3);
  static const Color primaryTeal = Color(0xFF008996);

  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final nipController = TextEditingController();
  final alamatController = TextEditingController();
  final npwpController = TextEditingController();
  final perempuanController = TextEditingController(text: '0');
  final lakiController = TextEditingController(text: '0');

  DateTimeRange? selectedDate;
  File? buktiPembayaran;
  bool _isSubmitting = false; // State untuk loading

  final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  int get totalHarga {
    if (selectedDate == null) return 0;
    final totalDays = selectedDate!.end.difference(selectedDate!.start).inDays + 1;
    
    const int hargaHarian = 250000;
    int hargaBulanan = widget.room.name.toLowerCase().contains("hortensia") 
        ? 2500000 
        : 750000;

    if (totalDays >= 30) {
      int jumlahBulan = totalDays ~/ 30;
      int sisaHari = totalDays % 30;
      return (jumlahBulan * hargaBulanan) + (sisaHari * hargaHarian);
    }
    return totalDays * hargaHarian;
  }

  @override
  void dispose() {
    namaController.dispose();
    nikController.dispose();
    nipController.dispose();
    alamatController.dispose();
    npwpController.dispose();
    perempuanController.dispose();
    lakiController.dispose();
    super.dispose();
  }

  // FUNGSI SIMPAN DATA KE FIREBASE
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && selectedDate != null && buktiPembayaran != null) {
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
          totalPayment: totalHarga.toDouble(),
          status: BookingStatus.pending,
          paymentProof: buktiPembayaran!.path, 
          // Data Tambahan
          nik: nikController.text.trim(),
          address: alamatController.text.trim(),
          npwp: npwpController.text.trim(),
          maleCount: int.tryParse(lakiController.text) ?? 0,
          femaleCount: int.tryParse(perempuanController.text) ?? 0,
          userType: 'eksternal',
        );

        await _db.createBooking(newBooking, widget.item.id);

        if (!mounted) return;
        _showSuccessDialog();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim pesanan: $e"), backgroundColor: Colors.red),
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
                  "Pesanan Berhasil!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 12),
                Text(
                  "Permohonan reservasi eksternal Anda telah berhasil dikirim ke sistem. Silakan tunggu konfirmasi selanjutnya.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog
                      Navigator.pop(context, true); // Kembali ke Detail dengan sukses
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
              // 1. HEADER (Layout Tetap)
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: SvgPicture.asset('lib/assets/images/header_riwayat.svg', fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 15,
                    left: 15,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_back, color: Colors.black, size: 20),
                      ),
                    ),
                  ),
                ],
              ),

              // 2. JUDUL DAN SUBJUDUL (Layout Tetap)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Formulir Reservasi", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Lengkapi data pemesanan ${widget.room.name}", 
                      style: const TextStyle(fontSize: 13, color: Colors.grey)
                    ),
                  ],
                ),
              ),

              // 3. FORM BODY
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField("Nama Lengkap", namaController, Icons.person_outline),
                      _buildField("Nomor Induk Kependudukan (NIK)", nikController, Icons.badge_outlined, TextInputType.number),
                      _buildField("Nomor Induk Pegawai (Opsional)", nipController, Icons.work_outline, TextInputType.number, false),
                      _buildField("Alamat", alamatController, Icons.home_outlined),
                      _buildField("Nomor NPWP", npwpController, Icons.assignment_outlined, TextInputType.number),

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
                      const SizedBox(height: 24),
                      
                      if (selectedDate != null) ...[
                        _buildTotalCard(),
                        const SizedBox(height: 24),
                        _buildRekeningCard(),
                        const SizedBox(height: 16),
                        _buildUploadBox("Unggah Bukti Pembayaran", buktiPembayaran != null, _pickImage),
                      ],

                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: (_isSubmitting || buktiPembayaran == null) ? null : _submitForm, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isSubmitting 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Pesan Sekarang",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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

  // Widget helper tetap sama persis layoutnya
  Widget _buildField(String label, TextEditingController controller, IconData icon, [TextInputType type = TextInputType.text, bool isRequired = true]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: type,
            // --- TAMBAHKAN LOGIKA INI ---
            onTap: () {
              if (controller.text == '0') {
                controller.clear();
              }
            },
            // ----------------------------
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) return "Wajib diisi";
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: isFileSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  isFileSelected ? Icons.check_circle : Icons.file_upload_outlined, 
                  color: isFileSelected ? Colors.green : Colors.grey[600],
                  size: 24,
                ),
                if (isFileSelected)
                  const Positioned(
                    right: 16,
                    child: Text("Berhasil", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Periode Reservasi", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        InkWell(
          onTap: _pickDateRange,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.grey[600], size: 18),
                const SizedBox(width: 12),
                Text(
                  selectedDate == null 
                  ? "Pilih Tanggal" 
                  : "${DateFormat('dd/MM/yyyy').format(selectedDate!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDate!.end)}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: softTeal, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(currency.format(totalHarga), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryTeal)),
        ],
      ),
    );
  }

  Widget _buildRekeningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryTeal,
        borderRadius: BorderRadius.circular(12), 
      ),
      child: const Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Bank BRI\n033901000171301\nReceipt PT. PLN", 
              style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white, fontWeight: FontWeight.w500)
            ),
          ),
        ],
      ),
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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => buktiPembayaran = File(picked.path));
  }
}