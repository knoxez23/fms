import 'dart:developer' as developer;
import 'package:injectable/injectable.dart';
import '../network/api_service.dart';
import '../models/inventory_dto.dart';
import '../../features/inventory/domain/entities/inventory_item.dart';

@LazySingleton()
class InventoryService {
  final ApiService _api;

  InventoryService(this._api);

  /// Fetch all inventory items from server
  Future<List<InventoryItem>> getInventory(
      {Map<String, dynamic>? params}) async {
    try {
      developer.log('InventoryService: Fetching inventory list');
      final res = await _api.get('/inventories', queryParameters: params);
      final data = List<dynamic>.from(res.data as List);
      developer.log('InventoryService: Fetched ${data.length} items');
      return data
          .map((item) => _mapToItem(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      developer.log('InventoryService.getInventory failed: $e');
      rethrow;
    }
  }

  /// Create new inventory item
  Future<InventoryItem> addInventoryItem({
    required String itemName,
    required String category,
    String? lotCode,
    String? sourceType,
    String? sourceRef,
    String? sourceLabel,
    required double quantity,
    double? reservedQuantity,
    required String unit,
    int? minStock,
    String? supplier,
    int? supplierId,
    double? unitPrice,
    double? totalValue,
    String? notes,
    int? freshnessHours,
    DateTime? expiryDate,
    DateTime? lastRestock,
  }) async {
    try {
      final dto = InventoryDto(
        itemName: itemName,
        category: category,
        lotCode: lotCode,
        sourceType: sourceType,
        sourceRef: sourceRef,
        sourceLabel: sourceLabel,
        quantity: quantity,
        reservedQuantity: reservedQuantity ?? 0,
        unit: unit,
        minStock: minStock ?? 0,
        supplier: supplier,
        supplierId: supplierId,
        unitPrice: unitPrice,
        totalValue: totalValue,
        notes: notes,
        freshnessHours: freshnessHours,
        expiryDate: expiryDate,
        lastRestock: lastRestock ?? DateTime.now(),
      );

      developer.log('InventoryService: Creating item, payload: ${dto.toApi()}');
      final res = await _api.post('/inventories', data: dto.toApi());
      return _mapToItem(Map<String, dynamic>.from(res.data as Map));
    } catch (e) {
      developer.log('InventoryService.addInventoryItem failed: $e');
      rethrow;
    }
  }

  /// Update existing inventory item
  Future<InventoryItem> updateInventoryItem({
    required int id,
    String? itemName,
    String? category,
    String? lotCode,
    String? sourceType,
    String? sourceRef,
    String? sourceLabel,
    double? quantity,
    double? reservedQuantity,
    String? unit,
    int? minStock,
    String? supplier,
    int? supplierId,
    double? unitPrice,
    double? totalValue,
    String? notes,
    int? freshnessHours,
    DateTime? expiryDate,
    DateTime? lastRestock,
  }) async {
    try {
      final data = <String, dynamic>{
        if (itemName != null) 'item_name': itemName,
        if (category != null) 'category': category,
        if (lotCode != null) 'lot_code': lotCode,
        if (sourceType != null) 'source_type': sourceType,
        if (sourceRef != null) 'source_ref': sourceRef,
        if (sourceLabel != null) 'source_label': sourceLabel,
        if (quantity != null) 'quantity': quantity,
        if (reservedQuantity != null) 'reserved_quantity': reservedQuantity,
        if (unit != null) 'unit': unit,
        if (minStock != null) 'min_stock': minStock,
        if (supplier != null) 'supplier': supplier,
        if (supplierId != null) 'supplier_id': supplierId,
        if (unitPrice != null) 'unit_price': unitPrice,
        if (totalValue != null) 'total_value': totalValue,
        if (notes != null) 'notes': notes,
        if (freshnessHours != null) 'freshness_hours': freshnessHours,
        if (expiryDate != null) 'expiry_date': expiryDate.toIso8601String(),
        if (lastRestock != null) 'last_restock': lastRestock.toIso8601String(),
      };

      final res = await _api.put('/inventories/$id', data: data);
      return _mapToItem(Map<String, dynamic>.from(res.data as Map));
    } catch (e) {
      developer.log('InventoryService.updateInventoryItem failed: $e');
      rethrow;
    }
  }

  /// Delete inventory item
  Future<void> deleteInventoryItem(int id) async {
    try {
      await _api.delete('/inventories/$id');
    } catch (e) {
      developer.log('InventoryService.deleteInventoryItem failed: $e');
      rethrow;
    }
  }

  /// Backwards-compatible helpers
  Future<List<dynamic>> list({Map<String, dynamic>? params}) async {
    final res = await _api.get('/inventories', queryParameters: params);
    return List<dynamic>.from(res.data as List);
  }

  Future<Map<String, dynamic>> get(int id) async {
    final res = await _api.get('/inventories/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final res = await _api.post('/inventories', data: data);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final res = await _api.put('/inventories/$id', data: data);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> delete(int id) async {
    await _api.delete('/inventories/$id');
  }

  InventoryItem _mapToItem(Map<String, dynamic> data) {
    return InventoryItem(
      id: data['id']?.toString(),
      clientUuid: data['client_uuid'],
      supplierId: data['supplier_id']?.toString(),
        itemName: data['item_name'] ?? data['itemName'] ?? '',
        category: data['category'] ?? '',
      lotCode: data['lot_code'] ?? data['lotCode'],
      sourceType: data['source_type'] ?? data['sourceType'],
      sourceRef: data['source_ref'] ?? data['sourceRef'],
      sourceLabel: data['source_label'] ?? data['sourceLabel'],
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
      reservedQuantity: (data['reserved_quantity'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] ?? '',
      minStock: (data['min_stock'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unit_price'] as num?)?.toDouble(),
      totalValue: (data['total_value'] as num?)?.toDouble(),
      supplier: data['supplier'],
      expiryDate: data['expiry_date'] != null
          ? DateTime.tryParse(data['expiry_date'])
          : null,
      freshnessHours: (data['freshness_hours'] as num?)?.toInt(),
      lastRestock: data['last_restock'] != null
          ? DateTime.tryParse(data['last_restock'])
          : null,
      isSynced: data['is_synced'] ?? true,
      hasConflict: data['has_conflict'] ?? false,
    );
  }
}
