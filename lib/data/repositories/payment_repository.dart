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

  /// [since] ke baad ki payments (chart ke liye aakhri 6 mahine kaafi hain)
  Stream<List<PaymentModel>> watchPayments(String hostelId,
      {required DateTime since}) {
    return _col(hostelId)
        .where('paidAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('paidAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PaymentModel.fromSnapshot).toList());
  }

  /// Partial payment support: student ke us mahine ke total me jama hota hai,
  /// aur fees se zyada nahi ja sakta. Transaction me, isliye double-tap ya
  /// do admins ek saath bhi count galat nahi karte.
  ///
  /// [fallbackFee]: purane students jinki monthlyFee save nahi thi, unke liye
  /// room ki price; payment ke saath student me bhi save ho jati hai.
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
}