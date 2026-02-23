import '../entities/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getItems();
  Future<void> addItem(InventoryItem item);
  Future<void> updateItem(InventoryItem item);
  Future<void> deleteItem(String id);
  Future<void> resolveConflictKeepLocal(String localId);
  Future<void> resolveConflictUseServer(String localId);
}
