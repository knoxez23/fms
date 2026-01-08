import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  /// Returns the color with the given alpha (0.0 - 1.0).
  /// If alpha is null or out of range, returns the original color.
  Color withValues({double? alpha}) {
    if (alpha == null) return this;
    final a = alpha.clamp(0.0, 1.0);
    final intAlpha = (a * 255).round();
    return withAlpha(intAlpha);
  }
}
