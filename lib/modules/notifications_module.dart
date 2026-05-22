import '../core/services/notification_service.dart';

class NotificationPreference {
  final String id;
  final String titleEn;
  final String titleAr;
  final bool isEnabled;
  final String? scheduledTime;
  final NotificationCategory category;
  final String? descriptionEn;
  final String? descriptionAr;

  const NotificationPreference({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    this.isEnabled = false,
    this.scheduledTime,
    required this.category,
    this.descriptionEn,
    this.descriptionAr,
  });

  NotificationPreference copyWith({
    bool? isEnabled,
    String? scheduledTime,
  }) =>
      NotificationPreference(
        id: id,
        titleEn: titleEn,
        titleAr: titleAr,
        isEnabled: isEnabled ?? this.isEnabled,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        category: category,
        descriptionEn: descriptionEn,
        descriptionAr: descriptionAr,
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
          descriptionEn: '8 minutes after sunrise',
          descriptionAr: 'بعد 8 دقائق من الشروق',
        ),
        NotificationPreference(
          id: 'morning_athkar',
          titleEn: 'Morning Athkar',
          titleAr: 'أذكار الصباح',
          isEnabled: true,
          category: NotificationCategory.morningAthkar,
          descriptionEn: '50 minutes after Fajr',
          descriptionAr: 'بعد 50 دقيقة من الفجر',
        ),
        NotificationPreference(
          id: 'evening_athkar',
          titleEn: 'Evening Athkar',
          titleAr: 'أذكار المساء',
          isEnabled: true,
          category: NotificationCategory.eveningAthkar,
          descriptionEn: '25 minutes after Maghrib',
          descriptionAr: 'بعد 25 دقيقة من المغرب',
        ),
        NotificationPreference(
          id: 'midnight',
          titleEn: 'Midnight',
          titleAr: 'منتصف الليل',
          isEnabled: true,
          category: NotificationCategory.midnight,
          descriptionEn: 'Calculated midpoint between Maghrib and Fajr',
          descriptionAr: 'منتصف الوقت بين المغرب والفجر',
        ),
        NotificationPreference(
          id: 'last_third',
          titleEn: 'Last Third of Night',
          titleAr: 'الثلث الأخير',
          isEnabled: true,
          category: NotificationCategory.lastThird,
          descriptionEn: 'Last third of night between Maghrib and Fajr',
          descriptionAr: 'الثلث الأخير من الليل بين المغرب والفجر',
        ),
        NotificationPreference(
          id: 'fourth_sixth',
          titleEn: 'Fourth Sixth of Night',
          titleAr: 'السدس الرابع',
          isEnabled: true,
          category: NotificationCategory.fourthSixth,
          descriptionEn: 'Fourth sixth of night between Maghrib and Fajr',
          descriptionAr: 'السدس الرابع من الليل بين المغرب والفجر',
        ),
        NotificationPreference(
          id: 'fasting_monday',
          titleEn: 'Fast Monday Reminder',
          titleAr: 'تذكير صيام الاثنين',
          isEnabled: true,
          category: NotificationCategory.fastingMonThu,
          descriptionEn: 'Sunday 30 min after Maghrib',
          descriptionAr: 'الأحد بعد 30 دقيقة من المغرب',
        ),
        NotificationPreference(
          id: 'fasting_thursday',
          titleEn: 'Fast Thursday Reminder',
          titleAr: 'تذكير صيام الخميس',
          isEnabled: true,
          category: NotificationCategory.fastingMonThu,
          descriptionEn: 'Wednesday 30 min after Maghrib',
          descriptionAr: 'الأربعاء بعد 30 دقيقة من المغرب',
        ),
        NotificationPreference(
          id: 'white_days',
          titleEn: 'White Days Fasting',
          titleAr: 'صيام الأيام البيض',
          isEnabled: true,
          category: NotificationCategory.whiteDays,
          descriptionEn: '12th of Hijri month, 30 min after Maghrib',
          descriptionAr: '12 من الشهر الهجري، بعد 30 دقيقة من المغرب',
        ),
        NotificationPreference(
          id: 'surah_kahf',
          titleEn: 'Surat Al-Kahf',
          titleAr: 'سورة الكهف',
          isEnabled: true,
          category: NotificationCategory.surahKahf,
          descriptionEn: 'Friday reminder to read Surat Al-Kahf',
          descriptionAr: 'تذكير يومي الجمعة بقراءة سورة الكهف',
        ),
        NotificationPreference(
          id: 'month_entrance',
          titleEn: 'New Month Dua',
          titleAr: 'دعاء دخول الشهر',
          isEnabled: true,
          category: NotificationCategory.monthEntrance,
          descriptionEn: 'End of Hijri month at Maghrib + 35 min',
          descriptionAr: 'نهاية الشهر الهجري عند المغرب + 35 دقيقة',
        ),
      ];

  static List<NotificationPreference> getByCategory(NotificationCategory category) {
    return defaults().where((n) => n.category == category).toList();
  }
}
