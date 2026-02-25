enum ComplaintStatus { pending, repairing, resolved }

class ComplaintModel {
  final String id;
  final String roomId;
  final String roomName;
  final String userId;
  final String description;
  final String? imageProof;
  ComplaintStatus status;
  final DateTime createdAt;

  ComplaintModel({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.userId,
    required this.description,
    this.imageProof,
    this.status = ComplaintStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'roomName': roomName,
      'userId': userId,
      'description': description,
      'imageProof': imageProof,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ComplaintModel.fromMap(String id, Map<String, dynamic> map) {
    return ComplaintModel(
      id: id,
      roomId: map['roomId'] ?? '',
      roomName: map['roomName'] ?? '',
      userId: map['userId'] ?? '',
      description: map['description'] ?? '',
      imageProof: map['imageProof'],
      status: ComplaintStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}