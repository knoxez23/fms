import 'package:flutter/foundation.dart';

@immutable
class Money {
  final double value;
  final String currency;

  const Money._(this.value, this.currency);

  factory Money(double input, {String currency = 'KSh'}) {
    if (input.isNaN || input.isInfinite) {
      throw ArgumentError('Amount must be a valid number');
    }
    if (input < 0) {
      throw ArgumentError('Amount cannot be negative');
    }
    return Money._(input, currency);
  }

  @override
  String toString() => '$currency ${value.toStringAsFixed(2)}';
}
