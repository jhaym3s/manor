import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1A3A2A);
  static const Color primaryLight = Color(0xFF234332);
  static const Color primaryDark = Color(0xFF0F2318);

  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Accent Colors
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);
  
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successBorder = Color(0xFF86EFAC);

  static const Color warning = Color(0xFFF97316);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFEF3C7);

  static const Color info = Color(0xFF0891B2);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleDark = Color(0xFF7C3AED);

  // Official/Management Colors
  static const Color official = Color(0xFF166534);
  static const Color officialLight = Color(0xFFF0FDF4);
  static const Color officialBorder = Color(0xFF86EFAC);

  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryLight],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, Color(0xFFB91C1C)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, purpleDark],
  );

  static const LinearGradient officialGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [officialLight, Color(0xFFDCFCE7)],
  );
}