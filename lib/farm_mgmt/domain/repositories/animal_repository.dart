import '../entities/animal_entity.dart';

abstract class AnimalRepository {
  Future<List<AnimalEntity>> getAnimals();
  Future<AnimalEntity> addAnimal(AnimalEntity animal);
  Future<AnimalEntity> updateAnimal(AnimalEntity animal);
  Future<void> deleteAnimal(String id);
}
