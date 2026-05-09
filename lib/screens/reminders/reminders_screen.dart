import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../modules/notifications_module.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late List<NotificationPreference> _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = NotificationData.defaults();
  }

  void _toggle(int index) {
    setState(() {
      _prefs[index] = _prefs[index].copyWith(isEnabled: !_prefs[index].isEnabled);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsProvider>().isArabic;
    final cs = Theme.of(context).colorScheme;

    // Group by type
    final prayers = _prefs.where((p) => p.type == NotificationType.prayerAlert).toList();
    final reminders = _prefs.where((p) => p.type == NotificationType.reminder).toList();
    final daily = _prefs.where((p) => p.type == NotificationType.daily).toList();

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? 'التذكيرات والإشعارات' : 'Reminders & Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.marginMobile),
        children: [
          _SectionHeader(title: isAr ? 'تنبيهات الصلاة' : 'Prayer Alerts'),
          ...prayers.map((p) => _ReminderTile(
              pref: p, isAr: isAr, onToggle: () => _toggle(_prefs.indexOf(p)))),
          const SizedBox(height: AppTheme.spaceMd),
          _SectionHeader(title: isAr ? 'تذكير بالأذكار' : 'Athkar Reminders'),
          ...reminders.map((p) => _ReminderTile(
              pref: p, isAr: isAr, onToggle: () => _toggle(_prefs.indexOf(p)))),
          const SizedBox(height: AppTheme.spaceMd),
          _SectionHeader(title: isAr ? 'يومي' : 'Daily'),
          ...daily.map((p) => _ReminderTile(
              pref: p, isAr: isAr, onToggle: () => _toggle(_prefs.indexOf(p)))),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTypography.titleLarge),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final NotificationPreference pref;
  final bool isAr;
  final VoidCallback onToggle;
  const _ReminderTile({required this.pref, required this.isAr, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isAr ? pref.titleAr : pref.titleEn, style: AppTypography.bodyLarge),
            if (pref.scheduledTime != null)
              Text(pref.scheduledTime!,
                  style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant)),
          ]),
        ),
        Switch.adaptive(
          value: pref.isEnabled,
          onChanged: (_) => onToggle(),
          activeColor: cs.primary,
        ),
      ]),
    );
  }
}
