import '../entities/entities.dart';

abstract class CropRepository {
  Future<List<Crop>> getCrops();
  Future<void> addCrop(Crop crop);
  Future<void> updateCrop(Crop crop);
  Future<void> deleteCrop(int id);
}
