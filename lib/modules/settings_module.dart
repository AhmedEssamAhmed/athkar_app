/// SettingsModule — Configuration options for the app.
///
/// Defines the settings items displayed on the "App Settings" screen.
class SettingsItem {
  final String key;
  final String titleEn;
  final String titleAr;
  final String? subtitleEn;
  final String? subtitleAr;
  final SettingsType type;

  const SettingsItem({
    required this.key,
    required this.titleEn,
    required this.titleAr,
    this.subtitleEn,
    this.subtitleAr,
    this.type = SettingsType.toggle,
  });
}

enum SettingsType { toggle, selector, action, navigation }

/// Predefined settings items matching the Stitch "App Settings" screen.
class SettingsData {
  static const List<SettingsItem> items = [
    SettingsItem(
      key: 'language',
      titleEn: 'Language',
      titleAr: 'اللغة',
      subtitleEn: 'Switch between Arabic and English',
      subtitleAr: 'التبديل بين العربية والإنجليزية',
      type: SettingsType.selector,
    ),
    SettingsItem(
      key: 'theme',
      titleEn: 'Theme',
      titleAr: 'المظهر',
      subtitleEn: 'Light, Dark, or System',
      subtitleAr: 'فاتح، داكن، أو النظام',
      type: SettingsType.selector,
    ),
    SettingsItem(
      key: 'notifications',
      titleEn: 'Prayer Notifications',
      titleAr: 'إشعارات الصلاة',
      subtitleEn: 'Get notified before each prayer',
      subtitleAr: 'تنبيه قبل كل صلاة',
      type: SettingsType.toggle,
    ),
    SettingsItem(
      key: 'athkar_reminder',
      titleEn: 'Athkar Reminders',
      titleAr: 'تذكير بالأذكار',
      subtitleEn: 'Morning and evening reminders',
      subtitleAr: 'تذكير بأذكار الصباح والمساء',
      type: SettingsType.toggle,
    ),
    SettingsItem(
      key: 'haptic',
      titleEn: 'Haptic Feedback',
      titleAr: 'الاهتزاز',
      subtitleEn: 'Vibrate on tasbeeh tap',
      subtitleAr: 'اهتزاز عند النقر على المسبحة',
      type: SettingsType.toggle,
    ),
    SettingsItem(
      key: 'about',
      titleEn: 'About Noor',
      titleAr: 'عن نور',
      type: SettingsType.navigation,
    ),
  ];
}
