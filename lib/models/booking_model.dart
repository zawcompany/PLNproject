enum BookingStatus { pending, approved, rejected, refundProcess, completed }

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final List<String> roomIds;
  final String itemName;
  final DateTime start;
  final DateTime end;
  final double totalPayment;
  final String? paymentProof;
  BookingStatus status;
  final String? accountNumber;
  final String? rejectReason;
  final String? nik;
  final String? nip;
  final String? address;
  final String? npwp;
  final int? maleCount;
  final int? femaleCount;
  final int? guestCount;
  final String? userType;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.roomIds,
    required this.itemName,
    required this.start,
    required this.end,
    required this.totalPayment,
    this.paymentProof,
    this.status = BookingStatus.pending,
    this.accountNumber,
    this.rejectReason,
    this.nik,
    this.nip,
    this.address,
    this.npwp,
    this.maleCount,
    this.femaleCount,
    this.guestCount,
    this.userType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'roomIds': roomIds,
      'itemName': itemName,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'totalPayment': totalPayment,
      'paymentProof': paymentProof,
      'status': status.name,
      'accountNumber': accountNumber,
      'rejectReason': rejectReason,
      'nik': nik,
      'nip': nip,
      'address': address,
      'npwp': npwp,
      'male_count': maleCount,
      'female_count': femaleCount,
      'guest_count': guestCount,
      'user_type': userType,
    };
  }

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    return BookingModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      roomIds: List<String>.from(map['roomIds'] ?? []),
      itemName: map['itemName'] ?? '',
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
      totalPayment: (map['totalPayment'] ?? 0).toDouble(),
      paymentProof: map['paymentProof'],
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      accountNumber: map['accountNumber'],
      rejectReason: map['rejectReason'],
      nik: map['nik'],
      nip: map['nip'],
      address: map['address'],
      npwp: map['npwp'],
      maleCount: map['male_count'],
      femaleCount: map['female_count'],
      guestCount: map['guest_count'],
      userType: map['user_type'],
    );
  }
}