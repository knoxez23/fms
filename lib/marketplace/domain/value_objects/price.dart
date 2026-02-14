import 'package:flutter/foundation.dart';

@immutable
class Price {
  final double value;
  final String currency;

  const Price._(this.value, this.currency);

  factory Price(double input, {String currency = 'KSh'}) {
    if (input.isNaN || input.isInfinite) {
      throw ArgumentError('Price must be a valid number');
    }
    if (input < 0) {
      throw ArgumentError('Price cannot be negative');
    }
    return Price._(input, currency);
  }

  @override
  String toString() => '$currency ${value.toStringAsFixed(2)}';
}
