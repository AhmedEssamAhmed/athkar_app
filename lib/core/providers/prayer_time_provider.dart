import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/prayer_time_service.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
import '../../modules/prayer_module.dart';
import '../providers/settings_provider.dart';

class PrayerTimeProvider extends ChangeNotifier {
  final PrayerTimeService _prayerService = PrayerTimeService();
  final NotificationService _notificationService = NotificationService();

  List<PrayerTime> _prayers = [];
  HijriDate _hijriDate = const HijriDate(
    day: 1,
    monthName: 'Muharram',
    monthNameAr: 'محرم',
    year: 1447,
  );
  String _midnightTime = '--:--';
  String _lastThirdTime = '--:--';
  String _duhaTime = '--:--';
  String _fourthSixthTime = '--:--';
  String _morningAthkarTime = '--:--';
  String _eveningAthkarTime = '--:--';
  bool _isLoading = true;
  String? _error;
  String _locationName = '';
  bool _isArabic = false;

  List<PrayerTime> get prayers => _prayers;
  HijriDate get hijriDate => _hijriDate;
  String get midnightTime => _midnightTime;
  String get lastThirdTime => _lastThirdTime;
  String get duhaTime => _duhaTime;
  String get fourthSixthTime => _fourthSixthTime;
  String get morningAthkarTime => _morningAthkarTime;
  String get eveningAthkarTime => _eveningAthkarTime;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get locationName => _locationName;

  DateTime? get fajrTime => _prayerService.fajrTime;
  DateTime? get dhuhrTime => _prayerService.dhuhrTime;
  DateTime? get asrTime => _prayerService.asrTime;
  DateTime? get maghribTime => _prayerService.maghribTime;
  DateTime? get ishaTime => _prayerService.ishaTime;
  DateTime? get sunriseTime => _prayerService.sunriseTime;

