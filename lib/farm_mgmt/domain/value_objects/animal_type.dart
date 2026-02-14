import 'package:flutter/foundation.dart';

@immutable
class AnimalType {
  final String value;

  const AnimalType._(this.value);

  static const supported = <String>{
    'cattle',
    'poultry',
    'goat',
    'sheep',
    'pig',
    'other',
  };

  factory AnimalType(String input) {
    final normalized = input.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw ArgumentError('Animal type cannot be empty');
    }
    if (!supported.contains(normalized)) {
      return AnimalType._('other');
    }
    return AnimalType._(normalized);
  }

  @override
  String toString() => value;
}
