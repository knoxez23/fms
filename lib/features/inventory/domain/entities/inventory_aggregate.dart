import 'inventory_item.dart';

class InventoryAggregate {
  final InventoryItem item;

  InventoryAggregate(this.item) {
    _validate(item);
  }

  void _validate(InventoryItem value) {
    if (value.itemName.trim().isEmpty) {
      throw ArgumentError('Inventory item name cannot be empty');
    }
    if (value.quantity < 0) {
      throw ArgumentError('Inventory quantity cannot be negative');
    }
    if (value.minStock < 0) {
      throw ArgumentError('Inventory min stock cannot be negative');
    }
    if (value.unitPrice != null && value.unitPrice! < 0) {
      throw ArgumentError('Inventory unit price cannot be negative');
    }
  }

  bool get requiresReorder => item.isLowStock;
}
