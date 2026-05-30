import 'package:flutter/material.dart';

class PrayerNames {
  PrayerNames._();

  static const List<String> keys = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'];

  static const Map<String, ({String en, String ar})> names = {
    'fajr': (en: 'Fajr', ar: 'الفجر'),
    'sunrise': (en: 'Sunrise', ar: 'الشروق'),
    'dhuhr': (en: 'Dhuhr', ar: 'الظهر'),
    'asr': (en: 'Asr', ar: 'العصر'),
    'maghrib': (en: 'Maghrib', ar: 'المغرب'),
    'isha': (en: 'Isha', ar: 'العشاء'),
  };

  static const Map<String, IconData> icons = {
    'Fajr': Icons.wb_sunny_rounded,
    'Sunrise': Icons.sunny,
    'Dhuhr': Icons.wb_cloudy_rounded,
    'Asr': Icons.cloud_rounded,
    'Maghrib': Icons.nightlight_round,
    'Isha': Icons.nights_stay_rounded,
  };
}
