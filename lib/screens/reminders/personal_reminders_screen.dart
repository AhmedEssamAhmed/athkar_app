import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_typography.dart';
import '../../core/widgets/decorative_background.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/prayer_time_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/prayer_time_service.dart';
import '../../core/constants/prayer_names.dart';

class PersonalRemindersScreen extends StatefulWidget {
  const PersonalRemindersScreen({super.key});
  @override
  State<PersonalRemindersScreen> createState() => _PersonalRemindersScreenState();
}

class _PersonalRemindersScreenState extends State<PersonalRemindersScreen> {
  final NotificationService _notificationService = NotificationService();
  List<ScheduledNotification> _personalNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadPersonalNotifications();
  }

  Future<void> _loadPersonalNotifications() async {
    final notifications = await _notificationService.getNotifications();
    if (!mounted) return;
    setState(() {
      _personalNotifications = notifications
          .where((n) => n.category == NotificationCategory.personal)
          .toList();
    });
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'الإشعارات الشخصية' : 'Personal Reminders'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPersonalNotification,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(Icons.add),
        label: Text(isAr ? 'إشعار جديد' : 'New Notification'),
      ),
      body: DecorativeBackground(
        child: _personalNotifications.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              cs.primary.withAlpha(20),
                              cs.primary.withAlpha(8),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: cs.primary.withAlpha(80),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        isAr ? 'لا توجد إشعارات شخصية' : 'No Personal Reminders',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAr
                            ? 'أضف إشعاراً مخصصاً ليتم تذكيرك بما تريد'
                            : 'Add a custom notification to get reminded of what matters',
                        style: AppTypography.bodyMedium.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: _addPersonalNotification,
                        icon: const Icon(Icons.add_rounded),
                        label: Text(isAr ? 'إضافة إشعار' : 'Add Reminder'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: _personalNotifications.length,
                itemBuilder: (context, index) {
                  final n = _personalNotifications[index];
                  return _PersonalNotificationTile(
                    notification: n,
                    isAr: isAr,
                    onDelete: () => _deletePersonalNotification(n.id),
                    onEdit: () => _editPersonalNotification(n),
                  );
                },
              ),
      ),
    );
  }
}

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

  String _formatFixedTime() {
    final hour = notification.hour;
    final minute = notification.minute;
    if (hour == null || minute == null) return '--:--';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, hour, minute);
    return PrayerTimeService().formatTime(dt, isArabic: isAr);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    String timeText;
    if (notification.basePrayer != null && notification.minutesAfterPrayer != null) {
      final prayerName = PrayerNames.names[notification.basePrayer];
      final mins = notification.minutesAfterPrayer!;
      final before = notification.isBeforePrayer == true;
      if (isAr) {
        timeText = before
            ? 'قبل $mins دقيقة من ${prayerName?.ar ?? notification.basePrayer}'
            : 'بعد $mins دقيقة من ${prayerName?.ar ?? notification.basePrayer}';
      } else {
        timeText = before
            ? '$mins min before ${prayerName?.en ?? notification.basePrayer}'
            : '$mins min after ${prayerName?.en ?? notification.basePrayer}';
      }
    } else {
      timeText = _formatFixedTime();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cs.tertiary.withAlpha(15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_rounded, color: cs.tertiary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? notification.titleAr : notification.titleEn,
                style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: cs.primary),
                  const SizedBox(width: 4),
                  Text(
                    timeText,
                    style: AppTypography.labelMedium.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.onSurface.withAlpha(6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined, color: cs.onSurfaceVariant, size: 18),
                onPressed: onEdit,
                splashRadius: 18,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: cs.error.withAlpha(180), size: 18),
                onPressed: onDelete,
                splashRadius: 18,
              ),
            ],
          ),
        ),
      ]),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
              textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(isAr ? 'وقت محدد' : 'Fixed Time', style: AppTypography.bodyMedium),
                    leading: Radio<bool>(
                      value: false,
                      // ignore: deprecated_member_use
                      groupValue: _usePrayerTime,
                      // ignore: deprecated_member_use
                      onChanged: (v) => setState(() => _usePrayerTime = v!),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onTap: () => setState(() => _usePrayerTime = false),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(isAr ? 'حسب الصلاة' : 'By Prayer', style: AppTypography.bodyMedium),
                    leading: Radio<bool>(
                      value: true,
                      // ignore: deprecated_member_use
                      groupValue: _usePrayerTime,
                      // ignore: deprecated_member_use
                      onChanged: (v) => setState(() => _usePrayerTime = v!),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onTap: () => setState(() => _usePrayerTime = true),
                  ),
                ),
              ],
            ),
            if (_usePrayerTime) ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedPrayer,
                decoration: InputDecoration(
                  labelText: isAr ? 'الصلاة' : 'Prayer',
                  border: const OutlineInputBorder(),
                ),
                items: PrayerNames.keys.where((k) => k != 'sunrise').map((p) {
                  final names = PrayerNames.names[p]!;
                  return DropdownMenuItem(
                    value: p,
                    child: Text(isAr ? names.ar : names.en),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAr ? 'وقت الإشعار' : 'Notification Time',
                        style: AppTypography.bodyMedium,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _fixedTime.format(context),
                          style: AppTypography.bodyLarge.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
              isAr ? (widget.existing?.titleEn ?? title) : title,
              isAr ? title : (widget.existing?.titleAr ?? title),
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
