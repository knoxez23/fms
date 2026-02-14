import 'package:flutter/foundation.dart';

@immutable
class TaskTitle {
  final String value;

  const TaskTitle._(this.value);

  factory TaskTitle(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Task title cannot be empty');
    }
    return TaskTitle._(trimmed);
  }

  @override
  String toString() => value;
}
