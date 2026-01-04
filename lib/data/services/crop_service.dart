import 'package:dio/dio.dart';
import '../models/crop.dart';
import '../network/api_service.dart';
import '../network/api_error.dart';

class CropService {
  final ApiService _api = ApiService();

  /// Create crop
  Future<Crop> createCrop(Crop crop) async {
    try {
      final response = await _api.post(
        '/crops',
        data: crop.toMap(),
      );

      return Crop.fromMap(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  /// Fetch all crops
  Future<List<Crop>> fetchCrops() async {
    try {
      final response = await _api.get('/crops');

      return (response.data as List)
          .map((e) => Crop.fromMap(e))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  /// Update crop
  Future<Crop> updateCrop(int id, Crop crop) async {
    try {
      final response = await _api.put(
        '/crops/$id',
        data: crop.toMap(),
      );

      return Crop.fromMap(response.data);
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }

  /// Delete crop
  Future<void> deleteCrop(int id) async {
    try {
      await _api.delete('/crops/$id');
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }
}
