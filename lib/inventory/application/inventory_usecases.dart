import '../domain/repositories/repositories.dart';

class GetInventory {
  final InventoryRepository repository;
  GetInventory(this.repository);

  Future<List<Map<String, dynamic>>> execute() async => await repository.getItems();
}

class AddInventoryItem {
  final InventoryRepository repository;
  AddInventoryItem(this.repository);

  Future<void> execute(Map<String, dynamic> item) async => await repository.addItem(item);
}
