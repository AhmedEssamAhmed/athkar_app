import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/prayer_time_provider.dart';
import '../../core/services/notification_service.dart';
import '../../modules/notifications_module.dart';
import 'package:intl/intl.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late List<NotificationPreference> _prefs;
  final NotificationService _notificationService = NotificationService();
  List<ScheduledNotification> _personalNotifications = [];

  @override
  void initState() {
    super.initState();
    _prefs = NotificationData.defaults();
    _loadPersonalNotifications();
  }

  Future<void> _loadPersonalNotifications() async {
    final notifications = await _notificationService.getNotifications();
    setState(() {
      _personalNotifications = notifications
          .where((n) => n.category == NotificationCategory.personal)
          .toList();
    });
  }

  Future<void> _toggle(int index) async {
    final pref = _prefs[index];
    final newState = !pref.isEnabled;
    setState(() {
      _prefs[index] = pref.copyWith(isEnabled: newState);
    });
    if (!newState) {
      await _notificationService.cancelNotification(pref.id);
    } else {
      await context.read<PrayerTimeProvider>().refresh();
    }
  }

  Future<void> _tryNotification(NotificationPreference pref) async {
    await _notificationService.showTestNotification(
      titleEn: pref.titleEn,
      titleAr: pref.titleAr,
      bodyEn: pref.descriptionEn ?? 'Test notification',
      bodyAr: pref.descriptionAr ?? 'إشعار تجريبي',
    );
  }

  void _addPersonalNotification() {
    showDialog(
      context: context,
      builder: (context) => _AddPersonalNotificationDialog(
        onAdd: (titleEn, titleAr, bodyEn, bodyAr, hour, minute) async {
          final id = DateTime.now().millisecondsSinceEpoch.toString();
          await _notificationService.schedulePersonalNotification(
            id: id,
            titleEn: titleEn,
            titleAr: titleAr,
            bodyEn: bodyEn,
            bodyAr: bodyAr,
            hour: hour,
            minute: minute,
          );
          await _loadPersonalNotifications();
        },
      ),
    );
  }

  Future<void> _deletePersonalNotification(String id) async {
    await _notificationService.cancelNotification(id);
    await _loadPersonalNotifications();
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPersonalNotification,
        icon: const Icon(Icons.add),
        label: Text(isAr ? 'إشعار جديد' : 'New Notification'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.marginMobile),
        children: [
          _SectionHeader(title: isAr ? 'إشعارات شخصية' : 'Personal Notifications'),
          ..._personalNotifications.map((n) => _PersonalNotificationTile(
            notification: n,
            isAr: isAr,
            onDelete: () => _deletePersonalNotification(n.id),
          )),
          const SizedBox(height: AppTheme.spaceSm),
          _AddPersonalTile(isAr: isAr, onTap: _addPersonalNotification),
          const SizedBox(height: AppTheme.spaceLg),

          _SectionHeader(title: isAr ? 'تنبيهات الصلاة' : 'Prayer Alerts'),
          ...prayers.map((p) => _ReminderTile(
              pref: p,
              isAr: isAr,
              onToggle: () => _toggle(_prefs.indexOf(p)),
              onTry: () => _tryNotification(p))),
          const SizedBox(height: AppTheme.spaceMd),

          _SectionHeader(title: isAr ? 'صلاة الضحى' : 'Duha Prayer'),
          ...duha.map((p) => _ReminderTile(
              pref: p,
              isAr: isAr,
              onToggle: () => _toggle(_prefs.indexOf(p)),
              onTry: () => _tryNotification(p))),
          const SizedBox(height: AppTheme.spaceMd),

          _SectionHeader(title: isAr ? 'تذكير بالأذكار' : 'Athkar Reminders'),
          ...athkar.map((p) => _ReminderTile(
              pref: p,
              isAr: isAr,
              onToggle: () => _toggle(_prefs.indexOf(p)),
              onTry: () => _tryNotification(p))),
          const SizedBox(height: AppTheme.spaceMd),

          _SectionHeader(title: isAr ? 'أوقات الليل' : 'Night Times'),
          ...nightTimes.map((p) => _ReminderTile(
              pref: p,
              isAr: isAr,
              onToggle: () => _toggle(_prefs.indexOf(p)),
              onTry: () => _tryNotification(p))),
          const SizedBox(height: AppTheme.spaceMd),

          _SectionHeader(title: isAr ? 'تذكير الصيام' : 'Fasting Reminders'),
          ...fasting.map((p) => _ReminderTile(
              pref: p,
              isAr: isAr,
              onToggle: () => _toggle(_prefs.indexOf(p)),
              onTry: () => _tryNotification(p))),
          const SizedBox(height: AppTheme.spaceMd),

          _SectionHeader(title: isAr ? 'الأيام البيض' : 'White Days'),
          ...whiteDays.map((p) => _ReminderTile(
              pref: p,
              isAr: isAr,
              onToggle: () => _toggle(_prefs.indexOf(p)),
              onTry: () => _tryNotification(p))),
          const SizedBox(height: AppTheme.spaceMd),

          _SectionHeader(title: isAr ? 'سورة الكهف' : 'Surat Al-Kahf'),
          ...surahKahf.map((p) => _ReminderTile(
              pref: p,
              isAr: isAr,
              onToggle: () => _toggle(_prefs.indexOf(p)),
              onTry: () => _tryNotification(p))),
          const SizedBox(height: AppTheme.spaceMd),

          _SectionHeader(title: isAr ? 'دعاء دخول الشهر' : 'Month Entrance Dua'),
          ...monthEntrance.map((p) => _ReminderTile(
              pref: p,
              isAr: isAr,
              onToggle: () => _toggle(_prefs.indexOf(p)),
              onTry: () => _tryNotification(p))),

          const SizedBox(height: AppTheme.spaceLg),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isAr ? pref.titleAr : pref.titleEn, style: AppTypography.bodyLarge),
            if (pref.descriptionEn != null && !isAr)
              Text(pref.descriptionEn!,
                  style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant)),
            if (pref.descriptionAr != null && isAr)
              Text(pref.descriptionAr!,
                  style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant)),
            if (pref.scheduledTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(pref.scheduledTime!,
                    style: AppTypography.labelMedium.copyWith(color: cs.primary)),
              ),
          ]),
        ),
        TextButton(
          onPressed: onTry,
          child: Text(isAr ? 'تجربة' : 'Try'),
        ),
        Switch.adaptive(
          value: pref.isEnabled,
          onChanged: (_) => onToggle(),
          activeTrackColor: cs.primary,
        ),
      ]),
    );
  }
}

