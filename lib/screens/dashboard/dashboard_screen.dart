import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/decorative_background.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/prayer_time_provider.dart';
import '../../main.dart';
import '../qibla/qibla_screen.dart';
import '../mosques/mosques_screen.dart';
import '../reminders/reminders_screen.dart';
import '../../modules/prayer_module.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final prayerProvider = context.watch<PrayerTimeProvider>();
    final isAr = settings.isArabic;
    final hijri = prayerProvider.hijriDate;
    final prayers = prayerProvider.prayers;

    return Scaffold(
      body: SafeArea(
        child: prayerProvider.isLoading
            ? const _AnimatedLoadingWidget()
            : DecorativeBackground(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _AnimatedSection(
                        delayMs: 0,
                        child: _GreetingHeader(
                          isArabic: isAr,
                          hijri: hijri,
                          isLoadingLocation: prayerProvider.isLoading,
                          locationName: prayerProvider.locationName,
                          error: prayerProvider.error,
                          onRetry: () => prayerProvider.refresh(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _AnimatedSection(
                        delayMs: 100,
                        child: _CurrentPrayerCard(prayers: prayers, isArabic: isAr, provider: prayerProvider),
                      ),
                      const SizedBox(height: 24),
                      _AnimatedSection(
                        delayMs: 200,
                        child: _SectionLabel(
                          icon: Icons.schedule_rounded,
                          label: isAr ? 'مواقيت الصلاة' : 'Prayer Times',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AnimatedSection(
                        delayMs: 250,
                        child: _PrayerTimesList(prayers: prayers, isArabic: isAr),
                      ),
                      const SizedBox(height: 24),
                      _AnimatedSection(
                        delayMs: 350,
                        child: _SpecialTimesRow(
                          isArabic: isAr,
                          items: [
                            _TimeItem(
                              icon: Icons.nights_stay_rounded,
                              labelAr: 'منتصف الليل',
                              labelEn: 'Midnight',
                              time: prayerProvider.midnightTime,
                              color: AppColors.primary,
                            ),
                            _TimeItem(
                              icon: Icons.star_rounded,
                              labelAr: 'الثلث الأخير',
                              labelEn: 'Last Third',
                              time: prayerProvider.lastThirdTime,
                              color: AppColors.gold,
                            ),
                            _TimeItem(
                              icon: Icons.wb_sunny_rounded,
                              labelAr: 'الضحى',
                              labelEn: 'Duha',
                              time: prayerProvider.duhaTime,
                              color: AppColors.primaryLight,
                            ),
                            _TimeItem(
                              icon: Icons.wb_sunny_outlined,
                              labelAr: 'أذكار الصباح',
                              labelEn: 'Morning Athkar',
                              time: prayerProvider.morningAthkarTime,
                              color: AppColors.primary,
                            ),
                            _TimeItem(
                              icon: Icons.nightlight_round,
                              labelAr: 'أذكار المساء',
                              labelEn: 'Evening Athkar',
                              time: prayerProvider.eveningAthkarTime,
                              color: AppColors.gold,
                            ),
                            _TimeItem(
                              icon: Icons.star_border,
                              labelAr: 'السدس الرابع',
                              labelEn: '4th Sixth',
                              time: prayerProvider.fourthSixthTime,
                              color: AppColors.primaryLight,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      _AnimatedSection(
                        delayMs: 450,
                        child: _SectionLabel(
                          icon: Icons.explore_rounded,
                          label: isAr ? 'الوصول السريع' : 'Quick Access',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AnimatedSection(
                        delayMs: 500,
                        child: _QuickAccessGrid(isArabic: isAr),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Animated Loading Widget
// ─────────────────────────────────────────────

class _AnimatedLoadingWidget extends StatefulWidget {
  const _AnimatedLoadingWidget();
  @override
  State<_AnimatedLoadingWidget> createState() => _AnimatedLoadingWidgetState();
}

class _AnimatedLoadingWidgetState extends State<_AnimatedLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + 0.08 * sin(_controller.value * pi * 2),
                child: Opacity(
                  opacity: 0.6 + 0.4 * sin(_controller.value * pi * 2 + pi * 0.5),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.primary.withAlpha(40),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.mosque_rounded,
                      size: 36,
                      color: cs.primary.withAlpha(180),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: 0.5 + 0.5 * sin(_controller.value * pi * 2),
                child: Text(
                  'Noor',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withAlpha(140),
                    letterSpacing: 4,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Animated Section (fade + slide entrance)
// ─────────────────────────────────────────────

class _AnimatedSection extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const _AnimatedSection({required this.child, this.delayMs = 0});

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    if (widget.delayMs > 0) {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: FractionalTranslation(
            translation: _slide.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(label, style: AppTypography.titleLarge),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Greeting Header
// ─────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final bool isArabic;
  final dynamic hijri;
  final bool isLoadingLocation;
  final String locationName;
  final String? error;
  final VoidCallback? onRetry;

  const _GreetingHeader({
    required this.isArabic,
    required this.hijri,
    required this.isLoadingLocation,
    required this.locationName,
    this.error,
    this.onRetry,
  });

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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withAlpha(12),
            AppColors.gold.withAlpha(8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: cs.primary.withAlpha(15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(),
            style: GoogleFonts.amiri(
              fontSize: isArabic ? 30 : 28,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.gold),
              const SizedBox(width: 6),
              Text(
                isArabic ? hijri.formattedAr : hijri.formatted,
                style: AppTypography.bodyMedium.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                error != null ? Icons.location_off_rounded : Icons.location_on_rounded,
                size: 15,
                color: error != null ? cs.error : cs.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isLoadingLocation
                      ? (isArabic ? 'جاري تحديد الموقع...' : 'Detecting location...')
                      : (error ?? locationName),
                  style: AppTypography.bodyMedium.copyWith(
                    color: error != null ? cs.error : cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, size: 18,
                    color: error != null ? cs.error : cs.primary),
                  onPressed: onRetry,
                  tooltip: isArabic ? 'تحديث الموقع' : 'Refresh location',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Current Prayer Card
// ─────────────────────────────────────────────

class _CurrentPrayerCard extends StatefulWidget {
  final List<PrayerTime> prayers;
  final bool isArabic;
  final PrayerTimeProvider provider;

  const _CurrentPrayerCard({
    required this.prayers,
    required this.isArabic,
    required this.provider,
  });

  @override
  State<_CurrentPrayerCard> createState() => _CurrentPrayerCardState();
}

class _CurrentPrayerCardState extends State<_CurrentPrayerCard> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  DateTime? _prayerDateTime(String name) {
    return switch (name) {
      'Fajr' => widget.provider.fajrTime,
      'Sunrise' => widget.provider.sunriseTime,
      'Dhuhr' => widget.provider.dhuhrTime,
      'Asr' => widget.provider.asrTime,
      'Maghrib' => widget.provider.maghribTime,
      'Isha' => widget.provider.ishaTime,
      _ => null,
    };
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final isArabic = widget.isArabic;
    final period = hour < 12
        ? (isArabic ? 'صباحاً' : 'AM')
        : (isArabic ? 'مساءً' : 'PM');
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h12:$m $period';
  }

  Duration _timeUntil(DateTime? target) {
    if (target == null) return Duration.zero;
    return target.difference(_now);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final prayers = widget.prayers;
    final isArabic = widget.isArabic;

    if (prayers.isEmpty) return const SizedBox.shrink();

    final current = prayers.firstWhere(
      (p) => p.isCurrent,
      orElse: () => prayers.first,
    );

    final currentIdx = prayers.indexOf(current);
    final next = currentIdx + 1 < prayers.length
        ? prayers[currentIdx + 1]
        : prayers.first;

    final nextDt = _prayerDateTime(next.name);
    final timeLeft = _timeUntil(nextDt);
    final hours = timeLeft.inHours;
    final minutes = timeLeft.inMinutes.remainder(60);
    final seconds = timeLeft.inSeconds.remainder(60);
    final isNegative = timeLeft.isNegative;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            cs.primary.withAlpha(200),
            cs.primary.withAlpha(180),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withAlpha(70),
            blurRadius: 35,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: cs.primary.withAlpha(30),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.mosque_rounded, size: 16, color: Colors.white.withAlpha(220)),
              ),
              const SizedBox(width: 10),
              Text(
                isArabic ? 'الصلاة الحالية' : 'Current Prayer',
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white.withAlpha(200),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? current.nameAr : current.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: isArabic ? 'Amiri' : 'Manrope',
                        fontSize: isArabic ? 32 : 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _formatTime(_now),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 44,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withAlpha(240),
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.white.withAlpha(25),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            isArabic ? next.nameAr : next.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.navigate_next_rounded, size: 16, color: Colors.white.withAlpha(160)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isNegative
                          ? (isArabic ? '--:--' : '--:--')
                          : hours > 0
                              ? '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                              : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Prayer Times List
// ─────────────────────────────────────────────

const _prayerIconMap = <String, IconData>{
  'Fajr': Icons.wb_sunny_rounded,
  'Sunrise': Icons.sunny,
  'Dhuhr': Icons.wb_cloudy_rounded,
  'Asr': Icons.cloud_rounded,
  'Maghrib': Icons.nightlight_round,
  'Isha': Icons.nights_stay_rounded,
};

class _PrayerTimesList extends StatelessWidget {
  final List<PrayerTime> prayers;
  final bool isArabic;

  const _PrayerTimesList({required this.prayers, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: prayers.map((prayer) {
          final isCurrent = prayer.isCurrent;
          final icon = _prayerIconMap[prayer.name] ?? Icons.schedule_rounded;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isCurrent ? cs.primary.withAlpha(12) : Colors.transparent,
              borderRadius: isCurrent ? BorderRadius.circular(AppTheme.radiusMd) : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? cs.primary.withAlpha(25)
                        : cs.surfaceContainerHighest.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: isCurrent ? cs.primary : cs.onSurfaceVariant),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    isArabic ? prayer.nameAr : prayer.name,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isCurrent ? cs.primary : cs.onSurface,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  prayer.time,
                  style: AppTypography.bodyLarge.copyWith(
                    color: isCurrent ? cs.primary : cs.onSurfaceVariant,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (isCurrent)
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(80),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Special Times Row
// ─────────────────────────────────────────────

class _TimeItem {
  final IconData icon;
  final String labelAr;
  final String labelEn;
  final String time;
  final Color color;

  const _TimeItem({
    required this.icon,
    required this.labelAr,
    required this.labelEn,
    required this.time,
    required this.color,
  });
}

class _SpecialTimesRow extends StatelessWidget {
  final bool isArabic;
  final List<_TimeItem> items;

  const _SpecialTimesRow({required this.isArabic, required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'أوقات اليوم' : "Today's Times",
                style: AppTypography.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.3,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final badgeStyle = index % 3;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      item.color.withAlpha(isDark ? 25 : 15),
                      item.color.withAlpha(isDark ? 10 : 5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: item.color.withAlpha(isDark ? 40 : 25),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    if (badgeStyle == 0)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              item.color.withAlpha(isDark ? 160 : 200),
                              item.color.withAlpha(isDark ? 120 : 150),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, size: 18, color: Colors.white),
                      )
                    else if (badgeStyle == 1)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.color.withAlpha(isDark ? 50 : 30),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: item.color.withAlpha(isDark ? 100 : 70),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(item.icon, size: 18, color: item.color),
                      )
                    else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: item.color.withAlpha(isDark ? 70 : 50),
                            width: 1,
                          ),
                        ),
                        child: Icon(item.icon, size: 18, color: item.color.withAlpha(isDark ? 200 : 220)),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        clipBehavior: Clip.hardEdge,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.time,
                              style: AppTypography.bodyLarge.copyWith(
                                color: isDark ? item.color.withAlpha(220) : item.color,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              isArabic ? item.labelAr : item.labelEn,
                              style: AppTypography.labelMedium.copyWith(
                                color: cs.onSurfaceVariant.withAlpha(isDark ? 160 : 180),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quick Access Grid
// ─────────────────────────────────────────────

class _QuickItem {
  final IconData icon;
  final String labelEn;
  final String labelAr;
  final Color color;
  final Widget? screen;
  final int? tabIndex;

  const _QuickItem({
    required this.icon,
    required this.labelEn,
    required this.labelAr,
    required this.color,
    this.screen,
    this.tabIndex,
  });
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
        color: cs.primary,
        tabIndex: 1,
      ),
      _QuickItem(
        icon: Icons.menu_book_rounded,
        labelEn: 'Quran',
        labelAr: 'القرآن',
        color: AppColors.gold,
        tabIndex: 3,
      ),
      _QuickItem(
        icon: Icons.touch_app_rounded,
        labelEn: 'Tasbeeh',
        labelAr: 'المسبحة',
        color: AppColors.primaryLight,
        tabIndex: 2,
      ),
      _QuickItem(
        icon: Icons.explore_rounded,
        labelEn: 'Qibla',
        labelAr: 'القبلة',
        color: cs.primary,
        screen: const QiblaScreen(),
      ),
      _QuickItem(
        icon: Icons.mosque_rounded,
        labelEn: 'Mosques',
        labelAr: 'المساجد',
        color: AppColors.gold,
        screen: const MosquesScreen(),
      ),
      _QuickItem(
        icon: Icons.notifications_rounded,
        labelEn: 'Reminders',
        labelAr: 'التذكيرات',
        color: AppColors.primaryLight,
        screen: const RemindersScreen(),
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 40 - 24) / 3,
          child: _QuickAccessTile(item: item, isArabic: isArabic),
        );
      }).toList(),
    );
  }
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
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        onTap: () {
          if (item.tabIndex != null) {
            AppShell.navigateTo(context, item.tabIndex!);
          } else if (item.screen != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen!));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: cs.outlineVariant.withAlpha(50), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withAlpha(18),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                  isArabic ? item.labelAr : item.labelEn,
                  style: AppTypography.bodyMedium.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
