import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> doc(String path) => _db.doc(path);

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _db.collection(path);

  WriteBatch batch() => _db.batch();

  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc(String path) =>
      _db.doc(path).get();

  Future<T> runTransaction<T>(TransactionHandler<T> handler) =>
      _db.runTransaction(handler);
}