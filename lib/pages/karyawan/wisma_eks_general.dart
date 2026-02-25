import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Fixed: Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/item_model.dart';
import '../../models/room_model.dart';
import '../../models/booking_model.dart'; 
import '../../services/database_service.dart'; 
import '../../data/exsistingdata.dart';

class FormWismaGeneralEksternal extends StatefulWidget {
  const FormWismaGeneralEksternal({super.key});

  @override
  State<FormWismaGeneralEksternal> createState() => _FormWismaGeneralEksternalState();
}

class _FormWismaGeneralEksternalState extends State<FormWismaGeneralEksternal> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService(); 
  
  static const Color primaryTeal = Color(0xFF008996);
  static const Color softTeal = Color(0xFFE8F1F3);
  static const Color softred = Color(0xffffd6d6);
  static const Color blueBoxColor = Color(0xffbfe0e6);

  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final alamatController = TextEditingController();
  final npwpController = TextEditingController();
  final perempuanController = TextEditingController(text: '0');
  final lakiController = TextEditingController(text: '0');

  DateTimeRange? selectedDate;
  File? buktiPembayaran;
  List<RoomModel> selectedRooms = [];
  bool _isSubmitting = false; 

  final currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void dispose() {
    namaController.dispose();
    nikController.dispose();
    alamatController.dispose();
    npwpController.dispose();
    perempuanController.dispose();
    lakiController.dispose();
    super.dispose();
  }

  int get totalHarga {
    if (selectedDate == null || selectedRooms.isEmpty) return 0;
    final totalDays = selectedDate!.end.difference(selectedDate!.start).inDays + 1;
    
    int total = 0;
    for (var room in selectedRooms) {
      int hargaHarian = room.name.toLowerCase().contains("hortensia") ? 500000 : 250000;
      total += hargaHarian * totalDays;
    }
    return total;
  }

  bool isRoomAvailable(RoomModel room) {
    // Status fisik dibaca dari model yang datang dari Firestore
    return room.condition == RoomCondition.kosong;
  }

  Future<void> _submitGeneralBooking() async {
    if (selectedRooms.isEmpty || buktiPembayaran == null) return;
    
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "User tidak ditemukan";

      // 1. Siapkan Objek Booking
      final newBooking = BookingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        userName: namaController.text.trim(),
        roomIds: selectedRooms.map((r) => r.id).toList(), 
        itemName: "Pemesanan General (${selectedRooms.length} Kamar)",
        start: selectedDate!.start,
        end: selectedDate!.end,
        totalPayment: totalHarga.toDouble(),
        status: BookingStatus.pending,
        paymentProof: buktiPembayaran!.path,
      );

      // 2. Loop update status kamar di Wisma masing-masing menjadi TERISI
      // Kita butuh data items terbaru untuk mencocokkan room dengan parent item-nya
      final snapshot = await FirebaseFirestore.instance.collection('items').get();
      final allItems = snapshot.docs.map((doc) => ItemModel.fromMap(doc.id, doc.data())).toList();

      for (var room in selectedRooms) {
        final parentWisma = allItems.firstWhere((item) => item.rooms.any((r) => r.id == room.id));
        await _db.updateRoomCondition(parentWisma.id, room.name, RoomCondition.terisi);
      }

      // 3. Simpan dokumen booking utama
      await FirebaseFirestore.instance.collection('bookings').doc(newBooking.id).set(newBooking.toMap());

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memproses pesanan: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showWismaSelection() {
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
            // Mengambil data Wisma secara real-time untuk pemilihan kamar
            return StreamBuilder<List<ItemModel>>(
              stream: _db.getItems(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final allWismaItems = snapshot.data!.where((item) => item.type == ItemType.wisma).toList();

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
                              child: const Icon(Icons.home_work_rounded, color: primaryTeal, size: 22),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Pilih Wisma", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text("Klik nomor kamar untuk memilih", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: allWismaItems.map((item) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: item.rooms.map((room) {
                                        final bool available = isRoomAvailable(room);
                                        final bool isSelected = selectedRooms.any((r) => r.id == room.id);
                                        String displayNumber = room.name.replaceAll(item.title, "").trim();

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
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
              const SizedBox(height: 20),
              const Text("Pesanan Berhasil!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Pemesanan general Anda telah masuk ke sistem. Status kamar telah diperbarui.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); 
                    Navigator.pop(context, true); 
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Tutup", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
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
                    const Text("Formulir Reservasi General", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text("Lengkapi data pemesanan untuk beberapa wisma sekaligus", style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                      _buildField("Alamat Lengkap", alamatController, Icons.home_outlined),
                      _buildField("Nomor NPWP", npwpController, Icons.assignment_outlined, TextInputType.number),
                      
                      const SizedBox(height: 10),
                      const Text("Jumlah Tamu", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                      const Text("Wisma yang dipilih", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _showWismaSelection,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.home_work_outlined, color: Colors.grey, size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedRooms.isEmpty ? "Klik untuk memilih wisma" : selectedRooms.map((r) => r.name).join(", "),
                                  style: TextStyle(fontSize: 14, color: selectedRooms.isEmpty ? Colors.grey : Colors.black),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),

                      if (totalHarga > 0) ...[
                        const SizedBox(height: 25),
                        _buildTotalCard(),
                        const SizedBox(height: 20),
                        _buildRekeningCard(),
                        const SizedBox(height: 16),
                        _buildUploadBox("Unggah Bukti Pembayaran", buktiPembayaran != null, _pickBukti),
                      ],

                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity, height: 55,
                        child: ElevatedButton(
                          onPressed: (selectedRooms.isNotEmpty && buktiPembayaran != null && !_isSubmitting) ? _submitGeneralBooking : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isSubmitting 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Konfirmasi Pesanan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
        const Text("Periode Menginap", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: softTeal, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: blueBoxColor)
      ),
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
      decoration: BoxDecoration(color: primaryTeal, borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Bank BRI\n033901000171301\nReceipt PT. PLN", 
              style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)
            )
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
          child: Container(
            width: double.infinity, 
            height: 55,
            decoration: BoxDecoration(
              color: isFileSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5), 
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(
              isFileSelected ? Icons.check_circle : Icons.file_upload_outlined, 
              color: isFileSelected ? Colors.green : Colors.grey
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickBukti() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => buktiPembayaran = File(picked.path));
  }
}