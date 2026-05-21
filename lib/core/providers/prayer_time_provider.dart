import 'package:flutter/foundation.dart';
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
  HijriDate _hijriDate = HijriDate(
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
        _locationName = '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      } else if (savedLat != null && savedLng != null) {
        _prayerService.setCoordinates(savedLat, savedLng);
        _locationName = '${savedLat.toStringAsFixed(2)}, ${savedLng.toStringAsFixed(2)}';
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
        nextPrayerTime = _prayerService.formatTime(t);
        break;
      }
    }

    _prayers = prayerList.map((p) {
      final t = p['time'] as DateTime?;
      final timeStr = _prayerService.formatTime(t);
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
    _midnightTime = _prayerService.formatTime(_prayerService.midnightTime);
    _lastThirdTime = _prayerService.formatTime(_prayerService.lastThirdOfNightTime);
    _duhaTime = _prayerService.formatTime(_prayerService.duhaTime);
    _fourthSixthTime = _prayerService.formatTime(_prayerService.fourthSixthOfNightTime);
    
    final fajr = _prayerService.fajrTime;
    final maghrib = _prayerService.maghribTime;
    final sunrise = _prayerService.sunriseTime;
    if (fajr != null) {
      _morningAthkarTime = _prayerService.formatTime(fajr.add(const Duration(minutes: 50)));
    }
    if (maghrib != null) {
      _eveningAthkarTime = _prayerService.formatTime(maghrib.add(const Duration(minutes: 25)));
    }
    if (sunrise != null) {
      _duhaTime = _prayerService.formatTime(sunrise.add(const Duration(minutes: 8)));
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
    if (_prayerService.dhuhrTime != null) prayerTimes['dhuhr'] = _prayerService.dhuhrTime!;
    if (_prayerService.asrTime != null) prayerTimes['asr'] = _prayerService.asrTime!;
    if (maghrib != null) prayerTimes['maghrib'] = maghrib;
    if (_prayerService.ishaTime != null) prayerTimes['isha'] = _prayerService.ishaTime!;

    await _notificationService.schedulePrayerNotifications(prayerTimes);
    
    if (sunrise != null) {
      await _notificationService.scheduleDuhaNotification(sunrise);
    }
    
    if (fajr != null) {
      await _notificationService.scheduleMorningAthkar(fajr);
    }
    
    if (maghrib != null) {
      await _notificationService.scheduleEveningAthkar(maghrib);
    }
    
    if (maghrib != null && fajr != null) {
      await _notificationService.scheduleMidnightNotification(maghrib, fajr);
      await _notificationService.scheduleLastThirdNotification(maghrib, fajr);
      await _notificationService.scheduleFourthSixthNotification(maghrib, fajr);
    }
    
    if (maghrib != null) {
      await _notificationService.scheduleFastingMonThuReminders(maghrib);
      await _notificationService.scheduleWhiteDaysReminder(maghrib, hijriDate.day);
      await _notificationService.scheduleMonthEntranceReminder(maghrib, hijriDate.day);
    }
    
    await _notificationService.scheduleSurahKahfReminder();
  }

  Future<void> refresh() async {
    await _loadPrayerTimes();
  }

  Future<void> setLocation(double lat, double lng) async {
    _prayerService.setCoordinates(lat, lng);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_lat', lat);
    await prefs.setDouble('user_lng', lng);
    _locationName = '${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)}';
    _updatePrayerTimes();
    await _scheduleAllNotifications();
    notifyListeners();
  }

  Future<void> updateHijriMethod(HijriCalendarMethod method) async {
    _prayerService.setHijriMethod(method);
    _updatePrayerTimes();
    await _scheduleAllNotifications();
    notifyListeners();
  }
}
