import 'package:flutter/foundation.dart';

@immutable
class InventoryMoney {
  final double value;
  final String currency;

  const InventoryMoney._(this.value, this.currency);

  factory InventoryMoney(double input, {String currency = 'KSh'}) {
    if (input.isNaN || input.isInfinite) {
      throw ArgumentError('Amount must be a valid number');
    }
    if (input < 0) {
      throw ArgumentError('Amount cannot be negative');
    }
    return InventoryMoney._(input, currency);
  }

  @override
  String toString() => '$currency ${value.toStringAsFixed(2)}';
}
