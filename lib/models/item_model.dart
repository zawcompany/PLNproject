import 'room_model.dart';

enum ItemType { wisma, kelas }

class ItemModel {
  final String id; 
  final String title;
  final String description;
  final String imagePath;
  final ItemType type;
  bool isDone; 
  final List<RoomModel> rooms;
  final int priceDay;    
  final int priceMonth;

  ItemModel({
    required this.id, 
    required this.title,
    required this.description,
    required this.imagePath,
    required this.type,
    this.isDone = false, 
    this.rooms = const [],
    this.priceDay = 0,    
    this.priceMonth = 0, 
  });

  ItemModel.seed({
    this.id = '', 
    required this.title,
    required this.description,
    required this.imagePath,
    required this.type,
    this.isDone = false, 
    this.rooms = const [],
    this.priceDay = 0,
    this.priceMonth = 0,
  });

  ItemModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imagePath,
    ItemType? type,
    bool? isDone,
    List<RoomModel>? rooms,
    int? priceDay,
    int? priceMonth,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      type: type ?? this.type,
      isDone: isDone ?? this.isDone,
      rooms: rooms ?? this.rooms,
      priceDay: priceDay ?? this.priceDay,
      priceMonth: priceMonth ?? this.priceMonth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, 
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'type': type.name,
      'isDone': isDone,
      'rooms': rooms.map((room) => room.toMap()).toList(), 
      'priceDay': priceDay,    
      'priceMonth': priceMonth, 
    };
  }

  factory ItemModel.fromMap(String id, Map<String, dynamic> map) {
    return ItemModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '',
      type: ItemType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ItemType.wisma,
      ),
      isDone: map['isDone'] ?? false,
      rooms: map['rooms'] != null
          ? (map['rooms'] as List).map((x) => RoomModel.fromMap(x)).toList()
          : [],
      priceDay: _toInt(map['priceDay']),
      priceMonth: _toInt(map['priceMonth']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}