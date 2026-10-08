import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/firebase_constants.dart';
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

  Future<void> recordPayment(PaymentModel p, {required bool markStudentPaid}) {
    final batch = _fs.batch();

    batch.set(_col(p.hostelId).doc(), {
      ...p.toJson(),
      'createdAt': Timestamp.now(),
    });

    if (markStudentPaid) {
      batch.update(
        _fs.doc('${_base(p.hostelId)}/students/${p.studentId}'),
        {'paymentStatus': PaymentStatus.paid.name},
      );
    }
    return batch.commit();
  }
}