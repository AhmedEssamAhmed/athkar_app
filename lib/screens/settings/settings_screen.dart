import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../modules/settings_module.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final isAr = s.isArabic;
    final cs = Theme.of(context).colorScheme;

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
        onTap = () => s.toggleLanguage();
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
      case 'athkar_reminder':
      case 'haptic':
        trailing = Switch.adaptive(
          value: true, // TODO: wire to actual preference
          onChanged: (_) {},
          activeColor: cs.primary,
        );
        break;
      case 'about':
        trailing = Icon(Icons.chevron_right_rounded, color: cs.outline);
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
}
