import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static const double radiusSm = 6;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 9999;

  static const double spaceXs = 4;
  static const double spaceSm = 12;
  static const double spaceMd = 24;
  static const double spaceLg = 40;
  static const double marginMobile = 20;
  static const double gutter = 16;

  static ThemeData light() {
    final cs = AppColors.lightScheme;
    return _buildTheme(cs, Brightness.light);
  }

  static ThemeData dark() {
    final cs = AppColors.darkScheme;
    return _buildTheme(cs, Brightness.dark);
  }

  static ThemeData _buildTheme(ColorScheme cs, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final textTheme = AppTypography.textTheme(cs.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      textTheme: textTheme,
      scaffoldBackgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: isLight ? AppColors.glassWhite : AppColors.glassDark,
        elevation: 0,
        shadowColor: Colors.black.withAlpha(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.primary;
          return isLight ? AppColors.mutedText : Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return cs.primary.withAlpha(60);
          return isLight ? Colors.grey.withAlpha(40) : Colors.grey.withAlpha(30);
        }),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.cream : AppColors.glassDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isLight
            ? AppColors.glassWhite
            : AppColors.glassDark,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant.withAlpha(120),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
      ),

      dividerTheme: DividerThemeData(
        color: cs.outlineVariant.withAlpha(80),
        thickness: 0.5,
        space: 0,
      ),
    );
  }
}
