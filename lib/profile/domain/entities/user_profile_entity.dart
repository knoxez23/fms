import '../value_objects/value_objects.dart';

class UserProfileEntity {
  final String? id;
  final String name;
  final PhoneNumber? phone;
  final String? location;

  UserProfileEntity({
    this.id,
    required this.name,
    this.phone,
    this.location,
  });
}
