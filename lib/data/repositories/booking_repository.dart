import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/date_text.dart';
import '../../core/constant/firebase_constants.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../models/student_model.dart';
import '../services/firestore_service.dart';

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

  DocumentReference<Map<String, dynamic>> _userNotif(String uid) =>
      _fs.collection('${FirebaseConstants.users}/$uid/notifications').doc();
  Future<bool> hasPendingRequest(String hostelId, String userId) async {
    final snap = await _col(hostelId)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: BookingStatus.pending.name)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> createBooking(BookingModel b) {
    final batch = _fs.batch();
    final bookingRef = _col(b.hostelId).doc();

    batch.set(bookingRef, {...b.toJson(), 'createdAt': Timestamp.now()});

    if (b.userId != null) {
      batch.set(
        _fs.collection('${_base(b.hostelId)}/notifications').doc(),
        NotificationModel.create(
          type: NotificationType.booking,
          title: 'New booking request',
          body:
          '${b.studentName} requested Room ${b.roomNumber}, bed ${b.bed} from ${dateText(b.checkInDate)}.',
          senderId: b.userId!,
          refId: bookingRef.id,
        ).toJson(),
      );
    }
    return batch.commit();
  }

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
      final fee = (data['monthlyPrice'] as num?)?.toDouble() ?? 0;

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
        monthlyFee: fee,
      );
      tx.set(studentRef, {...student.toJson(), 'createdAt': Timestamp.now()});

      tx.update(bookingRef, {
        'status': BookingStatus.approved.name,
        'studentId': studentRef.id,
        'updatedAt': Timestamp.now(),
      });

      if (b.userId != null) {
        tx.set(
          _userNotif(b.userId!),
          NotificationModel.create(
            type: NotificationType.booking,
            title: 'Booking approved',
            body:
            'Your request for Room ${b.roomNumber}, bed ${b.bed} was approved. Check-in: ${dateText(b.checkInDate)}.',
            senderId: b.hostelId,
            refId: b.id,
          ).toJson(),
        );
      }
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

      if (b.userId != null) {
        tx.set(
          _userNotif(b.userId!),
          NotificationModel.create(
            type: NotificationType.booking,
            title: 'Booking rejected',
            body:
            'Your request for Room ${b.roomNumber}, bed ${b.bed} was not accepted. You can try another room or hostel.',
            senderId: b.hostelId,
            refId: b.id,
          ).toJson(),
        );
      }
    });
  }
}