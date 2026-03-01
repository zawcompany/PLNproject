// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import '../../models/booking_model.dart';
// import '../../services/database_service.dart';

// class NotificationStaffPage extends StatelessWidget {
//   const NotificationStaffPage({super.key});

//   static const Color primaryTeal = Color(0xFF008996);

//   @override
//   Widget build(BuildContext context) {
//     final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFB),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 1. HEADER
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
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
//               child: Text(
//                 "Notifikasi",
//                 style: TextStyle(
//                   fontSize: 16, 
//                   fontWeight: FontWeight.bold, 
//                   color: primaryTeal,
//                 ),
//               ),
//             ),

//             // 3. DAFTAR NOTIFIKASI
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('bookings')
//                     .where('userId', isEqualTo: currentUserId)
//                     .orderBy('start', descending: true)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator(color: primaryTeal));
//                   }

//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(
//                       child: Text("Belum ada notifikasi terbaru", style: TextStyle(color: Colors.grey)),
//                     );
//                   }

//                   final bookingsDocs = snapshot.data!.docs;

//                   return ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     itemCount: bookingsDocs.length,
//                     itemBuilder: (context, index) {
//                       final data = bookingsDocs[index].data() as Map<String, dynamic>;
//                       final booking = BookingModel.fromMap(bookingsDocs[index].id, data);
                      
//                       // Abaikan status pending karena belum ada aksi admin
//                       if (booking.status == BookingStatus.pending) return const SizedBox.shrink();

//                       bool isApproved = booking.status == BookingStatus.approved;
//                       bool isWaitingRefund = booking.status == BookingStatus.waitingRefund;

//                       return _buildNotifItem(
//                         context: context, 
//                         booking: booking,
//                         title: isApproved ? "Pesanan Disetujui" : (isWaitingRefund ? "Refund Diproses" : "Pesanan Ditolak"),
//                         message: _getNotifMessage(booking),
//                         time: DateFormat('dd MMM, HH:mm').format(booking.start),
//                         status: booking.status,
//                         isUnread: index == 0,
//                       );
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

//   String _getNotifMessage(BookingModel booking) {
//     if (booking.status == BookingStatus.approved) {
//       return "Reservasi ${booking.itemName} telah disetujui. Silakan datang sesuai jadwal.";
//     } else if (booking.status == BookingStatus.waitingRefund) {
//       return "Permintaan refund untuk ${booking.itemName} sedang dikaji oleh Admin.";
//     } else {
//       return "Maaf, permohonan ${booking.itemName} ditolak${booking.rejectReason != null ? ': ${booking.rejectReason}' : '.'}";
//     }
//   }

//   Widget _buildNotifItem({
//     required BuildContext context,
//     required BookingModel booking,
//     required String title,
//     required String message,
//     required String time,
//     required BookingStatus status,
//     required bool isUnread,
//   }) {
//     bool isApproved = status == BookingStatus.approved;
//     // Munculkan tombol refund jika: Ditolak DAN Eksternal (biasanya eksternal yang bayar)
//     bool canRefund = status == BookingStatus.rejected && booking.userType == 'eksternal';

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
//         border: isUnread ? Border.all(color: primaryTeal.withOpacity(0.2)) : null,
//       ),
//       child: Column(
//         children: [
//           ListTile(
//             contentPadding: const EdgeInsets.all(15),
//             leading: CircleAvatar(
//               backgroundColor: isApproved ? Colors.green.shade50 : (status == BookingStatus.waitingRefund ? Colors.blue.shade50 : Colors.red.shade50),
//               child: Icon(
//                 isApproved ? Icons.check_circle_outline : (status == BookingStatus.waitingRefund ? Icons.account_balance_wallet : Icons.error_outline),
//                 color: isApproved ? Colors.green : (status == BookingStatus.waitingRefund ? Colors.blue : Colors.red),
//                 size: 20,
//               ),
//             ),
//             title: Text(
//               title,
//               style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w600, fontSize: 14),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 5),
//                 Text(message, style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4)),
//                 const SizedBox(height: 8),
//                 Text(time, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
//               ],
//             ),
//           ),
          
//           if (canRefund)
//             Padding(
//               padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: () => _showRefundFormDialog(context, booking),
//                   icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
//                   label: const Text("Isi Form Refund Dana", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange.shade50,
//                     foregroundColor: Colors.orange.shade800,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       side: BorderSide(color: Colors.orange.shade200),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   void _showRefundFormDialog(BuildContext context, BookingModel booking) {
//     String? selectedBank;
//     final List<String> daftarBank = ["BRI", "BCA", "BNI", "Mandiri", "Lainnya"];
//     final TextEditingController bankLainController = TextEditingController();
//     final TextEditingController norekController = TextEditingController();
//     final TextEditingController namaRekController = TextEditingController();

//     // Hitung estimasi refund (1 kamar x 1 hari)
//     double nominalRefund = 200000; // Contoh harga

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//           title: const Text("Form Pengajuan Refund", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text("Estimasi Refund: Rp ${NumberFormat('#,###').format(nominalRefund)}", 
//                   style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
//                 const SizedBox(height: 15),
//                 DropdownButtonFormField<String>(
//                   decoration: _inputDecor("Pilih Bank"),
//                   items: daftarBank.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
//                   onChanged: (val) => setDialogState(() => selectedBank = val),
//                 ),
//                 if (selectedBank == "Lainnya") ...[
//                   const SizedBox(height: 10),
//                   TextField(controller: bankLainController, decoration: _inputDecor("Nama Bank Lainnya")),
//                 ],
//                 const SizedBox(height: 10),
//                 TextField(controller: norekController, keyboardType: TextInputType.number, decoration: _inputDecor("Nomor Rekening")),
//                 const SizedBox(height: 10),
//                 TextField(controller: namaRekController, decoration: _inputDecor("Nama Pemilik Rekening")),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
//             ElevatedButton(
//               onPressed: () async {
//                 String bankFinal = selectedBank == "Lainnya" ? bankLainController.text : (selectedBank ?? "");
//                 if (bankFinal.isEmpty || norekController.text.isEmpty || namaRekController.text.isEmpty) return;

//                 final DatabaseService db = DatabaseService();
//                 await db.submitRefundRequest(booking.id, {
//                   'bank': bankFinal,
//                   'norek': norekController.text,
//                   'nama': namaRekController.text,
//                   'nominal': nominalRefund,
//                   'requestedAt': DateTime.now(),
//                 });
                
//                 if (context.mounted) {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pengajuan refund berhasil dikirim")));
//                 }
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: primaryTeal),
//               child: const Text("Kirim", style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   InputDecoration _inputDecor(String label) => InputDecoration(
//     labelText: label, labelStyle: const TextStyle(fontSize: 12),
//     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//   );
// }