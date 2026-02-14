import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/core/domain/events/domain_event_bus.dart';

import 'package:pamoja_twalima/farm_mgmt/application/breeding_usecases.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/breeding_record_entity.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/repositories/breeding_repository.dart';
import 'package:pamoja_twalima/farm_mgmt/presentation/bloc/breeding/breeding_cubit.dart';

class InMemoryBreedingRepository implements BreedingRepository {
  final List<BreedingRecordEntity> _items = [];

  @override
  Future<BreedingRecordEntity> addRecord(BreedingRecordEntity record) async {
    final entity = BreedingRecordEntity(
      id: (_items.length + 1).toString(),
      damAnimalId: record.damAnimalId,
      sireAnimalId: record.sireAnimalId,
      matingDate: record.matingDate,
      expectedBirthDate: record.expectedBirthDate,
      status: record.status,
      method: record.method,
      success: record.success,
      vet: record.vet,
      notes: record.notes,
    );
    _items.insert(0, entity);
    return entity;
  }

  @override
  Future<void> deleteRecord(String id) async {
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<BreedingRecordEntity>> getRecords() async => List.of(_items);
}

void main() {
  test('BreedingCubit load/add/delete updates state', () async {
    final repo = InMemoryBreedingRepository();
    final cubit = BreedingCubit(
      GetBreedingRecords(repo),
      AddBreedingRecord(repo, DomainEventBus()),
      DeleteBreedingRecord(repo),
    );

    await cubit.load();
    expect(cubit.state.records, isEmpty);

    await cubit.add(
      BreedingRecordEntity(
        damAnimalId: '1',
        matingDate: DateTime(2026, 2, 13),
        expectedBirthDate: DateTime(2026, 11, 20),
        status: 'scheduled',
      ),
    );
    expect(cubit.state.records, hasLength(1));

    await cubit.delete(cubit.state.records.first.id!);
    expect(cubit.state.records, isEmpty);
  });
}
