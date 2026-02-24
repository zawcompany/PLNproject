import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationApprovalPage extends StatelessWidget {
  const NotificationApprovalPage({super.key});

  static const Color primaryTeal = Color(0xFF008996);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER DENGAN GAMBAR DAN TOMBOL BACK
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Notifikasi Approval",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Pantau pengajuan masuk dan laporan dari staff",
                    style: TextStyle(
                      fontSize: 12, 
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // 3. DAFTAR NOTIFIKASI KHUSUS APPROVAL
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildNotifItem(
                    title: "Pengajuan Baru",
                    message: "Zahra Amaliah mengajukan pemesanan Wisma Hortensia untuk tanggal 25 Feb.",
                    time: "Baru saja",
                    type: "request",
                    isUnread: true,
                  ),
                  _buildNotifItem(
                    title: "Laporan Pengaduan",
                    message: "Ahmad Dhani melaporkan 'AC Rusak' di Kelas A1. Segera tindak lanjuti.",
                    time: "2 jam yang lalu",
                    type: "complaint",
                    isUnread: true,
                  ),
                  _buildNotifItem(
                    title: "Pemesanan Dibatalkan",
                    message: "Staff membatalkan pengajuan Wisma Anggrek ID #2941.",
                    time: "Kemarin",
                    type: "cancel",
                    isUnread: false,
                  ),
                ],
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
    required String type, // 'request', 'complaint', 'cancel'
    required bool isUnread,
  }) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    // Logika warna berdasarkan tipe notifikasi approval
    if (type == "request") {
      icon = Icons.assignment_late_outlined;
      iconColor = primaryTeal;
      bgColor = primaryTeal.withValues(alpha: 0.1);
    } else if (type == "complaint") {
      icon = Icons.report_problem_outlined;
      iconColor = Colors.orange;
      bgColor = Colors.orange.withValues(alpha: 0.1);
    } else {
      icon = Icons.cancel_outlined;
      iconColor = Colors.red;
      bgColor = Colors.red.withValues(alpha: 0.1);
    }

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
        border: isUnread 
            ? Border.all(color: primaryTeal.withValues(alpha: 0.3), width: 1.5) 
            : Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: bgColor,
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (isUnread)
              const CircleAvatar(radius: 4, backgroundColor: Colors.orange),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              time, 
              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}