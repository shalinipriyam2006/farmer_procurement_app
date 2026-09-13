import 'package:flutter/material.dart';

class AppColors {
  // Primary Agrarian Emerald & Deep Forest Green
  static const Color primary = Color(0xFF0F5A27); // Rich Emerald Forest Green
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF073817);
  static const Color primaryContainer = Color(0xFFE8F5E9);
  static const Color primaryContainerDark = Color(0xFFC8E6C9);

  // Secondary Warm Golden Wheat / Harvest Amber
  static const Color secondary = Color(0xFFD84315); // Deep Harvest Amber
  static const Color secondaryLight = Color(0xFFFF6F00);
  static const Color secondaryContainer = Color(0xFFFFF3E0);

  // Accent Gold & Earth Tones
  static const Color goldAccent = Color(0xFFFFB300);
  static const Color earthBrown = Color(0xFF5D4037);

  // Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFEF6C00);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF0277BD);

  // Backgrounds & Surface Tones
  static const Color background = Color(0xFFF4F7F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEDF2EE);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E6E1);

  // Text Colors (High Contrast for Outdoor Daylight Readability)
  static const Color textPrimary = Color(0xFF131F16);
  static const Color textSecondary = Color(0xFF3F4F43);
  static const Color textTertiary = Color(0xFF6C7C70);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF073817), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0B461D), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFD84315), Color(0xFFFF6F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
