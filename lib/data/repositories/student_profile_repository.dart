import 'dart:io';
import '../../core/constant/firebase_constants.dart';
import '../../core/exceptions/app_exception.dart';
import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';

class StudentProfile {
  final String name;
  final String email;
  final String phone;
  final String city;
  final String? photoUrl;

  const StudentProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    this.photoUrl,
  });
}

class StudentProfileRepository {
  final FirestoreService _fs;
  final CloudinaryService _cloud;
  StudentProfileRepository(this._fs, this._cloud);

  String _user(String uid) => '${FirebaseConstants.users}/$uid';

  Future<StudentProfile> load(String uid) async {
    final snap = await _fs.getDoc(_user(uid));
    if (!snap.exists) throw const AppException('Profile not found.');

    final d = snap.data() ?? {};
    return StudentProfile(
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
      city: d['city'] ?? '',
      photoUrl: d['photoUrl'],
    );
  }

  Future<void> save(
      String uid, {
        required String name,
        required String phone,
        required String city,
        required String? photoUrl,
      }) {
    return _fs.doc(_user(uid)).update({
      'name': name,
      'phone': phone,
      'city': city,
      'photoUrl': photoUrl,
    });
  }

  Future<String> uploadPhoto(File file) => _cloud.uploadImage(file);
}