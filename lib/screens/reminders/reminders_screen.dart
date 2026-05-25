import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/decorative_background.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/prayer_time_provider.dart';
import '../../core/services/notification_service.dart';
import '../../modules/notifications_module.dart';
import 'personal_reminders_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  static const _disabledReminderPrefsKey = 'disabled_reminder_toggles';

  late List<NotificationPreference> _prefs;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _prefs = NotificationData.defaults();
    _loadReminderToggleStates();
  }

  Future<void> _loadReminderToggleStates() async {
    final prefs = await SharedPreferences.getInstance();
    final disabledIds =
        (prefs.getStringList(_disabledReminderPrefsKey) ?? []).toSet();
    if (!mounted) return;

    setState(() {
      _prefs = _prefs
          .map((pref) => pref.copyWith(isEnabled: !disabledIds.contains(pref.id)))
          .toList();
    });
  }

  Future<void> _saveReminderToggleStates() async {
    final prefs = await SharedPreferences.getInstance();
    final disabledIds = _prefs
        .where((pref) => !pref.isEnabled)
        .map((pref) => pref.id)
        .toList();
    await prefs.setStringList(_disabledReminderPrefsKey, disabledIds);
  }

  String _scheduledNotificationId(String preferenceId) {
    return switch (preferenceId) {
      'fajr_alert' => 'prayer_fajr',
      'sunrise_alert' => 'prayer_sunrise',
      'dhuhr_alert' => 'prayer_dhuhr',
      'asr_alert' => 'prayer_asr',
      'maghrib_alert' => 'prayer_maghrib',
      'isha_alert' => 'prayer_isha',
      'duha_alert' => 'duha_prayer',
      'white_days' => 'white_days_reminder',
      _ => preferenceId,
    };
  }

  Future<void> _toggle(int index) async {
    final pref = _prefs[index];
    final newState = !pref.isEnabled;
    setState(() {
      _prefs[index] = pref.copyWith(isEnabled: newState);
    });
    await _saveReminderToggleStates();
    if (!mounted) return;

    if (!newState) {
      await _notificationService.cancelNotification(
        _scheduledNotificationId(pref.id),
      );
    } else {
      await context.read<PrayerTimeProvider>().refresh();
    }
  }

  Future<void> _tryNotification(NotificationPreference pref) async {
    await _notificationService.showTestNotification(
      titleEn: pref.titleEn,
      titleAr: pref.titleAr,
      bodyEn: 'Test notification',
      bodyAr: 'إشعار تجريبي',
      category: pref.category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsProvider>().isArabic;

    final prayers = _prefs.where((p) => p.category == NotificationCategory.prayer).toList();
    final duha = _prefs.where((p) => p.category == NotificationCategory.duha).toList();
    final athkar = _prefs.where((p) => p.category == NotificationCategory.morningAthkar || p.category == NotificationCategory.eveningAthkar).toList();
    final nightTimes = _prefs.where((p) => p.category == NotificationCategory.midnight || p.category == NotificationCategory.lastThird || p.category == NotificationCategory.fourthSixth).toList();
    final fasting = _prefs.where((p) => p.category == NotificationCategory.fastingMonThu).toList();
    final whiteDays = _prefs.where((p) => p.category == NotificationCategory.whiteDays).toList();
    final surahKahf = _prefs.where((p) => p.category == NotificationCategory.surahKahf).toList();
    final monthEntrance = _prefs.where((p) => p.category == NotificationCategory.monthEntrance).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'التذكيرات والإشعارات' : 'Reminders & Notifications'),
      ),
      body: DecorativeBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            _PersonalRemindersNavCard(isAr: isAr),
            const SizedBox(height: 28),

            _SectionHeader(
              icon: Icons.mosque_rounded,
              title: isAr ? 'تنبيهات الصلاة' : 'Prayer Alerts',
              count: prayers.length,
            ),
            ...prayers.map((p) => _toggleTile(p, isAr)),
            const SizedBox(height: 24),

            _SectionHeader(
              icon: Icons.wb_sunny_rounded,
              title: isAr ? 'صلاة الضحى' : 'Duha Prayer',
              count: duha.length,
            ),
            ...duha.map((p) => _toggleTile(p, isAr)),
            const SizedBox(height: 24),

            _SectionHeader(
              icon: Icons.auto_stories_rounded,
              title: isAr ? 'تذكير بالأذكار' : 'Athkar Reminders',
              count: athkar.length,
            ),
            ...athkar.map((p) => _toggleTile(p, isAr)),
            const SizedBox(height: 24),

            _SectionHeader(
              icon: Icons.nights_stay_rounded,
              title: isAr ? 'أوقات الليل' : 'Night Times',
              count: nightTimes.length,
            ),
            ...nightTimes.map((p) => _toggleTile(p, isAr)),
            const SizedBox(height: 24),

            _SectionHeader(
              icon: Icons.free_breakfast_rounded,
              title: isAr ? 'تذكير الصيام' : 'Fasting Reminders',
              count: fasting.length,
            ),
            ...fasting.map((p) => _toggleTile(p, isAr)),
            const SizedBox(height: 24),

            _SectionHeader(
              icon: Icons.brightness_5_rounded,
              title: isAr ? 'الأيام البيض' : 'White Days',
              count: whiteDays.length,
            ),
            ...whiteDays.map((p) => _toggleTile(p, isAr)),
            const SizedBox(height: 24),

            _SectionHeader(
              icon: Icons.menu_book_rounded,
              title: isAr ? 'سورة الكهف' : 'Surat Al-Kahf',
              count: surahKahf.length,
            ),
            ...surahKahf.map((p) => _toggleTile(p, isAr)),
            const SizedBox(height: 24),

            _SectionHeader(
              icon: Icons.celebration_rounded,
              title: isAr ? 'دعاء دخول الشهر' : 'Month Entrance Dua',
              count: monthEntrance.length,
            ),
            ...monthEntrance.map((p) => _toggleTile(p, isAr)),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _toggleTile(NotificationPreference pref, bool isAr) {
    final idx = _prefs.indexOf(pref);
    return _ReminderTile(
      pref: pref,
      isAr: isAr,
      onToggle: () => _toggle(idx),
      onTry: () => _tryNotification(pref),
    );
  }
}

