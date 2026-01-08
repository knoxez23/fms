import '../network/api_service.dart';
import 'dart:developer' as developer;

class SaleService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> list({Map<String, dynamic>? params}) async {
    final res = await _api.get('/sales', queryParameters: params);
    return List<dynamic>.from(res.data as List);
  }

  Future<Map<String, dynamic>> get(int id) async {
    final res = await _api.get('/sales/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    try {
      developer.log('Creating sale, payload: $data');
      final res = await _api.post('/sales', data: data);
      return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      developer.log('SaleService.create failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final res = await _api.put('/sales/$id', data: data);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> delete(int id) async {
    await _api.delete('/sales/$id');
  }
}
