import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/firebase_constants.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/payment_model.dart';
import '../models/student_model.dart';
import '../services/firestore_service.dart';

/// Path: hostels/{hostelId}/payments/{paymentId}
class PaymentRepository {
  final FirestoreService _fs;
  PaymentRepository(this._fs);

  String _base(String hostelId) => '${FirebaseConstants.hostels}/$hostelId';

  CollectionReference<Map<String, dynamic>> _col(String hostelId) =>
      _fs.collection('${_base(hostelId)}/payments');

  Stream<List<PaymentModel>> watchPayments(String hostelId,
      {required DateTime since}) {
    return _col(hostelId)
        .where('paidAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('paidAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PaymentModel.fromSnapshot).toList());
  }

  Future<void> recordPayment(PaymentModel p, {double fallbackFee = 0}) {
    final studentRef = _fs.doc('${_base(p.hostelId)}/students/${p.studentId}');
    final paymentRef = _col(p.hostelId).doc();

    return _fs.runTransaction((tx) async {
      final snap = await tx.get(studentRef);
      if (!snap.exists) throw const AppException('Student not found.');

      final student = StudentModel.fromSnapshot(snap);
      if (!student.isActive) {
        throw const AppException('This student has already left.');
      }

      final fee = student.monthlyFee > 0 ? student.monthlyFee : fallbackFee;
      final alreadyPaid = student.paidFor(p.forMonth);

      if (fee > 0) {
        final remaining = fee - alreadyPaid;
        if (remaining <= 0.5) {
          throw const AppException(
              'Fees for this month are already fully paid.');
        }
        if (p.amount > remaining + 0.5) {
          throw AppException(
              'Amount is more than the remaining ${remaining.toStringAsFixed(0)}.');
        }
      }

      final updated = {...student.paidByMonth};
      updated[p.forMonth] = alreadyPaid + p.amount;

      tx.update(studentRef, {
        'paidByMonth': updated,
        if (student.monthlyFee <= 0 && fallbackFee > 0) 'monthlyFee': fallbackFee,
      });
      tx.set(paymentRef, {...p.toJson(), 'createdAt': Timestamp.now()});
    });
  }

  Future<List<PaymentModel>> fetchPayments(
      String hostelId, {
        required DateTime from,
        required DateTime to,
      }) async {
    final snap = await _col(hostelId)
        .where('paidAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('paidAt', isLessThan: Timestamp.fromDate(to))
        .get();
    return snap.docs.map(PaymentModel.fromSnapshot).toList();
  }
}