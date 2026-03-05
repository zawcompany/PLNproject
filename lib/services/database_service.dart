import 'dart:io';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/item_model.dart';
import '../models/booking_model.dart'; 
import '../models/room_model.dart';   
import '../models/complaint_model.dart'; 

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  //MANAJEMEN FILE (FIREBASE STORAGE)

  Future<String?> uploadFile(File file, String folder) async {
    try {
      String fileName = "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
      Reference ref = _storage.ref().child('$folder/$fileName');
      
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      developer.log("Gagal upload file", error: e);
      return null;
    }
  }

  // MANAJEMEN ITEM & KONDISI KAMAR
  Stream<List<ItemModel>> getItems() {
    return _db.collection('items').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ItemModel.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> updateRoomCondition(
      String itemId,
      String roomName, 
      RoomCondition newCondition) async {
    final docRef = _db.collection('items').doc(itemId);
    
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final snapshotData = snapshot.data();
      if (!snapshot.exists || snapshotData == null) return;

      final item = ItemModel.fromMap(snapshot.id, snapshotData);
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

  Future<void> updateRoomConditionByIds(
      String itemId,
      List<String> roomIds,
      RoomCondition newCondition) async {
    final docRef = _db.collection('items').doc(itemId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final snapshotData = snapshot.data();
      if (!snapshot.exists || snapshotData == null) return;
      
      final item = ItemModel.fromMap(snapshot.id, snapshotData);
      
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

  //MANAJEMEN BOOKING
  Future<void> createBooking(BookingModel booking, String itemId) async {
    final batch = _db.batch();
    final bookingRef = _db.collection('bookings').doc(booking.id);
    
    batch.set(bookingRef, booking.toMap());
    await batch.commit();
    await updateRoomConditionByIds(itemId, booking.roomIds, RoomCondition.terisi);
  }

  Stream<List<BookingModel>> getPendingBookings() {
    return _db.collection('bookings')
        .where('status', isEqualTo: BookingStatus.pending.name)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
          final data = doc.data();
          return BookingModel.fromMap(doc.id, data);
        }).toList());
  }

  Future<void> approveBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.approved.name,
    });
  }

  Future<void> rejectBookingWithRedirect(
    BookingModel oldBooking, 
    String reason, 
    List<String> newRoomIds,
    String newItemName // Nama wisma/kelas yang baru
    ) async {
    
    // 1. Update booking lama menjadi REJECTED
    await _db.collection('bookings').doc(oldBooking.id).update({
      'status': BookingStatus.rejected.name,
      'rejectReason': reason,
      'isRead': false,
    });

    // 2. Buat booking baru sebagai PENGALIHAN (Otomatis Approved)
    String newBookingId = "RE- ${DateTime.now().millisecondsSinceEpoch}";
    BookingModel redirectedBooking = BookingModel(
      id: newBookingId,
      userId: oldBooking.userId,
      userName: oldBooking.userName,
      itemName: newItemName, // Wisma yang dipilih admin
      roomIds: newRoomIds,    // Kamar tunggal yang dipilih admin
      start: oldBooking.start,
      end: oldBooking.end,
      totalPayment: oldBooking.totalPayment, // Harga tetap sama sesuai permintaan
      status: BookingStatus.approved, // Langsung disetujui
      createdAt: DateTime.now(),
    );

    // Simpan booking baru ke Firestore
    await _db.collection('bookings').doc(newBookingId).set(redirectedBooking.toMap());

    // 3. Update Kondisi Kamar di koleksi 'items'
    final itemsSnapshot = await _db.collection('items').get();
    for (var doc in itemsSnapshot.docs) {
      List rooms = List.from(doc.data()['rooms'] ?? []);
      bool isChanged = false;

      for (var room in rooms) {
        // Kosongkan kamar lama
        if (oldBooking.roomIds.contains(room['id'])) {
          room['condition'] = RoomCondition.kosong.name;
          isChanged = true;
        }
        // Isi kamar baru
        if (newRoomIds.contains(room['id'])) {
          room['condition'] = RoomCondition.terisi.name;
          isChanged = true;
        }
      }

      if (isChanged) {
        await doc.reference.update({'rooms': rooms});
      }
    }
  }

  //MANAJEMEN COMPLAINT (PENGADUAN)
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
  // 5. SYSTEM SEEDER
  Future<void> seedDataAndInitialComplaints(List<ItemModel> allItems) async {
    final itemsCollection = _db.collection('items');
    for (var item in allItems) {
      try {
        final check = await itemsCollection.where('title', isEqualTo: item.title).get();
        if (check.docs.isNotEmpty) continue;

        DocumentReference itemDoc = await itemsCollection.add(item.toMap());
        await itemDoc.update({'id': itemDoc.id});
      } catch (e) {
        developer.log("Error seeding data", error: e);
      }
    }
  }

  Future<void> teknisiSelesaikanPerbaikan(String complaintId, String imageUrl) async {
    await _db.collection('complaints').doc(complaintId).update({
      'status': 'waitingApproval', 
      'completionProof': imageUrl,   
    });
  }

  Future<void> approvalValidasiPerbaikan(String complaintId, bool isValid, String itemId, String roomName) async {
    if (isValid) {
      await resolveComplaint(complaintId, itemId, roomName);
    } else {
      await _db.collection('complaints').doc(complaintId).update({
        'status': ComplaintStatus.repairing.name,
      });
    }
  }
}