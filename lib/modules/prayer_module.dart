// PrayerModule — Handles prayer time data and Hijri date computation.

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
  final int monthNumber;

  const HijriDate({
    required this.day,
    required this.monthName,
    required this.monthNameAr,
    required this.year,
    this.monthNumber = 1,
  });

  String get formatted => '$day $monthName $year AH';
  String get formattedAr => '$day $monthNameAr $year هـ';
}


