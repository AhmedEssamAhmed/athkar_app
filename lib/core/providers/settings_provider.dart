import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages global app settings: theme mode, locale (language), onboarding
/// state, and persists choices to SharedPreferences for offline use.
class SettingsProvider extends ChangeNotifier {
  static const _keyThemeMode = 'theme_mode';
  static const _keyLocale = 'locale';
  static const _keyOnboarded = 'is_onboarded';

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ar'); // Default to Arabic
  bool _isOnboarded = false;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isOnboarded => _isOnboarded;
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  /// Call once at app startup to hydrate from disk.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString(_keyThemeMode);
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }

    final savedLocale = prefs.getString(_keyLocale);
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    }

    _isOnboarded = prefs.getBool(_keyOnboarded) ?? false;

    notifyListeners();
  }

  /// Mark onboarding as complete so Splash skips it on next launch.
  Future<void> completeOnboarding() async {
    _isOnboarded = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarded, true);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.languageCode);
  }

  Future<void> toggleLanguage() async {
    final next = isArabic ? const Locale('en') : const Locale('ar');
    await setLocale(next);
  }

  Future<void> cycleTheme() async {
    final next = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }
}
