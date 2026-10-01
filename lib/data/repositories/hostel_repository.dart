import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/firebase_constants.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/hostel_model.dart';
import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';

class HostelRepository {
  final FirestoreService _fs;
  final CloudinaryService _cloud;
  HostelRepository(this._fs, this._cloud);

  Future<HostelModel> getHostel(String id) async {
    final snap = await _fs.getDoc('${FirebaseConstants.hostels}/$id');
    if (!snap.exists) throw const AppException('Hostel not found.');
    return HostelModel.fromSnapshot(snap);
  }

  Future<void> updateHostel(HostelModel hostel) {
    return _fs
        .doc('${FirebaseConstants.hostels}/${hostel.id}')
        .set(hostel.toUpdateJson(), SetOptions(merge: true));
  }

  Future<String> uploadImage(File file) => _cloud.uploadImage(file);
}