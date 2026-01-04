import '../domain/repositories/animal_repository.dart';
import '../domain/entities/entities.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';

class AnimalRepositoryImpl implements AnimalRepository {
  // This implementation uses LocalData (SQLite) for animal data
  AnimalRepositoryImpl();

  @override
  Future<void> addAnimal(Animal animal) async {
    await LocalData.insertAnimal(animal);
  }

  @override
  Future<void> deleteAnimal(int id) async {
    await LocalData.deleteAnimal(id);
  }

  @override
  Future<List<Animal>> getAnimals() async {
    return await LocalData.getAnimals();
  }

  @override
  Future<void> updateAnimal(Animal animal) async {
    await LocalData.updateAnimal(animal);
  }
}

