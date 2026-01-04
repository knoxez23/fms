class User {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? farmName;
  final String? location;
  final String? createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.farmName,
    this.location,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'farm_name': farmName,
      'location': location,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      farmName: map['farm_name'],
      location: map['location'],
      createdAt: map['created_at'],
    );
  }
}