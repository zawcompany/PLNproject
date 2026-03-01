// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:rxdart/rxdart.dart';
// import '../../models/item_model.dart';
// import '../../models/room_model.dart';
// import '../../models/booking_model.dart';
// import '../../models/complaint_model.dart';
// import '../form_komplain.dart';
// // Import file dengan benar
// import '../karyawan/form_pemesanan_eks.dart';
// import '../karyawan/form_pemesanan_int.dart';
// import '../karyawan/kelas_general.dart';

// class DetailApprovalPage extends StatefulWidget {
//   final ItemModel item;
//   const DetailApprovalPage({super.key, required this.item});

//   @override
//   State<DetailApprovalPage> createState() => _DetailApprovalPageState();
// }

// class _DetailApprovalPageState extends State<DetailApprovalPage> {
//   int selectedTab = 0;

//   // 1. FUNGSI FILTER UTAMA
//   List<RoomModel> getFilteredRooms(
//     List<RoomModel> currentRooms, 
//     List<BookingModel> activeBookings, 
//     List<ComplaintModel> activeComplaints
//   ) {
//     return currentRooms.where((room) {
//       // PERBAIKAN: Kamar dianggap TERISI hanya jika ada booking 'approved' atau 'pending'
//       // Jika statusnya 'completed' atau 'rejected', maka kamar dianggap KOSONG
//       final hasActiveBooking = activeBookings.any((b) => 
//         b.roomIds.contains(room.id) && 
//         (b.status == BookingStatus.approved || b.status == BookingStatus.pending)
//       );

//       final roomComplaints = activeComplaints.where((c) => c.roomId == room.id).toList();
//       final bool isPendingRepair = roomComplaints.any((c) => c.status == ComplaintStatus.pending);
//       final bool isRepairing = roomComplaints.any((c) => c.status == ComplaintStatus.repairing);

//       switch (selectedTab) {
//         case 0: return hasActiveBooking && !isPendingRepair && !isRepairing; // Tab Terisi
//         case 1: return !hasActiveBooking && !isPendingRepair && !isRepairing; // Tab Kosong
//         case 2: return isPendingRepair;
//         case 3: return isRepairing;
//         default: return true;
//       }
//     }).toList();
//   }

//   // 2. FUNGSI CHECKOUT
//   Future<void> _handleCheckout(RoomModel room, ItemModel item) async {
//     try {
//       // 1. Update Kondisi Kamar di Koleksi 'items' menjadi 'kosong'
//       final itemRef = FirebaseFirestore.instance.collection('items').doc(item.id);
//       final itemDoc = await itemRef.get();
//       List roomsData = List.from(itemDoc.get('rooms'));
      
//       int index = roomsData.indexWhere((r) => r['id'] == room.id);
//       if (index != -1) {
//         roomsData[index]['condition'] = RoomCondition.kosong.name; // 'kosong'
//         await itemRef.update({'rooms': roomsData});
//       }

//       // 2. Update status Booking di koleksi 'bookings' menjadi 'completed'
//       final bookingQuery = await FirebaseFirestore.instance
//           .collection('bookings')
//           .where('roomIds', arrayContains: room.id)
//           .where('status', isEqualTo: BookingStatus.approved.name)
//           .get();

//       if (bookingQuery.docs.isNotEmpty) {
//         for (var bDoc in bookingQuery.docs) {
//           await bDoc.reference.update({
//             'status': 'completed' // JANGAN tulis 'pending' atau 'menunggu' di sini
//           }); 
//         }
//       }

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("${room.name} Berhasil Checkout"), backgroundColor: Colors.green)
//         );
//       }
//     } catch (e) {
//       print("Error CO: $e");
//     }
//   }

//   // 3. FUNGSI DIALOG JENIS PESANAN
//   void _showBookingTypeDialog(RoomModel room) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         title: const Text("Jenis Pesanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//         content: const Text("Silahkan pilih kategori pemesanan:"),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (context) => FormWismaInternalPage(room: room, item: widget.item)
//                       ));
//                     },
//                     child: const Text("Internal"),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       Navigator.push(context, MaterialPageRoute(
//                         builder: (context) => FormWismaEksternalPage(room: room, item: widget.item)
//                       ));
//                     },
//                     style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008996)),
//                     child: const Text("Eksternal", style: TextStyle(color: Colors.white)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isKelas = widget.item.type == ItemType.kelas;

//     return StreamBuilder<List<dynamic>>(
//       stream: CombineLatestStream.list([
//         FirebaseFirestore.instance.collection('items').doc(widget.item.id).snapshots(),
//         FirebaseFirestore.instance.collection('bookings').snapshots(),
//         FirebaseFirestore.instance.collection('complaints').snapshots(),
//       ]),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

//         final itemDoc = snapshot.data![0] as DocumentSnapshot;
//         if (!itemDoc.exists) return const Scaffold(body: Center(child: Text("Item tidak ditemukan")));

//         final updatedItem = ItemModel.fromMap(itemDoc.id, itemDoc.data() as Map<String, dynamic>);
//         final allBookings = (snapshot.data![1] as QuerySnapshot).docs.map((doc) => 
//           BookingModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
//         final allComplaints = (snapshot.data![2] as QuerySnapshot).docs.map((doc) => 
//           ComplaintModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();

//         final filteredRooms = getFilteredRooms(updatedItem.rooms, allBookings, allComplaints);

