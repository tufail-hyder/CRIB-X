import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/firebase_constants.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/complaint_model.dart';
import '../services/firestore_service.dart';

/// Path: hostels/{hostelId}/complaints/{complaintId}
class ComplaintRepository {
  final FirestoreService _fs;
  ComplaintRepository(this._fs);

  CollectionReference<Map<String, dynamic>> _col(String hostelId) =>
      _fs.collection('${FirebaseConstants.hostels}/$hostelId/complaints');

  Stream<List<ComplaintModel>> watchComplaints(String hostelId) {
    return _col(hostelId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ComplaintModel.fromSnapshot).toList());
  }

  Future<void> createComplaint(ComplaintModel c) {
    return _col(c.hostelId).add({
      ...c.toJson(),
      'status': ComplaintStatus.open.name,
      'createdAt': Timestamp.now(),
      'updatedAt': null,
      'resolvedAt': null,
    });
  }

  Future<void> updateStatus(
      ComplaintModel c,
      ComplaintStatus status, {
        String? response,
      }) async {
    final ref = _col(c.hostelId).doc(c.id);
    final snap = await ref.get();
    if (!snap.exists) throw const AppException('Complaint not found.');

    final reply = response?.trim();
    await ref.update({
      'status': status.name,
      if (reply != null && reply.isNotEmpty) 'adminResponse': reply,
      'updatedAt': Timestamp.now(),
      'resolvedAt': status == ComplaintStatus.resolved
          ? (c.resolvedAt != null
          ? Timestamp.fromDate(c.resolvedAt!)
          : Timestamp.now())
          : null,
    });
  }
}