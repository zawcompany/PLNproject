// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:rxdart/rxdart.dart'; 
// import '../../models/booking_model.dart';
// import '../../models/complaint_model.dart';

// class NotificationApprovalPage extends StatelessWidget {
//   const NotificationApprovalPage({super.key});

//   static const Color primaryTeal = Color(0xFF008996);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFB),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 1. HEADER (Sesuai perbaikan borderRadius sebelumnya agar tidak terlalu lengkung)
//             Stack(
//               children: [
//                 SizedBox(
//                   width: double.infinity,
//                   height: 100,
//                   child: SvgPicture.asset(
//                     'lib/assets/images/header_riwayat.svg',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 Positioned(
//                   top: 15,
//                   left: 15,
//                   child: InkWell(
//                     onTap: () => Navigator.pop(context),
//                     child: const CircleAvatar(
//                       radius: 18,
//                       backgroundColor: Colors.white,
//                       child: Icon(Icons.arrow_back, color: Colors.black, size: 20),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             // 2. JUDUL
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//               child: Text(
//                 "Notifikasi Approval",
//                 style: TextStyle(
//                   fontSize: 18, 
//                   fontWeight: FontWeight.bold, 
//                   color: primaryTeal,
//                 ),
//               ),
//             ),

//             // 3. DAFTAR NOTIFIKASI REAL-TIME
//             Expanded(
//               child: StreamBuilder<List<dynamic>>(
//                 stream: CombineLatestStream.list([
//                   FirebaseFirestore.instance.collection('bookings').snapshots(),
//                   FirebaseFirestore.instance.collection('complaints').snapshots(),
//                 ]),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator(color: primaryTeal));
//                   }

//                   if (!snapshot.hasData || snapshot.data == null) {
//                     return const Center(child: Text("Tidak ada data"));
//                   }

//                   List<dynamic> allNotifications = [];

//                   // Ambil data Booking & Mapping ke Model
//                   final bookingDocs = snapshot.data![0] as QuerySnapshot;
//                   allNotifications.addAll(bookingDocs.docs.map((doc) {
//                     return BookingModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
//                   }).toList());

//                   // Ambil data Complaint & Mapping ke Model
//                   final complaintDocs = snapshot.data![1] as QuerySnapshot;
//                   allNotifications.addAll(complaintDocs.docs.map((doc) {
//                     return ComplaintModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
//                   }).toList());

//                   // FILTER: Hanya status yang butuh tindakan Admin
//                   allNotifications = allNotifications.where((notif) {
//                     if (notif is BookingModel) {
//                       // Menampilkan yang baru masuk (pending) atau yang minta refund (waitingRefund)
//                       return notif.status == BookingStatus.pending || 
//                              notif.status == BookingStatus.waitingRefund;
//                     } else if (notif is ComplaintModel) {
//                       // Menampilkan laporan yang belum diproses
//                       return notif.status == ComplaintStatus.pending;
//                     }
//                     return false;
//                   }).toList();

//                   // SORT: Berdasarkan waktu terbaru (createdAt atau start)
//                   allNotifications.sort((a, b) {
//                     DateTime timeA = (a is BookingModel) ? a.start : (a as ComplaintModel).createdAt;
//                     DateTime timeB = (b is BookingModel) ? b.start : (b as ComplaintModel).createdAt;
//                     return timeB.compareTo(timeA);
//                   });

//                   if (allNotifications.isEmpty) {
//                     return const Center(
//                       child: Text("Semua tugas selesai. Tidak ada notifikasi.", style: TextStyle(color: Colors.grey)),
//                     );
//                   }

//                   return ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     itemCount: allNotifications.length,
//                     itemBuilder: (context, index) {
//                       final item = allNotifications[index];

//                       if (item is BookingModel) {
//                         bool isRefund = item.status == BookingStatus.waitingRefund;
//                         return _buildNotifItem(
//                           context: context,
//                           title: isRefund ? "Permintaan Refund" : "Pengajuan Baru",
//                           message: isRefund 
//                               ? "Data refund dari ${item.userName} untuk ${item.itemName} telah masuk."
//                               : "Ada pengajuan baru dari ${item.userName} di ${item.itemName}.",
//                           time: DateFormat('dd MMM, HH:mm').format(item.start),
//                           type: isRefund ? "refund" : "request",
//                           onTap: () {
//                              // Arahkan ke halaman approval/detail booking sesuai logika aplikasi Anda
//                           },
//                         );
//                       } else {
//                         final complaint = item as ComplaintModel;
//                         return _buildNotifItem(
//                           context: context,
//                           title: "Laporan Kerusakan",
//                           message: "Laporan '${complaint.description}' di ${complaint.roomName}.",
//                           time: DateFormat('dd MMM, HH:mm').format(complaint.createdAt),
//                           type: "complaint",
//                           onTap: () {
//                              // Arahkan ke halaman detail komplain
//                           },
//                         );
//                       }
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNotifItem({
//     required BuildContext context,
//     required String title,
//     required String message,
//     required String time,
//     required String type,
//     required VoidCallback onTap,
//   }) {
//     IconData icon;
//     Color color;

//     switch (type) {
//       case "request":
//         icon = Icons.assignment_late_outlined;
//         color = primaryTeal;
//         break;
//       case "complaint":
//         icon = Icons.report_problem_outlined;
//         color = Colors.orange;
//         break;
//       case "refund":
//         icon = Icons.account_balance_wallet_outlined;
//         color = Colors.blue;
//         break;
//       default:
//         icon = Icons.notifications;
//         color = Colors.grey;
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ListTile(
//         onTap: onTap,
//         contentPadding: const EdgeInsets.all(12),
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: color, size: 24),
//         ),
//         title: Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Text(
//               message,
//               style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 8),
//             Text(time, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
//           ],
//         ),
//         trailing: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[300]),
//       ),
//     );
//   }
// }