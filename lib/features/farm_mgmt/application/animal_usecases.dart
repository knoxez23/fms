// Use-cases for animal feature
import 'package:injectable/injectable.dart';
import '../domain/repositories/repositories.dart';
import '../domain/entities/animal_entity.dart';

@lazySingleton
class GetAnimals {
  final AnimalRepository repository;
  GetAnimals(this.repository);

  Future<List<AnimalEntity>> execute() async => await repository.getAnimals();
}

@lazySingleton
class AddAnimal {
  final AnimalRepository repository;
  AddAnimal(this.repository);

  Future<AnimalEntity> execute(AnimalEntity animal) async =>
      await repository.addAnimal(animal);
}

@lazySingleton
class UpdateAnimal {
  final AnimalRepository repository;
  UpdateAnimal(this.repository);

  Future<AnimalEntity> execute(AnimalEntity animal) async =>
      await repository.updateAnimal(animal);
}

@lazySingleton
class DeleteAnimal {
  final AnimalRepository repository;
  DeleteAnimal(this.repository);

  Future<void> execute(String id) async => await repository.deleteAnimal(id);
}
