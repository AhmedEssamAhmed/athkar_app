import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../modules/athkar_module.dart';
import '../../core/storage/hive_service.dart';

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
            Icons.wb_sunny_rounded,       // morning
            Icons.nightlight_round,        // evening
            Icons.bedtime_rounded,         // sleep
            Icons.mosque_rounded,          // after prayer
            Icons.flight_takeoff_rounded,  // travel
            Icons.home_rounded,            // home
            Icons.restaurant_rounded,      // food & drink
            Icons.wash_rounded,            // bathroom
            Icons.healing_rounded,         // ruqya sunnah
            Icons.menu_book_rounded,       // ruqya quran
          ];
          final colors = [
            AppColors.gold,        // morning
            cs.primary,                    // evening
            cs.primary,                    // sleep
            cs.tertiary,                   // after prayer
            AppColors.gold,        // travel
            cs.primary,                    // home
            cs.tertiary,                   // food
            AppColors.mutedSage,           // bathroom
            AppColors.gold,                // ruqya sunnah
            cs.primary,                    // ruqya quran
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
                        child:
                            Icon(icons[index], color: colors[index], size: 26),
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
                        isAr
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        color: cs.outline,
                      ),
                    ],
                  ),
              ),
            ),
          ));

        },
      ),
    );
  }

  int _countForCategory(AthkarCategory cat) {
    return AthkarData.forCategory(cat.key).length;
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
  late List<int> _currentCounts;

  @override
  void initState() {
    super.initState();
    _athkar = AthkarData.forCategory(widget.category.key);
    _currentCounts = _athkar.map((d) {
      final saved = HiveService.getDhikrProgress(d.id);
      return saved ?? 0;
    }).toList();
  }

  void _onTapDhikr(int index) {
    final target = _athkar[index].repeatCount;

    if (_currentCounts[index] < target) {
      setState(() {
        _currentCounts[index]++;
        HiveService.saveDhikrProgress(_athkar[index].id, _currentCounts[index]);
      });
    }
  }

  void _resetAll() {
    setState(() {
      for (int i = 0; i < _athkar.length; i++) {
        _currentCounts[i] = 0;
      }
    });
    HiveService.resetCategoryProgress(_athkar.map((d) => d.id).toList());
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: isAr ? 'إعادة ضبط' : 'Reset',
            onPressed: _resetAll,
          ),
        ],
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _athkar.length,
        itemBuilder: (context, index) {
          final dhikr = _athkar[index];
          final current = _currentCounts[index];
          final target = dhikr.repeatCount;
          final done = current >= target;

          return GestureDetector(
            onTap: () => _onTapDhikr(index),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              margin: const EdgeInsets.all(AppTheme.marginMobile),
              decoration: BoxDecoration(
                color: done ? cs.primaryContainer.withAlpha(20) : cs.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(
                  color: done
                      ? cs.primary.withAlpha(40)
                      : cs.outlineVariant.withAlpha(60),
                  width: done ? 1.5 : 0.5,
                ),
              ),
              child: SingleChildScrollView(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: done
                            ? cs.primary
                            : AppColors.gold.withAlpha(30),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        done ? (isAr ? '✓ تم' : '✓ Done') : '$current / $target',
                        style: AppTypography.titleLarge.copyWith(
                          color: done ? cs.onPrimary : AppColors.gold,
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
                      isAr
                          ? 'اضغط للعد • اسحب للتالي'
                          : 'Tap to count • Swipe for next',
                      style: AppTypography.labelMedium.copyWith(
                        color: cs.outline.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
