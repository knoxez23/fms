import '../network/api_service.dart';
import 'dart:developer' as developer;

class InventoryService {
  final ApiService _api = ApiService();

  /// Fetch all inventory items from server
  Future<List<dynamic>> list({Map<String, dynamic>? params}) async {
    try {
      developer.log('InventoryService: Fetching inventory list');
      final res = await _api.get('/inventories', queryParameters: params);
      final data = List<dynamic>.from(res.data as List);
      developer.log('InventoryService: Fetched ${data.length} items');
      return data;
    } catch (e) {
      developer.log('InventoryService.list failed: $e');
      rethrow;
    }
  }

  /// Get single inventory item by ID
  Future<Map<String, dynamic>> get(int id) async {
    try {
      final res = await _api.get('/inventories/$id');
      return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      developer.log('InventoryService.get failed: $e');
      rethrow;
    }
  }

  /// Create new inventory item
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    try {
      developer.log('InventoryService: Creating item, payload: $data');
      final res = await _api.post('/inventories', data: data);
      return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      developer.log('InventoryService.create failed: $e');
      rethrow;
    }
  }

  /// Update existing inventory item
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    try {
      final res = await _api.put('/inventories/$id', data: data);
      return Map<String, dynamic>.from(res.data as Map);
    } catch (e) {
      developer.log('InventoryService.update failed: $e');
      rethrow;
    }
  }

  /// Delete inventory item
  Future<void> delete(int id) async {
    try {
      await _api.delete('/inventories/$id');
    } catch (e) {
      developer.log('InventoryService.delete failed: $e');
      rethrow;
    }
  }
}