import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
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
  final DatabaseService _db = DatabaseService();

  List<String> selectedWisma = ["Semua"];
  List<String> selectedStatus = ["Semua"];
  String selectedRiwayatType = "Pemesanan";

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

        // Sorting Terbaru
        allItems.sort((a, b) {
          DateTime timeA = (a is BookingModel) ? a.start : a.createdAt;
          DateTime timeB = (b is BookingModel) ? b.start : b.createdAt;
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
              Text(booking.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(DateFormat('dd MMM yyyy').format(booking.start), style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Text("Oleh: ${booking.userName}", style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(booking.status.name),
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
              _buildStatusBadge(complaint.status.name),
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

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'approved' || status == 'resolved') color = primaryColor;
    if (status == 'rejected') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
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
          onSelected: (v) => setState(() => selectedRiwayatType = v),
          itemBuilder: (c) => [
            const PopupMenuItem(value: "Pemesanan", child: Text("Pemesanan")),
            const PopupMenuItem(value: "Pengaduan", child: Text("Pengaduan")),
          ],
          child: Row(children: [Text("Riwayat $selectedRiwayatType", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)), const Icon(Icons.keyboard_arrow_down_rounded)]),
        ),
        Icon(Icons.filter_list_rounded, color: primaryColor),
      ],
    ),
  );
}

// --- DIALOG TINJAU PEMESANAN ---
class DialogTinjauPemesanan extends StatelessWidget {
  final BookingModel booking;
  const DialogTinjauPemesanan({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();
    const Color primaryTeal = Color(0xFF008996);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
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
            
            _sectionTitle("Informasi Pemesan"),
            _infoBox([
              _rowInfo("Nama Lengkap", booking.userName),
              // Field di bawah ini diasumsikan ada di Firestore, jika tidak tampilkan default
              _rowInfo("NIK", "Tersimpan di Sistem"),
              _rowInfo("Status Akun", "Karyawan"),
            ]),
            
            const SizedBox(height: 20),
            _sectionTitle("Detail Reservasi"),
            _infoBox([
              _rowInfo("Jenis/Nama", booking.itemName),
              _rowInfo("Periode", "${DateFormat('dd MMM').format(booking.start)} - ${DateFormat('dd MMM').format(booking.end)}"),
              _rowInfo("Total Bayar", "Rp ${booking.totalPayment.toInt()}"),
            ]),
            
            const SizedBox(height: 20),
            _sectionTitle("Dokumen Pendukung"),
            _infoBox([
              if (booking.paymentProof != null)
                _rowFileLink("Bukti Bayar / Surat", "Lihat File")
              else
                const Text("Tidak ada dokumen diunggah", style: TextStyle(fontSize: 11, color: Colors.grey)),
            ]),

            const SizedBox(height: 32),
            if (booking.status == BookingStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        // Logika tolak sederhana
                        await db.rejectBooking(booking.id, "Ditolak oleh Admin", "item_id_placeholder", booking.roomIds);
                        if (context.mounted) Navigator.pop(context);
                      }, 
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), 
                      child: const Text("Tolak", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await db.approveBooking(booking.id);
                        if (context.mounted) Navigator.pop(context);
                      }, 
                      style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), 
                      child: const Text("Terima", style: TextStyle(fontWeight: FontWeight.bold))
                    )
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF008996)));
  Widget _infoBox(List<Widget> children) => Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8FBFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))), child: Column(children: children));
  Widget _rowInfo(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(l, style: const TextStyle(fontSize: 11, color: Colors.grey))), const SizedBox(width: 8), Expanded(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))]));
  Widget _rowFileLink(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(fontSize: 11, color: Colors.grey)), InkWell(onTap: () {}, child: Text(v, style: const TextStyle(fontSize: 11, color: Color(0xFF008996), fontWeight: FontWeight.bold, decoration: TextDecoration.underline)))]));
}

// --- DIALOG TINJAU PENGADUAN ---
class DialogTinjauPengaduan extends StatelessWidget {
  final ComplaintModel complaint;
  const DialogTinjauPengaduan({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();
    const Color primaryTeal = Color(0xFF008996);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
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
            _sectionTitle("Keluhan / Masalah"),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)),
              child: Text(complaint.description, style: TextStyle(color: Colors.red.shade900, fontSize: 12, height: 1.5)),
            ),
            const SizedBox(height: 24),
            _sectionTitle("Informasi Ruangan"),
            _infoBox([
              _rowInfo("Nama Ruangan", complaint.roomName),
              _rowInfo("Pelapor", "Staff User"),
              _rowInfo("Tanggal Laporan", DateFormat('dd MMM yyyy, HH:mm').format(complaint.createdAt)),
            ]),
            const SizedBox(height: 32),
            if (complaint.status != ComplaintStatus.resolved)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (complaint.status == ComplaintStatus.pending) {
                      await db.startRepair(complaint.id, "placeholder_id", complaint.roomName);
                    } else {
                      await db.resolveComplaint(complaint.id, "placeholder_id", complaint.roomName);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: complaint.status == ComplaintStatus.repairing ? Colors.green : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(complaint.status == ComplaintStatus.repairing ? "Selesaikan" : "Perbaiki Sekarang", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF008996)));
  Widget _infoBox(List<Widget> children) => Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8FBFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))), child: Column(children: children));
  Widget _rowInfo(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(l, style: const TextStyle(fontSize: 11, color: Colors.grey))), const SizedBox(width: 8), Expanded(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))]));
}