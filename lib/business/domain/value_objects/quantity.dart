import 'package:flutter/foundation.dart';

@immutable
class BusinessQuantity {
  final double value;

  const BusinessQuantity._(this.value);

  factory BusinessQuantity(double input) {
    if (input.isNaN || input.isInfinite) {
      throw ArgumentError('Quantity must be a valid number');
    }
    if (input < 0) {
      throw ArgumentError('Quantity cannot be negative');
    }
    return BusinessQuantity._(input);
  }

  @override
  String toString() => value.toString();
}
