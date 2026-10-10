import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constant/firebase_constants.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/setting_model.dart';
import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';

class SettingsRepository {
  final FirestoreService _fs;
  final CloudinaryService _cloud;
  SettingsRepository(this._fs, this._cloud);

  String _user(String uid) => '${FirebaseConstants.users}/$uid';
  String _kyc(String uid) =>
      '${FirebaseConstants.users}/$uid/${FirebaseConstants.privateSubcollection}/${FirebaseConstants.kycDoc}';
  String _hostel(String uid) => '${FirebaseConstants.hostels}/$uid';

  Future<AdminSettings> load(String uid) async {
    final results = await Future.wait([
      _fs.getDoc(_user(uid)),
      _fs.getDoc(_kyc(uid)),
      _fs.getDoc(_hostel(uid)),
    ]);

    if (!results[2].exists) throw const AppException('Hostel not found.');

    return AdminSettings.fromDocs(
      user: results[0].data() ?? {},
      kyc: results[1].data() ?? {},
      hostel: results[2].data() ?? {},
    );
  }

  Future<void> save(String uid, AdminSettings s) {
    final batch = _fs.batch();

    batch.update(_fs.doc(_user(uid)), {
      'phone': s.phone,
      'photoUrl': s.photoUrl,
    });

    batch.set(_fs.doc(_kyc(uid)), {'cnic': s.cnic}, SetOptions(merge: true));

    batch.set(
      _fs.doc(_hostel(uid)),
      {
        'name': s.hostelName,
        'city': s.city,
        'defaultRoomPrice': s.defaultRoomPrice,
        'currency': s.currency,
        'language': s.language,
        'notifications': s.notifications.toJson(),
        'paymentAccounts': s.paymentAccounts.map((a) => a.toJson()).toList(),
        'updatedAt': Timestamp.now(),
      },
      SetOptions(merge: true),
    );

    return batch.commit();
  }

  Future<String> uploadPhoto(File file) => _cloud.uploadImage(file);
}