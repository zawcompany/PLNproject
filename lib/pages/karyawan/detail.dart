import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../models/item_model.dart';
import '../../models/room_model.dart';
import '../../models/booking_model.dart'; 
import '../../models/complaint_model.dart'; // Tambahkan import ini
import '../../services/database_service.dart'; 
import '../form_komplain.dart';
import 'form_pemesanan_eks.dart';
import 'form_pemesanan_int.dart';
import 'form_pemesanan_kls.dart';

class DetailKelasPage extends StatefulWidget {
  final ItemModel item;
  const DetailKelasPage({super.key, required this.item});

  @override
  State<DetailKelasPage> createState() => _DetailKelasPageState();
}

class _DetailKelasPageState extends State<DetailKelasPage> {
  final DatabaseService _db = DatabaseService();
  int selectedTab = 0;

  bool isRoomUsed(RoomModel room, List<BookingModel> activeBookings) {
    final now = DateTime.now();
    return activeBookings.any((b) =>
        b.roomIds.contains(room.id) &&
        b.status == BookingStatus.approved && 
        now.isAfter(b.start) &&
        now.isBefore(b.end));
  }

  void _showBookingTypeDialog(RoomModel room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Jenis Pesanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text("Silahkan pilih kategori pemesanan untuk wisma ini:"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context); 
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormWismaInternalPage(room: room, item: widget.item),
                        ),
                      );
                      if (result == true && mounted) _showSuccessSnackBar("Pesanan internal terkirim");
                    },
                    child: const Text("Internal"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormWismaEksternalPage(room: room, item: widget.item),
                        ),
                      );
                      if (result == true && mounted) _showSuccessSnackBar("Pesanan eksternal terkirim");
                    },
                    child: const Text("Eksternal"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }

  // FIXED: Ditambahkan itemId dan perbaikan BuildContext Async Gap
  void _showComplaintDialog(RoomModel room) {
    showDialog(
      context: context,
      builder: (context) => ComplaintDialog(
        room: room,
        itemId: widget.item.id, // FIX LINE 94: Required parameter
        onSubmitted: (newCondition, issues, detail) {
          // logic callback sudah dihandle di dalam dialog untuk firebase
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Laporan berhasil dikirim"), 
              backgroundColor: Color(0xFF008996),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  List<String> getTabs(bool isKelas) => isKelas 
      ? ["Digunakan", "Kosong", "Perlu Perbaikan", "Dalam Perbaikan"]
      : ["Terisi", "Kosong", "Perlu Perbaikan", "Dalam Perbaikan"];

  List<RoomModel> getFilteredRooms(List<RoomModel> currentRooms, List<BookingModel> activeBookings) {
    return currentRooms.where((room) {
      final used = isRoomUsed(room, activeBookings);
      switch (selectedTab) {
        case 0: return used || room.condition == RoomCondition.terisi;
        case 1: return !used && room.condition == RoomCondition.kosong;
        case 2: return room.condition == RoomCondition.perluPerbaikan;
        case 3: return room.condition == RoomCondition.dalamPerbaikan;
        default: return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isKelas = widget.item.type == ItemType.kelas;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('items').doc(widget.item.id).snapshots(),
      builder: (context, itemSnapshot) {
        if (!itemSnapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        
        final itemData = itemSnapshot.data!.data() as Map<String, dynamic>;
        final updatedItem = ItemModel.fromMap(itemSnapshot.data!.id, itemData);
        final currentRooms = updatedItem.rooms;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
          builder: (context, bookingSnapshot) {
            final activeBookings = bookingSnapshot.data?.docs.map((doc) => 
              BookingModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList() ?? [];
            
            final filteredRooms = getFilteredRooms(currentRooms, activeBookings);

            return Scaffold(
              backgroundColor: const Color(0xFFF5F7F9),
              body: Column(
                children: [
                  _buildHeader(context, updatedItem),
                  const SizedBox(height: 10),
                  _buildTabs(isKelas),
                  Expanded(
                    child: filteredRooms.isEmpty 
                      ? const Center(child: Text("Tidak ada data", style: TextStyle(color: Colors.grey)))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.75, // Disesuaikan agar muat teks masalah
                          ),
                          itemCount: filteredRooms.length,
                          itemBuilder: (context, index) => _buildRoomCard(filteredRooms[index], isKelas, activeBookings, updatedItem),
                        ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildHeader(BuildContext context, ItemModel item) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              child: item.imagePath.startsWith('http') 
                ? Image.network(item.imagePath, fit: BoxFit.cover)
                : Image.asset(item.imagePath, fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.2), Colors.black.withValues(alpha: 0.8)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50, left: 5,
            child: IconButton(
              icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.arrow_back, color: Colors.black)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isKelas) {
    final tabs = getTabs(isKelas);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(tabs.length, (index) {
        final selected = selectedTab == index;
        return GestureDetector(
          onTap: () => setState(() => selectedTab = index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: selected ? const Color(0xFF008996) : Colors.transparent, width: 2))),
            child: Text(tabs[index], style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? const Color(0xFF008996) : Colors.grey)),
          ),
        );
      }),
    );
  }

  Widget _buildRoomCard(RoomModel room, bool isKelas, List<BookingModel> activeBookings, ItemModel item) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: item.imagePath.startsWith('http') ? Image.network(item.imagePath, fit: BoxFit.cover) : Image.asset(item.imagePath, fit: BoxFit.cover),
                  ),
                ),
                if (selectedTab < 2)
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () => _showComplaintDialog(room),
                      child: const CircleAvatar(radius: 12, backgroundColor: Color(0xFF008996), child: Icon(Icons.priority_high, color: Colors.white, size: 14)),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                
                if (selectedTab >= 2) ...[
                  const SizedBox(height: 4),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('complaints')
                        .where('roomId', isEqualTo: room.id)
                        .where('status', isNotEqualTo: ComplaintStatus.resolved.name)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
                      
                      final complaintData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                      final String desc = complaintData['description'] ?? "";
                      
                      // Membersihkan string description untuk diambil kategori saja
                      // Format: "Kategori: Umum: Pintu rusak, Detail: ..."
                      List<String> displayIssues = [];
                      if (desc.contains("Kategori: ")) {
                        String issuesPart = desc.split("Kategori: ")[1].split(". Detail:")[0];
                        displayIssues = issuesPart.split(", ").take(2).toList();
                        if (issuesPart.contains("Lainnya") || desc.contains("Detail: ")) {
                          if (displayIssues.length < 2) displayIssues.add("Lainnya");
                        }
                      }

                      return Wrap(
                        spacing: 4,
                        children: displayIssues.map((issue) {
                          String cleanIssue = issue.contains(": ") ? issue.split(": ")[1] : issue;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xffffd6d6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              cleanIssue, 
                              style: const TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          if (selectedTab == 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => item.type == ItemType.wisma ? _showBookingTypeDialog(room) : Navigator.push(context, MaterialPageRoute(builder: (c) => FormKelasPage(room: room, item: item))),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008996), padding: EdgeInsets.zero),
                  child: const Text("Pesan", style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            )
        ],
      ),
    );
  }
}