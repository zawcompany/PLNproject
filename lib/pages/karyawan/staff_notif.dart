import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationStaffPage extends StatelessWidget {
  const NotificationStaffPage({super.key});

  static const Color primaryTeal = Color(0xFF008996);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER DENGAN GAMBAR DAN TOMBOL BACK DI ATASNYA
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

            // 2. JUDUL DAN SUBJUDUL SEJAJAR FIELD (Rata Kiri, Padding 24)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Notifikasi",
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Text(
                  //   "Update terbaru mengenai reservasi Anda",
                  //   style: TextStyle(
                  //     fontSize: 12, // Ukuran wajar untuk subjudul
                  //     color: Colors.grey[600]
                  //   ),
                  // ),
                ],
              ),
            ),

            // 3. DAFTAR NOTIFIKASI
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 3, 
                itemBuilder: (context, index) {
                  bool isApproved = index != 1; 
                  return _buildNotifItem(
                    title: isApproved ? "Pesanan Disetujui" : "Pesanan Ditolak",
                    message: isApproved 
                        ? "Reservasi Wisma Anggrek 101 telah disetujui."
                        : "Maaf, permohonan Wisma Cempaka ditolak karena alasan renovasi.",
                    time: "Tadi, 10:30",
                    isApproved: isApproved,
                    isUnread: index == 0,
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
    required String title,
    required String message,
    required String time,
    required bool isApproved,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isUnread ? Border.all(color: primaryTeal.withOpacity(0.3)) : null,
      ),
      child: ListTile(
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
            fontSize: 14, // Ukuran teks notif utama
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
            Text(
              time, 
              style: TextStyle(fontSize: 10, color: Colors.grey[400])
            ),
          ],
        ),
      ),
    );
  }
}