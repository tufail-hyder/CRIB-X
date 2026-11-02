import '../../core/constant/firebase_constants.dart';
import '../models/notification_model.dart';
import '../models/setting_model.dart';
import '../services/firestore_service.dart';

class NotificationRepository {
  final FirestoreService _fs;
  NotificationRepository(this._fs);

  String userPath(String uid) => '${FirebaseConstants.users}/$uid/notifications';
  String hostelPath(String hostelId) =>
      '${FirebaseConstants.hostels}/$hostelId/notifications';

  Stream<List<NotificationModel>> watch(String path) {
    return _fs
        .collection(path)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(NotificationModel.fromSnapshot).toList());
  }

  Stream<int> watchUnreadCount(String path) {
    return _fs
        .collection(path)
        .where('isRead', isEqualTo: false)
        .limit(10)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> markRead(String path, String id) =>
      _fs.doc('$path/$id').update({'isRead': true});

  Future<void> markAllRead(String path, Iterable<String> ids) {
    final batch = _fs.batch();
    for (final id in ids) {
      batch.update(_fs.doc('$path/$id'), {'isRead': true});
    }
    return batch.commit();
  }

  Future<NotificationPrefs> loadAdminPrefs(String uid) async {
    final snap = await _fs.getDoc('${FirebaseConstants.hostels}/$uid');
    final raw = snap.data()?['notifications'];
    return raw is Map
        ? NotificationPrefs.fromJson(Map<String, dynamic>.from(raw))
        : const NotificationPrefs();
  }
}