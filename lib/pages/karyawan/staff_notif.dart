import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../services/database_service.dart'; // FIX: Menghilangkan error Undefined class DatabaseService

class NotificationStaffPage extends StatelessWidget {
  const NotificationStaffPage({super.key});

  static const Color primaryTeal = Color(0xFF008996);

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER (Layout Tetap)
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: SvgPicture.asset(
                    'lib/assets/images/header_riwayat.svg',
                    fit: BoxFit.cover,
                  ),
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

            // 2. JUDUL
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notifikasi",
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: primaryTeal,
                    ),
                  ),
                  SizedBox(height: 2),
                ],
              ),
            ),

            // 3. DAFTAR NOTIFIKASI REAL-TIME
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('userId', isEqualTo: currentUserId)
                    .orderBy('start', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: primaryTeal));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("Belum ada notifikasi terbaru", style: TextStyle(color: Colors.grey)),
                    );
                  }

                  final bookingsDocs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: bookingsDocs.length,
                    itemBuilder: (context, index) {
                      final data = bookingsDocs[index].data() as Map<String, dynamic>;
                      final booking = BookingModel.fromMap(bookingsDocs[index].id, data);
                      
                      // Lewati jika masih pending (karena pending bukan hasil keputusan)
                      if (booking.status == BookingStatus.pending) {
                        return const SizedBox.shrink();
                      }

                      bool isApproved = booking.status == BookingStatus.approved;

                      // FIX: Mengirim context dan booking ke widget item
                      return _buildNotifItem(
                        context: context, 
                        booking: booking,
                        title: isApproved ? "Pesanan Disetujui" : "Pesanan Ditolak",
                        message: isApproved 
                            ? "Reservasi ${booking.itemName} telah disetujui untuk tanggal ${DateFormat('dd MMM').format(booking.start)}."
                            : "Maaf, permohonan ${booking.itemName} ditolak${booking.rejectReason != null ? ': ${booking.rejectReason}' : '.'}",
                        time: "Terbaru", // Anda bisa ganti dengan format DateTime jika ada field updatedAt
                        isApproved: isApproved,
                        isUnread: index == 0,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifItem({
    required BuildContext context,
    required BookingModel booking,
    required String title,
    required String message,
    required String time,
    required bool isApproved,
    required bool isUnread,
  }) {
    // LOGIKA PENGECEKAN REFUND:
    // Muncul jika status ditolak DAN ada bukti pembayaran (untuk wisma berbayar/eksternal)
    bool showRefundButton = !isApproved && 
                            booking.paymentProof != null && 
                            booking.paymentProof!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isUnread ? Border.all(color: primaryTeal.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: CircleAvatar(
              backgroundColor: isApproved ? Colors.green.shade50 : Colors.red.shade50,
              child: Icon(
                isApproved ? Icons.check_circle_outline : Icons.error_outline,
                color: isApproved ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  message,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(time, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              ],
            ),
          ),
          
          // TOMBOL REFUND (Hanya muncul jika pesanan ditolak & ada bukti bayar)
          if (showRefundButton)
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showRefundFormDialog(context, booking);
                  },
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                  label: const Text("Isi Form Refund Dana", 
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade50,
                    foregroundColor: Colors.orange.shade800,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.orange.shade200),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showRefundFormDialog(BuildContext context, BookingModel booking) {
    final TextEditingController bankController = TextEditingController();
    final TextEditingController norekController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Form Refund Dana", 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Silakan masukkan detail rekening Anda untuk pengembalian dana.", 
              style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 15),
            TextField(
              controller: bankController,
              decoration: const InputDecoration(
                labelText: "Nama Bank (Contoh: BRI, BCA)", 
                labelStyle: TextStyle(fontSize: 13)
              ),
            ),
            TextField(
              controller: norekController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Nomor Rekening", 
                labelStyle: TextStyle(fontSize: 13)
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              // Validasi input
              if (bankController.text.isEmpty || norekController.text.isEmpty) return;

              final DatabaseService db = DatabaseService();
              await db.updateRefundAccount(booking.id, "${bankController.text} - ${norekController.text}");
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data refund berhasil dikirim"), backgroundColor: Colors.green)
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryTeal),
            child: const Text("Kirim", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}