import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mendengarkan perubahan status login
  Stream<User?> get user => _auth.authStateChanges();

  // 1. Ambil data role dari Firestore
  Future<String?> getRole(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc['role'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 2. Registrasi User dengan Role Dinamis
  // Mengganti registerKaryawan menjadi registerUser agar bisa menerima berbagai role
  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
    required String role, 
  }) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
      
      await _db.collection('users').doc(res.user!.uid).set({
        'uid': res.user!.uid,
        'name': name,
        'email': email.trim(),
        'role': role, 
        'createdAt': FieldValue.serverTimestamp(), 
      });
    } catch (e) {
      rethrow; 
    }
  }

  // Fungsi Login (Tambahan agar lebih rapi)
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Fungsi Reset Password
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