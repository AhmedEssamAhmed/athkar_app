import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../modules/prayer_module.dart';
import '../../main.dart';
import '../athkar/athkar_screen.dart';
import '../qibla/qibla_screen.dart';
import '../mosques/mosques_screen.dart';
import '../reminders/reminders_screen.dart';

/// Dashboard screen — the home screen of Noor Athkar.
///
/// Matches the Stitch "Home Dashboard" design:
/// - Hijri date header
/// - Prayer time cards with current-prayer highlight
/// - Quick-access grid for app features
/// - Greeting based on time of day
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isAr = settings.isArabic;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hijri = PrayerData.todayHijri();
    final prayers = PrayerData.todayPrayers();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.marginMobile,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spaceMd),

              // ── Greeting & Hijri date ─────────────────────
              _GreetingHeader(isArabic: isAr, hijri: hijri),

              const SizedBox(height: AppTheme.spaceMd),

              // ── Current prayer hero card ──────────────────
              _CurrentPrayerCard(prayers: prayers, isArabic: isAr),

              const SizedBox(height: AppTheme.spaceMd),

              // ── All prayer times ──────────────────────────
              Text(
                isAr ? 'مواقيت الصلاة' : 'Prayer Times',
                style: tt.titleLarge,
              ),
              const SizedBox(height: AppTheme.spaceSm),
              _PrayerTimesList(prayers: prayers, isArabic: isAr),

              const SizedBox(height: AppTheme.spaceLg),

              // ── Quick access grid ─────────────────────────
              Text(
                isAr ? 'الوصول السريع' : 'Quick Access',
                style: tt.titleLarge,
              ),
              const SizedBox(height: AppTheme.spaceSm),
              _QuickAccessGrid(isArabic: isAr),

              const SizedBox(height: AppTheme.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Private widgets
// ════════════════════════════════════════════════════════════════════

class _GreetingHeader extends StatelessWidget {
  final bool isArabic;
  final HijriDate hijri;

  const _GreetingHeader({required this.isArabic, required this.hijri});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (isArabic) {
      if (hour < 12) return 'صباح الخير';
      if (hour < 18) return 'مساء الخير';
      return 'مساء النور';
    } else {
      if (hour < 12) return 'Good Morning';
      if (hour < 18) return 'Good Afternoon';
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(),
          style: AppTypography.headlineLarge.copyWith(
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isArabic ? hijri.formattedAr : hijri.formatted,
          style: AppTypography.bodyMedium.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CurrentPrayerCard extends StatelessWidget {
  final List<PrayerTime> prayers;
  final bool isArabic;

  const _CurrentPrayerCard({required this.prayers, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final current = prayers.firstWhere(
      (p) => p.isCurrent,
      orElse: () => prayers.first,
    );

    // Find next prayer
    final currentIdx = prayers.indexOf(current);
    final next = currentIdx + 1 < prayers.length
        ? prayers[currentIdx + 1]
        : prayers.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            cs.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withAlpha(25),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'الصلاة الحالية' : 'Current Prayer',
            style: AppTypography.labelLarge.copyWith(
              color: Colors.white.withAlpha(180),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? current.nameAr : current.name,
                style: AppTypography.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                current.time,
                style: AppTypography.headlineLarge.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              isArabic
                  ? 'التالية: ${next.nameAr} – ${next.time}'
                  : 'Next: ${next.name} – ${next.time}',
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimesList extends StatelessWidget {
  final List<PrayerTime> prayers;
  final bool isArabic;

  const _PrayerTimesList({required this.prayers, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: prayers.map((prayer) {
        final isCurrent = prayer.isCurrent;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.gutter,
            vertical: AppTheme.spaceSm,
          ),
          decoration: BoxDecoration(
            color: isCurrent
                ? cs.primaryContainer.withAlpha(30)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: isCurrent
                ? Border.all(color: cs.primary.withAlpha(60), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Status dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent
                          ? AppColors.goldenAccent
                          : prayer.isPassed
                              ? AppColors.mutedSage
                              : cs.outline.withAlpha(60),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isArabic ? prayer.nameAr : prayer.name,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isCurrent ? cs.primary : cs.onSurface,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Text(
                prayer.time,
                style: AppTypography.bodyLarge.copyWith(
                  color: isCurrent ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  final bool isArabic;

  const _QuickAccessGrid({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final items = [
      _QuickItem(
        icon: Icons.auto_stories_rounded,
        labelEn: 'Athkar',
        labelAr: 'الأذكار',
        color: cs.primaryContainer,
        tabIndex: 1,
      ),
      _QuickItem(
        icon: Icons.menu_book_rounded,
        labelEn: 'Quran',
        labelAr: 'القرآن',
        color: cs.tertiaryContainer,
        tabIndex: 3,
      ),
      _QuickItem(
        icon: Icons.touch_app_rounded,
        labelEn: 'Tasbeeh',
        labelAr: 'المسبحة',
        color: AppColors.goldenAccent,
        tabIndex: 2,
      ),
      _QuickItem(
        icon: Icons.explore_rounded,
        labelEn: 'Qibla',
        labelAr: 'القبلة',
        color: cs.secondaryContainer,
        screen: const QiblaScreen(),
      ),
      _QuickItem(
        icon: Icons.mosque_rounded,
        labelEn: 'Mosques',
        labelAr: 'المساجد',
        color: cs.primaryContainer,
        screen: const MosquesScreen(),
      ),
      _QuickItem(
        icon: Icons.notifications_rounded,
        labelEn: 'Reminders',
        labelAr: 'التذكيرات',
        color: cs.tertiaryContainer,
        screen: const RemindersScreen(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppTheme.spaceSm,
        crossAxisSpacing: AppTheme.spaceSm,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _QuickAccessTile(item: item, isArabic: isArabic);
      },
    );
  }
}

class _QuickItem {
  final IconData icon;
  final String labelEn;
  final String labelAr;
  final Color color;
  final Widget? screen; // push this screen
  final int? tabIndex;  // or switch to this tab

  const _QuickItem({
    required this.icon,
    required this.labelEn,
    required this.labelAr,
    required this.color,
    this.screen,
    this.tabIndex,
  });
}

class _QuickAccessTile extends StatelessWidget {
  final _QuickItem item;
  final bool isArabic;

  const _QuickAccessTile({required this.item, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: () {
          if (item.tabIndex != null) {
            AppShell.navigateTo(context, item.tabIndex!);
          } else if (item.screen != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen!));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: cs.outlineVariant.withAlpha(80),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic ? item.labelAr : item.labelEn,
                style: AppTypography.labelMedium.copyWith(
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
