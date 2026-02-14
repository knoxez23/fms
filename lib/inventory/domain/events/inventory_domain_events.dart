import 'package:pamoja_twalima/core/domain/events/domain_event.dart';

class InventoryLowStock extends DomainEvent {
  final String? itemId;
  final String itemName;
  final double quantity;
  final int minStock;

  InventoryLowStock({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.minStock,
  });
}
