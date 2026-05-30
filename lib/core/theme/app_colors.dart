import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ──────────────────────── Premium Palette ────────────────────────
  // Deep forest greens + warm gold + cream — spiritual, warm, premium.

  static const Color primaryDeep = Color(0xFF0A3D2C);
  static const Color primaryDark = Color(0xFF145C3C);
  static const Color primary = Color(0xFF1E7A4B);
  static const Color primaryLight = Color(0xFF4CAF6E);
  static const Color primarySurface = Color(0xFFE8F5E9);

  static const Color gold = Color(0xFFC99B3B);
  static const Color goldLight = Color(0xFFF0D48B);
  static const Color goldSurface = Color(0xFFFFF8E1);

  static const Color cream = Color(0xFFFAF7F2);
  static const Color sand = Color(0xFFEDE6D8);
  static const Color warmWhite = Color(0xFFFDFBF9);

  static const Color darkText = Color(0xFF1B1B1B);
  static const Color mutedText = Color(0xFF7A7A7A);

  static const Color surfaceLight = Color(0xFFF8F5F0);
  static const Color surfaceDark = Color(0xFF121212);

  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  static const Color error = Color(0xFFBA1A1A);

  // ──────────────────────── Material Color Schemes ─────────────────

  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primarySurface,
    onPrimaryContainer: primaryDeep,
    secondary: gold,
    onSecondary: Colors.white,
    secondaryContainer: goldSurface,
    onSecondaryContainer: Color(0xFF3D2E00),
    tertiary: Color(0xFF5C6B5A),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFDFF2DC),
    onTertiaryContainer: Color(0xFF192219),
    error: error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: warmWhite,
    onSurface: darkText,
    surfaceContainerHighest: sand,
    outline: Color(0xFFB8B0A8),
    outlineVariant: Color(0xFFDBD3CB),
    inverseSurface: Color(0xFF303030),
    onInverseSurface: Color(0xFFF2EFEA),
    inversePrimary: Color(0xFF8ED4B2),
    surfaceTint: primary,
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF8ED4B2),
    onPrimary: Color(0xFF003823),
    primaryContainer: Color(0xFF005234),
    onPrimaryContainer: Color(0xFFAAF1CD),
    secondary: Color(0xFFF0D48B),
    onSecondary: Color(0xFF3D2E00),
    secondaryContainer: Color(0xFF5C4400),
    onSecondaryContainer: Color(0xFFFFDEA3),
    tertiary: Color(0xFFC3D6BF),
    onTertiary: Color(0xFF2D382D),
    tertiaryContainer: Color(0xFF434F42),
    onTertiaryContainer: Color(0xFFDFF2DB),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE5E1DC),
    surfaceContainerHighest: Color(0xFF3C3C3C),
    outline: Color(0xFF8A8A8A),
    outlineVariant: Color(0xFF444444),
    inverseSurface: Color(0xFFE5E1DC),
    onInverseSurface: Color(0xFF303030),
    inversePrimary: Color(0xFF1E7A4B),
    surfaceTint: Color(0xFF8ED4B2),
  );

  // ──────────────────────── Legacy Accents (keep for compat) ────────
  static const Color goldenAccent = gold;
  static const Color mutedSage = Color(0xFF8FA99B);

  // ──────────────────────── Decorative ─────────────────────────────
  static const Color glassWhite = Color(0xB3FFFFFF);
  static const Color glassWhiteHeavy = Color(0x80FFFFFF);
  static const Color glassDark = Color(0xB31E1E1E);
}
