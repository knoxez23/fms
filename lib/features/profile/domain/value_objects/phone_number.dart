import 'package:flutter/foundation.dart';

@immutable
class PhoneNumber {
  final String value;

  const PhoneNumber._(this.value);

  factory PhoneNumber(String input) {
    final trimmed = input.replaceAll(' ', '');
    if (trimmed.isEmpty) {
      throw ArgumentError('Phone number cannot be empty');
    }
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(trimmed)) {
      throw ArgumentError('Invalid phone number');
    }
    return PhoneNumber._(trimmed);
  }

  @override
  String toString() => value;
}
