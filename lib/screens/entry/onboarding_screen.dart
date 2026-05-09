import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../main.dart';

/// Onboarding journey – visual walkthrough shown on first launch.
///
/// Design reference: Stitch screen `97bce4d019254f2c8dd75ff7891c0f13`.
///
/// Three illustrated pages with floating feature chips, bold titles,
/// and descriptions – matching the "Find Peace" design language.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      image: 'assets/images/onboarding_athkar.png',
      titleEn: 'Find Peace',
      titleAr: 'اعثر على السكينة',
      descEn:
          'Access your daily remembrance anytime. Your Morning, Evening, and Sleep Athkar are always available, even offline.',
      descAr:
          'اطلع على أذكارك اليومية في أي وقت. أذكار الصباح والمساء والنوم متاحة دائمًا، حتى بدون إنترنت.',
      chips: [
        _ChipData(Icons.wb_sunny_rounded, 'Morning', 'الصباح'),
        _ChipData(Icons.nightlight_round, 'Evening', 'المساء'),
      ],
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_tasbeeh.png',
      titleEn: 'Track Your Dhikr',
      titleAr: 'تابع أذكارك',
      descEn:
          'Count your tasbeeh with a beautiful digital counter. Set goals, track progress, and build a consistent daily habit.',
      descAr:
          'عدّ تسبيحك بعداد رقمي أنيق. حدد أهدافك، تابع تقدمك، وابنِ عادة يومية ثابتة.',
      chips: [
        _ChipData(Icons.touch_app_rounded, 'Tasbeeh', 'تسبيح'),
        _ChipData(Icons.trending_up_rounded, 'Progress', 'التقدم'),
      ],
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_quran.png',
      titleEn: 'Read the Quran',
      titleAr: 'اقرأ القرآن',
      descEn:
          'Browse all 114 Surahs and 30 Juz. Download any Juz for offline reading wherever you are.',
      descAr:
          'تصفح جميع السور الـ 114 والأجزاء الـ 30. حمّل أي جزء للقراءة بدون إنترنت أينما كنت.',
      chips: [
        _ChipData(Icons.menu_book_rounded, 'Quran', 'القرآن'),
        _ChipData(Icons.download_rounded, 'Offline', 'بدون إنترنت'),
      ],
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    final settings = context.read<SettingsProvider>();
    await settings.completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AppShell(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsProvider>().isArabic;
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Skip
              Align(
                alignment: isAr ? Alignment.topLeft : Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.marginMobile,
                    vertical: 12,
                  ),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      isAr ? 'تخطي' : 'Skip',
                      style: AppTypography.labelLarge
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, i) =>
                      _OnboardingPage(data: _pages[i], isAr: isAr),
                ),
              ),

              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.marginMobile, 0,
                  AppTheme.marginMobile, AppTheme.spaceLg,
                ),
                child: Row(
                  children: [
                    // Dots
                    Row(
                      children: List.generate(_pages.length, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          width: active ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: active
                                ? AppColors.goldenAccent
                                : cs.outlineVariant.withAlpha(100),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    // Next / Get Started
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: _currentPage == _pages.length - 1
                                ? 32
                                : 20,
                          ),
                        ),
                        child: _currentPage < _pages.length - 1
                            ? Icon(
                                isAr
                                    ? Icons.arrow_back_rounded
                                    : Icons.arrow_forward_rounded,
                                color: cs.onPrimary,
                              )
                            : Text(
                                isAr ? 'ابدأ الآن' : 'Get Started',
                                style: AppTypography.labelLarge
                                    .copyWith(color: cs.onPrimary),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Single onboarding page
// ═══════════════════════════════════════════════════════════════════

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final bool isAr;
  const _OnboardingPage({required this.data, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // ── Arch-framed illustration with floating chips ─────
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Arch container
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: cs.primary.withAlpha(20),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(120),
                      topRight: Radius.circular(120),
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: cs.primary.withAlpha(30),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(120),
                      topRight: Radius.circular(120),
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Image.asset(
                      data.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Floating chips
                Positioned(
                  bottom: 40,
                  left: 24,
                  child: _FloatingChip(
                    icon: data.chips[0].icon,
                    label: isAr ? data.chips[0].labelAr : data.chips[0].labelEn,
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 24,
                  child: _FloatingChip(
                    icon: data.chips[1].icon,
                    label: isAr ? data.chips[1].labelAr : data.chips[1].labelEn,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spaceMd),

          // ── Title ─────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  isAr ? data.titleAr : data.titleEn,
                  style: AppTypography.headlineLarge.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // ── Description ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    isAr ? data.descAr : data.descEn,
                    style: AppTypography.bodyMedium.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Floating chip widget (matches the Stitch design)
// ═══════════════════════════════════════════════════════════════════

class _FloatingChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FloatingChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.goldenAccent),
          const SizedBox(width: 8),
          Text(label,
              style: AppTypography.labelLarge.copyWith(color: cs.onSurface)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Data models
// ═══════════════════════════════════════════════════════════════════

class _OnboardingData {
  final String image;
  final String titleEn;
  final String titleAr;
  final String descEn;
  final String descAr;
  final List<_ChipData> chips;

  const _OnboardingData({
    required this.image,
    required this.titleEn,
    required this.titleAr,
    required this.descEn,
    required this.descAr,
    required this.chips,
  });
}

class _ChipData {
  final IconData icon;
  final String labelEn;
  final String labelAr;
  const _ChipData(this.icon, this.labelEn, this.labelAr);
}
