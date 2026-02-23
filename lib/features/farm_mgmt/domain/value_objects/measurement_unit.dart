import 'package:flutter/foundation.dart';

@immutable
class MeasurementUnit {
  final String value;

  const MeasurementUnit._(this.value);

  factory MeasurementUnit(String input) {
    final normalized = input.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('Measurement unit cannot be empty');
    }
    return MeasurementUnit._(normalized);
  }

  @override
  String toString() => value;
}
