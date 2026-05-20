import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

/// PrayerModule — Handles prayer time data and Hijri date computation.

class PrayerTime {
  final String name;
  final String nameAr;
  final String time;
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

class PrayerData {
  /// Default fallback location: Damanhur, Egypt.
  /// Used only if GPS fails or permission is denied.
  static const double defaultLatitude = 31.0341;
  static const double defaultLongitude = 30.4682;
  static const String defaultLocationName = 'Damanhur, Egypt';

  static List<PrayerTime> todayPrayers({
    required double latitude,
    required double longitude,
  }) {
    final coordinates = Coordinates(latitude, longitude);

    // Egyptian prayer calculation method.
    final params = CalculationMethod.egyptian.getParameters();

    // Common default. Change to Madhab.hanafi if required.
    params.madhab = Madhab.shafi;

    final date = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(coordinates, date, params);

    final now = DateTime.now();

    final rawPrayers = [
      _RawPrayer('Fajr', 'الفجر', prayerTimes.fajr),
      _RawPrayer('Sunrise', 'الشروق', prayerTimes.sunrise),
      _RawPrayer('Dhuhr', 'الظهر', prayerTimes.dhuhr),
      _RawPrayer('Asr', 'العصر', prayerTimes.asr),
      _RawPrayer('Maghrib', 'المغرب', prayerTimes.maghrib),
      _RawPrayer('Isha', 'العشاء', prayerTimes.isha),
    ];

    final currentIndex = _getCurrentPrayerIndex(rawPrayers, now);

    return List.generate(rawPrayers.length, (index) {
      final prayer = rawPrayers[index];

      return PrayerTime(
        name: prayer.name,
        nameAr: prayer.nameAr,
        time: _format12Hour(prayer.dateTime),
        isCurrent: index == currentIndex,
        isPassed: prayer.dateTime.isBefore(now),
      );
    });
  }

  static String _format12Hour(DateTime time) {
    return DateFormat.jm().format(time);
  }

  static int _getCurrentPrayerIndex(List<_RawPrayer> prayers, DateTime now) {
    int currentIndex = prayers.length - 1;

    for (int i = 0; i < prayers.length; i++) {
      if (now.isBefore(prayers[i].dateTime)) {
        return i == 0 ? prayers.length - 1 : i - 1;
      }
    }

    return currentIndex;
  }

  static HijriDate todayHijri() {
    // Temporary until you implement real Hijri calculation later.
    return const HijriDate(
      day: 11,
      monthName: 'Dhul Qi\'dah',
      monthNameAr: 'ذو القعدة',
      year: 1447,
    );
  }
}

class _RawPrayer {
  final String name;
  final String nameAr;
  final DateTime dateTime;

  const _RawPrayer(this.name, this.nameAr, this.dateTime);
}
