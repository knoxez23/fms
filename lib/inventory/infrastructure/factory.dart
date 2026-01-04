import '../domain/repositories/repositories.dart';
import '../application/inventory_usecases.dart';
import 'inventory_repository_impl.dart';

class InventoryFactory {
  static InventoryRepository createRepository() => InventoryRepositoryImpl();

  static GetInventory createGetInventory() => GetInventory(createRepository());

  static AddInventoryItem createAddInventoryItem() => AddInventoryItem(createRepository());
}
