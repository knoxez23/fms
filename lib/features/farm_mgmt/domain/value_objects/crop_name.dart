import 'package:flutter/foundation.dart';

@immutable
class CropName {
  final String value;

  const CropName._(this.value);

  factory CropName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Crop name cannot be empty');
    }
    return CropName._(trimmed);
  }

  @override
  String toString() => value;
}
