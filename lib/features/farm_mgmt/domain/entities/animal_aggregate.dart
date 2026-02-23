import 'animal_entity.dart';

class AnimalAggregate {
  final AnimalEntity animal;

  AnimalAggregate(this.animal) {
    _validate(animal);
  }

  static const Map<String, int> _breedingAgeInMonths = {
    'cattle': 15,
    'goat': 8,
    'sheep': 8,
    'pig': 7,
    'poultry': 6,
    'other': 8,
  };

  void _validate(AnimalEntity value) {
    if (value.birthDate != null && value.birthDate!.isAfter(DateTime.now())) {
      throw ArgumentError('Animal birth date cannot be in the future');
    }
    if (value.weight != null && value.weight! <= 0) {
      throw ArgumentError('Animal weight must be greater than zero');
    }
  }

  bool canBreedAt(DateTime onDate) {
    final birthDate = animal.birthDate;
    if (birthDate == null || onDate.isBefore(birthDate)) return false;

    final ageInMonths = onDate.difference(birthDate).inDays ~/ 30;
    final minMonths = _breedingAgeInMonths[animal.type.value] ?? 8;
    return ageInMonths >= minMonths;
  }

  AnimalEntity recordWeight(double newWeight) {
    if (newWeight <= 0) {
      throw ArgumentError('Recorded weight must be greater than zero');
    }
    return AnimalEntity(
      id: animal.id,
      name: animal.name,
      type: animal.type,
      breed: animal.breed,
      birthDate: animal.birthDate,
      weight: newWeight,
    );
  }
}
