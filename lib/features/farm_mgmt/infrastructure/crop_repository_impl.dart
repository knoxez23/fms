import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/data/models/crop.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import '../domain/repositories/crop_repository.dart';
import '../domain/entities/crop_entity.dart';
import '../domain/value_objects/value_objects.dart';

@LazySingleton(as: CropRepository)
class CropRepositoryImpl implements CropRepository {
  final SyncData _syncData;

  CropRepositoryImpl(this._syncData);

  @override
  Future<CropEntity> addCrop(CropEntity crop) async {
    final model = _mapToModel(crop);
    final id = await _syncData.insertCrop(model);
    final created = Crop(
      id: id,
      name: model.name,
      variety: model.variety,
      plantedDate: model.plantedDate,
      expectedHarvestDate: model.expectedHarvestDate,
      area: model.area,
      status: model.status,
      notes: model.notes,
    );
    return _mapToEntity(created);
  }

  @override
  Future<void> deleteCrop(String id) async {
    final parsed = int.tryParse(id);
    if (parsed == null) return;
    await _syncData.deleteCrop(parsed);
  }

  @override
  Future<List<CropEntity>> getCrops() async {
    final crops = await _syncData.getCrops();
    return crops.map(_mapToEntity).toList();
  }

  @override
  Future<CropEntity> updateCrop(CropEntity crop) async {
    final model = _mapToModel(crop);
    if (model.id != null) {
      await _syncData.updateCrop(model);
    }
    return crop;
  }

  CropEntity _mapToEntity(Crop model) {
    return CropEntity(
      id: model.id?.toString(),
      name: CropName(model.name),
      variety: model.variety,
      plantedAt: DateTime.tryParse(model.plantedDate),
      expectedHarvest: model.expectedHarvestDate != null
          ? DateTime.tryParse(model.expectedHarvestDate!)
          : null,
      area: model.area,
      status: model.status,
      notes: model.notes,
    );
  }

  Crop _mapToModel(CropEntity entity) {
    return Crop(
      id: entity.id != null ? int.tryParse(entity.id!) : null,
      name: entity.name.value,
      variety: entity.variety,
      plantedDate: (entity.plantedAt ?? DateTime.now()).toIso8601String(),
      expectedHarvestDate: entity.expectedHarvest?.toIso8601String(),
      area: entity.area ?? 0,
      status: entity.status ?? 'Growing',
      notes: entity.notes,
    );
  }
}
