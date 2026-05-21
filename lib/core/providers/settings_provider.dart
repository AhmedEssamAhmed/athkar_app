import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HijriCalendarMethod {
  ummAlQura('Umm al-Qura (Egypt/Saudi)', 'أم القرى (مصر/السعودية)'),
  egyptian('Egyptian', 'المصري'),
  islamicTakanobu('Islamic Takanobu', 'تقنية إسلامية');

  final String labelEn;
  final String labelAr;
  const HijriCalendarMethod(this.labelEn, this.labelAr);
}

class SettingsProvider extends ChangeNotifier {
  static const _keyThemeMode = 'theme_mode';
  static const _keyLocale = 'locale';
  static const _keyOnboarded = 'is_onboarded';
  static const _keyHijriMethod = 'hijri_method';

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ar');
  bool _isOnboarded = false;
  HijriCalendarMethod _hijriMethod = HijriCalendarMethod.ummAlQura;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isOnboarded => _isOnboarded;
  HijriCalendarMethod get hijriMethod => _hijriMethod;
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

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

    final savedHijri = prefs.getString(_keyHijriMethod);
    if (savedHijri != null) {
      _hijriMethod = HijriCalendarMethod.values.firstWhere(
        (m) => m.name == savedHijri,
        orElse: () => HijriCalendarMethod.ummAlQura,
      );
    }

    notifyListeners();
  }

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

  Future<void> setHijriMethod(HijriCalendarMethod method) async {
    _hijriMethod = method;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHijriMethod, method.name);
  }
}
