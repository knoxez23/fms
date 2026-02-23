import 'package:injectable/injectable.dart';
import '../domain/entities/animal_health_record_entity.dart';
import '../domain/repositories/animal_health_record_repository.dart';

@lazySingleton
class GetAnimalHealthRecords {
  final AnimalHealthRecordRepository repository;
  GetAnimalHealthRecords(this.repository);

  Future<List<AnimalHealthRecordEntity>> execute() async {
    return repository.getRecords();
  }
}

@lazySingleton
class AddAnimalHealthRecord {
  final AnimalHealthRecordRepository repository;
  AddAnimalHealthRecord(this.repository);

  Future<int> execute(AnimalHealthRecordEntity record) async {
    return repository.addRecord(record);
  }
}

@lazySingleton
class UpdateAnimalHealthRecord {
  final AnimalHealthRecordRepository repository;
  UpdateAnimalHealthRecord(this.repository);

  Future<int> execute(AnimalHealthRecordEntity record) async {
    return repository.updateRecord(record);
  }
}

@lazySingleton
class DeleteAnimalHealthRecord {
  final AnimalHealthRecordRepository repository;
  DeleteAnimalHealthRecord(this.repository);

  Future<int> execute(int id) async {
    return repository.deleteRecord(id);
  }
}
