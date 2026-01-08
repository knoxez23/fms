import '../domain/entities/inventory_item.dart';
import '../domain/repositories/repositories.dart';

class GetInventory {
  final InventoryRepository repository;
  GetInventory(this.repository);

  Future<List<InventoryItem>> execute() async => await repository.getItems();
}

class AddInventoryItem {
  final InventoryRepository repository;
  AddInventoryItem(this.repository);

  Future<void> execute(InventoryItem item) async =>
      await repository.addItem(item);
}
