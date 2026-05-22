import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationCategory {
  prayer,
  duha,
  morningAthkar,
  eveningAthkar,
  midnight,
  lastThird,
  fourthSixth,
  fastingMonThu,
  whiteDays,
  monthEntrance,
  surahKahf,
  personal,
}

class ScheduledNotification {
  final String id;
  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final NotificationCategory category;
  final bool isEnabled;
  final int? hour;
  final int? minute;
  final List<int>? daysOfWeek;
  final int? dayOfMonth;
  final int? minutesAfterPrayer;
  final String? basePrayer;

  const ScheduledNotification({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.category,
    this.isEnabled = true,
    this.hour,
    this.minute,
    this.daysOfWeek,
    this.dayOfMonth,
    this.minutesAfterPrayer,
    this.basePrayer,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleEn': titleEn,
        'titleAr': titleAr,
        'bodyEn': bodyEn,
        'bodyAr': bodyAr,
        'category': category.name,
        'isEnabled': isEnabled,
        'hour': hour,
        'minute': minute,
        'daysOfWeek': daysOfWeek,
        'dayOfMonth': dayOfMonth,
        'minutesAfterPrayer': minutesAfterPrayer,
        'basePrayer': basePrayer,
      };

  factory ScheduledNotification.fromJson(Map<String, dynamic> json) {
    return ScheduledNotification(
      id: json['id'] as String,
      titleEn: json['titleEn'] as String,
      titleAr: json['titleAr'] as String,
      bodyEn: json['bodyEn'] as String,
      bodyAr: json['bodyAr'] as String,
      category: NotificationCategory.values.byName(json['category'] as String),
      isEnabled: json['isEnabled'] as bool? ?? true,
      hour: json['hour'] as int?,
      minute: json['minute'] as int?,
      daysOfWeek: json['daysOfWeek'] != null
          ? List<int>.from(json['daysOfWeek'] as List)
          : null,
      dayOfMonth: json['dayOfMonth'] as int?,
      minutesAfterPrayer: json['minutesAfterPrayer'] as int?,
      basePrayer: json['basePrayer'] as String?,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _prefsKey = 'scheduled_notifications';

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {}

  Future<void> showTestNotification({
    required String titleEn,
    required String titleAr,
    required String bodyEn,
    required String bodyAr,
  }) async {
    await _plugin.show(
      99999,
      titleEn,
      bodyEn,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'athkar_notifications',
          'Athkar Notifications',
          channelDescription: 'Notifications for prayers and athkar',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'titleAr:$titleAr,bodyAr:$bodyAr',
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<List<ScheduledNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_prefsKey) ?? [];
    return data
        .map((e) => ScheduledNotification.fromJson(
            Map<String, dynamic>.from(_decodeJsonString(e))))
        .toList();
  }

  Future<void> saveNotifications(List<ScheduledNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final data = notifications.map((n) => _encodeJsonMap(n.toJson())).toList();
    await prefs.setStringList(_prefsKey, data);
  }

  String _encodeJsonMap(Map<String, dynamic> map) {
    return map.entries.map((e) => '${e.key}:${e.value}').join(',');
  }

  Map<String, dynamic> _decodeJsonString(String str) {
    final map = <String, dynamic>{};
    for (final part in str.split(',')) {
      final kv = part.split(':');
      if (kv.length >= 2) {
        final key = kv[0];
        final value = kv.sublist(1).join(':');
        if (value == 'true') {
          map[key] = true;
        } else if (value == 'false') {
          map[key] = false;
        } else if (int.tryParse(value) != null) {
          map[key] = int.parse(value);
        } else if (value.startsWith('[') && value.endsWith(']')) {
          map[key] = value
              .substring(1, value.length - 1)
              .split(',')
              .map((e) => int.parse(e.trim()))
              .toList();
        } else {
          map[key] = value;
        }
      }
    }
    return map;
  }

  Future<void> schedulePrayerNotifications(
    Map<String, DateTime> prayerTimes,
  ) async {
    final prayerNames = {
      'fajr': ('Fajr Prayer', 'صلاة الفجر', 'It is time for Fajr prayer.', 'حان وقت صلاة الفجر.'),
      'sunrise': ('Sunrise', 'الشروق', 'The sun has risen.', 'لقد طلعت الشمس.'),
      'dhuhr': ('Dhuhr Prayer', 'صلاة الظهر', 'It is time for Dhuhr prayer.', 'حان وقت صلاة الظهر.'),
      'asr': ('Asr Prayer', 'صلاة العصر', 'It is time for Asr prayer.', 'حان وقت صلاة العصر.'),
      'maghrib': ('Maghrib Prayer', 'صلاة المغرب', 'It is time for Maghrib prayer.', 'حان وقت صلاة المغرب.'),
      'isha': ('Isha Prayer', 'صلاة العشاء', 'It is time for Isha prayer.', 'حان وقت صلاة العشاء.'),
    };

    for (final entry in prayerTimes.entries) {
      final name = entry.key;
      final time = entry.value;
      final names = prayerNames[name];
      if (names == null) continue;

      await _scheduleDaily(
        id: _hashString('prayer_$name'),
        titleEn: names.$1,
        titleAr: names.$2,
        bodyEn: names.$3,
        bodyAr: names.$4,
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  Future<void> scheduleDuhaNotification(DateTime sunriseTime) async {
    final duhaTime = sunriseTime.add(const Duration(minutes: 8));
    await _scheduleDaily(
      id: _hashString('duha_prayer'),
      titleEn: 'Duha Prayer',
      titleAr: 'صلاة الضحى',
      bodyEn: 'It is time for Duha prayer.',
      bodyAr: 'حان وقت صلاة الضحى.',
      hour: duhaTime.hour,
      minute: duhaTime.minute,
    );
  }

  Future<void> scheduleMorningAthkar(DateTime fajrTime) async {
    final time = fajrTime.add(const Duration(minutes: 50));
    await _scheduleDaily(
      id: _hashString('morning_athkar'),
      titleEn: 'Morning Athkar',
      titleAr: 'أذكار الصباح',
      bodyEn: 'Time for morning athkar and remembrance.',
      bodyAr: 'حان وقت أذكار الصباح والذكر.',
      hour: time.hour,
      minute: time.minute,
    );
  }

  Future<void> scheduleEveningAthkar(DateTime maghribTime) async {
    final time = maghribTime.add(const Duration(minutes: 25));
    await _scheduleDaily(
      id: _hashString('evening_athkar'),
      titleEn: 'Evening Athkar',
      titleAr: 'أذكار المساء',
      bodyEn: 'Time for evening athkar and remembrance.',
      bodyAr: 'حان وقت أذكار المساء والذكر.',
      hour: time.hour,
      minute: time.minute,
    );
  }

  Future<void> scheduleMidnightNotification(DateTime maghribTime, DateTime fajrTime) async {
    final sunsetToNextFajr = fajrTime.add(const Duration(days: 1)).difference(maghribTime);
    final midnight = maghribTime.add(sunsetToNextFajr ~/ 2);
    await _scheduleDaily(
      id: _hashString('midnight'),
      titleEn: 'Midnight',
      titleAr: 'منتصف الليل',
      bodyEn: 'It is midnight. A blessed time for prayer and remembrance.',
      bodyAr: 'إنه منتصف الليل. وقت مبارك للصلاة والذكر.',
      hour: midnight.hour,
      minute: midnight.minute,
    );
  }

  Future<void> scheduleLastThirdNotification(DateTime maghribTime, DateTime fajrTime) async {
    final sunsetToNextFajr = fajrTime.add(const Duration(days: 1)).difference(maghribTime);
    final lastThird = maghribTime.add((sunsetToNextFajr * 2) ~/ 3);
    await _scheduleDaily(
      id: _hashString('last_third'),
      titleEn: 'Last Third of Night',
      titleAr: 'الثلث الأخير من الليل',
      bodyEn: 'The last third of the night has begun. A time when Allah descends to the lowest heaven.',
      bodyAr: 'بدأ الثلث الأخير من الليل. وقت ينزل الله فيه إلى السماء الدنيا.',
      hour: lastThird.hour,
      minute: lastThird.minute,
    );
  }

  Future<void> scheduleFourthSixthNotification(DateTime maghribTime, DateTime fajrTime) async {
    final sunsetToNextFajr = fajrTime.add(const Duration(days: 1)).difference(maghribTime);
    final fourthSixth = maghribTime.add((sunsetToNextFajr * 4) ~/ 6);
    await _scheduleDaily(
      id: _hashString('fourth_sixth'),
      titleEn: 'Fourth Sixth of Night',
      titleAr: 'السدس الرابع من الليل',
      bodyEn: 'The fourth sixth of the night. A blessed time for worship.',
      bodyAr: 'السدس الرابع من الليل. وقت مبارك للعبادة.',
      hour: fourthSixth.hour,
      minute: fourthSixth.minute,
    );
  }

  Future<void> scheduleFastingMonThuReminders(DateTime maghribTime) async {
    final now = DateTime.now();
    final today = now.weekday;

    if (today == DateTime.sunday) {
      final time = maghribTime.add(const Duration(minutes: 30));
      await _plugin.zonedSchedule(
        _hashString('fasting_monday'),
        'Fast Tomorrow',
        'صُم غداً',
        tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'athkar_notifications',
            'Athkar Notifications',
            channelDescription: 'Notifications for prayers and athkar',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }

    if (today == DateTime.wednesday) {
      final time = maghribTime.add(const Duration(minutes: 30));
      await _plugin.zonedSchedule(
        _hashString('fasting_thursday'),
        'Fast Tomorrow',
        'صُم غداً',
        tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'athkar_notifications',
            'Athkar Notifications',
            channelDescription: 'Notifications for prayers and athkar',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> scheduleWhiteDaysReminder(DateTime maghribTime, int hijriDay) async {
    if (hijriDay == 12) {
      final time = maghribTime.add(const Duration(minutes: 30));
      await _scheduleDaily(
        id: _hashString('white_days_reminder'),
        titleEn: 'White Days Fasting Tomorrow',
        titleAr: 'صيام الأيام البيض غداً',
        bodyEn: 'Tomorrow begins the white days (13, 14, 15). Remember to fast.',
        bodyAr: 'غداً تبدأ الأيام البيض (13، 14، 15). تذكر الصيام.',
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  Future<void> scheduleMonthEntranceReminder(DateTime maghribTime, int hijriDay) async {
    if (hijriDay == 28 || hijriDay == 29) {
      final time = maghribTime.add(const Duration(minutes: 35));
      await _scheduleDaily(
        id: _hashString('month_entrance'),
        titleEn: 'New Month Entrance Dua',
        titleAr: 'دعاء دخول الشهر الجديد',
        bodyEn: 'A new Hijri month is approaching. Recite: "Allahumma ahillahu alayna bil-amni wal-iman"',
        bodyAr: 'يقترب شهر هجري جديد. ادعُ: "اللهم أهله علينا بالأمن والإيمان"',
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  Future<void> scheduleSurahKahfReminder() {
    return _scheduleWeekly(
      id: _hashString('surah_kahf'),
      titleEn: 'Read Surat Al-Kahf',
      titleAr: 'اقرأ سورة الكهف',
      bodyEn: 'It is Friday. Remember to read Surat Al-Kahf today.',
      bodyAr: 'اليوم الجمعة. تذكر قراءة سورة الكهف اليوم.',
      dayOfWeek: DateTime.friday,
      hour: 6,
      minute: 0,
    );
  }

  Future<void> schedulePersonalNotification({
    required String id,
    required String titleEn,
    required String titleAr,
    required String bodyEn,
    required String bodyAr,
    required int hour,
    required int minute,
  }) {
    return _scheduleDaily(
      id: _hashString('personal_$id'),
      titleEn: titleEn,
      titleAr: titleAr,
      bodyEn: bodyEn,
      bodyAr: bodyAr,
      hour: hour,
      minute: minute,
    );
  }

  Future<void> cancelNotification(String id) async {
    await _plugin.cancel(_hashString(id));
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> _scheduleDaily({
    required int id,
    required String titleEn,
    required String titleAr,
    required String bodyEn,
    required String bodyAr,
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      titleEn,
      bodyEn,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'athkar_notifications',
          'Athkar Notifications',
          channelDescription: 'Notifications for prayers and athkar',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'titleAr:$titleAr,bodyAr:$bodyAr',
    );
  }

  Future<void> _scheduleWeekly({
    required int id,
    required String titleEn,
    required String titleAr,
    required String bodyEn,
    required String bodyAr,
    required int dayOfWeek,
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      titleEn,
      bodyEn,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'athkar_notifications',
          'Athkar Notifications',
          channelDescription: 'Notifications for prayers and athkar',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'titleAr:$titleAr,bodyAr:$bodyAr',
    );
  }

  int _hashString(String str) {
    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = ((hash << 5) - hash) + str.codeUnitAt(i);
      hash |= 0;
    }
    return hash.abs() % 100000;
  }
}
