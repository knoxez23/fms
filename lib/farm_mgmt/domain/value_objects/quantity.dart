import 'package:flutter/foundation.dart';

@immutable
class Quantity {
  final double value;

  const Quantity._(this.value);

  factory Quantity(double input) {
    if (input <= 0) {
      throw ArgumentError('Quantity must be greater than zero');
    }
    return Quantity._(input);
  }

  @override
  String toString() => value.toString();
}
