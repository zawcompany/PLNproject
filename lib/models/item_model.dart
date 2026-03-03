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
      priceDay: (map['priceDay'] is int) 
          ? map['priceDay'] 
          : int.tryParse(map['priceDay']?.toString() ?? '0') ?? 0,
      priceMonth: (map['priceMonth'] is int) 
          ? map['priceMonth'] 
          : int.tryParse(map['priceMonth']?.toString() ?? '0') ?? 0,
    );
  }
}