class _PersonalNotificationTile extends StatelessWidget {
  final ScheduledNotification notification;
  final bool isAr;
  final VoidCallback onDelete;
  const _PersonalNotificationTile({
    required this.notification,
    required this.isAr,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final time = '${notification.hour.toString().padLeft(2, '0')}:${notification.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: cs.tertiaryContainer.withAlpha(60),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_rounded, color: cs.tertiary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isAr ? notification.titleAr : notification.titleEn, style: AppTypography.bodyLarge),
            Text(time, style: AppTypography.labelMedium.copyWith(color: cs.primary)),
          ]),
        ),
        IconButton(
          icon: Icon(Icons.delete_outline, color: cs.error, size: 20),
          onPressed: onDelete,
        ),
      ]),
    );
  }
}

class _AddPersonalTile extends StatelessWidget {
  final bool isAr;
  final VoidCallback onTap;
  const _AddPersonalTile({required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                isAr ? 'إضافة إشعار شخصي' : 'Add Personal Notification',
                style: AppTypography.bodyLarge.copyWith(color: cs.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddPersonalNotificationDialog extends StatefulWidget {
  final Function(String titleEn, String titleAr, String bodyEn, String bodyAr, int hour, int minute) onAdd;
  const _AddPersonalNotificationDialog({required this.onAdd});

  @override
  State<_AddPersonalNotificationDialog> createState() => _AddPersonalNotificationDialogState();
}

class _AddPersonalNotificationDialogState extends State<_AddPersonalNotificationDialog> {
  final _titleEnController = TextEditingController();
  final _titleArController = TextEditingController();
  final _bodyEnController = TextEditingController();
  final _bodyArController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleArController.dispose();
    _bodyEnController.dispose();
    _bodyArController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAr = context.watch<SettingsProvider>().isArabic;

    return AlertDialog(
      title: Text(isAr ? 'إشعار شخصي جديد' : 'New Personal Notification'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleEnController,
              decoration: InputDecoration(
                labelText: 'Title (English)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleArController,
              decoration: InputDecoration(
                labelText: 'العنوان (العربية)',
                border: const OutlineInputBorder(),
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyEnController,
              decoration: InputDecoration(
                labelText: 'Description (English)',
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyArController,
              decoration: InputDecoration(
                labelText: 'الوصف (العربية)',
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: cs.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isAr ? 'وقت الإشعار' : 'Notification Time'),
                    Text(
                      _selectedTime.format(context),
                      style: AppTypography.bodyLarge.copyWith(color: cs.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isAr ? 'إلغاء' : 'Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_titleEnController.text.isEmpty || _titleArController.text.isEmpty) return;
            widget.onAdd(
              _titleEnController.text,
              _titleArController.text,
              _bodyEnController.text,
              _bodyArController.text,
              _selectedTime.hour,
              _selectedTime.minute,
            );
            Navigator.pop(context);
          },
          child: Text(isAr ? 'إضافة' : 'Add'),
        ),
      ],
    );
  }
}
