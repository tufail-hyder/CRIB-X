import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/firebase_constants.dart';
import '../models/hostel_model.dart';
import '../models/room_model.dart';
import '../models/student_model.dart';
import '../services/firestore_service.dart';

class RoomSummary {
  final int availableBeds;
  final Set<int> seaters;
  final double? minPrice;
  const RoomSummary(this.availableBeds, this.seaters, this.minPrice);
}

/// Student portal ka data: hostels, rooms, favorites, apna stay
class StudentHomeRepository {
  final FirestoreService _fs;
  StudentHomeRepository(this._fs);

  /// Sab active hostels jinka naam bhara ho (adhure profile nahi)
  Future<List<HostelModel>> fetchHostels() async {
    final snap = await _fs
        .collection(FirebaseConstants.hostels)
        .where('isActive', isEqualTo: true)
        .get();

    return snap.docs
        .map(HostelModel.fromSnapshot)
        .where((h) => h.name.trim().isNotEmpty)
        .toList();
  }

  /// hostelId -> khali beds, room types, sab se sasti price. Ek hi query se.
  /// Rules/network ka masla ho to null (list phir bhi dikhegi).
  Future<Map<String, RoomSummary>?> fetchRoomSummaries() async {
    try {
      final snap = await _fs.collectionGroup('rooms').get();

      final beds = <String, int>{};
      final seaters = <String, Set<int>>{};
      final prices = <String, double>{};

      for (final doc in snap.docs) {
        final room = RoomModel.fromSnapshot(doc);
        final id = doc.reference.parent.parent?.id ?? room.hostelId;
        final free = room.availableBeds;

        beds[id] = (beds[id] ?? 0) + free;
        if (free > 0) {
          seaters.putIfAbsent(id, () => <int>{}).add(room.seater);
          if (room.monthlyPrice > 0) {
            prices[id] = math.min(prices[id] ?? double.infinity, room.monthlyPrice);
          }
        }
      }

      return {
        for (final id in beds.keys)
          id: RoomSummary(beds[id]!, seaters[id] ?? <int>{}, prices[id]),
      };
    } catch (_) {
      return null;
    }
  }

  /// Ek hostel ke saare rooms (Details + booking ke liye)
  Future<List<RoomModel>> fetchRooms(String hostelId) async {
    final snap = await _fs
        .collection('${FirebaseConstants.hostels}/$hostelId/rooms')
        .orderBy('roomNumber')
        .get();
    return snap.docs.map(RoomModel.fromSnapshot).toList();
  }

  /// Student ka apna abhi ka stay record (admin ne jo student record banaya
  /// aur userId se jora). Nahi mila ya ijazat nahi = null.
  Future<StudentModel?> fetchMyStay(String uid) async {
    try {
      final snap = await _fs
          .collectionGroup('students')
          .where('userId', isEqualTo: uid)
          .get();

      final stays = snap.docs
          .map(StudentModel.fromSnapshot)
          .where((s) => s.isActive)
          .toList()
        ..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));
      return stays.isEmpty ? null : stays.first;
    } catch (_) {
      return null;
    }
  }

  // ---------------- Favorites: users/{uid}.favoriteHostelIds ----------------
  Stream<Set<String>> watchFavorites(String uid) {
    return _fs.doc('${FirebaseConstants.users}/$uid').snapshots().map((snap) {
      final raw = snap.data()?['favoriteHostelIds'];
      return raw is List ? raw.map((e) => e.toString()).toSet() : <String>{};
    });
  }

  Future<void> setFavorite(String uid, String hostelId, bool add) {
    return _fs.doc('${FirebaseConstants.users}/$uid').update({
      'favoriteHostelIds': add
          ? FieldValue.arrayUnion([hostelId])
          : FieldValue.arrayRemove([hostelId]),
    });
  }
}