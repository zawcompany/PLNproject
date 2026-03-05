enum UserRole { 
  karyawan, 
  approval, 
  teknisiKelistrikan, 
  teknisiLapangan, 
  staffBiasa 
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: _parseRole(map['role']),
    );
  }

  static UserRole _parseRole(String? roleString) {
    switch (roleString) {
      case 'approval': return UserRole.approval;
      case 'teknisi_kelistrikan': return UserRole.teknisiKelistrikan;
      case 'teknisi_lapangan': return UserRole.teknisiLapangan;
      case 'karyawan': return UserRole.karyawan;
      case 'staff_biasa': return UserRole.staffBiasa;
      default: return UserRole.karyawan;
    }
  }
}