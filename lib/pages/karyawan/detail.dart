import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../../models/room_model.dart';
import '../../data/booking_data.dart';
import '../form_komplain.dart';

bool isRoomUsed(RoomModel room) {
  final now = DateTime.now();

  return BookingData.bookings.any((b) =>
      b.roomName == room.name &&
      now.isAfter(b.start) &&
      now.isBefore(b.end));
}

class DetailKelasPage extends StatefulWidget {
  final ItemModel item;

  const DetailKelasPage({super.key, required this.item});

  @override
  State<DetailKelasPage> createState() => _DetailKelasPageState();
}

class _DetailKelasPageState extends State<DetailKelasPage> {
  void _showComplaintDialog(RoomModel room) {
    showDialog(
      context: context,
      builder: (context) => ComplaintDialog(
        room: room,
        onSubmitted: (newCondition, issues, detail) {
          setState(() {
            room.condition = newCondition;
            // Di sini kamu bisa simpan data 'issues' dan 'detail' ke database/state
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Laporan ${room.name} berhasil dikirim"),
              backgroundColor: const Color(0xFF008996),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  int selectedTab = 0;
  late List<RoomModel> rooms;

  Color getStatusColor(RoomModel room, bool isKelas) {
    final used = isRoomUsed(room);
    if (room.condition == RoomCondition.dalamPerbaikan) return Colors.red;
    if (room.condition == RoomCondition.perluPerbaikan) return Colors.orange;
    return used ? Colors.blue : Colors.green;
  }

  List<String> getTabs(bool isKelas) {
    if (isKelas) {
      return ["Digunakan", "Kosong", "Perlu Perbaikan"];
    } else {
      return ["Terisi", "Kosong", "Perlu Perbaikan", "Dalam Perbaikan"];
    }
  }

  List<RoomModel> get filteredRooms {
    return rooms.where((room) {
      final used = isRoomUsed(room);
      switch (selectedTab) {
        case 0: return used;
        case 1: return !used && room.condition == RoomCondition.normal;
        case 2: return room.condition == RoomCondition.perluPerbaikan;
        case 3: return room.condition == RoomCondition.dalamPerbaikan;
        default: return true;
      }
    }).toList();
  }

  String _getMonthName(int month) {
    const months = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
    return months[month - 1];
  }

  Widget _buildRoomSubtitle(RoomModel room) {
    IconData icon;
    String text;

    switch (selectedTab) {
      case 0:
        final booking = BookingData.bookings.firstWhere(
          (b) => b.roomName == room.name && DateTime.now().isAfter(b.start) && DateTime.now().isBefore(b.end),
          orElse: () => BookingData.bookings.first,
        );
        icon = Icons.calendar_month_outlined;
        text = "Hingga ${booking.end.day} ${_getMonthName(booking.end.month)} ${booking.end.year}";
        break;
      case 1:
        icon = Icons.payments_outlined;
        text = "Rp250.000";
        break;
      case 2:
      case 3:
        icon = Icons.error_outline;
        text = "Masalah: Lampu Mati";
        break;
      default:
        icon = Icons.people_outline;
        text = "${room.capacity} orang";
    }

    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.normal),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    rooms = widget.item.rooms;
  }

  @override
  Widget build(BuildContext context) {
    final isKelas = widget.item.type == ItemType.kelas;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 10),
          _buildTabs(isKelas),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.73,
              ),
              itemCount: filteredRooms.length,
              itemBuilder: (context, index) {
                final room = filteredRooms[index];
                return _buildRoomCard(room, isKelas);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              child: Image.asset(widget.item.imagePath, fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2), 
                    Colors.black.withValues(alpha: 0.8)
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.black, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.item.title,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.item.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isKelas) {
    final tabs = getTabs(isKelas);
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (index) {
            final selected = selectedTab == index;
            return GestureDetector(
              onTap: () => setState(() => selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2), 
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? const Color(0xFF008996) : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: selected ? const Color(0xFF008996) : Colors.grey[600],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRoomCard(RoomModel room, bool isKelas) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(widget.item.imagePath, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _showComplaintDialog(room),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF008996),
                        shape: BoxShape.circle, // PERBAIKAN: BoxType -> BoxShape
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: const Icon(Icons.priority_high, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _buildRoomSubtitle(room),
                if (selectedTab == 1) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008996),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text("Pesan", style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}