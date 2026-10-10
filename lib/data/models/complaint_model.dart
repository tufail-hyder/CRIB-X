import 'package:cloud_firestore/cloud_firestore.dart';

enum ComplaintStatus {
  open,
  inProgress,
  resolved;

  String get label {
    switch (this) {
      case ComplaintStatus.open:
        return 'Open';
      case ComplaintStatus.inProgress:
        return 'In Progress';
      case ComplaintStatus.resolved:
        return 'Resolved';
    }
  }

  static ComplaintStatus fromString(String? value) {
    return ComplaintStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => ComplaintStatus.open,
    );
  }
}

enum ComplaintCategory {
  maintenance,
  wifi,
  food,
  water,
  electricity,
  cleanliness,
  security,
  other;

  String get label {
    switch (this) {
      case ComplaintCategory.wifi:
        return 'WiFi';
      case ComplaintCategory.cleanliness:
        return 'Cleaning';
      default:
        return name[0].toUpperCase() + name.substring(1);
    }
  }

  static ComplaintCategory fromString(String? value) {
    return ComplaintCategory.values.firstWhere(
          (e) => e.name == value,
      orElse: () => ComplaintCategory.other,
    );
  }
}

enum ComplaintPriority {
  low,
  medium,
  high;

  String get label => name[0].toUpperCase() + name.substring(1);

  static ComplaintPriority fromString(String? value) {
    return ComplaintPriority.values.firstWhere(
          (e) => e.name == value,
      orElse: () => ComplaintPriority.medium,
    );
  }
}

class ComplaintModel {
  final String id;
  final String hostelId;
  final String studentId;
  final String studentName;
  final String roomNumber;
  final String title;
  final String description;
  final ComplaintCategory category;
  final ComplaintPriority priority;
  final ComplaintStatus status;
  final List<String> images;
  final String? adminResponse;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  const ComplaintModel({
    required this.id,
    required this.hostelId,
    required this.studentId,
    required this.studentName,
    required this.roomNumber,
    required this.title,
    required this.description,
    this.category = ComplaintCategory.other,
    this.priority = ComplaintPriority.medium,
    this.status = ComplaintStatus.open,
    this.images = const [],
    this.adminResponse,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
  });

  /// Naya khali model (form ke liye)
  factory ComplaintModel.empty() => ComplaintModel(
    id: '',
    hostelId: '',
    studentId: '',
    studentName: '',
    roomNumber: '',
    title: '',
    description: '',
    createdAt: DateTime.now(),
  );

  /// Firestore document se model
  factory ComplaintModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ComplaintModel.fromJson(data, id: doc.id);
  }

  factory ComplaintModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ComplaintModel(
      id: id ?? json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: ComplaintCategory.fromString(json['category']),
      priority: ComplaintPriority.fromString(json['priority']),
      status: ComplaintStatus.fromString(json['status']),
      images: List<String>.from(json['images'] ?? []),
      adminResponse: json['adminResponse'],
      createdAt: _toDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _toDate(json['updatedAt']),
      resolvedAt: _toDate(json['resolvedAt']),
    );
  }

  /// Firestore me save karne ke liye (id document ka naam hota hai, isliye nahi)
  Map<String, dynamic> toJson() {
    return {
      'hostelId': hostelId,
      'studentId': studentId,
      'studentName': studentName,
      'roomNumber': roomNumber,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'images': images,
      'adminResponse': adminResponse,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  ComplaintModel copyWith({
    String? id,
    String? hostelId,
    String? studentId,
    String? studentName,
    String? roomNumber,
    String? title,
    String? description,
    ComplaintCategory? category,
    ComplaintPriority? priority,
    ComplaintStatus? status,
    List<String>? images,
    String? adminResponse,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      hostelId: hostelId ?? this.hostelId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      roomNumber: roomNumber ?? this.roomNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      images: images ?? this.images,
      adminResponse: adminResponse ?? this.adminResponse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  bool get isOpen => status == ComplaintStatus.open;
  bool get isInProgress => status == ComplaintStatus.inProgress;
  bool get isResolved => status == ComplaintStatus.resolved;

  String get shortId =>
      '#${(id.length >= 6 ? id.substring(0, 6) : id).toUpperCase()}';

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}