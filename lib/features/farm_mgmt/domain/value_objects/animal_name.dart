import 'package:flutter/foundation.dart';

@immutable
class AnimalName {
  final String value;

  const AnimalName._(this.value);

  factory AnimalName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Animal name cannot be empty');
    }
    return AnimalName._(trimmed);
  }

  @override
  String toString() => value;
}
