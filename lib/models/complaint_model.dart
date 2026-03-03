enum ComplaintStatus { 
  pending, 
  repairing, 
  waitingApproval, 
  resolved 
}

class ComplaintModel {
  final String id;
  final String roomId;
  final String roomName;
  final String userId;
  final String description;
  final String? imageProof;
  ComplaintStatus status;
  final DateTime createdAt;
  String? technicianId;        
  String? evidenceImagePath;   
  String? technicianNote;      
  String? rejectionReason;
  String? category; 

  ComplaintModel({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.userId,
    required this.description,
    this.imageProof,
    this.status = ComplaintStatus.pending,
    required this.createdAt,
    this.technicianId,
    this.evidenceImagePath,
    this.technicianNote,
    this.rejectionReason,
    this.category,
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
      'technicianId': technicianId,
      'evidenceImagePath': evidenceImagePath,
      'technicianNote': technicianNote,
      'rejectionReason': rejectionReason,
      'category': category,
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
      status: ComplaintStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ComplaintStatus.pending, 
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      technicianId: map['technicianId'],
      evidenceImagePath: map['evidenceImagePath'],
      technicianNote: map['technicianNote'],
      rejectionReason: map['rejectionReason'],
      category: map['category'] ?? 'lapangan',
    );
  }
} 