import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream untuk memantau status login pengguna
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

  // Registrasi Karyawan dengan penyimpanan data ke Firestore
  Future<void> registerKaryawan(String email, String password, String name) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
      
      // Simpan detail profil ke collection 'users'
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
      // Mengatur bahasa email ke Indonesia (Opsional)
      await _auth.setLanguageCode("id");
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      // Melempar error agar bisa ditangkap oleh UI (SnackBar/Dialog)
      throw e.message ?? "Terjadi kesalahan saat mengirim email reset.";
    } catch (e) {
      throw "Terjadi kesalahan yang tidak terduga.";
    }
  } // <-- Tadi kurang tutup kurung di sini

  // Fungsi Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}