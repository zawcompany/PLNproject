import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../../models/room_model.dart';
import '../../data/booking_data.dart';
import '../form_komplain.dart';
import 'form_pemesanan_eks.dart';
import 'form_pemesanan_int.dart';
import 'form_pemesanan_kls.dart';

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
  void _showBookingTypeDialog(RoomModel room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Jenis Pesanan", 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text("Silahkan pilih kategori pemesanan untuk wisma ini:"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context); 
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormWismaInternalPage(
                            room: room, 
                            item: widget.item
                          ),
                        ),
                      );

                      if (result == true) {
                        _showSuccessSnackBar("Pesanan internal berhasil dikirim");
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF008996)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Internal", style: TextStyle(color: Color(0xFF008996))),
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
                          builder: (context) => FormWismaEksternalPage(
                            room: room, 
                            item: widget.item
                          ),
                        ),
                      );

                      if (result == true) {
                        _showSuccessSnackBar("Pesanan eksternal berhasil dikirim");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008996),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Eksternal", style: TextStyle(color: Colors.white)),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComplaintDialog(RoomModel room) {
    showDialog(
      context: context,
      builder: (context) => ComplaintDialog(
        room: room,
        onSubmitted: (newCondition, issues, detail) {
          setState(() {
            room.condition = newCondition;
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
        text = room.name.toLowerCase().contains("hortensia") ? "Rp2.500.000" : "Rp250.000";
        break;
      case 2:
      case 3:
        icon = Icons.error_outline;
        text = "Lapor Kerusakan";
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
            child: filteredRooms.isEmpty 
              ? Center(child: Text("Tidak ada data ${getTabs(isKelas)[selectedTab]}", style: const TextStyle(color: Colors.grey)))
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.85,
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
      height: 180,
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
                    Colors.black.withOpacity(0.2), 
                    Colors.black.withOpacity(0.8)
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 5,
            child: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.black, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            left: 19,
            right: 20,
            bottom: 12, // Teks diturunkan ke dekat batas bawah (sebelumnya 20 atau 30)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.item.title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.item.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.2),
                  maxLines: 2,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (index) {
            final selected = selectedTab == index;
            return GestureDetector(
              onTap: () => setState(() => selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), 
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(widget.item.imagePath, fit: BoxFit.cover),
                  ),
                ),
                // Tombol seru (komplain) hanya muncul jika bukan di tab perbaikan
                if (selectedTab < 2)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _showComplaintDialog(room),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF008996),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.priority_high, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _buildRoomSubtitle(room),
                if (selectedTab == 1) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () async {
                          if (widget.item.type == ItemType.wisma) {
                            _showBookingTypeDialog(room);
                          } else {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormKelasPage(
                                  room: room,
                                  item: widget.item,
                                ),
                              ),
                            );
                            if (result == true) {
                              _showSuccessSnackBar("Permohonan peminjaman kelas berhasil dikirim");
                            }
                          }
                        },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008996),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Pesan", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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