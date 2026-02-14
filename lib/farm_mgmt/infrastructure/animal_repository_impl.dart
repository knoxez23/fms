import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/data/models/animal.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import '../domain/repositories/animal_repository.dart';
import '../domain/entities/animal_entity.dart';
import '../domain/value_objects/value_objects.dart';

@LazySingleton(as: AnimalRepository)
class AnimalRepositoryImpl implements AnimalRepository {
  final SyncData _syncData;

  AnimalRepositoryImpl(this._syncData);

  @override
  Future<AnimalEntity> addAnimal(AnimalEntity animal) async {
    final model = _mapToModel(animal);
    final id = await _syncData.insertAnimal(model);
    return _withId(animal, id.toString());
  }

  @override
  Future<void> deleteAnimal(String id) async {
    final parsed = int.tryParse(id);
    if (parsed == null) return;
    await _syncData.deleteAnimal(parsed);
  }

  @override
  Future<List<AnimalEntity>> getAnimals() async {
    final rows = await _syncData.getAnimals();
    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<AnimalEntity> updateAnimal(AnimalEntity animal) async {
    final model = _mapToModel(animal);
    await _syncData.updateAnimal(model);
    return animal;
  }

  AnimalEntity _mapToEntity(Animal model) {
    return AnimalEntity(
      id: model.id?.toString(),
      name: AnimalName(model.name),
      type: AnimalType(model.type),
      breed: model.breed,
      birthDate: null,
      weight: model.weight,
    );
  }

  Animal _mapToModel(AnimalEntity entity) {
    return Animal(
      id: entity.id != null ? int.tryParse(entity.id!) : null,
      name: entity.name.value,
      type: entity.type.value,
      breed: entity.breed,
      weight: entity.weight,
      age: entity.birthDate == null
          ? null
          : (DateTime.now().difference(entity.birthDate!).inDays ~/ 365),
      healthStatus: null,
      dateAcquired: null,
      notes: null,
      userId: null,
    );
  }

  AnimalEntity _withId(AnimalEntity entity, String id) {
    return AnimalEntity(
      id: id,
      name: entity.name,
      type: entity.type,
      breed: entity.breed,
      birthDate: entity.birthDate,
      weight: entity.weight,
    );
  }
}
