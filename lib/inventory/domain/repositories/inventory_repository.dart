abstract class InventoryRepository {
  Future<List<Map<String, dynamic>>> getItems();
  Future<void> addItem(Map<String, dynamic> item);
  Future<void> updateItem(Map<String, dynamic> item);
  Future<void> deleteItem(String id);
}
