import 'package:flutter_test/flutter_test.dart';
import 'package:pamoja_twalima/inventory/domain/entities/inventory_aggregate.dart';
import 'package:pamoja_twalima/inventory/domain/entities/inventory_item.dart';

void main() {
  test('requires reorder when quantity is below minimum', () {
    final aggregate = InventoryAggregate(
      InventoryItem(
        itemName: 'Poultry Feed',
        category: 'Feed',
        quantity: 2,
        unit: 'kg',
        minStock: 5,
      ),
    );

    expect(aggregate.requiresReorder, isTrue);
  });
}
