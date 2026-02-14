import '../network/api_service.dart';

class AnimalService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> list({Map<String, dynamic>? params}) async {
    final res = await _api.get('/animals', queryParameters: params);
    return List<dynamic>.from(res.data as List);
  }

  Future<Map<String, dynamic>> get(int id) async {
    final res = await _api.get('/animals/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final res = await _api.post('/animals', data: data);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final res = await _api.put('/animals/$id', data: data);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> delete(int id) async {
    await _api.delete('/animals/$id');
  }
}
