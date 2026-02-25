import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<User?> get user => _auth.authStateChanges();

  // Login dan ambil data role
  Future<String?> getRole(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      return doc.exists ? doc['role'] : null;
    } catch (e) {
      return null;
    }
  }

  // Registrasi Karyawan dengan Error Handling
  Future<void> registerKaryawan(String email, String password, String name) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      await _db.collection('users').doc(res.user!.uid).set({
        'uid': res.user!.uid,
        'name': name,
        'email': email,
        'role': 'karyawan',
        'createdAt': FieldValue.serverTimestamp(), 
      });
    } catch (e) {
      rethrow; 
    }
  }

  // Fungsi Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}