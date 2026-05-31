import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/prayer_time_provider.dart';
import '../../modules/settings_module.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final isAr = s.isArabic;

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? 'الإعدادات' : 'Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.marginMobile,
          vertical: AppTheme.spaceSm,
        ),
        children: SettingsData.items.map((item) {
          return _SettingsTile(item: item, isArabic: isAr);
        }).toList(),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final SettingsItem item;
  final bool isArabic;
  const _SettingsTile({required this.item, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final cs = Theme.of(context).colorScheme;
    final title = isArabic ? item.titleAr : item.titleEn;
    final subtitle = isArabic ? item.subtitleAr : item.subtitleEn;

    Widget? trailing;
    VoidCallback? onTap;

    switch (item.key) {
      case 'language':
        trailing = Text(s.isArabic ? 'العربية' : 'English',
            style: AppTypography.labelLarge.copyWith(color: cs.primary));
        onTap = () async {
          await s.toggleLanguage();
          if (context.mounted) {
            context.read<PrayerTimeProvider>().setLanguage(isArabic: s.isArabic);
            context.read<PrayerTimeProvider>().rescheduleNotifications();
          }
        };
        break;
      case 'theme':
        final label = switch (s.themeMode) {
          ThemeMode.light => isArabic ? 'فاتح' : 'Light',
          ThemeMode.dark => isArabic ? 'داكن' : 'Dark',
          ThemeMode.system => isArabic ? 'النظام' : 'System',
        };
        trailing = Text(label,
            style: AppTypography.labelLarge.copyWith(color: cs.primary));
        onTap = () => s.cycleTheme();
        break;

      case 'notifications':
        trailing = Switch.adaptive(
          value: s.prayerNotificationsEnabled,
          onChanged: (enabled) async {
            await s.setPrayerNotificationsEnabled(enabled);
            if (context.mounted) {
              context.read<PrayerTimeProvider>().rescheduleNotifications();
            }
          },
          activeTrackColor: cs.primary.withAlpha(120),
          activeThumbColor: Colors.white,
          inactiveThumbColor: cs.onSurface.withAlpha(100),
          inactiveTrackColor: cs.onSurface.withAlpha(25),
        );
        break;
      case 'athkar_reminder':
        trailing = Switch.adaptive(
          value: s.athkarRemindersEnabled,
          onChanged: (enabled) async {
            await s.setAthkarRemindersEnabled(enabled);
            if (context.mounted) {
              context.read<PrayerTimeProvider>().rescheduleNotifications();
            }
          },
          activeTrackColor: cs.primary.withAlpha(120),
          activeThumbColor: Colors.white,
          inactiveThumbColor: cs.onSurface.withAlpha(100),
          inactiveTrackColor: cs.onSurface.withAlpha(25),
        );
        break;
      case 'about':
        trailing = Icon(Icons.chevron_right_rounded, color: cs.outline);
        onTap = () => _showAboutDialog(context, isArabic);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: Text(title, style: AppTypography.bodyLarge),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: AppTypography.labelMedium
                    .copyWith(color: cs.onSurfaceVariant))
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }


  void _showAboutDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(isArabic ? 'عن نور' : 'About Noor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App intro description
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    isArabic
                        ? 'تطبيق نور الأذكار هو رفيقك الإسلامي المتكامل. يساعدك على البقاء على صلة بدينك طوال اليوم من خلال مواقيت الصلاة الدقيقة، الأذكار اليومية، المسبحة الرقمية، المصحف الشامل مع دعم القراءة بدون إنترنت، بوصلة القبلة، البحث عن المساجد القريبة، والإشعارات الذكية لمواقيت الصلاة والأذكار وأيام الصيام وغيرها. كل هذا في تطبيق واحد جميل يعمل بدون إنترنت ويدعم العربية والإنجليزية بشكل كامل.'
                        : 'Noor Athkar is your complete Islamic companion app. It helps you stay connected to your faith throughout the day with accurate prayer times, daily athkar (remembrances), a digital Tasbeeh counter, a full Quran reader with offline support, a Qibla compass, nearby mosque finder, and smart notifications for prayer times, athkar, fasting days, and more. All in one beautiful, offline-first app with full Arabic and English support.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),
                _buildAboutSection(
                  icon: Icons.nightlight_round,
                  title: isArabic ? 'أفضل وقت لقيام الليل' : 'Best Time for Qiyam',
                  content: isArabic
                      ? 'السدس الرابع من الليل هو أفضل وقت لقيام الليل، كما أخبر النبي ﷺ عن صلاة نبي الله داود عليه السلام.'
                      : 'The fourth sixth of the night is the best time for Qiyam, as the Prophet Muhammad (PBUH) mentioned regarding the prayer of Prophet Dawud.',
                  cs: cs,
                ),
                const SizedBox(height: 16),
                _buildAboutSection(
                  icon: Icons.mosque_rounded,
                  title: isArabic ? 'أقرب المساجد' : 'Nearest Mosques',
                  content: isArabic
                      ? 'قسم المساجد يعرض لك أقرب المساجد لموقعك الحالي لتسهيل أداء الصلاة في وقتها.'
                      : 'The Mosques section tells you the nearest mosques to your current location.',
                  cs: cs,
                ),
                const SizedBox(height: 16),
                _buildAboutSection(
                  icon: Icons.notifications_active_rounded,
                  title: isArabic ? 'إشعارات مخصصة' : 'Custom Reminders',
                  content: isArabic
                      ? 'يمكنك إضافة إشعارات وتنبيهات مخصصة خاصة بك عن طريق الضغط على زر (+) في شاشة التنبيهات.'
                      : 'You can add your own custom notifications/reminders by tapping the "+" button in the Reminders screen.',
                  cs: cs,
                ),
                const SizedBox(height: 16),
                _buildAboutSection(
                  icon: Icons.info_outline_rounded,
                  title: isArabic ? 'إرشادات عامة' : 'General Guidance',
                  content: isArabic
                      ? '• تأكد من تفعيل صلاحيات الموقع الجغرافي والإشعارات لضمان دقة مواقيت الصلاة.\n• يمكنك تتبع تقدمك في الأذكار اليومية، حيث يتم إعادة ضبط العدادات تلقائياً.'
                      : '• Ensure location and notification permissions are enabled for accurate prayer times.\n• You can track your daily Athkar progress. Counters reset automatically.',
                  cs: cs,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isArabic ? 'إغلاق' : 'Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAboutSection({required IconData icon, required String title, required String content, required ColorScheme cs}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: cs.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleLarge.copyWith(color: cs.onSurface)),
              const SizedBox(height: 4),
              Text(content, style: AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
