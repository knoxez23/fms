import 'package:flutter/foundation.dart';

@immutable
class InventoryItemName {
  final String value;

  const InventoryItemName._(this.value);

  factory InventoryItemName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Item name cannot be empty');
    }
    if (trimmed.length > 255) {
      throw ArgumentError('Item name is too long');
    }
    return InventoryItemName._(trimmed);
  }

  @override
  String toString() => value;
}
