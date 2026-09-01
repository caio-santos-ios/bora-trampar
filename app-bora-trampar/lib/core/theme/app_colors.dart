import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0D0D0D);
  static const Color cardBackground = Color(0xFF161616);
  static const Color cardElevated = Color(0xFF1F1F1F);
  static const Color cardBorder = Color(0xFF262626);
  static const Color inputBackground = Color(0xFF1A1A1A);

  // Primary & Accents
  static const Color primaryGold = Color(0xFFFDBF0F);
  static const Color primaryGoldDark = Color(0xFFE5A800);
  static const Color primaryGoldLight = Color(0xFFFFD54F);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF757575);
  static const Color textDark = Color(0xFF121212);

  // Borders & Dividers
  static const Color divider = Color(0xFF242424);
  static const Color borderLight = Color(0xFF333333);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFC82C), Color(0xFFE5A800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E1E1E), Color(0xFF141414)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
