import 'room_model.dart';

enum ItemType { wisma, kelas }

class ItemModel {
  String title;
  String imagePath;
  ItemType type;
  List<RoomModel> rooms;
  bool isDone;

  ItemModel({
    required this.title,
    required this.imagePath,
    required this.type,
    this.rooms = const [],
    this.isDone = false, 
  });
}
