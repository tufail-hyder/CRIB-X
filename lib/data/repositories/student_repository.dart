import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/firebase_constants.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/payment_model.dart';
import '../models/student_model.dart';
import '../services/firestore_service.dart';

/// Path: hostels/{hostelId}/students/{studentId}
class StudentRepository {
  final FirestoreService _fs;
  StudentRepository(this._fs);

  String _base(String hostelId) => '${FirebaseConstants.hostels}/$hostelId';

  CollectionReference<Map<String, dynamic>> _col(String hostelId) =>
      _fs.collection('${_base(hostelId)}/students');

  Stream<List<StudentModel>> watchStudents(String hostelId) {
    return _col(hostelId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(StudentModel.fromSnapshot).toList());
  }

  /// Student banao + bed bharo + (agar kuch diya hai to) payment record bhi.
  /// Sab ek transaction me, isliye Payments screen ke revenue me bhi aayega.
  Future<void> addStudent(
      StudentModel s, {
        double initialPaid = 0,
        PaymentMethod method = PaymentMethod.cash,
      }) {
    if (s.monthlyFee <= 0) {
      throw const AppException('Monthly fee must be greater than 0.');
    }
    if (initialPaid < 0 || initialPaid > s.monthlyFee) {
      throw const AppException('Paid amount cannot be more than monthly fee.');
    }

    final roomRef = _fs.doc('${_base(s.hostelId)}/rooms/${s.roomId}');
    final studentRef = _col(s.hostelId).doc();
    final paymentRef = _fs.collection('${_base(s.hostelId)}/payments').doc();

    return _fs.runTransaction((tx) async {
      final roomSnap = await tx.get(roomRef);
      if (!roomSnap.exists) throw const AppException('Room not found.');

      final data = roomSnap.data()!;
      final total = (data['totalBeds'] as num?)?.toInt() ?? 0;
      final labels = List<String>.from(data['occupiedBedLabels'] ?? []);

      if (labels.contains(s.bed)) {
        throw AppException('Bed ${s.bed} is already taken.');
      }
      if (labels.length >= total) {
        throw const AppException('This room is full.');
      }

      labels.add(s.bed);
      tx.update(roomRef, {
        'occupiedBedLabels': labels,
        'occupiedBeds': labels.length,
      });

      final now = DateTime.now();
      // Future check-in ho to pehli fees usi mahine ki, warna is mahine ki
      final feeMonth = StudentModel.monthKey(
          s.checkInDate.isAfter(now) ? s.checkInDate : now);

      tx.set(studentRef, {
        ...s.toJson(),
        'paidByMonth': initialPaid > 0 ? {feeMonth: initialPaid} : {},
        'createdAt': Timestamp.now(),
      });

      if (initialPaid > 0) {
        tx.set(paymentRef, {
          ...PaymentModel(
            id: '',
            hostelId: s.hostelId,
            studentId: studentRef.id,
            studentName: s.name,
            roomNumber: s.roomNumber,
            amount: initialPaid,
            method: method,
            forMonth: feeMonth,
            note: 'Paid at check-in',
            paidAt: now,
          ).toJson(),
          'createdAt': Timestamp.now(),
        });
      }
    });
  }

  /// Student chala gaya: bed khali + stayStatus = left
  Future<void> checkOut(StudentModel s) {
    final roomRef = _fs.doc('${_base(s.hostelId)}/rooms/${s.roomId}');
    final studentRef = _col(s.hostelId).doc(s.id);

    return _fs.runTransaction((tx) async {
      final roomSnap = await tx.get(roomRef);
      final studentSnap = await tx.get(studentRef);

      final alreadyLeft = StayStatus.fromString(studentSnap.data()?['stayStatus']) ==
          StayStatus.left;
      if (alreadyLeft) return;

      if (roomSnap.exists) {
        final labels =
        List<String>.from(roomSnap.data()?['occupiedBedLabels'] ?? []);
        labels.remove(s.bed);
        tx.update(roomRef, {
          'occupiedBedLabels': labels,
          'occupiedBeds': labels.length,
        });
      }
      tx.update(studentRef, {
        'stayStatus': StayStatus.left.name,
        'checkOutDate': Timestamp.now(),
      });
    });
  }
}