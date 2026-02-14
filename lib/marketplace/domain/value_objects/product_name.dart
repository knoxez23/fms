import 'package:flutter/foundation.dart';

@immutable
class ProductName {
  final String value;

  const ProductName._(this.value);

  factory ProductName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Product name cannot be empty');
    }
    return ProductName._(trimmed);
  }

  @override
  String toString() => value;
}
