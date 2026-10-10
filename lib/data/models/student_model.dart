import 'dart:math' as math;
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
  /// Har mahine ki is tareekh tak fees do. Iske baad unpaid = Overdue.
  /// (Baad me hostel settings se aa sakta hai.)
  static const dueDay = 10;

  final String id;
  final String hostelId;
  final String name;
  final String phone;
  final String? cnic;
  final String? photoUrl;

  /// null = walk-in student (abhi app account nahi). Baad me phone se jorenge.
  final String? userId;

  final String roomId;
  final String roomNumber; // display ke liye copy
  final String bed; // A1, A2...
  final DateTime checkInDate;
  final DateTime? checkOutDate;
  final StayStatus stayStatus;
  final DateTime? createdAt;

  /// Is student ki mahana fees (room ki price se shuru hoti hai)
  final double monthlyFee;

  /// Har mahine me ab tak kitna diya: {'2026-10': 5000, '2026-11': 15000}
  final Map<String, double> paidByMonth;

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
    this.stayStatus = StayStatus.active,
    this.createdAt,
    this.monthlyFee = 0,
    this.paidByMonth = const {},
  });

  bool get isActive => stayStatus == StayStatus.active;

  static String monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  double paidFor(String monthKey) => paidByMonth[monthKey] ?? 0;

  double remainingFor(String monthKey) =>
      monthlyFee > 0 ? math.max(0.0, monthlyFee - paidFor(monthKey)) : 0;

  /// Status hamesha payments se nikalta hai (manual flag nahi), isliye
  /// naya mahina shuru hote hi khud reset ho jata hai.
  ///  - Paid: is mahine ki poori fees di
  ///  - Pending: poori nahi di (ya kuch bhi nahi) aur due date nahi guzri
  ///  - Due (Overdue): due date guzar gayi aur poori fees nahi mili
  PaymentStatus statusAt(DateTime now) {
    final paid = paidFor(monthKey(now));
    final fullyPaid = monthlyFee > 0 ? paid >= monthlyFee : paid > 0;
    if (fullyPaid) return PaymentStatus.paid;

    // Abhi aaya hi nahi (future check-in) to overdue nahi
    if (checkInDate.isAfter(now)) return PaymentStatus.pending;

    var due = DateTime(now.year, now.month, dueDay);
    // Is mahine aaya hai to kam az kam 7 din ki mohlat
    if (checkInDate.year == now.year && checkInDate.month == now.month) {
      final grace = checkInDate.add(const Duration(days: 7));
      if (grace.isAfter(due)) due = grace;
    }
    return now.isAfter(due) ? PaymentStatus.due : PaymentStatus.pending;
  }

  PaymentStatus get paymentStatus => statusAt(DateTime.now());

  static DateTime? _date(dynamic v) => v is Timestamp ? v.toDate() : null;

  factory StudentModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) =>
      StudentModel.fromJson(doc.data() ?? {}, id: doc.id);

  factory StudentModel.fromJson(Map<String, dynamic> json, {String? id}) {
    final paid = <String, double>{};
    final raw = json['paidByMonth'];
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v is num) paid[k.toString()] = v.toDouble();
      });
    }

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
      stayStatus: StayStatus.fromString(json['stayStatus']),
      createdAt: _date(json['createdAt']),
      monthlyFee: (json['monthlyFee'] as num?)?.toDouble() ?? 0,
      paidByMonth: paid,
    );
  }

  /// createdAt repository lagata hai
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
    'stayStatus': stayStatus.name,
    'monthlyFee': monthlyFee,
    'paidByMonth': paidByMonth,
  };
}