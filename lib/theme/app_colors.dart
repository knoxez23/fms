import 'package:flutter/material.dart';

/// 🌿 Global color and shadow constants for the Pamoja Twalima app
class AppColors {
  // 🌱 Brand Colors
  static const primary = Color(0xFF4CAF50);
  static const primaryDark = Color(0xFF388E3C);
  static const secondary = Color(0xFFFF9800);
  static const accent = Color(0xFFFF9800); // Used for highlights like category tags

  // 🪵 Backgrounds & Surfaces
  static const backgroundLight = Color(0xFFFAF8F3);
  static const backgroundDark = Color(0xFF121212);
  static const surfaceLight = Colors.white;
  static const surfaceDark = Color(0xFF1E1E1E);

  // 📝 Text Colors
  static const textDark = Color(0xFF1B1B1B);
  static const textLight = Color(0xFFF5F5F5);
  static const textMuted = Color(0xFF757575); // For subtitles, hints, etc.

  // 🎨 Icons
  static const iconLight = Color(0xFF9E9E9E);
  static const iconDark = Color(0xFFE0E0E0);

  // 🌈 Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ☁️ Shadows
  static const subtleShadow = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.06),
    blurRadius: 8,
    offset: Offset(0, 3),
  );

  static const cardShadow = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.10),
    blurRadius: 12,
    offset: Offset(0, 6),
  );

  static const shadow = Color.fromRGBO(0, 0, 0, 0.08); // Used for custom shadows
}
