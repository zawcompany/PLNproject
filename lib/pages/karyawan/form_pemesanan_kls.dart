import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/item_model.dart';
import '../../models/room_model.dart';
import '../../data/exsistingdata.dart'; 

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

  static const Color softTeal = Color(0xFFE8F1F3);
  static const Color primaryTeal = Color(0xFF008996);

  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final nipController = TextEditingController();
  final tamuController = TextEditingController(text: '0');

  DateTimeRange? selectedDate;
  File? suratTugas;
  RoomModel? recommendedRoom; // Untuk menyimpan rekomendasi kelas lain

  @override
  void dispose() {
    namaController.dispose();
    nikController.dispose();
    nipController.dispose();
    tamuController.dispose();
    super.dispose();
  }

  // LOGIKA PENGECEKAN KAPASITAS & REKOMENDASI
  void _checkCapacity(String value) {
    int inputTamu = int.tryParse(value) ?? 0;
    
    if (inputTamu > widget.room.capacity) {
      // Cari kelas lain dalam kategori yang sama yang kapasitasnya cukup
      try {
        final alternative = widget.item.rooms.firstWhere(
          (r) => r.capacity >= inputTamu && r.name != widget.room.name && r.condition == RoomCondition.normal,
        );
        setState(() => recommendedRoom = alternative);
      } catch (e) {
        // Jika tidak ada kelas yang cukup besar
        setState(() => recommendedRoom = null);
      }
    } else {
      setState(() => recommendedRoom = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: softTeal,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          titleSpacing: 0,
          title: const Padding(
            padding: EdgeInsets.only(top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Reservasi Ruang Kelas", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                Text("Isi data untuk peminjaman ruangan", 
                  style: TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              _buildField("Nama Lengkap", namaController, Icons.person_outline),
              _buildField("NIK", nikController, Icons.badge_outlined, TextInputType.number),
              _buildField("NIP", nipController, Icons.work_outline, TextInputType.number),
              
              _buildUploadBox("Unggah Surat Tugas", suratTugas != null, _pickSurat),
              
              const SizedBox(height: 30),
              _buildField(
                "Jumlah Tamu (Kapasitas: ${widget.room.capacity})", 
                tamuController, 
                Icons.groups_outlined, 
                TextInputType.number,
                onChanged: _checkCapacity
              ),

              // TAMPILAN REKOMENDASI JIKA OVER-CAPACITY
              if (recommendedRoom != null) _buildRecommendationCard(),

              _buildDateRangeField(),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("Pesan Sekarang",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, [TextInputType type = TextInputType.text, Function(String)? onChanged]) {
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
            onChanged: onChanged,
            validator: (value) => (value == null || value.isEmpty) ? "Wajib diisi" : null,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(color: isFileSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(isFileSelected ? Icons.check_circle : Icons.file_upload_outlined, color: isFileSelected ? Colors.green : Colors.grey[600], size: 24),
                if (isFileSelected) const Positioned(right: 16, child: Text("Terpilih ✔", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))),
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
                // Navigasi ulang ke halaman ini dengan room yang baru direkomendasikan
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FormKelasPage(room: recommendedRoom!, item: widget.item)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, elevation: 0),
              child: const Text("Pindah ke Kelas Rekomendasi", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
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
        const Text("Periode Peminjaman", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                Text(selectedDate == null ? "Pilih Tanggal" : "${DateFormat('dd/MM/yyyy').format(selectedDate!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDate!.end)}"),
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

  void _submitForm() {
    if (_formKey.currentState!.validate() && selectedDate != null) {
      Navigator.pop(context, true);
    }
  }
}