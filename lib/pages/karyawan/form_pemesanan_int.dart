import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/item_model.dart';
import '../../models/room_model.dart';

class FormWismaInternalPage extends StatefulWidget {
  final RoomModel room;
  final ItemModel item;

  const FormWismaInternalPage({
    super.key,
    required this.room,
    required this.item,
  });

  @override
  State<FormWismaInternalPage> createState() => _FormWismaInternalPageState();
}

class _FormWismaInternalPageState extends State<FormWismaInternalPage> {
  final _formKey = GlobalKey<FormState>();

  // Definisi warna
  static const Color softTeal = Color(0xFFE8F1F3);
  static const Color primaryTeal = Color(0xFF008996);

  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final nipController = TextEditingController();
  final perempuanController = TextEditingController(text: '0');
  final lakiController = TextEditingController(text: '0');

  DateTimeRange? selectedDate;
  File? buktiPembayaran;

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
    perempuanController.dispose();
    lakiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      // MENGGUNAKAN PREFERREDSIZE UNTUK MEMPERBESAR TOP BAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0), // Tinggi Top Bar diperbesar menjadi 80
        child: AppBar(
          backgroundColor: softTeal, 
          elevation: 0,
          centerTitle: false,
          leading: Padding(
            padding: const EdgeInsets.only(top: 10), // Menyesuaikan posisi icon back
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black), // Panah warna hitam
              onPressed: () => Navigator.pop(context),
            ),
          ),
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 15), // Menyesuaikan posisi teks ke bawah
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Pemesanan Internal", 
                  style: TextStyle(
                    fontSize: 20, // Ukuran teks judul diperbesar
                    fontWeight: FontWeight.bold, 
                    color: Colors.black // Teks judul warna hitam
                  )
                ),
                Text(
                  "Lengkapi data pemesanan wisma", 
                  style: TextStyle(fontSize: 13, color: Colors.black54)
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildField("Nama Lengkap", namaController, Icons.person_outline),
              _buildField("Nomor Induk Karyawan (NIK)", nikController, Icons.badge_outlined, TextInputType.number),
              _buildField("Nomor Induk Pegawai (NIP)", nipController, Icons.work_outline, TextInputType.number, false),

              const Text("Jumlah Tamu", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _buildField("Perempuan", perempuanController, Icons.female_outlined, TextInputType.number)),
                  const SizedBox(width: 14),
                  Expanded(child: _buildField("Laki-laki", lakiController, Icons.male_outlined, TextInputType.number)),
                ],
              ),

              _buildDateRangeField(),
              const SizedBox(height: 22),
              _buildTotalCard(),

              if (totalHarga > 0) ...[
                const SizedBox(height: 22),
                _buildRekeningCard(),
                const SizedBox(height: 16),
                _buildUploadBukti(),
              ],

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (buktiPembayaran != null) ? _submitForm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    "Pesan Sekarang",
                    style: TextStyle(
                      color: buktiPembayaran != null ? Colors.white : Colors.grey[600], 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, [TextInputType type = TextInputType.text, bool isRequired = true]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: type,
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) return "Wajib diisi";
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: Colors.grey), // Ikon dalam field warna abu-abu
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDADADA))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDADADA))),
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
        const Text("Periode Pemesanan", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        InkWell(
          onTap: _pickDateRange,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDADADA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.grey), // Ikon tanggal warna abu-abu
                const SizedBox(width: 12),
                Text(
                  selectedDate == null 
                  ? "Pilih Tanggal" 
                  : "${DateFormat('dd/MM/yyyy').format(selectedDate!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDate!.end)}",
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: softTeal, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            currency.format(totalHarga), 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryTeal)
          ),
        ],
      ),
    );
  }

  Widget _buildRekeningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: const Text("Bank BRI\n033901000171301\nReceipt PT. PLN", style: TextStyle(fontSize: 12, height: 1.5)),
    );
  }

  Widget _buildUploadBukti() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: buktiPembayaran != null ? Colors.green[50] : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: buktiPembayaran != null ? Colors.green : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(Icons.upload_file, color: buktiPembayaran != null ? Colors.green : Colors.grey),
            const SizedBox(width: 10),
            Expanded(child: Text(buktiPembayaran != null ? "Bukti Terunggah" : "Unggah Bukti Pembayaran")),
          ],
        ),
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
    if (picked != null) {
      setState(() {
        buktiPembayaran = File(picked.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, true);
    }
  }
}