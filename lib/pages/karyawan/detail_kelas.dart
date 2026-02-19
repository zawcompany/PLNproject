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
                  print("Aduan Terpilih: $selectedIssues");
                  print("Aduan Lainnya: ${otherIssueController.text}");
                  
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

    if (isKelas) {
      return used ? "Digunakan" : "Kosong";
    } else {
      return used ? "Terisi" : "Kosong";
    }
  }

  List<String> getTabs(bool isKelas) {
    if (isKelas) {
      return ["Digunakan", "Kosong", "Perlu Perbaikan"];
    } else {
      return ["Terisi", "Kosong", "Perlu Perbaikan", "Dalam Perbaikan"];
    }
  }

  List<RoomModel> get filteredRooms {
    final isKelas = widget.item.type == ItemType.kelas;

    return rooms.where((room) {
      final used = isRoomUsed(room);

      switch (selectedTab) {
        case 0:
          return used;
        case 1:
          return !used &&
              room.condition != RoomCondition.perluPerbaikan &&
              room.condition != RoomCondition.dalamPerbaikan;
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
      appBar: AppBar(
        title: Text(isKelas ? "Detail Kelas" : "Detail Wisma"),
        backgroundColor: const Color(0xFF008996),
      ),
      body: Column(
        children: [
          Image.asset(widget.item.imagePath, height: 200, fit: BoxFit.cover),

          const SizedBox(height: 12),

          Text(
            widget.item.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          /// TAB STATUS
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: getTabs(isKelas).length,
              itemBuilder: (context, index) {
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
                      getTabs(isKelas)[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? const Color(0xFF008996) : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

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

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ],
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
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
