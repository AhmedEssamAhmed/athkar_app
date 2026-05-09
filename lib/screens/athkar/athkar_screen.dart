import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../modules/athkar_module.dart';

/// Athkar Categories screen — lists all athkar categories as tappable cards.
class AthkarCategoriesScreen extends StatelessWidget {
  const AthkarCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsProvider>().isArabic;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? 'الأذكار' : 'Athkar')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.marginMobile),
        itemCount: AthkarCategory.values.length,
        itemBuilder: (context, index) {
          final cat = AthkarCategory.values[index];
          final icons = [
            Icons.wb_sunny_rounded,
            Icons.nightlight_round,
            Icons.mosque_rounded,
            Icons.bedtime_rounded,
            Icons.alarm_rounded,
            Icons.menu_book_rounded,
            Icons.auto_awesome_rounded,
            Icons.more_horiz_rounded,
          ];
          final colors = [
            AppColors.goldenAccent,
            cs.primary,
            cs.tertiary,
            cs.primaryContainer,
            AppColors.goldenAccent,
            cs.tertiaryContainer,
            cs.secondaryContainer,
            AppColors.mutedSage,
          ];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AthkarReaderScreen(category: cat),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(
                      color: cs.outlineVariant.withAlpha(60),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight.withAlpha(10),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors[index].withAlpha(30),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icons[index], color: colors[index], size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? cat.arabicTitle : cat.englishTitle,
                              style: AppTypography.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAr
                                  ? '${_countForCategory(cat)} ذكر'
                                  : '${_countForCategory(cat)} adhkar',
                              style: AppTypography.labelMedium.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isAr ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                        color: cs.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  int _countForCategory(AthkarCategory cat) {
    // Placeholder counts — replace with real DB queries
    return switch (cat) {
      AthkarCategory.morning => 27,
      AthkarCategory.evening => 25,
      AthkarCategory.afterPrayer => 10,
      AthkarCategory.sleep => 12,
      AthkarCategory.wakeUp => 5,
      AthkarCategory.quranDua => 15,
      AthkarCategory.propheticDua => 20,
      AthkarCategory.misc => 18,
    };
  }
}

/// Athkar Reader — displays the individual dhikr items for a given category.
class AthkarReaderScreen extends StatefulWidget {
  final AthkarCategory category;
  const AthkarReaderScreen({super.key, required this.category});

  @override
  State<AthkarReaderScreen> createState() => _AthkarReaderScreenState();
}

class _AthkarReaderScreenState extends State<AthkarReaderScreen> {
  late List<Dhikr> _athkar;
  late List<int> _remainingCounts;

  @override
  void initState() {
    super.initState();
    _athkar = AthkarData.sampleMorningAthkar(); // Use sample for all for now
    _remainingCounts = _athkar.map((d) => d.repeatCount).toList();
  }

  void _onTapDhikr(int index) {
    if (_remainingCounts[index] > 0) {
      setState(() => _remainingCounts[index]--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsProvider>().isArabic;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAr ? widget.category.arabicTitle : widget.category.englishTitle,
        ),
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _athkar.length,
        itemBuilder: (context, index) {
          final dhikr = _athkar[index];
          final remaining = _remainingCounts[index];
          final done = remaining == 0;

          return GestureDetector(
            onTap: () => _onTapDhikr(index),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              margin: const EdgeInsets.all(AppTheme.marginMobile),
              decoration: BoxDecoration(
                color: done
                    ? cs.primaryContainer.withAlpha(20)
                    : cs.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(
                  color: done ? cs.primary.withAlpha(40) : cs.outlineVariant.withAlpha(60),
                  width: done ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Arabic text
                  Text(
                    dhikr.arabicText,
                    style: AppTypography.arabicBody.copyWith(
                      color: cs.onSurface,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  // Translation
                  if (dhikr.translation.isNotEmpty)
                    Text(
                      dhikr.translation,
                      style: AppTypography.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // Counter chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: done
                          ? cs.primary
                          : AppColors.goldenAccent.withAlpha(30),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      done
                          ? (isAr ? '✓ تم' : '✓ Done')
                          : '$remaining / ${dhikr.repeatCount}',
                      style: AppTypography.titleLarge.copyWith(
                        color: done ? cs.onPrimary : AppColors.goldenAccent,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Reference
                  if (dhikr.reference != null)
                    Text(
                      dhikr.reference!,
                      style: AppTypography.labelMedium.copyWith(
                        color: cs.outline,
                      ),
                    ),

                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'اضغط للعد • اسحب للتالي' : 'Tap to count • Swipe for next',
                    style: AppTypography.labelMedium.copyWith(
                      color: cs.outline.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