//         return Scaffold(
//           backgroundColor: const Color(0xFFF5F7F9),
//           body: Column(
//             children: [
//               _buildHeader(context, updatedItem),
//               const SizedBox(height: 15),
//               _buildTabs(isKelas),
//               Expanded(
//                 child: filteredRooms.isEmpty
//                     ? const Center(child: Text("Tidak ada data", style: TextStyle(color: Colors.grey)))
//                     : GridView.builder(
//                         padding: const EdgeInsets.all(16),
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 14,
//                           mainAxisSpacing: 14,
//                           childAspectRatio: 0.88, 
//                         ),
//                         itemCount: filteredRooms.length,
//                         itemBuilder: (context, index) => _buildRoomCard(
//                           filteredRooms[index], isKelas, allBookings, allComplaints, updatedItem
//                         ),
//                       ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//  Widget _buildRoomCard(RoomModel room, bool isKelas, List<BookingModel> bookings, List<ComplaintModel> complaints, ItemModel item) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.white,
//         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AspectRatio(
//             aspectRatio: 1.4,
//             child: Stack(
//               children: [
//                 Positioned.fill(
//                   child: ClipRRect(
//                     borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                     child: item.imagePath.startsWith('http') 
//                       ? Image.network(item.imagePath, fit: BoxFit.cover) 
//                       : Image.asset(item.imagePath, fit: BoxFit.cover),
//                   ),
//                 ),
//                 if (selectedTab < 2)
//                   Positioned(
//                     top: 8, right: 8,
//                     child: GestureDetector(
//                       onTap: () => _showComplaintDialog(room),
//                       child: const CircleAvatar(
//                         radius: 12, backgroundColor: Color(0xFF008996), 
//                         child: Icon(Icons.priority_high, color: Colors.white, size: 14)
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Nama Kamar
//                       Expanded(child: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      
//                       // LOGIKA TOMBOL BERDASARKAN TAB
//                       if (selectedTab == 1) ...[
//                         // Tombol Pesan (Tab Kosong)
//                         GestureDetector(
//                           onTap: () => item.type == ItemType.wisma 
//                             ? _showBookingTypeDialog(room) 
//                             : Navigator.push(context, MaterialPageRoute(builder: (c) => const FormKelasGeneral())),
//                           child: const Icon(Icons.add_circle_outline, color: Color(0xFF008996), size: 22),
//                         ),
//                       ] else if (selectedTab == 0) ...[
//                         // Tombol Checkout Berupa Icon (Tab Terisi/Digunakan)
//                         GestureDetector(
//                           onTap: () => _showConfirmCheckoutDialog(room, item), // Menambah dialog konfirmasi agar tidak sengaja terpencet
//                           child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
//                         ),
//                       ],
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   _buildDynamicInfo(room, bookings, complaints, isKelas),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Tambahan: Dialog Konfirmasi Checkout supaya lebih aman karena cuma berupa icon
//   void _showConfirmCheckoutDialog(RoomModel room, ItemModel item) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Konfirmasi Checkout"),
//         content: Text("Apakah Anda yakin ingin menyelesaikan pesanan untuk ${room.name}?"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _handleCheckout(room, item);
//             }, 
//             child: const Text("Konfirmasi", style: TextStyle(color: Colors.red))
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDynamicInfo(RoomModel room, List<BookingModel> bookings, List<ComplaintModel> complaints, bool isKelas) {
//     if (selectedTab == 0) {
//       try {
//         final b = bookings.firstWhere((b) => b.roomIds.contains(room.id) && b.status != BookingStatus.rejected);
//         return Text("Hingga: ${DateFormat('dd MMM').format(b.end)}", style: const TextStyle(fontSize: 11, color: Colors.grey));
//       } catch (_) { return const Text("Aktif", style: TextStyle(fontSize: 11, color: Colors.grey)); }
//     } else if (selectedTab == 1) {
//       return Text(isKelas ? "Kapasitas: ${room.capacity}" : "Tipe 70", style: const TextStyle(fontSize: 11, color: Colors.grey));
//     } else {
//       try {
//         final c = complaints.firstWhere((c) => c.roomId == room.id && c.status != ComplaintStatus.resolved);
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//           decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
//           child: Text(c.description, style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
//         );
//       } catch (_) { return const SizedBox.shrink(); }
//     }
//   }

//   Widget _buildHeader(BuildContext context, ItemModel item) {
//     return SizedBox(
//       height: 220,
//       child: Stack(
//         children: [
//           Positioned.fill(child: ClipRRect(
//             child: item.imagePath.startsWith('http') ? Image.network(item.imagePath, fit: BoxFit.cover) : Image.asset(item.imagePath, fit: BoxFit.cover),
//           )),
//           Positioned(top: 50, left: 10, child: IconButton(
//             icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.arrow_back, color: Colors.black)),
//             onPressed: () => Navigator.pop(context),
//           )),
//           Positioned(bottom: 25, left: 20, child: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabs(bool isKelas) {
//     final tabs = isKelas
//       ? ["Digunakan", "Kosong", "Perlu Perbaikan", "Dalam Perbaikan"]
//       : ["Terisi", "Kosong", "Perlu Perbaikan", "Dalam Perbaikan"];

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: List.generate(tabs.length, (index) => GestureDetector(
//         onTap: () => setState(() => selectedTab = index),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           decoration: BoxDecoration(border: Border(bottom: BorderSide(color: selectedTab == index ? const Color(0xFF008996) : Colors.transparent, width: 2.5))),
//           child: Text(tabs[index], style: TextStyle(fontSize: 12, fontWeight: selectedTab == index ? FontWeight.bold : FontWeight.normal, color: selectedTab == index ? const Color(0xFF008996) : Colors.grey)),
//         ),
//       )),
//     );
//   }

//   void _showComplaintDialog(RoomModel room) {
//     showDialog(context: context, builder: (context) => ComplaintDialog(
//       room: room, itemId: widget.item.id,
//       onSubmitted: (newCondition, issues, detail) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan dikirim")));
//       },
//     ));
//   }
// }