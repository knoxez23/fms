import 'package:flutter/foundation.dart';

@immutable
class EmailAddress {
  final String value;

  const EmailAddress._(this.value);

  factory EmailAddress(String input) {
    final trimmed = input.trim();
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(trimmed)) {
      throw ArgumentError('Invalid email address');
    }
    return EmailAddress._(trimmed);
  }

  @override
  String toString() => value;
}