// ─────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  const _SectionHeader({required this.icon, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.primary.withAlpha(18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: cs.primary),
          ),
          const SizedBox(width: 10),
          Text(title, style: AppTypography.titleLarge),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cs.onSurface.withAlpha(10),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$count',
              style: AppTypography.labelMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reminder Toggle Tile
// ─────────────────────────────────────────────

const _reminderIconMap = <String, IconData>{
  'fajr_alert': Icons.wb_sunny_rounded,
  'sunrise_alert': Icons.sunny,
  'dhuhr_alert': Icons.wb_cloudy_rounded,
  'asr_alert': Icons.cloud_rounded,
  'maghrib_alert': Icons.nightlight_round,
  'isha_alert': Icons.nights_stay_rounded,
  'duha_alert': Icons.wb_sunny_rounded,
  'morning_athkar': Icons.wb_sunny_outlined,
  'evening_athkar': Icons.nightlight_round,
  'midnight': Icons.nights_stay_rounded,
  'last_third': Icons.star_rounded,
  'fourth_sixth': Icons.star_border,
  'fasting_monday': Icons.free_breakfast_rounded,
  'fasting_thursday': Icons.free_breakfast_rounded,
  'white_days': Icons.brightness_5_rounded,
  'surah_kahf': Icons.menu_book_rounded,
  'month_entrance': Icons.celebration_rounded,
};

class _ReminderTile extends StatelessWidget {
  final NotificationPreference pref;
  final bool isAr;
  final VoidCallback onToggle;
  final VoidCallback onTry;
  const _ReminderTile({
    required this.pref,
    required this.isAr,
    required this.onToggle,
    required this.onTry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final icon = _reminderIconMap[pref.id] ?? Icons.notifications_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(50), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: pref.isEnabled
                ? cs.primary.withAlpha(18)
                : cs.onSurface.withAlpha(8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: pref.isEnabled ? cs.primary : cs.onSurface.withAlpha(80),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            isAr ? pref.titleAr : pref.titleEn,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: pref.isEnabled ? cs.onSurface : cs.onSurface.withAlpha(120),
            ),
          ),
        ),
        TextButton(
          onPressed: onTry,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: cs.primary.withAlpha(180),
          ),
          child: Text(
            isAr ? 'تجربة' : 'Try',
            style: AppTypography.labelLarge,
          ),
        ),
        Switch.adaptive(
          value: pref.isEnabled,
          onChanged: (_) => onToggle(),
          activeTrackColor: cs.primary.withAlpha(100),
          activeThumbColor: Colors.white,
          inactiveThumbColor: cs.onSurface.withAlpha(100),
          inactiveTrackColor: cs.onSurface.withAlpha(25),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// Personal Reminders Nav Card
// ─────────────────────────────────────────────

class _PersonalRemindersNavCard extends StatelessWidget {
  final bool isAr;
  const _PersonalRemindersNavCard({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PersonalRemindersScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary.withAlpha(25),
                AppColors.gold.withAlpha(15),
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(
              color: cs.primary.withAlpha(20),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withAlpha(200)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withAlpha(40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.person_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'الإشعارات الشخصية' : 'Personal Reminders',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr ? 'إدارة الإشعارات المخصصة' : 'Manage your custom notifications',
                      style: AppTypography.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: cs.onSurfaceVariant,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
