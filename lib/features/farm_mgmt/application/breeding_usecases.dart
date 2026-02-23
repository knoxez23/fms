import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/core/domain/events/domain_event_bus.dart';
import '../domain/entities/breeding_record_entity.dart';
import '../domain/events/farm_domain_events.dart';
import '../domain/repositories/breeding_repository.dart';

@lazySingleton
class GetBreedingRecords {
  final BreedingRepository repository;
  GetBreedingRecords(this.repository);

  Future<List<BreedingRecordEntity>> execute() => repository.getRecords();
}

@lazySingleton
class AddBreedingRecord {
  final BreedingRepository repository;
  final DomainEventBus _eventBus;

  AddBreedingRecord(this.repository, this._eventBus);

  Future<BreedingRecordEntity> execute(BreedingRecordEntity record) async {
    final created = await repository.addRecord(record);
    _eventBus.publish(
      AnimalBred(
        damAnimalId: created.damAnimalId,
        sireAnimalId: created.sireAnimalId,
        expectedBirthDate: created.expectedBirthDate,
      ),
    );
    return created;
  }
}

@lazySingleton
class DeleteBreedingRecord {
  final BreedingRepository repository;
  DeleteBreedingRecord(this.repository);

  Future<void> execute(String id) => repository.deleteRecord(id);
}
