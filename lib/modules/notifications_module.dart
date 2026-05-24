import '../core/services/notification_service.dart';

class NotificationPreference {
  final String id;
  final String titleEn;
  final String titleAr;
  final bool isEnabled;
  final NotificationCategory category;

  const NotificationPreference({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    this.isEnabled = false,
    required this.category,
  });

  NotificationPreference copyWith({
    bool? isEnabled,
  }) =>
      NotificationPreference(
        id: id,
        titleEn: titleEn,
        titleAr: titleAr,
        isEnabled: isEnabled ?? this.isEnabled,
        category: category,
      );
}

class NotificationData {
  static List<NotificationPreference> defaults() => const [
        NotificationPreference(
          id: 'fajr_alert',
          titleEn: 'Fajr Prayer',
          titleAr: 'صلاة الفجر',
          isEnabled: true,
          category: NotificationCategory.prayer,
        ),
        NotificationPreference(
          id: 'sunrise_alert',
          titleEn: 'Sunrise',
          titleAr: 'الشروق',
          isEnabled: true,
          category: NotificationCategory.prayer,
        ),
        NotificationPreference(
          id: 'dhuhr_alert',
          titleEn: 'Dhuhr Prayer',
          titleAr: 'صلاة الظهر',
          isEnabled: true,
          category: NotificationCategory.prayer,
        ),
        NotificationPreference(
          id: 'asr_alert',
          titleEn: 'Asr Prayer',
          titleAr: 'صلاة العصر',
          isEnabled: true,
          category: NotificationCategory.prayer,
        ),
        NotificationPreference(
          id: 'maghrib_alert',
          titleEn: 'Maghrib Prayer',
          titleAr: 'صلاة المغرب',
          isEnabled: true,
          category: NotificationCategory.prayer,
        ),
        NotificationPreference(
          id: 'isha_alert',
          titleEn: 'Isha Prayer',
          titleAr: 'صلاة العشاء',
          isEnabled: true,
          category: NotificationCategory.prayer,
        ),
        NotificationPreference(
          id: 'duha_alert',
          titleEn: 'Duha Prayer',
          titleAr: 'صلاة الضحى',
          isEnabled: true,
          category: NotificationCategory.duha,
        ),
        NotificationPreference(
          id: 'morning_athkar',
          titleEn: 'Morning Athkar',
          titleAr: 'أذكار الصباح',
          isEnabled: true,
          category: NotificationCategory.morningAthkar,
        ),
        NotificationPreference(
          id: 'evening_athkar',
          titleEn: 'Evening Athkar',
          titleAr: 'أذكار المساء',
          isEnabled: true,
          category: NotificationCategory.eveningAthkar,
        ),
        NotificationPreference(
          id: 'midnight',
          titleEn: 'Midnight',
          titleAr: 'منتصف الليل',
          isEnabled: true,
          category: NotificationCategory.midnight,
        ),
        NotificationPreference(
          id: 'last_third',
          titleEn: 'Last Third of Night',
          titleAr: 'الثلث الأخير',
          isEnabled: true,
          category: NotificationCategory.lastThird,
        ),
        NotificationPreference(
          id: 'fourth_sixth',
          titleEn: 'Fourth Sixth of Night',
          titleAr: 'السدس الرابع',
          isEnabled: true,
          category: NotificationCategory.fourthSixth,
        ),
        NotificationPreference(
          id: 'fasting_monday',
          titleEn: 'Fast Monday Reminder',
          titleAr: 'تذكير صيام الاثنين',
          isEnabled: true,
          category: NotificationCategory.fastingMonThu,
        ),
        NotificationPreference(
          id: 'fasting_thursday',
          titleEn: 'Fast Thursday Reminder',
          titleAr: 'تذكير صيام الخميس',
          isEnabled: true,
          category: NotificationCategory.fastingMonThu,
        ),
        NotificationPreference(
          id: 'white_days',
          titleEn: 'White Days Fasting',
          titleAr: 'صيام الأيام البيض',
          isEnabled: true,
          category: NotificationCategory.whiteDays,
        ),
        NotificationPreference(
          id: 'surah_kahf',
          titleEn: 'Surat Al-Kahf',
          titleAr: 'سورة الكهف',
          isEnabled: true,
          category: NotificationCategory.surahKahf,
        ),
        NotificationPreference(
          id: 'month_entrance',
          titleEn: 'New Month Dua',
          titleAr: 'دعاء دخول الشهر',
          isEnabled: true,
          category: NotificationCategory.monthEntrance,
        ),
      ];

  static List<NotificationPreference> getByCategory(NotificationCategory category) {
    return defaults().where((n) => n.category == category).toList();
  }
}
