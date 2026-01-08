class InventoryItem {
  final String? id; // local sqlite id
  final String itemName;
  final String category;
  final double quantity;
  final String unit;
  final int minStock;
  final double? unitPrice;
  final double? totalValue;
  final String? supplier;
  final DateTime? expiryDate;
  final DateTime? lastUpdated;

    // 🔹 SYNC STATE
  final bool isSynced;
  final bool hasConflict;

  InventoryItem({
    this.id,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minStock,
    this.unitPrice,
    this.totalValue,
    this.supplier,
    this.expiryDate,
    this.lastUpdated,
    this.isSynced = true,
    this.hasConflict = false,
  });
}
