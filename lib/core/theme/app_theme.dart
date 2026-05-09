import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Centralised ThemeData factory.
///
/// Produces a fully-populated Material 3 theme using the Stitch
/// "Athkar App Design System" tokens.  Supports **light** and **dark** modes.
class AppTheme {
  AppTheme._();

  // ─────────────── Shared shape tokens ───────────────────────
  static const double radiusSm = 4;   // 0.25rem
  static const double radiusMd = 12;  // 0.75rem
  static const double radiusLg = 16;  // 1rem  – standard containers
  static const double radiusXl = 24;  // 1.5rem – hero cards
  static const double radiusFull = 9999; // pill buttons

  // ─────────────── Spacing tokens ────────────────────────────
  static const double spaceXs = 4;
  static const double spaceSm = 12;
  static const double spaceMd = 24;
  static const double spaceLg = 40;
  static const double spaceXl = 64;
  static const double marginMobile = 20;
  static const double gutter = 16;

  // ─────────────── Light theme ───────────────────────────────

  static ThemeData light() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryLight,
      onPrimary: AppColors.onPrimaryLight,
      primaryContainer: AppColors.primaryContainerLight,
      onPrimaryContainer: AppColors.onPrimaryContainerLight,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.onSecondaryLight,
      secondaryContainer: AppColors.secondaryContainerLight,
      onSecondaryContainer: AppColors.onSecondaryContainerLight,
      tertiary: AppColors.tertiaryLight,
      onTertiary: AppColors.onTertiaryLight,
      tertiaryContainer: AppColors.tertiaryContainerLight,
      onTertiaryContainer: AppColors.onTertiaryContainerLight,
      error: AppColors.errorLight,
      onError: AppColors.onErrorLight,
      errorContainer: AppColors.errorContainerLight,
      onErrorContainer: AppColors.onErrorContainerLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
      outline: AppColors.outlineLight,
      outlineVariant: AppColors.outlineVariantLight,
      inverseSurface: AppColors.inverseSurfaceLight,
      onInverseSurface: AppColors.inverseOnSurfaceLight,
      inversePrimary: AppColors.inversePrimaryLight,
      surfaceTint: AppColors.surfaceTintLight,
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  // ─────────────── Dark theme ────────────────────────────────

  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.onSecondaryDark,
      secondaryContainer: AppColors.secondaryContainerDark,
      onSecondaryContainer: AppColors.onSecondaryContainerDark,
      tertiary: AppColors.tertiaryDark,
      onTertiary: AppColors.onTertiaryDark,
      tertiaryContainer: AppColors.tertiaryContainerDark,
      onTertiaryContainer: AppColors.onTertiaryContainerDark,
      error: AppColors.errorDark,
      onError: AppColors.onErrorDark,
      errorContainer: AppColors.errorContainerDark,
      onErrorContainer: AppColors.onErrorContainerDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
      outline: AppColors.outlineDark,
      outlineVariant: AppColors.outlineVariantDark,
      inverseSurface: AppColors.inverseSurfaceDark,
      onInverseSurface: AppColors.inverseOnSurfaceDark,
      inversePrimary: AppColors.inversePrimaryDark,
      surfaceTint: AppColors.surfaceTintDark,
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  // ─────────────── Shared builder ────────────────────────────

  static ThemeData _buildTheme(ColorScheme cs, Brightness brightness) {
    final textTheme = AppTypography.textTheme(cs.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      textTheme: textTheme,
      scaffoldBackgroundColor: cs.surface,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: cs.onSurface),
      ),

      // Cards – 24px radius, soft emerald-tinted shadow
      cardTheme: CardThemeData(
        color: brightness == Brightness.light
            ? AppColors.surfaceContainerLowestLight
            : AppColors.surfaceContainerDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: marginMobile,
          vertical: spaceSm,
        ),
      ),

      // Elevated buttons – pill shape
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          side: BorderSide(color: AppColors.mutedSage, width: 1),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Input decoration – soft fill, no border, 12px radius
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? AppColors.surfaceContainerLowLight
            : AppColors.surfaceContainerLowDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: cs.primary, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: gutter,
          vertical: spaceSm,
        ),
      ),

      // Bottom Navigation – glassmorphism feel
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cs.surface.withAlpha(230),
        selectedItemColor: cs.primary,
        unselectedItemColor: AppColors.mutedSage,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
      ),

      // Divider – 0.5px muted sage
      dividerTheme: DividerThemeData(
        color: AppColors.mutedSage.withAlpha(80),
        thickness: 0.5,
        space: spaceMd,
      ),

      // Page transitions – slow ease-in-out fades (300ms)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
