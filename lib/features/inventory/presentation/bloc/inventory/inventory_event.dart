part of 'inventory_bloc.dart';

@freezed
class InventoryEvent with _$InventoryEvent {
  const factory InventoryEvent.loadInventory() = LoadInventory;

  const factory InventoryEvent.addItem({
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
    String? supplierId,
    double? unitPrice,
    double? totalValue,
    String? notes,
    DateTime? expiryDate,
    int? freshnessHours,
    DateTime? lastRestock,
  }) = AddItem;

  const factory InventoryEvent.updateItem({
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
    String? supplierId,
    double? unitPrice,
    double? totalValue,
    String? notes,
    DateTime? expiryDate,
    int? freshnessHours,
    DateTime? lastRestock,
  }) = UpdateItem;

  const factory InventoryEvent.deleteItem({
    required int id,
  }) = DeleteItem;

  const factory InventoryEvent.searchInventory({
    required String query,
  }) = SearchInventory;

  const factory InventoryEvent.filterByCategory({
    required String category,
  }) = FilterByCategory;

  const factory InventoryEvent.resolveConflictKeepLocal({
    required int id,
  }) = ResolveConflictKeepLocal;

  const factory InventoryEvent.resolveConflictUseServer({
    required int id,
  }) = ResolveConflictUseServer;
}
