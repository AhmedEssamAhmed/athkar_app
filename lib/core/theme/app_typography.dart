import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens from the Stitch "Athkar App Design System".
///
/// English UI → **Manrope** (via Google Fonts)
/// Arabic sacred text → **Amiri** (bundled asset) or Noto Sans Arabic
class AppTypography {
  AppTypography._();

  // ─────────────── English text styles (Manrope) ───────────────

  static TextStyle get displayLarge => GoogleFonts.manrope(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 48 / 40, // lineHeight / fontSize
        letterSpacing: -0.02 * 40, // -0.02em
      );

  static TextStyle get headlineLarge => GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
      );

  static TextStyle get headlineMedium => GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
      );

  static TextStyle get titleLarge => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
      );

  static TextStyle get bodyLarge => GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
      );

  static TextStyle get bodyMedium => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      );

  static TextStyle get labelLarge => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
      );

  // ─────────────── Arabic text styles (Amiri) ──────────────────
  // Arabic text is 20 % larger than its English equivalent per the DS.

  static TextStyle get arabicDisplay => const TextStyle(
        fontFamily: 'Amiri',
        fontSize: 48, // 40 × 1.2
        fontWeight: FontWeight.w700,
        height: 1.4,
      );

  static TextStyle get arabicHeadline => const TextStyle(
        fontFamily: 'Amiri',
        fontSize: 29, // 24 × 1.2
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get arabicBody => const TextStyle(
        fontFamily: 'Amiri',
        fontSize: 22, // 18 × 1.2
        fontWeight: FontWeight.w400,
        height: 1.8,
      );

  /// Builds the Material [TextTheme] for use in [ThemeData].
  static TextTheme textTheme(Color onSurface) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: onSurface),
      headlineLarge: headlineLarge.copyWith(color: onSurface),
      headlineMedium: headlineMedium.copyWith(color: onSurface),
      titleLarge: titleLarge.copyWith(color: onSurface),
      bodyLarge: bodyLarge.copyWith(color: onSurface),
      bodyMedium: bodyMedium.copyWith(color: onSurface),
      labelLarge: labelLarge.copyWith(color: onSurface),
      labelMedium: labelMedium.copyWith(color: onSurface),
    );
  }
}
