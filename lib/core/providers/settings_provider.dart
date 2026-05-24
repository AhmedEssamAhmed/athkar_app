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
  static const _keyHapticEnabled = 'haptic_enabled';
  static const prayerNotificationsPrefsKey = 'prayer_notifications_enabled';
  static const athkarRemindersPrefsKey = 'athkar_reminders_enabled';

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ar');
  bool _isOnboarded = false;
  HijriCalendarMethod _hijriMethod = HijriCalendarMethod.ummAlQura;
  bool _hapticEnabled = true;
  bool _prayerNotificationsEnabled = true;
  bool _athkarRemindersEnabled = true;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isOnboarded => _isOnboarded;
  HijriCalendarMethod get hijriMethod => _hijriMethod;
  bool get hapticEnabled => _hapticEnabled;
  bool get prayerNotificationsEnabled => _prayerNotificationsEnabled;
  bool get athkarRemindersEnabled => _athkarRemindersEnabled;
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
    } else {
      await prefs.setString(_keyLocale, 'ar');
    }

    _isOnboarded = prefs.getBool(_keyOnboarded) ?? false;

    final savedHijri = prefs.getString(_keyHijriMethod);
    if (savedHijri != null) {
      _hijriMethod = HijriCalendarMethod.values.firstWhere(
        (m) => m.name == savedHijri,
        orElse: () => HijriCalendarMethod.ummAlQura,
      );
    }

    _hapticEnabled = prefs.getBool(_keyHapticEnabled) ?? true;
    _prayerNotificationsEnabled =
        prefs.getBool(prayerNotificationsPrefsKey) ?? true;
    _athkarRemindersEnabled = prefs.getBool(athkarRemindersPrefsKey) ?? true;

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

  Future<void> setHapticEnabled(bool enabled) async {
    _hapticEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHapticEnabled, enabled);
  }

  Future<void> setPrayerNotificationsEnabled(bool enabled) async {
    _prayerNotificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prayerNotificationsPrefsKey, enabled);
  }

  Future<void> setAthkarRemindersEnabled(bool enabled) async {
    _athkarRemindersEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(athkarRemindersPrefsKey, enabled);
  }
}
