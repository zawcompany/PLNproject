enum RoomCondition { terisi, kosong, perluPerbaikan, dalamPerbaikan }

class RoomModel {
  final String id;
  final String name; 
  final int capacity;
  final RoomCondition condition;

  // Constructor Standar (Digunakan saat mengambil data dari Firebase)
  RoomModel({
    required this.id,
    required this.name,
    required this.capacity,
    this.condition = RoomCondition.kosong, 
  });

  // --- TAMBAHAN: CONSTRUCTOR KHUSUS SEEDING ---
  // Gunakan ini di LocalData agar ID dibuat otomatis dari nama
  RoomModel.seed({
    required this.name,
    required this.capacity,
    this.condition = RoomCondition.kosong,
  }) : id = name.replaceAll(' ', '_').toLowerCase();

  // Konversi ke Map untuk diunggah ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Menggunakan ID yang sudah ada di instance
      'name': name,
      'capacity': capacity,
      'condition': condition.name, 
    };
  }

  // Membuat instance RoomModel dari data Firestore
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

  // Helper untuk mengubah data secara parsial
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