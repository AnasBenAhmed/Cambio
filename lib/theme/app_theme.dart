import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand palette — shared with the annas.host portfolio (dark-luxe).
class AppColors {
  AppColors._();

  static const bg = Color(0xFF0D0D0D);
  static const surface = Color(0xFF151515);
  static const surfaceHigh = Color(0xFF1C1C1C);
  static const hairline = Color(0xFF262626);

  static const crimson = Color(0xFFE11B22);
  static const gold = Color(0xFFE0A82E);

  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFF8A8A8A);
  static const textFaint = Color(0xFF5A5A5A);

  /// Crimson → gold — Cambio's signature accent (replaces the reference app's green).
  static const brandGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [crimson, gold],
  );
}

/// Typography — Bebas Neue for display numerals, Space Grotesk for UI text.
class AppText {
  AppText._();

  static TextStyle display(
    double size, {
    Color color = AppColors.textPrimary,
    double spacing = 1.5,
  }) =>
      GoogleFonts.bebasNeue(
        fontSize: size,
        color: color,
        letterSpacing: spacing,
        height: 1.0,
      );

  static TextStyle ui(
    double size, {
    Color color = AppColors.textPrimary,
    FontWeight weight = FontWeight.w500,
    double spacing = 0,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: spacing,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.bg,
        primary: AppColors.crimson,
        secondary: AppColors.gold,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      splashColor: AppColors.crimson.withValues(alpha: 0.08),
      highlightColor: AppColors.crimson.withValues(alpha: 0.04),
    );
  }
}
