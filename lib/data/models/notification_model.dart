import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationScope { student, admin }

enum NotificationType {
  booking,
  payment,
  rentDue,
  complaint,
  general;

  static NotificationType fromString(String? v) => NotificationType.values
      .firstWhere((e) => e.name == v, orElse: () => NotificationType.general);
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? senderId;
  final String? refId;
  final bool isDerived;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.senderId,
    this.refId,
    this.isDerived = false,
  });

  factory NotificationModel.create({
    required NotificationType type,
    required String title,
    required String body,
    required String senderId,
    String? refId,
  }) =>
      NotificationModel(
        id: '',
        type: type,
        title: title,
        body: body,
        createdAt: DateTime.now(),
        senderId: senderId,
        refId: refId,
      );

  factory NotificationModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final created = d['createdAt'];
    return NotificationModel(
      id: doc.id,
      type: NotificationType.fromString(d['type']),
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      isRead: d['isRead'] ?? false,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      senderId: d['senderId'],
      refId: d['refId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'title': title,
    'body': body,
    'isRead': false,
    'createdAt': Timestamp.fromDate(createdAt),
    'senderId': senderId,
    'refId': refId,
  };
}