import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';
import '../models/booking_model.dart'; 
import '../models/room_model.dart';   
import '../models/complaint_model.dart'; 

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ITEM & ROOM ---
  
  // Ambil semua data Wisma/Kelas secara Real-time
  Stream<List<ItemModel>> getItems() {
    return _db.collection('items').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ItemModel.fromMap(doc.id, doc.data())).toList());
  }

  // Update kondisi kamar tunggal berdasarkan Nama (untuk detail.dart)
  Future<void> updateRoomCondition(
      String itemId,
      String roomName, 
      RoomCondition newCondition) async {
    final docRef = _db.collection('items').doc(itemId);
    
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final item = ItemModel.fromMap(snapshot.id, snapshot.data()!);
      final updatedRooms = item.rooms.map((room) {
        if (room.name == roomName) {
          return room.copyWith(condition: newCondition);
        }
        return room;
      }).toList();

      transaction.update(docRef, {
        'rooms': updatedRooms.map((r) => r.toMap()).toList(),
      });
    });
  }

  // Update banyak kamar sekaligus berdasarkan ID (untuk Booking/Reject)
  Future<void> updateRoomConditionByIds(
      String itemId,
      List<String> roomIds,
      RoomCondition newCondition) async {
    final docRef = _db.collection('items').doc(itemId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final item = ItemModel.fromMap(snapshot.id, snapshot.data()!);
      final updatedRooms = item.rooms.map((room) {
        if (roomIds.contains(room.id)) {
          return room.copyWith(condition: newCondition);
        }
        return room;
      }).toList();

      transaction.update(docRef, {
        'rooms': updatedRooms.map((r) => r.toMap()).toList(),
      });
    });
  }

  // =======================
  // BOOKING (KARYAWAN)
  // =======================

  Future<void> createBooking(BookingModel booking, String itemId) async {
    final batch = _db.batch();
    final bookingRef = _db.collection('bookings').doc(booking.id);
    batch.set(bookingRef, booking.toMap());
    await batch.commit();

    // Kamar otomatis jadi TERISI
    await updateRoomConditionByIds(itemId, booking.roomIds, RoomCondition.terisi);
  }

  Future<void> updateRefundAccount(String bookingId, String accountNumber) async {
    await _db.collection('bookings').doc(bookingId).update({
      'accountNumber': accountNumber,
      'status': BookingStatus.refundProcess.name,
    });
  }

  Stream<List<BookingModel>> getPendingBookings() {
    return _db.collection('bookings')
        .where('status', isEqualTo: BookingStatus.pending.name)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => BookingModel.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> approveBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.approved.name,
    });
  }

  Future<void> rejectBooking(String bookingId, String reason, String itemId, List<String> roomIds) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.rejected.name,
      'rejectReason': reason,
    });
    // Kamar dikembalikan jadi KOSONG
    await updateRoomConditionByIds(itemId, roomIds, RoomCondition.kosong);
  }

  // =======================
  // COMPLAINT (PENGADUAN)
  // =======================

  Future<void> createComplaint(ComplaintModel complaint, String itemId) async {
    await _db.collection('complaints').doc(complaint.id).set(complaint.toMap());
    await updateRoomCondition(itemId, complaint.roomName, RoomCondition.perluPerbaikan);
  }

  Future<void> startRepair(String complaintId, String itemId, String roomName) async {
    await _db.collection('complaints').doc(complaintId).update({
      'status': ComplaintStatus.repairing.name,
    });
    await updateRoomCondition(itemId, roomName, RoomCondition.dalamPerbaikan);
  }

  Future<void> resolveComplaint(String complaintId, String itemId, String roomName) async {
    await _db.collection('complaints').doc(complaintId).update({
      'status': ComplaintStatus.resolved.name,
    });
    await updateRoomCondition(itemId, roomName, RoomCondition.kosong);
  }

  // =======================
  // SYSTEM SEEDER (JALANKAN SEKALI)
  // =======================

  Future<void> seedDataAndInitialComplaints(List<ItemModel> allItems) async {
    final itemsCollection = _db.collection('items');
    final complaintsCollection = _db.collection('complaints');

    for (var item in allItems) {
      try {
        // Cek dulu agar tidak duplikat berdasarkan judul
        final check = await itemsCollection.where('title', isEqualTo: item.title).get();
        if (check.docs.isNotEmpty) {
          print("INFO: ${item.title} sudah ada, melewati...");
          continue;
        }

        // 1. Tambah Wisma/Kelas
        DocumentReference itemDoc = await itemsCollection.add(item.toMap());
        await itemDoc.update({'id': itemDoc.id});
        print("SUCCESS: Berhasil upload ${item.title}");

        // 2. Scan Kamar Rusak dari LocalData
        for (var room in item.rooms) {
          if (room.condition == RoomCondition.perluPerbaikan) {
            String complaintId = "INIT_${room.id}_${DateTime.now().millisecondsSinceEpoch}";
            
            await complaintsCollection.doc(complaintId).set({
              'id': complaintId,
              'roomId': room.id,
              'roomName': "${item.title} - ${room.name}",
              'description': "Kamar memerlukan perbaikan (Data Inisialisasi Sistem).",
              'status': 'pending',
              'createdAt': FieldValue.serverTimestamp(),
              'userId': 'SYSTEM_ADMIN',
            });
            print("LOG: Tiket dibuat untuk: ${room.name}");
          }
        }
      } catch (e) {
        print("ERROR: Gagal upload ${item.title}: $e");
      }
    }
  }
}