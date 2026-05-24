import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/prayer_time_service.dart';
import '../services/notification_service.dart';
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
    await _requestLocationPermission();
    await _loadPrayerTimes();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await Permission.location.request();
    }
  }

  Future<void> _loadPrayerTimes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      LocationPermission permission;
      bool useLocation = false;

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        useLocation = true;
      }

      final prefs = await SharedPreferences.getInstance();
      final savedLat = prefs.getDouble('user_lat');
      final savedLng = prefs.getDouble('user_lng');

      if (useLocation) {
        final position = await Geolocator.getCurrentPosition();
        _prayerService.setCoordinates(position.latitude, position.longitude);
        await prefs.setDouble('user_lat', position.latitude);
        await prefs.setDouble('user_lng', position.longitude);
        _locationName = await _resolveLocationName(
          position.latitude,
          position.longitude,
        );
      } else if (savedLat != null && savedLng != null) {
        _prayerService.setCoordinates(savedLat, savedLng);
        _locationName = await _resolveLocationName(savedLat, savedLng);
      } else {
        _prayerService.setDefaultLocation();
        _locationName = _prayerService.getCityName();
      }

      _updatePrayerTimes();
      await _scheduleAllNotifications();
    } catch (e) {
      _error = e.toString();
      _prayerService.setDefaultLocation();
      _updatePrayerTimes();
    } finally {
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
    await _notificationService.init();

    final fajr = _prayerService.fajrTime;
    final sunrise = _prayerService.sunriseTime;
    final maghrib = _prayerService.maghribTime;
    final hijriDate = _hijriDate;

    final prayerTimes = <String, DateTime>{};
    if (fajr != null) prayerTimes['fajr'] = fajr;
    if (sunrise != null) prayerTimes['sunrise'] = sunrise;
    if (_prayerService.dhuhrTime != null)
      prayerTimes['dhuhr'] = _prayerService.dhuhrTime!;
    if (_prayerService.asrTime != null)
      prayerTimes['asr'] = _prayerService.asrTime!;
    if (maghrib != null) prayerTimes['maghrib'] = maghrib;
    if (_prayerService.ishaTime != null)
      prayerTimes['isha'] = _prayerService.ishaTime!;

    for (final name in prayerTimes.keys) {
      await _notificationService.cancelNotification('prayer_$name');
    }

    final prefs = await SharedPreferences.getInstance();
    final prayerNotificationsEnabled =
        prefs.getBool(SettingsProvider.prayerNotificationsPrefsKey) ?? true;
    if (prayerNotificationsEnabled) {
      await _notificationService.schedulePrayerNotifications(prayerTimes);
    }

    if (sunrise != null) {
      await _notificationService.scheduleDuhaNotification(sunrise);
    }

    await _notificationService.cancelNotification('morning_athkar');
    await _notificationService.cancelNotification('evening_athkar');

    final athkarRemindersEnabled =
        prefs.getBool(SettingsProvider.athkarRemindersPrefsKey) ?? true;
    if (athkarRemindersEnabled) {
      if (fajr != null) {
        await _notificationService.scheduleMorningAthkar(fajr);
      }

      if (maghrib != null) {
        await _notificationService.scheduleEveningAthkar(maghrib);
      }
    }

    if (maghrib != null && fajr != null) {
      await _notificationService.scheduleMidnightNotification(maghrib, fajr);
      await _notificationService.scheduleLastThirdNotification(maghrib, fajr);
      await _notificationService.scheduleFourthSixthNotification(maghrib, fajr);
    }

    if (maghrib != null) {
      await _notificationService.scheduleFastingMonThuReminders(maghrib);
      await _notificationService.scheduleWhiteDaysReminder(
          maghrib, hijriDate.day);
      await _notificationService.scheduleMonthEntranceReminder(
          maghrib, hijriDate.day);
    }

    await _notificationService.scheduleSurahKahfReminder();
  }

  Future<void> refresh() async {
    await _loadPrayerTimes();
  }

  Future<void> rescheduleNotifications() async {
    await _scheduleAllNotifications();
  }

  Future<void> setLocation(double lat, double lng) async {
    _prayerService.setCoordinates(lat, lng);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_lat', lat);
    await prefs.setDouble('user_lng', lng);
    _locationName = await _resolveLocationName(lat, lng);
    _updatePrayerTimes();
    await _scheduleAllNotifications();
    notifyListeners();
  }

  Future<String> _resolveLocationName(double lat, double lng) async {
    final fallback = '${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)}';

    try {
      final places = await placemarkFromCoordinates(lat, lng);
      if (places.isEmpty) return fallback;

      final place = places.first;
      final city = [
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
        place.country,
      ].firstWhere(
        (value) => value != null && value.trim().isNotEmpty,
        orElse: () => null,
      );
      final country = place.country;

      if (city == null) return fallback;
      if (country == null || country.trim().isEmpty || city == country) {
        return city;
      }

      return '$city, $country';
    } catch (_) {
      return fallback;
    }
  }

  Future<void> updateHijriMethod(HijriCalendarMethod method) async {
    _prayerService.setHijriMethod(method);
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
