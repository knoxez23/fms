import 'package:flutter/foundation.dart';

@immutable
class InventoryUnit {
  final String value;

  const InventoryUnit._(this.value);

  factory InventoryUnit(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Unit cannot be empty');
    }
    if (trimmed.length > 30) {
      throw ArgumentError('Unit is too long');
    }
    return InventoryUnit._(trimmed);
  }

  @override
  String toString() => value;
}
