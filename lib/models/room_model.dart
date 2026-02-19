enum RoomCondition { normal, perluPerbaikan, dalamPerbaikan }

class RoomModel {
  String name;
  int capacity;
  RoomCondition condition;

  RoomModel({
    required this.name,
    required this.capacity,
    this.condition = RoomCondition.normal,
  });
}
