import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/animal_aggregate.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/animal_entity.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/value_objects/value_objects.dart';

void main() {
  test('rejects future birth date', () {
    expect(
      () => AnimalAggregate(
        AnimalEntity(
          name: AnimalName('Bella'),
          type: AnimalType('cattle'),
          birthDate: DateTime.now().add(const Duration(days: 1)),
        ),
      ),
      throwsArgumentError,
    );
  });

  test('canBreedAt honors cattle threshold', () {
    final birthDate = DateTime(2024, 1, 1);
    final aggregate = AnimalAggregate(
      AnimalEntity(
        name: AnimalName('Bella'),
        type: AnimalType('cattle'),
        birthDate: birthDate,
      ),
    );

    expect(aggregate.canBreedAt(DateTime(2025, 2, 1)), isFalse);
    expect(aggregate.canBreedAt(DateTime(2025, 5, 1)), isTrue);
  });

  test('recordWeight returns updated entity with valid weight', () {
    final aggregate = AnimalAggregate(
      AnimalEntity(
        id: '1',
        name: AnimalName('Nia'),
        type: AnimalType('goat'),
        weight: 25.0,
      ),
    );

    final updated = aggregate.recordWeight(27.5);

    expect(updated.id, '1');
    expect(updated.weight, 27.5);
    expect(updated.name.value, 'Nia');
  });
}
