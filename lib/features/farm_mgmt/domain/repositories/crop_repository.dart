import '../entities/crop_entity.dart';

abstract class CropRepository {
  Future<List<CropEntity>> getCrops();
  Future<CropEntity> addCrop(CropEntity crop);
  Future<CropEntity> updateCrop(CropEntity crop);
  Future<void> deleteCrop(String id);
}
