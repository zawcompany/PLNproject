import 'room_model.dart';

enum ItemType { wisma, kelas }

class ItemModel {
  final String title;
  final String description; // Tambahkan ini
  final String imagePath;
  final ItemType type;
  bool isDone; 
  final List<RoomModel> rooms;

  ItemModel({
    required this.title,
    required this.description, // Tambahkan ini
    required this.imagePath,
    required this.type,
    this.isDone = false, // Default false
    this.rooms = const [], // Default list kosong jika belum ada
  });
}
