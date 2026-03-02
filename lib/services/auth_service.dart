import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<User?> get user => _auth.authStateChanges();

  // Login dan ambil data role dari Firestore
  Future<String?> getRole(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      return doc.exists ? doc['role'] as String? : null;
    } catch (e) {
      return null;
    }
  }

  // Registrasi Karyawan
  Future<void> registerKaryawan(String email, String password, String name) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
      
      await _db.collection('users').doc(res.user!.uid).set({
        'uid': res.user!.uid,
        'name': name,
        'email': email.trim(),
        'role': 'karyawan',
        'createdAt': FieldValue.serverTimestamp(), 
      });
    } catch (e) {
      rethrow; 
    }
  }

  // Fungsi Reset Password (Lupa Password)
  Future<void> resetPassword(String email) async {
    try {
      await _auth.setLanguageCode("id");
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Terjadi kesalahan saat mengirim email reset.";
    } catch (e) {
      throw "Terjadi kesalahan yang tidak terduga.";
    }
  } 

  // Fungsi Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}