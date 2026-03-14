class InventoryItem {
  final String? id; // local sqlite id
  final String? clientUuid;
  final String? supplierId;
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
  final DateTime? expiryDate;
  final int? freshnessHours;
  final DateTime? lastRestock;

  // 🔹 SYNC STATE
  final bool isSynced;
  final bool hasConflict;

  InventoryItem({
    this.id,
    this.clientUuid,
    this.supplierId,
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
    this.expiryDate,
    this.freshnessHours,
    this.lastRestock,
    this.isSynced = true,
    this.hasConflict = false,
  });

  bool get isCritical => quantity <= 0;

  bool get isLowStock => minStock > 0 && quantity <= minStock;

  bool get isAdequate => !isCritical && !isLowStock;

  double get availableQuantity {
    final available = quantity - reservedQuantity;
    return available < 0 ? 0 : available;
  }

  double get resolvedTotalValue =>
      totalValue ?? (unitPrice != null ? unitPrice! * quantity : 0);
}
