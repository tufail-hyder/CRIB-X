import 'package:cloud_firestore/cloud_firestore.dart';

class HostelModel {
  final String id;
  final String adminId;
  final String name;
  final String address;
  final String city;
  final double monthlyPrice;
  final String contactNumber;
  final String email;
  final String description;
  final List<String> images;
  final List<String> amenities;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HostelModel({
    required this.id,
    required this.adminId,
    required this.name,
    this.address = '',
    this.city = '',
    this.monthlyPrice = 0,
    this.contactNumber = '',
    this.email = '',
    this.description = '',
    this.images = const [],
    this.amenities = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory HostelModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) =>
      HostelModel.fromJson(doc.data() ?? {}, id: doc.id);

  factory HostelModel.fromJson(Map<String, dynamic> json, {String? id}) {
    DateTime? date(dynamic v) => v is Timestamp ? v.toDate() : null;
    return HostelModel(
      id: id ?? json['id'] ?? '',
      adminId: json['adminId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble() ?? 0,
      contactNumber: json['contactNumber'] ?? '',
      email: json['email'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: date(json['createdAt']),
      updatedAt: date(json['updatedAt']),
    );
  }

  /// Sirf wo fields jo admin edit karta hai (adminId, createdAt nahi badlte)
  Map<String, dynamic> toUpdateJson() => {
    'name': name,
    'address': address,
    'city': city,
    'monthlyPrice': monthlyPrice,
    'contactNumber': contactNumber,
    'email': email,
    'description': description,
    'images': images,
    'amenities': amenities,
    'updatedAt': Timestamp.now(),
  };

  HostelModel copyWith({
    String? name,
    String? address,
    String? city,
    double? monthlyPrice,
    String? contactNumber,
    String? email,
    String? description,
    List<String>? images,
    List<String>? amenities,
  }) {
    return HostelModel(
      id: id,
      adminId: adminId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      description: description ?? this.description,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}