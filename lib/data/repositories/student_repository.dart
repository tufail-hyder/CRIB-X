import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/firebase_constants.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/student_model.dart';
import '../services/firestore_service.dart';

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

  Future<void> addStudent(StudentModel s) {
    final roomRef = _fs.doc('${_base(s.hostelId)}/rooms/${s.roomId}');
    final studentRef = _col(s.hostelId).doc();

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
      tx.set(studentRef, {...s.toJson(), 'createdAt': Timestamp.now()});
    });
  }

  Future<void> updatePaymentStatus(
      String hostelId, String studentId, PaymentStatus status) =>
      _col(hostelId).doc(studentId).update({'paymentStatus': status.name});

  Future<void> checkOut(StudentModel s) {
    final roomRef = _fs.doc('${_base(s.hostelId)}/rooms/${s.roomId}');
    final studentRef = _col(s.hostelId).doc(s.id);

    return _fs.runTransaction((tx) async {
      final roomSnap = await tx.get(roomRef);

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