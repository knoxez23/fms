import '../application/application.dart';
import '../domain/repositories/repositories.dart';
import 'infrastructure.dart';

class FarmMgmtFactory {
  // Repositories
  static CropRepository createCropRepository() => CropRepositoryImpl();
  static AnimalRepository createAnimalRepository() => AnimalRepositoryImpl();
  static TaskRepository createTaskRepository() => TaskRepositoryImpl();

  // Use-cases
  static GetCrops createGetCrops() => GetCrops(createCropRepository());
  static AddCrop createAddCrop() => AddCrop(createCropRepository());

  static GetAnimals createGetAnimals() => GetAnimals(createAnimalRepository());
  static AddAnimal createAddAnimal() => AddAnimal(createAnimalRepository());

  static GetTasks createGetTasks() => GetTasks(createTaskRepository());
  static AddTask createAddTask() => AddTask(createTaskRepository());

  static GetOverview createGetOverview() => GetOverview();
}
