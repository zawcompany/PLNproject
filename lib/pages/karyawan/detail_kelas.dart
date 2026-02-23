import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../../models/room_model.dart';
import '../../data/booking_data.dart';

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
    List<String> commonIssues = ["Lampu Mati", "AC Tidak Dingin", "Kursi Rusak", "Kebersihan"];
    List<String> selectedIssues = [];
    TextEditingController otherIssueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Pengaduan - ${room.name}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...commonIssues.map((issue) => CheckboxListTile(
                          title: Text(issue),
                          value: selectedIssues.contains(issue),
                          onChanged: (bool? value) {
                            setDialogState(() {
                              if (value == true) {
                                selectedIssues.add(issue);
                              } else {
                                selectedIssues.remove(issue);
                              }
                            });
                          },
                        )),
                    const SizedBox(height: 10),
                    TextField(
                      controller: otherIssueController,
                      decoration: const InputDecoration(
                        labelText: "Aduan Lainnya",
                        hintText: "Ketik aduan Anda di sini...",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      room.condition = RoomCondition.perluPerbaikan;
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pengaduan berhasil dikirim")),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008996)),
                  child: const Text("Kirim", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
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

  String getStatusText(RoomModel room, bool isKelas) {
    final used = isRoomUsed(room);
    if (room.condition == RoomCondition.dalamPerbaikan) return "Dalam Perbaikan";
    if (room.condition == RoomCondition.perluPerbaikan) return "Perlu Perbaikan";
    return used ? (isKelas ? "Digunakan" : "Terisi") : "Kosong";
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
        case 0:
          return used;
        case 1:
          return !used &&
              room.condition == RoomCondition.normal; // Menggunakan .normal sesuai model
        case 2:
          return room.condition == RoomCondition.perluPerbaikan;
        case 3:
          return room.condition == RoomCondition.dalamPerbaikan;
        default:
          return true;
      }
    }).toList();
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
          /// HEADER
          _buildHeader(context),
          
          /// DESKRIPSI
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Deskripsi",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.item.description, 
                  style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// TABS (Horizontal Scroll)
          _buildTabs(isKelas),
          
          const SizedBox(height: 10),

          /// LIST KAMAR
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
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
      height: 260,
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
                  colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.6)],
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
            bottom: 40,
            child: Text(
              widget.item.title,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isKelas) {
    final tabs = getTabs(isKelas);
    return SizedBox(
      height: 45,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final selected = selectedTab == index;
            return GestureDetector(
              onTap: () => setState(() => selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? const Color(0xFF008996) : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? const Color(0xFF008996) : Colors.grey,
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
    return GestureDetector(
      onTap: () => _showComplaintDialog(room),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: getStatusColor(room, isKelas),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        getStatusText(room, isKelas),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("${room.capacity} orang", style: const TextStyle(fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}