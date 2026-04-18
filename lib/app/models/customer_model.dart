import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/firestore/firestore_fields.dart';

class CustomerModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String nic;
  final String email;
  final String notes;
  final DateTime? createdAt;
  final String? imageUrl;

  // Rental Statistics
  final int rentalsCount;
  final DateTime? lastRentalDate;
  final double rating;
  final int ratingCount;

  const CustomerModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.nic,
    required this.email,
    required this.notes,
    this.createdAt,
    this.imageUrl,
    this.rentalsCount = 0,
    this.lastRentalDate,
    this.rating = 0.0,
    this.ratingCount = 0,
  });

  /// Full name helper
  String get fullName => '$firstName $lastName'.trim();

  /// Average Rating
  double get averageRating => ratingCount > 0 ? rating / ratingCount : 0.0;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json[FirestoreFields.id],
      firstName: json[FirestoreFields.firstName] ?? '',
      lastName: json[FirestoreFields.lastName] ?? '',
      phone: json[FirestoreFields.phone] ?? '',
      nic: json[FirestoreFields.nic] ?? '',
      email: json[FirestoreFields.email] ?? '',
      notes: json[FirestoreFields.notes] ?? '',
      createdAt: json[FirestoreFields.createdAt] is Timestamp
          ? (json[FirestoreFields.createdAt] as Timestamp).toDate()
          : null,
      imageUrl: json[FirestoreFields.imageUrl],
      rentalsCount: (json[FirestoreFields.rentalsCount] as num?)?.toInt() ?? 0,
      lastRentalDate: json[FirestoreFields.lastRentalDate] is Timestamp
          ? (json[FirestoreFields.lastRentalDate] as Timestamp).toDate()
          : null,
      rating: (json[FirestoreFields.rating] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json[FirestoreFields.ratingCount] as num?)?.toInt() ?? 0,
    );
  }

  factory CustomerModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return CustomerModel(
      id: doc.id,
      firstName: data[FirestoreFields.firstName] ?? '',
      lastName: data[FirestoreFields.lastName] ?? '',
      phone: data[FirestoreFields.phone] ?? '',
      nic: data[FirestoreFields.nic] ?? '',
      email: data[FirestoreFields.email] ?? '',
      notes: data[FirestoreFields.notes] ?? '',
      createdAt: data[FirestoreFields.createdAt] is Timestamp
          ? (data[FirestoreFields.createdAt] as Timestamp).toDate()
          : null,
      imageUrl: data[FirestoreFields.imageUrl],
      rentalsCount: (data[FirestoreFields.rentalsCount] as num?)?.toInt() ?? 0,
      lastRentalDate: data[FirestoreFields.lastRentalDate] is Timestamp
          ? (data[FirestoreFields.lastRentalDate] as Timestamp).toDate()
          : null,
      rating: (data[FirestoreFields.rating] as num?)?.toDouble() ?? 0.0,
      ratingCount: (data[FirestoreFields.ratingCount] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.id: id,
      FirestoreFields.firstName: firstName,
      FirestoreFields.lastName: lastName,
      FirestoreFields.phone: phone,
      FirestoreFields.nic: nic,
      FirestoreFields.email: email,
      FirestoreFields.notes: notes,
      FirestoreFields.createdAt: createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : null,
      FirestoreFields.imageUrl: imageUrl ?? '',
      FirestoreFields.nameLowercase: "$firstName $lastName".toLowerCase(),
      FirestoreFields.rentalsCount: rentalsCount,
      FirestoreFields.lastRentalDate: lastRentalDate != null
          ? Timestamp.fromDate(lastRentalDate!)
          : null,
      FirestoreFields.rating: rating,
      FirestoreFields.ratingCount: ratingCount,
    };
  }

  /// CopyWith method for immutable updates
  CustomerModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? nic,
    String? email,
    String? notes,
    DateTime? createdAt,
    String? imageUrl,
    int? rentalsCount,
    DateTime? lastRentalDate,
    double? rating,
    int? ratingCount,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      nic: nic ?? this.nic,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      rentalsCount: rentalsCount ?? this.rentalsCount,
      lastRentalDate: lastRentalDate ?? this.lastRentalDate,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}
