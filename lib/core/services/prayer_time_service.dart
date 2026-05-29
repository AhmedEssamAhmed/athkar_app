import 'package:adhan/adhan.dart';
import 'package:hijri_date/hijri_date.dart' as hijri_pkg;

import '../../modules/prayer_module.dart';
import '../providers/settings_provider.dart';

class PrayerTimeService {
  static final PrayerTimeService _instance = PrayerTimeService._internal();
  factory PrayerTimeService() => _instance;
  PrayerTimeService._internal();

  Coordinates? _coordinates;
  PrayerTimes? _prayerTimes;
  DateTime? _date;
  DateTime? _calculationDate;
  HijriCalendarMethod _hijriMethod = HijriCalendarMethod.ummAlQura;

  static const double _defaultLatitude = 21.4225;
  static const double _defaultLongitude = 39.8262;
  static const String _defaultCity = 'Makkah';

  bool get isLocationSet => _coordinates != null;

  void setCoordinates(double latitude, double longitude) {
    _coordinates = Coordinates(latitude, longitude);
    _calculatePrayerTimes();
  }

  void setDefaultLocation() {
    _coordinates = Coordinates(_defaultLatitude, _defaultLongitude);
    _calculatePrayerTimes();
  }

  void setHijriMethod(HijriCalendarMethod method) {
    _hijriMethod = method;
    // Note: The Hijri calculation currently uses the hijri_date package directly
    // and doesn't use the _hijriMethod field. This is kept for future implementation.
  }

  bool get isNewDay {
    final now = DateTime.now();
    return _calculationDate == null ||
        _calculationDate!.year != now.year ||
        _calculationDate!.month != now.month ||
        _calculationDate!.day != now.day;
  }

  void _calculatePrayerTimes() {
    if (_coordinates == null) return;

    final now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
    _calculationDate = _date;

    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;

    _prayerTimes = PrayerTimes(
      _coordinates!,
      DateComponents(_date!.year, _date!.month, _date!.day),
      params,
    );
  }

  PrayerTimes? get prayerTimes => _prayerTimes;

  DateTime? get fajrTime => _prayerTimes?.fajr;
  DateTime? get sunriseTime => _prayerTimes?.sunrise;
  DateTime? get dhuhrTime => _prayerTimes?.dhuhr;
  DateTime? get asrTime => _prayerTimes?.asr;
  DateTime? get maghribTime => _prayerTimes?.maghrib;
  DateTime? get ishaTime => _prayerTimes?.isha;

  DateTime get duhaTime {
    final sunrise = sunriseTime;
    final dhuhr = dhuhrTime;
    if (sunrise == null || dhuhr == null) {
      return DateTime.now().copyWith(hour: 8, minute: 0);
    }
    final diff = dhuhr.difference(sunrise);
    return sunrise.add(diff ~/ 4);
  }

  DateTime get midnightTime {
    final maghrib = maghribTime;
    final fajr = fajrTime;
    if (maghrib == null || fajr == null) {
      return DateTime.now().copyWith(hour: 0, minute: 0);
    }
    final sunsetToNextFajr =
        fajr.add(const Duration(days: 1)).difference(maghrib);
    return maghrib.add(sunsetToNextFajr ~/ 2);
  }

  DateTime get lastThirdOfNightTime {
    final maghrib = maghribTime;
    final fajr = fajrTime;
    if (maghrib == null || fajr == null) {
      return DateTime.now().copyWith(hour: 2, minute: 0);
    }
    final sunsetToNextFajr =
        fajr.add(const Duration(days: 1)).difference(maghrib);
    return maghrib.add((sunsetToNextFajr * 2) ~/ 3);
  }

  DateTime get fourthSixthOfNightTime {
    final maghrib = maghribTime;
    final fajr = fajrTime;
    if (maghrib == null || fajr == null) {
      return DateTime.now().copyWith(hour: 2, minute: 0);
    }
    final sunsetToNextFajr =
        fajr.add(const Duration(days: 1)).difference(maghrib);
    return maghrib.add((sunsetToNextFajr * 3) ~/ 6);
  }

  HijriDate getHijriDate() {
    // Store the selected method for potential future use in Hijri calculations
    _hijriMethod; // Reference to suppress unused field warning
    final now = DateTime.now();
    final hijri = hijri_pkg.HijriDate.fromDate(now);
    return HijriDate(
      day: hijri.hDay,
      monthName: hijri.longMonthName,
      monthNameAr: _getArabicMonthName(hijri.hMonth),
      year: hijri.hYear,
      monthNumber: hijri.hMonth,
    );
  }

  String _getArabicMonthName(int month) {
    const months = [
      '',
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الثاني',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    return months[month];
  }

  String formatTime(DateTime? time, {bool isArabic = false}) {
    if (time == null) return '--:--';

    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');

    final hour12 = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;

    final period =
        hour < 12 ? (isArabic ? 'صباحاً' : 'AM') : (isArabic ? 'مساءً' : 'PM');

    return '$hour12:$minute $period';
  }

  String getCityName() {
    return _defaultCity;
  }
}
