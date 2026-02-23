import 'package:flutter/foundation.dart';

@immutable
class InventoryCategory {
  final String value;

  const InventoryCategory._(this.value);

  factory InventoryCategory(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Category cannot be empty');
    }
    if (trimmed.length > 100) {
      throw ArgumentError('Category is too long');
    }
    return InventoryCategory._(trimmed);
  }

  @override
  String toString() => value;
}
