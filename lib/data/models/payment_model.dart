import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMethod {
  cash,
  bankTransfer,
  easypaisa,
  jazzcash;

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.easypaisa:
        return 'EasyPaisa';
      case PaymentMethod.jazzcash:
        return 'JazzCash';
    }
  }

  static PaymentMethod fromString(String? v) => PaymentMethod.values
      .firstWhere((e) => e.name == v, orElse: () => PaymentMethod.cash);
}

class PaymentModel {
  final String id;
  final String hostelId;
  final String studentId;
  final String studentName; // display ke liye copy
  final String roomNumber; // display ke liye copy
  final double amount;
  final PaymentMethod method;

  /// Kis mahine ki fees: 'yyyy-MM' (e.g. '2026-10')
  final String forMonth;
  final String? note;

  /// Paisa kab mila (revenue chart isi se banta hai)
  final DateTime paidAt;
  final DateTime? createdAt;

  const PaymentModel({
    required this.id,
    required this.hostelId,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.amount,
    this.method = PaymentMethod.cash,
    required this.forMonth,
    this.note,
    required this.paidAt,
    this.createdAt,
  });

  static String monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  static DateTime? _date(dynamic v) => v is Timestamp ? v.toDate() : null;

  factory PaymentModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) =>
      PaymentModel.fromJson(doc.data() ?? {}, id: doc.id);

  factory PaymentModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return PaymentModel(
      id: id ?? json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      method: PaymentMethod.fromString(json['method']),
      forMonth: json['forMonth'] ?? '',
      note: json['note'],
      paidAt: _date(json['paidAt']) ?? DateTime.now(),
      createdAt: _date(json['createdAt']),
    );
  }

  /// createdAt repository lagata hai
  Map<String, dynamic> toJson() => {
    'hostelId': hostelId,
    'studentId': studentId,
    'studentName': studentName,
    'roomNumber': roomNumber,
    'amount': amount,
    'method': method.name,
    'forMonth': forMonth,
    'note': note,
    'paidAt': Timestamp.fromDate(paidAt),
  };
}