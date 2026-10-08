import 'package:cloud_firestore/cloud_firestore.dart';

enum RoomStatus {
  available,
  occupied,
  reserved;

  String get label => name[0].toUpperCase() + name.substring(1);

  static RoomStatus fromString(String? value) => RoomStatus.values.firstWhere(
        (e) => e.name == value,
    orElse: () => RoomStatus.available,
  );
}

class RoomModel {
  final String id;
  final String hostelId;
  final String roomNumber;
  final int seater;
  final int totalBeds;
  final int occupiedBeds;
  final double monthlyPrice;

  final RoomStatus status;
  final DateTime? createdAt;

  const RoomModel({
    required this.id,
    required this.hostelId,
    required this.roomNumber,
    required this.seater,
    required this.totalBeds,
    this.occupiedBeds = 0,
    required this.monthlyPrice,
    this.status = RoomStatus.available,
    this.createdAt,
  });

  factory RoomModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) =>
      RoomModel.fromJson(doc.data() ?? {}, id: doc.id);

  factory RoomModel.fromJson(Map<String, dynamic> json, {String? id}) {
    final created = json['createdAt'];
    return RoomModel(
      id: id ?? json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      seater: (json['seater'] as num?)?.toInt() ?? 1,
      totalBeds: (json['totalBeds'] as num?)?.toInt() ?? 1,
      occupiedBeds: (json['occupiedBeds'] as num?)?.toInt() ?? 0,
      monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble() ?? 0,
      status: RoomStatus.fromString(json['status']),
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'hostelId': hostelId,
    'roomNumber': roomNumber,
    'seater': seater,
    'totalBeds': totalBeds,
    'occupiedBeds': occupiedBeds,
    'monthlyPrice': monthlyPrice,
    'status': status.name,
    'updatedAt': Timestamp.now(),
  };

  RoomStatus get displayStatus {
    if (status == RoomStatus.reserved) return RoomStatus.reserved;
    return occupiedBeds >= totalBeds ? RoomStatus.occupied : RoomStatus.available;
  }

  int get availableBeds => status == RoomStatus.reserved
      ? 0
      : (totalBeds - occupiedBeds).clamp(0, totalBeds).toInt();
}