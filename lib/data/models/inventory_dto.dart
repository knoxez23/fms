import '../../features/inventory/domain/entities/inventory_item.dart';

class InventoryDto {
  final int? localId;
  final String? clientUuid;
  final String itemName;
  final String category;
  final String? lotCode;
  final String? sourceType;
  final String? sourceRef;
  final String? sourceLabel;
  final double quantity;
  final double reservedQuantity;
  final String unit;
  final int minStock;
  final double? unitPrice;
  final double? totalValue;
  final String? supplier;
  final int? supplierId;
  final String? notes;
  final int? freshnessHours;
  final DateTime? expiryDate;
  final DateTime lastRestock;

  InventoryDto({
    this.localId,
    this.clientUuid,
    required this.itemName,
    required this.category,
    this.lotCode,
    this.sourceType,
    this.sourceRef,
    this.sourceLabel,
    required this.quantity,
    this.reservedQuantity = 0,
    required this.unit,
    required this.minStock,
    this.unitPrice,
    this.totalValue,
    this.supplier,
    this.supplierId,
    this.notes,
    this.freshnessHours,
    this.expiryDate,
    required this.lastRestock,
  });

  /// Domain → DTO
  factory InventoryDto.fromEntity(InventoryItem item) {
    return InventoryDto(
      localId: item.id != null ? int.tryParse(item.id!) : null,
      clientUuid: item.clientUuid,
      itemName: item.itemName,
      category: item.category,
      lotCode: item.lotCode,
      sourceType: item.sourceType,
      sourceRef: item.sourceRef,
      sourceLabel: item.sourceLabel,
      quantity: item.quantity,
      reservedQuantity: item.reservedQuantity,
      unit: item.unit,
      minStock: item.minStock,
      unitPrice: item.unitPrice,
      totalValue: item.totalValue,
      supplier: item.supplier,
      supplierId: item.supplierId != null ? int.tryParse(item.supplierId!) : null,
      notes: null,
      freshnessHours: item.freshnessHours,
      expiryDate: item.expiryDate,
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
      'lot_code': lotCode,
      'source_type': sourceType,
      'source_ref': sourceRef,
      'source_label': sourceLabel,
      'quantity': quantity,
      'reserved_quantity': reservedQuantity,
      'unit': unit,
      'min_stock': minStock,
      'supplier': supplier ?? '', // Provide empty string instead of null
      'supplier_id': supplierId,
      'unit_price': unitPrice,
      'total_value': totalValue,
      'notes': notes,
      'freshness_hours': freshnessHours,
      'expiry_date': expiryDate?.toIso8601String(),
      'last_restock': formattedDate, // Use formatted date
    };
  }

  /// DTO → SQLite
  Map<String, dynamic> toDb() {
    return {
      'client_uuid': clientUuid,
      'item_name': itemName,
      'category': category,
      'lot_code': lotCode,
      'source_type': sourceType,
      'source_ref': sourceRef,
      'source_label': sourceLabel,
      'quantity': quantity,
      'reserved_quantity': reservedQuantity,
      'unit': unit,
      'min_stock': minStock,
      'unit_price': unitPrice,
      'total_value': totalValue,
      'supplier': supplier,
      'supplier_id': supplierId,
      'freshness_hours': freshnessHours,
      'expiry_date': expiryDate?.toIso8601String(),
      'last_restock': lastRestock.toIso8601String(),
      'is_synced': 0,
    };
  }
}
