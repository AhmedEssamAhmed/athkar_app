import 'package:flutter_test/flutter_test.dart';

import 'package:noor_athkar/core/services/prayer_time_service.dart';
import 'package:noor_athkar/modules/prayer_module.dart';
import 'package:noor_athkar/modules/notifications_module.dart';
import 'package:noor_athkar/core/services/notification_service.dart';

void main() {
  group('Prayer Module Tests', () {
    test('PrayerTime creates correctly', () {
      const prayer = PrayerTime(
        name: 'Fajr',
        nameAr: 'الفجر',
        time: '04:30',
      );
      expect(prayer.name, 'Fajr');
      expect(prayer.nameAr, 'الفجر');
      expect(prayer.time, '04:30');
      expect(prayer.isCurrent, false);
      expect(prayer.isPassed, false);
    });

    test('HijriDate formats correctly', () {
      const hijri = HijriDate(
        day: 15,
        monthName: 'Ramadan',
        monthNameAr: 'رمضان',
        year: 1447,
      );
      expect(hijri.formatted, '15 Ramadan 1447 AH');
      expect(hijri.formattedAr, '15 رمضان 1447 هـ');
    });

    test('PrayerTimeService calculates prayer times', () {
      final service = PrayerTimeService()..setDefaultLocation();

      expect(service.fajrTime, isNotNull);
      expect(service.sunriseTime, isNotNull);
      expect(service.dhuhrTime, isNotNull);
      expect(service.asrTime, isNotNull);
      expect(service.maghribTime, isNotNull);
      expect(service.ishaTime, isNotNull);
    });
  });

   group('Notifications Module Tests', () {
     test('NotificationPreference creates correctly', () {
       final pref = NotificationPreference(
         id: 'fajr_alert',
         titleEn: 'Fajr Prayer',
         titleAr: 'صلاة الفجر',
         isEnabled: true,
         category: NotificationCategory.prayer,
       );
       expect(pref.id, 'fajr_alert');
       expect(pref.isEnabled, true);
     });

    test('NotificationData returns defaults', () {
      final defaults = NotificationData.defaults();
      expect(defaults.isNotEmpty, true);
    });
  });
}
