class CustomerModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String nic;
  final String email;
  final String notes;
  final String? createdAt;
  final String? imageUrl;

  CustomerModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.nic,
    required this.email,
    required this.notes,
    this.createdAt,
    this.imageUrl,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      nic: json['nic'] ?? '',
      email: json['email'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: json['created_at'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'nic': nic,
      'email': email,
      'notes': notes,
      'created_at': createdAt,
      'image_url': imageUrl ?? '',
    };
  }
}
