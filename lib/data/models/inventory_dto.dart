import '../../inventory/domain/entities/inventory_item.dart';

class InventoryDto {
  final int? localId;
  final String itemName;
  final String category;
  final double quantity;
  final String unit;
  final int minStock;
  final double? unitPrice;
  final double? totalValue;
  final String? supplier;
  final String? notes;
  final DateTime lastRestock;

  InventoryDto({
    this.localId,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minStock,
    this.unitPrice,
    this.totalValue,
    this.supplier,
    this.notes,
    required this.lastRestock,
  });

  /// Domain → DTO
  factory InventoryDto.fromEntity(InventoryItem item) {
    return InventoryDto(
      localId: item.id != null ? int.tryParse(item.id!) : null,
      itemName: item.itemName,
      category: item.category,
      quantity: item.quantity,
      unit: item.unit,
      minStock: item.minStock,
      unitPrice: item.unitPrice,
      totalValue: item.totalValue,
      supplier: item.supplier,
      notes: null,
      lastRestock: item.lastRestock ?? DateTime.now(),
    );
  }

  /// DTO → API
  Map<String, dynamic> toApi() {
    return {
      'item_name': itemName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'min_stock': minStock,
      'supplier': supplier,
      'unit_price': unitPrice,
      'total_value': totalValue,
      'last_restock': lastRestock.toIso8601String(),
    };
  }

  /// DTO → SQLite
  Map<String, dynamic> toDb() {
    return {
      'item_name': itemName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'min_stock': minStock,
      'unit_price': unitPrice,
      'total_value': totalValue,
      'supplier': supplier,
      'last_restock': lastRestock.toIso8601String(),
      'is_synced': 0,
    };
  }
}
