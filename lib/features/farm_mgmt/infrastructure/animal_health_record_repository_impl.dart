import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/data/models/animal_health_record.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import '../domain/entities/animal_health_record_entity.dart';
import '../domain/repositories/animal_health_record_repository.dart';

@LazySingleton(as: AnimalHealthRecordRepository)
class AnimalHealthRecordRepositoryImpl implements AnimalHealthRecordRepository {
  final SyncData _syncData;

  AnimalHealthRecordRepositoryImpl(this._syncData);

  @override
  Future<int> addRecord(AnimalHealthRecordEntity record) async {
    return _syncData.insertAnimalHealthRecord(_toModel(record));
  }

  @override
  Future<int> deleteRecord(int id) async {
    return _syncData.deleteAnimalHealthRecord(id);
  }

  @override
  Future<List<AnimalHealthRecordEntity>> getRecords() async {
    final rows = await _syncData.getAnimalHealthRecords();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<int> updateRecord(AnimalHealthRecordEntity record) async {
    return _syncData.updateAnimalHealthRecord(_toModel(record));
  }

  AnimalHealthRecord _toModel(AnimalHealthRecordEntity entity) {
    return AnimalHealthRecord(
      id: entity.id,
      animalId: entity.animalId,
      type: entity.type,
      name: entity.name,
      notes: entity.notes,
      treatedAt: entity.treatedAt?.toIso8601String(),
    );
  }

  AnimalHealthRecordEntity _toEntity(AnimalHealthRecord model) {
    return AnimalHealthRecordEntity(
      id: model.id,
      animalId: model.animalId,
      type: model.type,
      name: model.name,
      notes: model.notes,
      treatedAt:
          model.treatedAt == null ? null : DateTime.tryParse(model.treatedAt!),
    );
  }
}
