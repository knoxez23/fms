import '../../features/inventory/domain/entities/inventory_item.dart';

class InventoryDto {
  final int? localId;
  final String? clientUuid;
  final String itemName;
  final String category;
  final double quantity;
  final String unit;
  final int minStock;
  final double? unitPrice;
  final double? totalValue;
  final String? supplier;
  final int? supplierId;
  final String? notes;
  final DateTime lastRestock;

  InventoryDto({
    this.localId,
    this.clientUuid,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minStock,
    this.unitPrice,
    this.totalValue,
    this.supplier,
    this.supplierId,
    this.notes,
    required this.lastRestock,
  });

  /// Domain → DTO
  factory InventoryDto.fromEntity(InventoryItem item) {
    return InventoryDto(
      localId: item.id != null ? int.tryParse(item.id!) : null,
      clientUuid: item.clientUuid,
      itemName: item.itemName,
      category: item.category,
      quantity: item.quantity,
      unit: item.unit,
      minStock: item.minStock,
      unitPrice: item.unitPrice,
      totalValue: item.totalValue,
      supplier: item.supplier,
      supplierId: item.supplierId != null ? int.tryParse(item.supplierId!) : null,
      notes: null,
      lastRestock: item.lastRestock ?? DateTime.now(),
    );
  }

  /// DTO → API
  Map<String, dynamic> toApi() {
    final formattedDate = '${lastRestock.year}-'
        '${lastRestock.month.toString().padLeft(2, '0')}-'
        '${lastRestock.day.toString().padLeft(2, '0')} '
        '${lastRestock.hour.toString().padLeft(2, '0')}:'
        '${lastRestock.minute.toString().padLeft(2, '0')}:'
        '${lastRestock.second.toString().padLeft(2, '0')}';

    return {
      'client_uuid': clientUuid,
      'item_name': itemName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'min_stock': minStock,
      'supplier': supplier ?? '', // Provide empty string instead of null
      'supplier_id': supplierId,
      'unit_price': unitPrice,
      'total_value': totalValue,
      'notes': notes,
      'last_restock': formattedDate, // Use formatted date
    };
  }

  /// DTO → SQLite
  Map<String, dynamic> toDb() {
    return {
      'client_uuid': clientUuid,
      'item_name': itemName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'min_stock': minStock,
      'unit_price': unitPrice,
      'total_value': totalValue,
      'supplier': supplier,
      'supplier_id': supplierId,
      'last_restock': lastRestock.toIso8601String(),
      'is_synced': 0,
    };
  }
}
