import 'package:flutter/foundation.dart';

@immutable
class InventoryQuantity {
  final double value;

  const InventoryQuantity._(this.value);

  factory InventoryQuantity(double input) {
    if (input.isNaN || input.isInfinite) {
      throw ArgumentError('Quantity must be a valid number');
    }
    if (input < 0) {
      throw ArgumentError('Quantity cannot be negative');
    }
    return InventoryQuantity._(input);
  }

  @override
  String toString() => value.toString();
}
