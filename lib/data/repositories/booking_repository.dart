import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/firebase_constants.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/booking_model.dart';
import '../models/student_model.dart';
import '../services/firestore_service.dart';

/// Path: hostels/{hostelId}/bookings/{bookingId}
class BookingRepository {
  final FirestoreService _fs;
  BookingRepository(this._fs);

  String _base(String hostelId) => '${FirebaseConstants.hostels}/$hostelId';

  CollectionReference<Map<String, dynamic>> _col(String hostelId) =>
      _fs.collection('${_base(hostelId)}/bookings');

  Stream<List<BookingModel>> watchBookings(String hostelId) {
    return _col(hostelId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromSnapshot).toList());
  }

  /// Nayi booking hamesha Pending banti hai. Bed tab bharta hai jab approve ho.
  Future<void> createBooking(BookingModel b) =>
      _col(b.hostelId).add({...b.toJson(), 'createdAt': Timestamp.now()});

  /// Approve = bed bharo + student record banao + booking approved.
  /// Sab ek transaction me, taake bed double-book na ho.
  Future<void> approve(BookingModel b) {
    final bookingRef = _col(b.hostelId).doc(b.id);
    final roomRef = _fs.doc('${_base(b.hostelId)}/rooms/${b.roomId}');
    final studentRef = _fs.collection('${_base(b.hostelId)}/students').doc();

    return _fs.runTransaction((tx) async {
      final bookingSnap = await tx.get(bookingRef);
      final current = BookingStatus.fromString(bookingSnap.data()?['status']);
      if (current != BookingStatus.pending) {
        throw const AppException('This booking is already processed.');
      }

      final roomSnap = await tx.get(roomRef);
      if (!roomSnap.exists) throw const AppException('Room not found.');

      final data = roomSnap.data()!;
      final total = (data['totalBeds'] as num?)?.toInt() ?? 0;
      final labels = List<String>.from(data['occupiedBedLabels'] ?? []);

      if (labels.contains(b.bed)) {
        throw AppException(
            'Bed ${b.bed} is no longer free. Reject this booking or ask the student for another bed.');
      }
      if (labels.length >= total) {
        throw const AppException('This room is full.');
      }

      labels.add(b.bed);
      tx.update(roomRef, {
        'occupiedBedLabels': labels,
        'occupiedBeds': labels.length,
      });

      final student = StudentModel(
        id: '',
        hostelId: b.hostelId,
        name: b.studentName,
        phone: b.phone,
        userId: b.userId,
        roomId: b.roomId,
        roomNumber: b.roomNumber,
        bed: b.bed,
        checkInDate: b.checkInDate,
      );
      tx.set(studentRef, {...student.toJson(), 'createdAt': Timestamp.now()});

      tx.update(bookingRef, {
        'status': BookingStatus.approved.name,
        'studentId': studentRef.id,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  Future<void> reject(BookingModel b) {
    final ref = _col(b.hostelId).doc(b.id);
    return _fs.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = BookingStatus.fromString(snap.data()?['status']);
      if (current != BookingStatus.pending) {
        throw const AppException('This booking is already processed.');
      }
      tx.update(ref, {
        'status': BookingStatus.rejected.name,
        'updatedAt': Timestamp.now(),
      });
    });
  }
}