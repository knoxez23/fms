import '../value_objects/value_objects.dart';

class UserEntity {
  final int? id;
  final String name;
  final EmailAddress email;
  final String? phone;
  final String? farmName;
  final String? location;

  UserEntity({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.farmName,
    this.location,
  });
}
