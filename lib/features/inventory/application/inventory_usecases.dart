import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/core/domain/events/domain_event_bus.dart';
import 'package:pamoja_twalima/features/inventory/domain/entities/inventory_aggregate.dart';
import 'package:pamoja_twalima/features/inventory/domain/events/inventory_domain_events.dart';
import '../domain/entities/inventory_item.dart';
import '../domain/repositories/repositories.dart';

@lazySingleton
class GetInventory {
  final InventoryRepository repository;
  GetInventory(this.repository);

  Future<List<InventoryItem>> execute() async => await repository.getItems();
}

@lazySingleton
class AddInventoryItem {
  final InventoryRepository repository;
  final DomainEventBus _eventBus;
  AddInventoryItem(this.repository, this._eventBus);

  Future<void> execute(InventoryItem item) async {
    final aggregate = InventoryAggregate(item);
    await repository.addItem(item);
    if (aggregate.requiresReorder) {
      _eventBus.publish(
        InventoryLowStock(
          itemId: item.id,
          itemName: item.itemName,
          quantity: item.quantity,
          minStock: item.minStock,
        ),
      );
    }
  }
}

@lazySingleton
class DeleteInventoryItem {
  final InventoryRepository repository;

  DeleteInventoryItem(this.repository);

  Future<void> execute(String id) async {
    await repository.deleteItem(id);
  }
}

@lazySingleton
class UpdateInventoryItem {
  final InventoryRepository repository;
  final DomainEventBus _eventBus;

  UpdateInventoryItem(this.repository, this._eventBus);

  Future<void> execute(InventoryItem item) async {
    final aggregate = InventoryAggregate(item);
    await repository.updateItem(item);
    if (aggregate.requiresReorder) {
      _eventBus.publish(
        InventoryLowStock(
          itemId: item.id,
          itemName: item.itemName,
          quantity: item.quantity,
          minStock: item.minStock,
        ),
      );
    }
  }
}

@lazySingleton
class ResolveInventoryConflictKeepLocal {
  final InventoryRepository repository;
  ResolveInventoryConflictKeepLocal(this.repository);

  Future<void> execute(String localId) async {
    await repository.resolveConflictKeepLocal(localId);
  }
}

@lazySingleton
class ResolveInventoryConflictUseServer {
  final InventoryRepository repository;
  ResolveInventoryConflictUseServer(this.repository);

  Future<void> execute(String localId) async {
    await repository.resolveConflictUseServer(localId);
  }
}
