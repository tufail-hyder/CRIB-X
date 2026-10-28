import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/firebase_constants.dart';
import '../models/hostel_model.dart';
import '../models/room_model.dart';
import '../models/student_model.dart';
import '../services/firestore_service.dart';

class StudentHomeRepository {
  final FirestoreService _fs;
  StudentHomeRepository(this._fs);

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

  Future<Map<String, int>?> fetchAvailableBeds() async {
    try {
      final snap = await _fs.collectionGroup('rooms').get();
      final result = <String, int>{};
      for (final doc in snap.docs) {
        final room = RoomModel.fromSnapshot(doc);
        final hostelId = doc.reference.parent.parent?.id ?? room.hostelId;
        result[hostelId] = (result[hostelId] ?? 0) + room.availableBeds;
      }
      return result;
    } catch (_) {
      return null;
    }
  }

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