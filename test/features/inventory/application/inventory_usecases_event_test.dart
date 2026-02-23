import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/core/domain/events/domain_event_bus.dart';
import 'package:pamoja_twalima/features/inventory/application/inventory_usecases.dart';
import 'package:pamoja_twalima/features/inventory/domain/entities/inventory_item.dart';
import 'package:pamoja_twalima/features/inventory/domain/events/inventory_domain_events.dart';
import 'package:pamoja_twalima/features/inventory/domain/repositories/inventory_repository.dart';

class _FakeInventoryRepository implements InventoryRepository {
  @override
  Future<void> addItem(InventoryItem item) async {}

  @override
  Future<void> deleteItem(String id) async {}

  @override
  Future<List<InventoryItem>> getItems() async => const [];

  @override
  Future<void> updateItem(InventoryItem item) async {}

  @override
  Future<void> resolveConflictKeepLocal(String localId) async {}

  @override
  Future<void> resolveConflictUseServer(String localId) async {}
}

void main() {
  test('UpdateInventoryItem publishes InventoryLowStock for low stock items',
      () async {
    final bus = DomainEventBus();
    final useCase = UpdateInventoryItem(_FakeInventoryRepository(), bus);
    final eventFuture = bus.on<InventoryLowStock>().first;

    await useCase.execute(
      InventoryItem(
        id: 'inv-1',
        itemName: 'Layers Feed',
        category: 'Feed',
        quantity: 2,
        unit: 'kg',
        minStock: 5,
      ),
    );

    final event = await eventFuture;
    expect(event.itemId, 'inv-1');
    expect(event.itemName, 'Layers Feed');
    expect(event.minStock, 5);
  });
}
