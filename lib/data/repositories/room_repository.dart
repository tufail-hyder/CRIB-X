import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/firebase_constants.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/room_model.dart';
import '../services/firestore_service.dart';

class RoomRepository {
  final FirestoreService _fs;
  RoomRepository(this._fs);

  CollectionReference<Map<String, dynamic>> _col(String hostelId) =>
      _fs.collection('${FirebaseConstants.hostels}/$hostelId/rooms');

  Stream<List<RoomModel>> watchRooms(String hostelId) {
    return _col(hostelId).orderBy('roomNumber').snapshots().map(
          (snap) => snap.docs.map(RoomModel.fromSnapshot).toList(),
    );
  }

  Future<void> _ensureUnique(String hostelId, String roomNumber,
      {String? excludeId}) async {
    final snap =
    await _col(hostelId).where('roomNumber', isEqualTo: roomNumber).get();
    if (snap.docs.any((d) => d.id != excludeId)) {
      throw AppException('Room $roomNumber already exists.');
    }
  }

  Future<void> addRoom(RoomModel room) async {
    await _ensureUnique(room.hostelId, room.roomNumber);
    await _col(room.hostelId).add({
      ...room.toJson(),
      'occupiedBeds': 0,
      'occupiedBedLabels': <String>[],
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateRoom(RoomModel room) async {
    await _ensureUnique(room.hostelId, room.roomNumber, excludeId: room.id);
    await _col(room.hostelId).doc(room.id).update(room.toJson());
  }

  Future<void> deleteRoom(String hostelId, String roomId) =>
      _col(hostelId).doc(roomId).delete();
}