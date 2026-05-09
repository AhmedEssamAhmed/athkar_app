/// PrayerModule — Handles prayer time data and Hijri date computation.
///
/// In production, integrate with the Adhan package or Al Adhan API.
/// This module provides the data model and a mock implementation
/// for the Dashboard screen.
class PrayerTime {
  final String name;
  final String nameAr;
  final String time; // formatted HH:mm
  final bool isCurrent;
  final bool isPassed;

  const PrayerTime({
    required this.name,
    required this.nameAr,
    required this.time,
    this.isCurrent = false,
    this.isPassed = false,
  });
}

/// Simple Hijri date representation.
class HijriDate {
  final int day;
  final String monthName;
  final String monthNameAr;
  final int year;

  const HijriDate({
    required this.day,
    required this.monthName,
    required this.monthNameAr,
    required this.year,
  });

  String get formatted => '$day $monthName $year AH';
  String get formattedAr => '$day $monthNameAr $year هـ';
}

/// Mock data provider — replace with actual calculation library.
class PrayerData {
  static List<PrayerTime> todayPrayers() => const [
        PrayerTime(name: 'Fajr', nameAr: 'الفجر', time: '04:23', isPassed: true),
        PrayerTime(name: 'Sunrise', nameAr: 'الشروق', time: '05:48', isPassed: true),
        PrayerTime(name: 'Dhuhr', nameAr: 'الظهر', time: '12:15', isPassed: true),
        PrayerTime(name: 'Asr', nameAr: 'العصر', time: '15:42', isCurrent: true),
        PrayerTime(name: 'Maghrib', nameAr: 'المغرب', time: '18:51'),
        PrayerTime(name: 'Isha', nameAr: 'العشاء', time: '20:18'),
      ];

  static HijriDate todayHijri() => const HijriDate(
        day: 11,
        monthName: 'Dhul Qi\'dah',
        monthNameAr: 'ذو القعدة',
        year: 1447,
      );
}
