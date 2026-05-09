import 'package:flutter/material.dart';

/// Design tokens extracted from the Stitch "Athkar App Design System".
/// All color values map 1:1 to the `namedColors` in the design system.
class AppColors {
  AppColors._();

  // ──────────────────────────── Light mode ────────────────────────────

  static const Color primaryLight = Color(0xFF004337);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFF0F5C4D);
  static const Color onPrimaryContainerLight = Color(0xFF8ED2BF);

  static const Color secondaryLight = Color(0xFF7A5900);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFFFFCA5A);
  static const Color onSecondaryContainerLight = Color(0xFF745400);

  static const Color tertiaryLight = Color(0xFF284035);
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFF3F574B);
  static const Color onTertiaryContainerLight = Color(0xFFB1CBBD);

  static const Color errorLight = Color(0xFFBA1A1A);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color errorContainerLight = Color(0xFFFFDAD6);
  static const Color onErrorContainerLight = Color(0xFF93000A);

  static const Color surfaceLight = Color(0xFFFCF9F8);
  static const Color onSurfaceLight = Color(0xFF1B1B1C);
  static const Color surfaceVariantLight = Color(0xFFE5E2E1);
  static const Color onSurfaceVariantLight = Color(0xFF3F4945);
  static const Color surfaceContainerLight = Color(0xFFF0EDED);
  static const Color surfaceContainerHighLight = Color(0xFFEAE7E7);
  static const Color surfaceContainerHighestLight = Color(0xFFE5E2E1);
  static const Color surfaceContainerLowLight = Color(0xFFF6F3F2);
  static const Color surfaceContainerLowestLight = Color(0xFFFFFFFF);

  static const Color outlineLight = Color(0xFF6F7975);
  static const Color outlineVariantLight = Color(0xFFBFC9C4);
  static const Color inverseSurfaceLight = Color(0xFF303030);
  static const Color inverseOnSurfaceLight = Color(0xFFF3F0EF);
  static const Color inversePrimaryLight = Color(0xFF8FD4C1);
  static const Color surfaceTintLight = Color(0xFF22695A);

  // ──────────────────────────── Dark mode ─────────────────────────────
  // Dark mode: primary ↔ inversePrimary, surface → dark tones, etc.

  static const Color primaryDark = Color(0xFF8FD4C1);
  static const Color onPrimaryDark = Color(0xFF002019);
  static const Color primaryContainerDark = Color(0xFF005143);
  static const Color onPrimaryContainerDark = Color(0xFFABF0DC);

  static const Color secondaryDark = Color(0xFFF3BF50);
  static const Color onSecondaryDark = Color(0xFF261900);
  static const Color secondaryContainerDark = Color(0xFF5C4200);
  static const Color onSecondaryContainerDark = Color(0xFFFFDEA3);

  static const Color tertiaryDark = Color(0xFFB2CDBE);
  static const Color onTertiaryDark = Color(0xFF082016);
  static const Color tertiaryContainerDark = Color(0xFF344C40);
  static const Color onTertiaryContainerDark = Color(0xFFCEE9D9);

  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color onErrorDark = Color(0xFF690005);
  static const Color errorContainerDark = Color(0xFF93000A);
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  static const Color surfaceDark = Color(0xFF121212);
  static const Color onSurfaceDark = Color(0xFFE5E2E1);
  static const Color surfaceVariantDark = Color(0xFF3F4945);
  static const Color onSurfaceVariantDark = Color(0xFFBFC9C4);
  static const Color surfaceContainerDark = Color(0xFF1E1E1E);
  static const Color surfaceContainerHighDark = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighestDark = Color(0xFF353535);
  static const Color surfaceContainerLowDark = Color(0xFF1A1A1A);
  static const Color surfaceContainerLowestDark = Color(0xFF0E0E0E);

  static const Color outlineDark = Color(0xFF899A94);
  static const Color outlineVariantDark = Color(0xFF3F4945);
  static const Color inverseSurfaceDark = Color(0xFFE5E2E1);
  static const Color inverseOnSurfaceDark = Color(0xFF303030);
  static const Color inversePrimaryDark = Color(0xFF004337);
  static const Color surfaceTintDark = Color(0xFF8FD4C1);

  // ──────────────────────────── Brand accents ─────────────────────────
  /// Golden accent – used sparingly for tasbeeh highlights & progress.
  static const Color goldenAccent = Color(0xFFE8B547);

  /// Muted sage – inactive states, dividers.
  static const Color mutedSage = Color(0xFF8FA99B);
}
