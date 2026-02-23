import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/features/farm_mgmt/application/animal_health_record_usecases.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/animal_health_record_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/repositories/animal_health_record_repository.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/animal_health/animal_health_records_cubit.dart';

class InMemoryAnimalHealthRecordRepository
    implements AnimalHealthRecordRepository {
  final List<AnimalHealthRecordEntity> _items = [];

  @override
  Future<int> addRecord(AnimalHealthRecordEntity record) async {
    final id = _items.length + 1;
    _items.insert(
      0,
      AnimalHealthRecordEntity(
        id: id,
        animalId: record.animalId,
        type: record.type,
        name: record.name,
        notes: record.notes,
        treatedAt: record.treatedAt,
      ),
    );
    return id;
  }

  @override
  Future<int> deleteRecord(int id) async {
    _items.removeWhere((e) => e.id == id);
    return 1;
  }

  @override
  Future<List<AnimalHealthRecordEntity>> getRecords() async => List.of(_items);

  @override
  Future<int> updateRecord(AnimalHealthRecordEntity record) async {
    final index = _items.indexWhere((e) => e.id == record.id);
    if (index >= 0) {
      _items[index] = record;
    }
    return 1;
  }
}

void main() {
  test('AnimalHealthRecordsCubit load/add/update/delete updates state',
      () async {
    final repo = InMemoryAnimalHealthRecordRepository();
    final cubit = AnimalHealthRecordsCubit(
      GetAnimalHealthRecords(repo),
      AddAnimalHealthRecord(repo),
      UpdateAnimalHealthRecord(repo),
      DeleteAnimalHealthRecord(repo),
    );

    await cubit.load();
    expect(cubit.state.records, isEmpty);

    await cubit.add(
      AnimalHealthRecordEntity(
        animalId: 1,
        type: 'checkup',
        name: 'Initial exam',
        treatedAt: DateTime(2026, 2, 20),
      ),
    );
    expect(cubit.state.records, hasLength(1));

    final first = cubit.state.records.first;
    await cubit.update(
      AnimalHealthRecordEntity(
        id: first.id,
        animalId: first.animalId,
        type: 'treatment',
        name: 'Updated exam',
        treatedAt: first.treatedAt,
      ),
    );
    expect(cubit.state.records.first.type, equals('treatment'));

    await cubit.delete(cubit.state.records.first.id!);
    expect(cubit.state.records, isEmpty);
  });
}
