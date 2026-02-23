class InventoryItem {
  final String? id; // local sqlite id
  final String? clientUuid;
  final String? supplierId;
  final String itemName;
  final String category;
  final double quantity;
  final String unit;
  final int minStock;
  final double? unitPrice;
  final double? totalValue;
  final String? supplier;
  final DateTime? expiryDate;
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
    required this.quantity,
    required this.unit,
    required this.minStock,
    this.unitPrice,
    this.totalValue,
    this.supplier,
    this.expiryDate,
    this.lastRestock,
    this.isSynced = true,
    this.hasConflict = false,
  });

  bool get isCritical => quantity <= 0;

  bool get isLowStock => minStock > 0 && quantity <= minStock;

  bool get isAdequate => !isCritical && !isLowStock;

  double get resolvedTotalValue =>
      totalValue ?? (unitPrice != null ? unitPrice! * quantity : 0);
}
