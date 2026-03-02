enum RoomCondition { terisi, kosong, perluPerbaikan, dalamPerbaikan }

class RoomModel {
  final String id;
  final String name; 
  final int capacity;
  final RoomCondition condition;

  RoomModel({
    required this.id,
    required this.name,
    required this.capacity,
    this.condition = RoomCondition.kosong, 
  });

  RoomModel.seed({
    required this.name,
    required this.capacity,
    this.condition = RoomCondition.kosong,
  }) : id = name.replaceAll(' ', '_').toLowerCase();

  Map<String, dynamic> toMap() {
    return {
      'id': id, 
      'name': name,
      'capacity': capacity,
      'condition': condition.name, 
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] ?? '', 
      name: map['name'] ?? '',
      capacity: map['capacity'] ?? 0,
      condition: RoomCondition.values.firstWhere(
        (e) => e.name == map['condition'],
        orElse: () => RoomCondition.kosong, 
      ),
    );
  }

  RoomModel copyWith({
    String? id,
    String? name,
    int? capacity,
    RoomCondition? condition,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      condition: condition ?? this.condition,
    );
  }
}