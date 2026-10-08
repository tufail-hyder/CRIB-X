import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  approved,
  rejected;

  String get label => name[0].toUpperCase() + name.substring(1);

  static BookingStatus fromString(String? v) => BookingStatus.values
      .firstWhere((e) => e.name == v, orElse: () => BookingStatus.pending);
}

class BookingModel {
  final String id;
  final String hostelId;
  final String studentName;
  final String phone;

  final String? userId;

  final String roomId;
  final String roomNumber;
  final int seater;
  final String bed;
  final DateTime checkInDate;
  final int durationMonths;
  final BookingStatus status;

  final String? studentId;

  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    required this.hostelId,
    required this.studentName,
    required this.phone,
    this.userId,
    required this.roomId,
    required this.roomNumber,
    required this.seater,
    required this.bed,
    required this.checkInDate,
    required this.durationMonths,
    this.status = BookingStatus.pending,
    this.studentId,
    this.createdAt,
  });

  bool get isPending => status == BookingStatus.pending;

  String get durationText =>
      '$durationMonths month${durationMonths == 1 ? '' : 's'}';

  static DateTime? _date(dynamic v) => v is Timestamp ? v.toDate() : null;

  factory BookingModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) =>
      BookingModel.fromJson(doc.data() ?? {}, id: doc.id);

  factory BookingModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return BookingModel(
      id: id ?? json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      studentName: json['studentName'] ?? '',
      phone: json['phone'] ?? '',
      userId: json['userId'],
      roomId: json['roomId'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      seater: (json['seater'] as num?)?.toInt() ?? 1,
      bed: json['bed'] ?? '',
      checkInDate: _date(json['checkInDate']) ?? DateTime.now(),
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 1,
      status: BookingStatus.fromString(json['status']),
      studentId: json['studentId'],
      createdAt: _date(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'hostelId': hostelId,
    'studentName': studentName,
    'phone': phone,
    'userId': userId,
    'roomId': roomId,
    'roomNumber': roomNumber,
    'seater': seater,
    'bed': bed,
    'checkInDate': Timestamp.fromDate(checkInDate),
    'durationMonths': durationMonths,
    'status': status.name,
    'studentId': studentId,
  };
}