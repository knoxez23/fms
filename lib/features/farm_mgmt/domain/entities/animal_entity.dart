import '../value_objects/value_objects.dart';

class AnimalEntity {
  final String? id;
  final AnimalName name;
  final AnimalType type;
  final String? breed;
  final DateTime? birthDate;
  final double? weight;
  final String? notes;

  AnimalEntity({
    this.id,
    required this.name,
    required this.type,
    this.breed,
    this.birthDate,
    this.weight,
    this.notes,
  });

  bool get canBreed {
    if (birthDate == null) return false;
    final ageInMonths = DateTime.now().difference(birthDate!).inDays ~/ 30;
    return ageInMonths >= 8;
  }
}
