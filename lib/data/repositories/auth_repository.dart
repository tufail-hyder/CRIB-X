import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constant/firebase_constants.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthRepository {
  final AuthService _auth;
  final FirestoreService _fs;

  AuthRepository(this._auth, this._fs);
  String? get currentUid => _auth.currentUser?.uid;

  /// Admin account + hostel + private CNIC
  Future<UserModel> registerAdmin({
    required String ownerName,
    required String email,
    required String password,
    required String phone,
    required String cnic,
    required String hostelName,
    required String city,
  }) async {
    final cred = await _auth.signUp(email, password);
    final uid = cred.user!.uid;

    final user = UserModel(
      uid: uid,
      role: UserRole.admin,
      name: ownerName,
      email: email,
      phone: phone,
      hostelId: uid,
      createdAt: DateTime.now(),
    );

    try {
      final batch = _fs.batch();
      batch.set(_fs.doc('${FirebaseConstants.users}/$uid'), user.toJson());
      batch.set(
        _fs.doc(
            '${FirebaseConstants.users}/$uid/${FirebaseConstants.privateSubcollection}/${FirebaseConstants.kycDoc}'),
        {'cnic': cnic},
      );
      batch.set(_fs.doc('${FirebaseConstants.hostels}/$uid'), {
        'name': hostelName,
        'city': city,
        'adminId': uid,
        'isActive': true,
        'createdAt': Timestamp.now(),
      });
      await batch.commit();
      return user;
    } catch (_) {
      await _auth.deleteCurrentUser();
      rethrow;
    }
  }

  Future<UserModel> loginAdmin(String email, String password) async {
    final cred = await _auth.signIn(email, password);
    final snap =
    await _fs.getDoc('${FirebaseConstants.users}/${cred.user!.uid}');

    if (!snap.exists) {
      await _auth.signOut();
      throw const AppException('Account not found. Please sign up.');
    }

    final user = UserModel.fromSnapshot(snap);
    if (!user.isAdmin) {
      await _auth.signOut();
      throw const AppException('This is not a hostel admin account.');
    }
    return user;
  }

  bool get isLoggedIn => _auth.currentUser != null;

  /// Logged-in user ka profile
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final snap =
    await _fs.getDoc('${FirebaseConstants.users}/${firebaseUser.uid}');
    if (!snap.exists) return null;
    return UserModel.fromSnapshot(snap);
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordReset(email);

  /// Settings page: purana password check karke naya set karo
  Future<void> changePassword(String current, String next) async {
    try {
      await _auth.changePassword(current, next);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          throw const AppException('Current password is incorrect.');
        case 'weak-password':
          throw const AppException('New password is too weak.');
        case 'too-many-requests':
          throw const AppException('Too many attempts. Try again later.');
        default:
          rethrow;
      }
    }
  }

  Future<void> logout() => _auth.signOut();
}