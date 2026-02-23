part of 'inventory_bloc.dart';

@freezed
class InventoryEvent with _$InventoryEvent {
  const factory InventoryEvent.loadInventory() = LoadInventory;

  const factory InventoryEvent.addItem({
    required String itemName,
    required String category,
    required double quantity,
    required String unit,
    int? minStock,
    String? supplier,
    String? supplierId,
    double? unitPrice,
    double? totalValue,
    String? notes,
    DateTime? lastRestock,
  }) = AddItem;

  const factory InventoryEvent.updateItem({
    required int id,
    String? itemName,
    String? category,
    double? quantity,
    String? unit,
    int? minStock,
    String? supplier,
    String? supplierId,
    double? unitPrice,
    double? totalValue,
    String? notes,
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
