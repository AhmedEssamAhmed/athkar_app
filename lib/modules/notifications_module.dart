/// NotificationsModule — Manages reminder scheduling and preferences.
///
/// In production, wire this to flutter_local_notifications + workmanager
/// for background scheduling.
class NotificationPreference {
  final String id;
  final String titleEn;
  final String titleAr;
  final bool isEnabled;
  final String? scheduledTime; // HH:mm format
  final NotificationType type;

  const NotificationPreference({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    this.isEnabled = false,
    this.scheduledTime,
    this.type = NotificationType.reminder,
  });

  NotificationPreference copyWith({bool? isEnabled, String? scheduledTime}) =>
      NotificationPreference(
        id: id,
        titleEn: titleEn,
        titleAr: titleAr,
        isEnabled: isEnabled ?? this.isEnabled,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        type: type,
      );
}

enum NotificationType { prayerAlert, reminder, daily }

/// Default notification preferences matching "Reminders & Notifications" screen.
class NotificationData {
  static List<NotificationPreference> defaults() => const [
        NotificationPreference(
          id: 'fajr_alert',
          titleEn: 'Fajr Prayer',
          titleAr: 'صلاة الفجر',
          isEnabled: true,
          scheduledTime: '04:15',
          type: NotificationType.prayerAlert,
        ),
        NotificationPreference(
          id: 'dhuhr_alert',
          titleEn: 'Dhuhr Prayer',
          titleAr: 'صلاة الظهر',
          isEnabled: true,
          scheduledTime: '12:10',
          type: NotificationType.prayerAlert,
        ),
        NotificationPreference(
          id: 'asr_alert',
          titleEn: 'Asr Prayer',
          titleAr: 'صلاة العصر',
          isEnabled: true,
          scheduledTime: '15:35',
          type: NotificationType.prayerAlert,
        ),
        NotificationPreference(
          id: 'maghrib_alert',
          titleEn: 'Maghrib Prayer',
          titleAr: 'صلاة المغرب',
          isEnabled: true,
          scheduledTime: '18:45',
          type: NotificationType.prayerAlert,
        ),
        NotificationPreference(
          id: 'isha_alert',
          titleEn: 'Isha Prayer',
          titleAr: 'صلاة العشاء',
          isEnabled: true,
          scheduledTime: '20:10',
          type: NotificationType.prayerAlert,
        ),
        NotificationPreference(
          id: 'morning_athkar',
          titleEn: 'Morning Athkar',
          titleAr: 'أذكار الصباح',
          isEnabled: true,
          scheduledTime: '05:00',
          type: NotificationType.reminder,
        ),
        NotificationPreference(
          id: 'evening_athkar',
          titleEn: 'Evening Athkar',
          titleAr: 'أذكار المساء',
          isEnabled: true,
          scheduledTime: '17:00',
          type: NotificationType.reminder,
        ),
        NotificationPreference(
          id: 'daily_verse',
          titleEn: 'Daily Verse',
          titleAr: 'آية اليوم',
          isEnabled: false,
          scheduledTime: '08:00',
          type: NotificationType.daily,
        ),
      ];
}
