enum UserRole { karyawan, approval }

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
      role: map['role'] == 'approval' ? UserRole.approval : UserRole.karyawan,
    );
  }
}