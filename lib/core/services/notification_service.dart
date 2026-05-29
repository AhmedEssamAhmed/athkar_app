import 'dart:io';
import 'dart:convert';

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
  final bool? isBeforePrayer;

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
    this.isBeforePrayer,
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
        'isBeforePrayer': isBeforePrayer,
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
      isBeforePrayer: json['isBeforePrayer'] as bool?,
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

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
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
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
      await _createNotificationChannels(android);
    }

    _initialized = true;
  }

  Future<void> _createNotificationChannels(
    AndroidFlutterLocalNotificationsPlugin? android,
  ) async {
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'prayer_notifications',
        'Prayer Notifications',
        description: 'Prayer time notifications with Athan sound',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('athan'),
        enableVibration: true,
        enableLights: true,
      ),
    );

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'athkar_notifications',
        'Athkar Notifications',
        description: 'General app notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
    );
  }

  void _onNotificationTap(NotificationResponse response) {}

  Future<void> showTestNotification({
    required String titleEn,
    required String titleAr,
    required String bodyEn,
    required String bodyAr,
    NotificationCategory? category,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isAr = prefs.getString('locale') == 'ar';
    final title = isAr ? titleAr : titleEn;
    final body = isAr ? bodyAr : bodyEn;
    final isPrayer = category == NotificationCategory.prayer;
    await _plugin.show(
      99999,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          isPrayer ? 'prayer_notifications' : 'athkar_notifications',
          isPrayer ? 'Prayer Notifications' : 'Athkar Notifications',
          channelDescription: isPrayer
              ? 'Prayer time notifications with Athan sound'
              : 'General app notifications',
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
    final notifications = <ScheduledNotification>[];

    for (final item in data) {
      try {
        final json = jsonDecode(item) as Map<String, dynamic>;
        notifications.add(ScheduledNotification.fromJson(json));
      } catch (_) {
        continue;
      }
    }

    return notifications;
  }

  Future<void> saveNotifications(List<ScheduledNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final data = notifications.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_prefsKey, data);
  }

  Future<void> schedulePrayerNotifications(
    Map<String, DateTime> prayerTimes,
  ) async {
    final prayerNames = {
      'fajr': ('Fajr Prayer', 'صلاة الفجر', '', ''),
      'sunrise': ('Sunrise', 'الشروق', '', ''),
      'dhuhr': ('Dhuhr Prayer', 'صلاة الظهر', '', ''),
      'asr': ('Asr Prayer', 'صلاة العصر', '', ''),
      'maghrib': ('Maghrib Prayer', 'صلاة المغرب', '', ''),
      'isha': ('Isha Prayer', 'صلاة العشاء', '', ''),
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
        hour: time.hour,
        minute: time.minute,
        useAthanSound: name != 'sunrise',
      );

      if (name != 'sunrise') {
        final reminderTime = time.subtract(const Duration(minutes: 10));
        await _scheduleDaily(
          id: _hashString('pre_prayer_$name'),
          titleEn: '10 minutes until ${names.$1}',
          titleAr: '${names.$2} بعد 10 دقائق',
          hour: reminderTime.hour,
          minute: reminderTime.minute,
        );
      }
    }
  }

  Future<void> scheduleDuhaNotification(DateTime sunriseTime) async {
    final duhaTime = sunriseTime.add(const Duration(minutes: 8));
    await _scheduleDaily(
      id: _hashString('duha_prayer'),
      titleEn: 'Duha Prayer',
      titleAr: 'صلاة الضحى',
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
      hour: lastThird.hour,
      minute: lastThird.minute,
    );
  }

  Future<void> scheduleFourthSixthNotification(DateTime maghribTime, DateTime fajrTime) async {
    final sunsetToNextFajr = fajrTime.add(const Duration(days: 1)).difference(maghribTime);
    final fourthSixth = maghribTime.add((sunsetToNextFajr * 3) ~/ 6);
    await _scheduleDaily(
      id: _hashString('fourth_sixth'),
      titleEn: 'Fourth Sixth of Night',
      titleAr: 'السدس الرابع من الليل',
      hour: fourthSixth.hour,
      minute: fourthSixth.minute,
    );
  }

  Future<void> scheduleFastingMonThuReminders(DateTime maghribTime) async {
    final prefs = await SharedPreferences.getInstance();
    final isAr = prefs.getString('locale') == 'ar';
    final now = DateTime.now();
    final today = now.weekday;

    if (today == DateTime.sunday) {
      final time = maghribTime.add(const Duration(minutes: 30));
      await _plugin.zonedSchedule(
        _hashString('fasting_monday'),
        isAr ? 'صُم غداً' : 'Fast Tomorrow',
        '',
        tz.TZDateTime.from(DateTime(now.year, now.month, now.day, time.hour, time.minute), tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'athkar_notifications',
            'Athkar Notifications',
            channelDescription: 'General app notifications',
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
        isAr ? 'صُم غداً' : 'Fast Tomorrow',
        '',
        tz.TZDateTime.from(DateTime(now.year, now.month, now.day, time.hour, time.minute), tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'athkar_notifications',
            'Athkar Notifications',
            channelDescription: 'General app notifications',
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
      dayOfWeek: DateTime.friday,
      hour: 6,
      minute: 0,
    );
  }

  Future<void> schedulePersonalNotification({
    required String id,
    required String titleEn,
    required String titleAr,
    required int hour,
    required int minute,
    String? basePrayer,
    int? minutesAfterPrayer,
    bool? isBeforePrayer,
  }) async {
    final notification = ScheduledNotification(
      id: id,
      titleEn: titleEn,
      titleAr: titleAr,
      bodyEn: '',
      bodyAr: '',
      category: NotificationCategory.personal,
      hour: hour,
      minute: minute,
      basePrayer: basePrayer,
      minutesAfterPrayer: minutesAfterPrayer,
      isBeforePrayer: isBeforePrayer,
    );

    final notifications = await getNotifications();
    notifications.add(notification);
    await saveNotifications(notifications);

    await _schedulePersonalDaily(
      id: _hashString('personal_$id'),
      titleEn: titleEn,
      titleAr: titleAr,
      hour: hour,
      minute: minute,
    );
  }

  Future<void> updatePersonalNotification({
    required String id,
    required String titleEn,
    required String titleAr,
    required int hour,
    required int minute,
    String? basePrayer,
    int? minutesAfterPrayer,
    bool? isBeforePrayer,
  }) async {
    await cancelNotification('personal_$id');

    final notifications = await getNotifications();
    notifications.removeWhere((n) => n.id == id);
    notifications.add(ScheduledNotification(
      id: id,
      titleEn: titleEn,
      titleAr: titleAr,
      bodyEn: '',
      bodyAr: '',
      category: NotificationCategory.personal,
      hour: hour,
      minute: minute,
      basePrayer: basePrayer,
      minutesAfterPrayer: minutesAfterPrayer,
      isBeforePrayer: isBeforePrayer,
    ));
    await saveNotifications(notifications);

    await _schedulePersonalDaily(
      id: _hashString('personal_$id'),
      titleEn: titleEn,
      titleAr: titleAr,
      hour: hour,
      minute: minute,
    );
  }

  Future<void> cancelNotification(String id) async {
    await _plugin.cancel(_hashString(id));
  }

  Future<void> deletePersonalNotification(String scheduledId) async {
    await _plugin.cancel(_hashString(scheduledId));
    final notifications = await getNotifications();
    notifications.removeWhere((n) => n.id == scheduledId.replaceFirst('personal_', ''));
    await saveNotifications(notifications);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> _schedulePersonalDaily({
    required int id,
    required String titleEn,
    required String titleAr,
    String bodyEn = '',
    String bodyAr = '',
    required int hour,
    required int minute,
  }) async {
    await init();
    await requestPermissions();

    final prefs = await SharedPreferences.getInstance();
    final isAr = prefs.getString('locale') == 'ar';
    final title = isAr ? titleAr : titleEn;
    final body = isAr ? bodyAr : bodyEn;

    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (!target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }

    final scheduledDate = tz.TZDateTime.from(target, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'athkar_notifications',
          'Athkar Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
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

  Future<void> _scheduleDaily({
    required int id,
    required String titleEn,
    required String titleAr,
    String bodyEn = '',
    String bodyAr = '',
    required int hour,
    required int minute,
    bool useAthanSound = false,
  }) async {
    await init();

    final prefs = await SharedPreferences.getInstance();
    final isAr = prefs.getString('locale') == 'ar';
    final title = isAr ? titleAr : titleEn;
    final body = isAr ? bodyAr : bodyEn;

    final now = DateTime.now();
    var scheduledDate = tz.TZDateTime.from(DateTime(now.year, now.month, now.day, hour, minute), tz.local);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          useAthanSound ? 'prayer_notifications' : 'athkar_notifications',
          useAthanSound ? 'Prayer Notifications' : 'Athkar Notifications',
          channelDescription: useAthanSound
              ? 'Prayer time notifications with Athan sound'
              : 'General app notifications',
          importance: Importance.max,
          priority: Priority.high,
          sound: useAthanSound
              ? const RawResourceAndroidNotificationSound('athan')
              : null,
          timeoutAfter: useAthanSound ? 240000 : null,
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
    String bodyEn = '',
    String bodyAr = '',
    required int dayOfWeek,
    required int hour,
    required int minute,
    bool useAthanSound = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isAr = prefs.getString('locale') == 'ar';
    final title = isAr ? titleAr : titleEn;
    final body = isAr ? bodyAr : bodyEn;

    final now = DateTime.now();
    var scheduledDate = tz.TZDateTime.from(DateTime(now.year, now.month, now.day, hour, minute), tz.local);
    
    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          useAthanSound ? 'prayer_notifications' : 'athkar_notifications',
          useAthanSound ? 'Prayer Notifications' : 'Athkar Notifications',
          channelDescription: useAthanSound
              ? 'Prayer time notifications with Athan sound'
              : 'General app notifications',
          importance: Importance.max,
          priority: Priority.high,
          timeoutAfter: useAthanSound ? 240000 : null,
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
