import '../entities/breeding_record_entity.dart';

abstract class BreedingRepository {
  Future<List<BreedingRecordEntity>> getRecords();
  Future<BreedingRecordEntity> addRecord(BreedingRecordEntity record);
  Future<void> deleteRecord(String id);
}