  Future<void> init() async {
    final cached = await LocationService().tryGetCached();
    if (cached != null) {
      _prayerService.setCoordinates(cached.latitude, cached.longitude);
      _updatePrayerTimes();
      notifyListeners();
    }
    await _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final locService = LocationService();
      final cached = await locService.tryGetCached();
      final result = await locService.resolve();

      if (result.isSuccess) {
        _prayerService.setCoordinates(result.latitude, result.longitude);
        _locationName = result.cityName;
        _error = null;
        _updatePrayerTimes();
      } else {
        _error = result.error;
        if (cached != null) {
          _prayerService.setCoordinates(cached.latitude, cached.longitude);
          _locationName = cached.cityName;
          _updatePrayerTimes();
        } else {
          _prayerService.setDefaultLocation();
          _locationName = 'Makkah';
        }
      }
    } catch (e) {
      _error = e.toString();
      if (!_prayerService.isLocationSet) {
        _prayerService.setDefaultLocation();
        _updatePrayerTimes();
      }
    } finally {
      await _scheduleAllNotifications();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updatePrayerTimes() {
    final now = DateTime.now();

    final prayerList = [
      {
        'name': 'Fajr',
        'nameAr': 'الفجر',
        'time': _prayerService.fajrTime,
      },
      {
        'name': 'Sunrise',
        'nameAr': 'الشروق',
        'time': _prayerService.sunriseTime,
      },
      {
        'name': 'Dhuhr',
        'nameAr': 'الظهر',
        'time': _prayerService.dhuhrTime,
      },
      {
        'name': 'Asr',
        'nameAr': 'العصر',
        'time': _prayerService.asrTime,
      },
      {
        'name': 'Maghrib',
        'nameAr': 'المغرب',
        'time': _prayerService.maghribTime,
      },
      {
        'name': 'Isha',
        'nameAr': 'العشاء',
        'time': _prayerService.ishaTime,
      },
    ];

    String? nextPrayerTime;
    for (final p in prayerList) {
      final t = p['time'] as DateTime?;
      if (t != null && t.isAfter(now)) {
        nextPrayerTime = _prayerService.formatTime(t, isArabic: _isArabic);
        break;
      }
    }

    _prayers = prayerList.map((p) {
      final t = p['time'] as DateTime?;
      final timeStr = _prayerService.formatTime(t, isArabic: _isArabic);
      bool isPassed = false;
      bool isCurrent = false;

      if (t != null) {
        isPassed = t.isBefore(now);
        final idx = prayerList.indexOf(p);
        if (!isPassed) {
          isCurrent = nextPrayerTime == timeStr;
        }
        if (isPassed && idx < prayerList.length - 1) {
          final next = prayerList[idx + 1]['time'] as DateTime?;
          if (next != null && next.isAfter(now)) {
            isCurrent = true;
          }
        }
        if (idx == prayerList.length - 1 && isPassed) {
          isCurrent = false;
        }
      }

      return PrayerTime(
        name: p['name'] as String,
        nameAr: p['nameAr'] as String,
        time: timeStr,
        isCurrent: isCurrent,
        isPassed: isPassed,
      );
    }).toList();

    _hijriDate = _prayerService.getHijriDate();
    _midnightTime = _prayerService.formatTime(
      _prayerService.midnightTime,
      isArabic: _isArabic,
    );

    _lastThirdTime = _prayerService.formatTime(
      _prayerService.lastThirdOfNightTime,
      isArabic: _isArabic,
    );

    _duhaTime = _prayerService.formatTime(
      _prayerService.duhaTime,
      isArabic: _isArabic,
    );

    _fourthSixthTime = _prayerService.formatTime(
      _prayerService.fourthSixthOfNightTime,
      isArabic: _isArabic,
    );

    final fajr = _prayerService.fajrTime;
    final maghrib = _prayerService.maghribTime;
    final sunrise = _prayerService.sunriseTime;
    if (fajr != null) {
      _morningAthkarTime = _prayerService.formatTime(
        fajr.add(const Duration(minutes: 50)),
        isArabic: _isArabic,
      );
    }
    if (maghrib != null) {
      _eveningAthkarTime = _prayerService.formatTime(
        maghrib.add(const Duration(minutes: 25)),
        isArabic: _isArabic,
      );
    }
    if (sunrise != null) {
      _duhaTime = _prayerService.formatTime(
        sunrise.add(const Duration(minutes: 8)),
        isArabic: _isArabic,
      );
    }

    notifyListeners();
  }

  Future<void> _scheduleAllNotifications() async {
    try {
      await _notificationService.init();
    } catch (_) {
      return;
    }

    final fajr = _prayerService.fajrTime;
    final sunrise = _prayerService.sunriseTime;
    final maghrib = _prayerService.maghribTime;
    final hijriDate = _hijriDate;

    final prayerTimes = <String, DateTime>{};
    if (fajr != null) prayerTimes['fajr'] = fajr;
    if (sunrise != null) {
      prayerTimes['sunrise'] = sunrise;
    }
    if (_prayerService.dhuhrTime != null) {
      prayerTimes['dhuhr'] = _prayerService.dhuhrTime!;
    }
    if (_prayerService.asrTime != null) {
      prayerTimes['asr'] = _prayerService.asrTime!;
    }
    if (maghrib != null) {
      prayerTimes['maghrib'] = maghrib;
    }
    if (_prayerService.ishaTime != null) {
      prayerTimes['isha'] = _prayerService.ishaTime!;
    }

    for (final name in prayerTimes.keys) {
      await _notificationService.cancelNotification('prayer_$name');
      await _notificationService.cancelNotification('pre_prayer_$name');
    }

    final prefs = await SharedPreferences.getInstance();
    final prayerNotificationsEnabled =
        prefs.getBool(SettingsProvider.prayerNotificationsPrefsKey) ?? true;
    if (prayerNotificationsEnabled) {
      try {
        await _notificationService.schedulePrayerNotifications(prayerTimes);
      } catch (_) {}
    }

    if (sunrise != null) {
      try {
        await _notificationService.scheduleDuhaNotification(sunrise);
      } catch (_) {}
    }

    await _notificationService.cancelNotification('morning_athkar');
    await _notificationService.cancelNotification('evening_athkar');

    final athkarRemindersEnabled =
        prefs.getBool(SettingsProvider.athkarRemindersPrefsKey) ?? true;
    if (athkarRemindersEnabled) {
      if (fajr != null) {
        try {
          await _notificationService.scheduleMorningAthkar(fajr);
        } catch (_) {}
      }

      if (maghrib != null) {
        try {
          await _notificationService.scheduleEveningAthkar(maghrib);
        } catch (_) {}
      }
    }

    if (maghrib != null && fajr != null) {
      try {
        await _notificationService.scheduleMidnightNotification(maghrib, fajr);
      } catch (_) {}
      try {
        await _notificationService.scheduleLastThirdNotification(maghrib, fajr);
      } catch (_) {}
      try {
        await _notificationService.scheduleFourthSixthNotification(maghrib, fajr);
      } catch (_) {}
    }

    if (maghrib != null) {
      try {
        await _notificationService.scheduleFastingMonThuReminders(maghrib);
      } catch (_) {}
      try {
        await _notificationService.scheduleWhiteDaysReminder(
            maghrib, hijriDate.day);
      } catch (_) {}
      try {
        await _notificationService.scheduleMonthEntranceReminder(
            maghrib, hijriDate.day);
      } catch (_) {}
    }

    try {
      await _notificationService.scheduleSurahKahfReminder();
    } catch (_) {}

    if (prayerTimes.isNotEmpty) {
      try {
        await _notificationService.reschedulePrayerRelativeNotifications(prayerTimes);
      } catch (_) {}
    }
  }

  void checkForNewDay() {
    if (_prayerService.isNewDay) {
      refresh();
    }
  }

  Future<void> refresh() async {
    await _loadPrayerTimes();
  }

  Future<void> rescheduleNotifications() async {
    await _scheduleAllNotifications();
  }

  Future<void> setLocation(double lat, double lng) async {
    _prayerService.setCoordinates(lat, lng);
    final locService = LocationService();
    await locService.cacheLocation(lat, lng);
    _locationName = await locService.resolveCityName(lat, lng);
    _updatePrayerTimes();
    await _scheduleAllNotifications();
    notifyListeners();
  }

  void setLanguage({required bool isArabic}) {
    if (_isArabic == isArabic) return;

    _isArabic = isArabic;
    _updatePrayerTimes();
  }
}
