import '../entities/animal_health_record_entity.dart';

abstract class AnimalHealthRecordRepository {
  Future<List<AnimalHealthRecordEntity>> getRecords();
  Future<int> addRecord(AnimalHealthRecordEntity record);
  Future<int> updateRecord(AnimalHealthRecordEntity record);
  Future<int> deleteRecord(int id);
}
