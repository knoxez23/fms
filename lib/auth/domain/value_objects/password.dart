import 'package:flutter/foundation.dart';

@immutable
class Password {
  final String value;

  const Password._(this.value);

  factory Password(String input) {
    if (input.length < 8) {
      throw ArgumentError('Password must be at least 8 characters');
    }
    if (!RegExp(r'[A-Z]').hasMatch(input)) {
      throw ArgumentError('Password must include an uppercase letter');
    }
    if (!RegExp(r'[a-z]').hasMatch(input)) {
      throw ArgumentError('Password must include a lowercase letter');
    }
    if (!RegExp(r'[0-9]').hasMatch(input)) {
      throw ArgumentError('Password must include a number');
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(input)) {
      throw ArgumentError('Password must include a symbol');
    }
    return Password._(input);
  }

  @override
  String toString() => '********';
}
