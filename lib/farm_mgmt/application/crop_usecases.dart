// Use-cases for crop feature
import '../domain/repositories/repositories.dart';
import '../domain/entities/entities.dart';

class GetCrops {
  final CropRepository repository;
  GetCrops(this.repository);

  Future<List<Crop>> execute() async {
    return await repository.getCrops();
  }
}

class AddCrop {
  final CropRepository repository;
  AddCrop(this.repository);

  Future<void> execute(Crop crop) async {
    await repository.addCrop(crop);
  }
}
