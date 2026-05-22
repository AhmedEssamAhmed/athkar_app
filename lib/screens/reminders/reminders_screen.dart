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
      bodyEn: 'Test notification',
      bodyAr: 'إشعار تجريبي',
      category: pref.category,
    );
  }

  void _addPersonalNotification() {
    _showDialog(existing: null);
  }

  void _editPersonalNotification(ScheduledNotification existing) {
    _showDialog(existing: existing);
  }

  void _showDialog({ScheduledNotification? existing}) {
    final isAr = context.read<SettingsProvider>().isArabic;
    showDialog(
      context: context,
      builder: (ctx) => _PersonalNotificationDialog(
        existing: existing,
        isAr: isAr,
        onSaved: (titleEn, titleAr, hour, minute, basePrayer, minutesAfterPrayer, isBeforePrayer) async {
          final id = existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
          int actualHour = hour;
          int actualMinute = minute;

          if (basePrayer != null && minutesAfterPrayer != null) {
            final provider = context.read<PrayerTimeProvider>();
            final prayerTimes = <String, DateTime>{};
            if (provider.fajrTime != null) prayerTimes['fajr'] = provider.fajrTime!;
            if (provider.dhuhrTime != null) prayerTimes['dhuhr'] = provider.dhuhrTime!;
            if (provider.asrTime != null) prayerTimes['asr'] = provider.asrTime!;
            if (provider.maghribTime != null) prayerTimes['maghrib'] = provider.maghribTime!;
            if (provider.ishaTime != null) prayerTimes['isha'] = provider.ishaTime!;

            final prayerTime = prayerTimes[basePrayer];
            if (prayerTime != null) {
              final offset = isBeforePrayer == true ? -minutesAfterPrayer : minutesAfterPrayer;
              final totalMinutes = prayerTime.hour * 60 + prayerTime.minute + offset;
              actualHour = ((totalMinutes % 1440) + 1440) % 1440 ~/ 60;
              actualMinute = ((totalMinutes % 1440) + 1440) % 1440 % 60;
            }
          }

          if (existing != null) {
            await _notificationService.updatePersonalNotification(
              id: id,
              titleEn: titleEn,
              titleAr: titleAr,
              hour: actualHour,
              minute: actualMinute,
              basePrayer: basePrayer,
              minutesAfterPrayer: minutesAfterPrayer,
              isBeforePrayer: isBeforePrayer,
            );
          } else {
            await _notificationService.schedulePersonalNotification(
              id: id,
              titleEn: titleEn,
              titleAr: titleAr,
              hour: actualHour,
              minute: actualMinute,
              basePrayer: basePrayer,
              minutesAfterPrayer: minutesAfterPrayer,
              isBeforePrayer: isBeforePrayer,
            );
          }
          await _loadPersonalNotifications();
        },
      ),
    );
  }

  Future<void> _deletePersonalNotification(String id) async {
    await _notificationService.deletePersonalNotification('personal_$id');
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
            onEdit: () => _editPersonalNotification(n),
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

const _prayerOptions = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

const _prayerNames = {
  'fajr': ('Fajr', 'الفجر'),
  'dhuhr': ('Dhuhr', 'الظهر'),
  'asr': ('Asr', 'العصر'),
  'maghrib': ('Maghrib', 'المغرب'),
  'isha': ('Isha', 'العشاء'),
};

class _PersonalNotificationTile extends StatelessWidget {
  final ScheduledNotification notification;
  final bool isAr;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const _PersonalNotificationTile({
    required this.notification,
    required this.isAr,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String timeText;
    if (notification.basePrayer != null && notification.minutesAfterPrayer != null) {
      final prayerName = _prayerNames[notification.basePrayer];
      final mins = notification.minutesAfterPrayer!;
      final before = notification.isBeforePrayer == true;
      if (isAr) {
        timeText = before
            ? 'قبل $mins دقيقة من ${prayerName?.$2 ?? notification.basePrayer}'
            : 'بعد $mins دقيقة من ${prayerName?.$2 ?? notification.basePrayer}';
      } else {
        timeText = before
            ? '$mins min before ${prayerName?.$1 ?? notification.basePrayer}'
            : '$mins min after ${prayerName?.$1 ?? notification.basePrayer}';
      }
    } else {
      timeText = '${notification.hour.toString().padLeft(2, '0')}:${notification.minute.toString().padLeft(2, '0')}';
    }

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
            Text(timeText, style: AppTypography.labelMedium.copyWith(color: cs.primary)),
          ]),
        ),
        IconButton(
          icon: Icon(Icons.edit_outlined, color: cs.onSurfaceVariant, size: 20),
          onPressed: onEdit,
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

class _PersonalNotificationDialog extends StatefulWidget {
  final ScheduledNotification? existing;
  final bool isAr;
  final void Function(
    String titleEn,
    String titleAr,
    int hour,
    int minute,
    String? basePrayer,
    int? minutesAfterPrayer,
    bool? isBeforePrayer,
  ) onSaved;

  const _PersonalNotificationDialog({
    this.existing,
    required this.isAr,
    required this.onSaved,
  });

  @override
  State<_PersonalNotificationDialog> createState() => _PersonalNotificationDialogState();
}

class _PersonalNotificationDialogState extends State<_PersonalNotificationDialog> {
  final _titleController = TextEditingController();
  bool _usePrayerTime = false;
  String _selectedPrayer = 'fajr';
  bool _isBeforePrayer = false;
  int _offsetMinutes = 15;
  TimeOfDay _fixedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      if (widget.isAr) {
        _titleController.text = existing.titleAr;
      } else {
        _titleController.text = existing.titleEn;
      }
      if (existing.basePrayer != null) {
        _usePrayerTime = true;
        _selectedPrayer = existing.basePrayer!;
        _offsetMinutes = existing.minutesAfterPrayer ?? 15;
        _isBeforePrayer = existing.isBeforePrayer ?? false;
      } else {
        _fixedTime = TimeOfDay(hour: existing.hour ?? 0, minute: existing.minute ?? 0);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAr = widget.isAr;

    return AlertDialog(
      title: Text(widget.existing != null
          ? (isAr ? 'تعديل الإشعار' : 'Edit Notification')
          : (isAr ? 'إشعار شخصي جديد' : 'New Personal Notification')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: isAr ? 'العنوان' : 'Title',
                border: const OutlineInputBorder(),
              ),
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(isAr ? 'وقت محدد' : 'Fixed Time', style: AppTypography.bodyMedium),
                    value: false,
                    groupValue: _usePrayerTime,
                    onChanged: (v) => setState(() => _usePrayerTime = v!),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(isAr ? 'حسب الصلاة' : 'By Prayer', style: AppTypography.bodyMedium),
                    value: true,
                    groupValue: _usePrayerTime,
                    onChanged: (v) => setState(() => _usePrayerTime = v!),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
            if (_usePrayerTime) ...[
              DropdownButtonFormField<String>(
                value: _selectedPrayer,
                decoration: InputDecoration(
                  labelText: isAr ? 'الصلاة' : 'Prayer',
                  border: const OutlineInputBorder(),
                ),
                items: _prayerOptions.map((p) {
                  final names = _prayerNames[p]!;
                  return DropdownMenuItem(
                    value: p,
                    child: Text(isAr ? names.$2 : names.$1),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedPrayer = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(value: false, label: Text(isAr ? 'بعد' : 'After')),
                        ButtonSegment(value: true, label: Text(isAr ? 'قبل' : 'Before')),
                      ],
                      selected: {_isBeforePrayer},
                      onSelectionChanged: (v) => setState(() => _isBeforePrayer = v.first),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: isAr ? 'عدد الدقائق' : 'Minutes',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: _offsetMinutes.toString()),
                      onChanged: (v) => _offsetMinutes = int.tryParse(v) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(isAr ? 'دقيقة' : 'min', style: AppTypography.bodyMedium),
                ],
              ),
            ] else ...[
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _fixedTime,
                  );
                  if (time != null) setState(() => _fixedTime = time);
                },
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
                        _fixedTime.format(context),
                        style: AppTypography.bodyLarge.copyWith(color: cs.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
            if (_titleController.text.isEmpty) return;
            final title = _titleController.text.trim();
            widget.onSaved(
              isAr ? '' : title,
              isAr ? title : '',
              _fixedTime.hour,
              _fixedTime.minute,
              _usePrayerTime ? _selectedPrayer : null,
              _usePrayerTime ? _offsetMinutes : null,
              _usePrayerTime ? _isBeforePrayer : null,
            );
            Navigator.pop(context);
          },
          child: Text(widget.existing != null
              ? (isAr ? 'حفظ' : 'Save')
              : (isAr ? 'إضافة' : 'Add')),
        ),
      ],
    );
  }
}
