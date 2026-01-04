// Use-cases for animal feature
import '../domain/repositories/repositories.dart';
import '../domain/entities/entities.dart';

class GetAnimals {
  final AnimalRepository repository;
  GetAnimals(this.repository);

  Future<List<Animal>> execute() async => await repository.getAnimals();
}

class AddAnimal {
  final AnimalRepository repository;
  AddAnimal(this.repository);

  Future<void> execute(Animal animal) async => await repository.addAnimal(animal);
}
