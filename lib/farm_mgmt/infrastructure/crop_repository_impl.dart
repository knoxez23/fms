import '../domain/repositories/crop_repository.dart';
import '../domain/entities/entities.dart';
import 'package:pamoja_twalima/data/services/crop_service.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';

class CropRepositoryImpl implements CropRepository {
  final CropService _apiService;

  CropRepositoryImpl({CropService? apiService}) : _apiService = apiService ?? CropService();

  @override
  Future<void> addCrop(Crop crop) async {
    // prefer remote create, then persist locally
    final created = await _apiService.createCrop(crop);
    await LocalData.insertCrop(created);
  }

  @override
  Future<void> deleteCrop(int id) async {
    await _apiService.deleteCrop(id);
    await LocalData.deleteCrop(id);
  }

  @override
  Future<List<Crop>> getCrops() async {
    // try local cache first
    final local = await LocalData.getCrops();
    if (local.isNotEmpty) return local;

    // fallback to API
    final remote = await _apiService.fetchCrops();
    // optionally cache remote results
    for (var c in remote) {
      await LocalData.insertCrop(c);
    }
    return remote;
  }

  @override
  Future<void> updateCrop(Crop crop) async {
    if (crop.id != null) {
      await _apiService.updateCrop(crop.id!, crop);
      await LocalData.updateCrop(crop);
    }
  }
}

