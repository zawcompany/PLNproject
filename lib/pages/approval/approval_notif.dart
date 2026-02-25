import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart'; 
import '../../models/booking_model.dart';
import '../../models/complaint_model.dart';

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
            // 1. HEADER
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
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notifikasi Approval",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: primaryTeal,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Text(
                  //   "Pantau pengajuan masuk dan laporan dari staff",
                  //   style: TextStyle(fontSize: 12, color: Colors.grey),
                  // ),
                ],
              ),
            ),

            // 3. DAFTAR NOTIFIKASI REAL-TIME
            Expanded(
              child: StreamBuilder<List<dynamic>>(
                stream: CombineLatestStream.list([
                  FirebaseFirestore.instance.collection('bookings').snapshots(),
                  FirebaseFirestore.instance.collection('complaints').snapshots(),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: primaryTeal));
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text("Tidak ada notifikasi"));
                  }

                  // FIXED: Inisialisasi list sebagai dynamic untuk menghindari Type Error
                  List<dynamic> allNotifications = [];

                  // Ambil data Booking
                  final bookingDocs = snapshot.data![0] as QuerySnapshot;
                  allNotifications.addAll(bookingDocs.docs.map((doc) {
                    return BookingModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                  }).toList());

                  // Ambil data Complaint
                  final complaintDocs = snapshot.data![1] as QuerySnapshot;
                  allNotifications.addAll(complaintDocs.docs.map((doc) {
                    return ComplaintModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                  }).toList());

                  // Filter hanya status yang butuh perhatian admin (Pending atau Refund)
                  allNotifications = allNotifications.where((notif) {
                    if (notif is BookingModel) {
                      return notif.status == BookingStatus.pending || notif.status == BookingStatus.refundProcess;
                    } else if (notif is ComplaintModel) {
                      return notif.status == ComplaintStatus.pending;
                    }
                    return false;
                  }).toList();

                  // Urutkan berdasarkan waktu terbaru
                  allNotifications.sort((a, b) {
                    DateTime timeA = (a is BookingModel) ? a.start : (a as ComplaintModel).createdAt;
                    DateTime timeB = (b is BookingModel) ? b.start : (b as ComplaintModel).createdAt;
                    return timeB.compareTo(timeA);
                  });

                  if (allNotifications.isEmpty) {
                    return const Center(
                      child: Text("Tidak ada pemesanan atau pengaduan terbaru.", style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: allNotifications.length,
                    itemBuilder: (context, index) {
                      final item = allNotifications[index];

                      if (item is BookingModel) {
                        bool isRefund = item.status == BookingStatus.refundProcess;
                        return _buildNotifItem(
                          title: isRefund ? "Permintaan Refund" : "Pengajuan Baru",
                          message: isRefund 
                              ? "${item.userName} telah mengisi form refund untuk ${item.itemName}."
                              : "${item.userName} mengajukan pemesanan ${item.itemName}.",
                          time: DateFormat('dd MMM, HH:mm').format(item.start),
                          type: isRefund ? "refund" : "request",
                          isUnread: true,
                        );
                      } else {
                        final complaint = item as ComplaintModel;
                        return _buildNotifItem(
                          title: "Laporan Pengaduan",
                          message: "Laporan '${complaint.description}' di ${complaint.roomName}. Segera cek.",
                          time: DateFormat('dd MMM, HH:mm').format(complaint.createdAt),
                          type: "complaint",
                          isUnread: true,
                        );
                      }
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
    required String title,
    required String message,
    required String time,
    required String type, 
    required bool isUnread,
  }) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case "request":
        icon = Icons.assignment_late_outlined;
        iconColor = primaryTeal;
        bgColor = primaryTeal.withValues(alpha: 0.1);
        break;
      case "complaint":
        icon = Icons.report_problem_outlined;
        iconColor = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.1);
        break;
      case "refund":
        icon = Icons.account_balance_wallet_outlined;
        iconColor = Colors.blue;
        bgColor = Colors.blue.withValues(alpha: 0.1);
        break;
      default:
        icon = Icons.notifications_none_outlined;
        iconColor = Colors.grey;
        bgColor = Colors.grey.withValues(alpha: 0.1);
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
        border: Border.all(color: isUnread ? iconColor.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1), width: 1.5),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            if (isUnread) CircleAvatar(radius: 4, backgroundColor: iconColor),
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