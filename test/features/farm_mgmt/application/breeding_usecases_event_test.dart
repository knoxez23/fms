import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/core/domain/events/domain_event_bus.dart';
import 'package:pamoja_twalima/farm_mgmt/application/breeding_usecases.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/breeding_record_entity.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/events/farm_domain_events.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/repositories/breeding_repository.dart';

class _FakeBreedingRepository implements BreedingRepository {
  @override
  Future<BreedingRecordEntity> addRecord(BreedingRecordEntity record) async =>
      BreedingRecordEntity(
        id: '1',
        damAnimalId: record.damAnimalId,
        sireAnimalId: record.sireAnimalId,
        matingDate: record.matingDate,
        expectedBirthDate: record.expectedBirthDate,
      );

  @override
  Future<void> deleteRecord(String id) async {}

  @override
  Future<List<BreedingRecordEntity>> getRecords() async => const [];
}

void main() {
  test('AddBreedingRecord publishes AnimalBred event', () async {
    final bus = DomainEventBus();
    final useCase = AddBreedingRecord(_FakeBreedingRepository(), bus);

    final futureEvent = bus.on<AnimalBred>().first;

    await useCase.execute(
      BreedingRecordEntity(
        damAnimalId: 'dam-1',
        sireAnimalId: 'sire-1',
        matingDate: DateTime(2026, 2, 1),
        expectedBirthDate: DateTime(2026, 11, 1),
      ),
    );

    final event = await futureEvent;
    expect(event.damAnimalId, 'dam-1');
    expect(event.sireAnimalId, 'sire-1');
  });
}
