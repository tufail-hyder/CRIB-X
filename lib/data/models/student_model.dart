import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus {
  paid,
  pending,
  due;

  String get label => name[0].toUpperCase() + name.substring(1);

  static PaymentStatus fromString(String? v) => PaymentStatus.values
      .firstWhere((e) => e.name == v, orElse: () => PaymentStatus.pending);
}

enum StayStatus {
  active,
  left;

  String get label => name[0].toUpperCase() + name.substring(1);

  static StayStatus fromString(String? v) => StayStatus.values
      .firstWhere((e) => e.name == v, orElse: () => StayStatus.active);
}

class StudentModel {
  final String id;
  final String hostelId;
  final String name;
  final String phone;
  final String? cnic;
  final String? photoUrl;

  final String? userId;

  final String roomId;
  final String roomNumber;
  final String bed; // A1, A2...
  final DateTime checkInDate;
  final DateTime? checkOutDate;
  final PaymentStatus paymentStatus;
  final StayStatus stayStatus;
  final DateTime? createdAt;

  const StudentModel({
    required this.id,
    required this.hostelId,
    required this.name,
    required this.phone,
    this.cnic,
    this.photoUrl,
    this.userId,
    required this.roomId,
    required this.roomNumber,
    required this.bed,
    required this.checkInDate,
    this.checkOutDate,
    this.paymentStatus = PaymentStatus.pending,
    this.stayStatus = StayStatus.active,
    this.createdAt,
  });

  bool get isActive => stayStatus == StayStatus.active;

  static DateTime? _date(dynamic v) => v is Timestamp ? v.toDate() : null;

  factory StudentModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) =>
      StudentModel.fromJson(doc.data() ?? {}, id: doc.id);

  factory StudentModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return StudentModel(
      id: id ?? json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      cnic: json['cnic'],
      photoUrl: json['photoUrl'],
      userId: json['userId'],
      roomId: json['roomId'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      bed: json['bed'] ?? '',
      checkInDate: _date(json['checkInDate']) ?? DateTime.now(),
      checkOutDate: _date(json['checkOutDate']),
      paymentStatus: PaymentStatus.fromString(json['paymentStatus']),
      stayStatus: StayStatus.fromString(json['stayStatus']),
      createdAt: _date(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'hostelId': hostelId,
    'name': name,
    'phone': phone,
    'cnic': cnic,
    'photoUrl': photoUrl,
    'userId': userId,
    'roomId': roomId,
    'roomNumber': roomNumber,
    'bed': bed,
    'checkInDate': Timestamp.fromDate(checkInDate),
    'checkOutDate':
    checkOutDate != null ? Timestamp.fromDate(checkOutDate!) : null,
    'paymentStatus': paymentStatus.name,
    'stayStatus': stayStatus.name,
  };
}