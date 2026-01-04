import '../entities/entities.dart';

abstract class AnimalRepository {
  Future<List<Animal>> getAnimals();
  Future<void> addAnimal(Animal animal);
  Future<void> updateAnimal(Animal animal);
  Future<void> deleteAnimal(int id);
}
