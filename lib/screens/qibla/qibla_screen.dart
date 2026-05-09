import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';

/// Qibla Compass screen — shows direction to Kaaba.
/// Uses a simulated compass; in production integrate compass_plus package.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});
  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  // Simulated Qibla bearing (degrees from north). Replace with real calculation.
  final double _qiblaBearing = 136.5;
  double _currentHeading = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    // Simulate heading changes
    _ctrl.addListener(() {
      setState(() {
        _currentHeading = math.sin(_ctrl.value * 2 * math.pi) * 15;
      });
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsProvider>().isArabic;
    final cs = Theme.of(context).colorScheme;
    final needleAngle = (_qiblaBearing - _currentHeading) * math.pi / 180;

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? 'اتجاه القبلة' : 'Qibla Direction')),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Instruction
            Text(
              isAr ? 'وجّه هاتفك نحو الاتجاه المُشار إليه' : 'Point your device in the indicated direction',
              style: AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Compass widget
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    width: 280, height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.outlineVariant, width: 2),
                    ),
                  ),
                  // Cardinal directions
                  ..._buildCardinals(cs),
                  // Inner circle
                  Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primaryContainer.withAlpha(20),
                      border: Border.all(color: cs.primary.withAlpha(40), width: 1),
                    ),
                  ),
                  // Qibla needle
                  Transform.rotate(
                    angle: needleAngle,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.navigation_rounded,
                            size: 48, color: cs.primary),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAr ? 'القبلة' : 'Qibla',
                            style: AppTypography.labelMedium.copyWith(color: cs.onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Kaaba icon at center
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.goldenAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldenAccent.withAlpha(60),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.adjust_rounded, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spaceMd),
            // Bearing info
            Text(
              '${_qiblaBearing.toStringAsFixed(1)}°',
              style: AppTypography.headlineLarge.copyWith(color: cs.primary),
            ),
            Text(
              isAr ? 'جنوب شرق' : 'South-East',
              style: AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant),
            ),
            const Spacer(),

            // Disclaimer
            Padding(
              padding: const EdgeInsets.all(AppTheme.marginMobile),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withAlpha(80),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 20, color: cs.outline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'للحصول على نتائج دقيقة، قم بمعايرة البوصلة بتحريك الهاتف بشكل 8'
                            : 'For accurate results, calibrate by moving your phone in a figure-8 motion.',
                        style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCardinals(ColorScheme cs) {
    final labels = ['N', 'E', 'S', 'W'];
    final labelsAr = ['ش', 'شر', 'ج', 'غ'];
    final isAr = context.watch<SettingsProvider>().isArabic;
    return List.generate(4, (i) {
      final angle = i * math.pi / 2;
      return Positioned(
        left: 140 + 120 * math.sin(angle) - 12,
        top: 140 - 120 * math.cos(angle) - 12,
        child: Text(
          isAr ? labelsAr[i] : labels[i],
          style: AppTypography.labelLarge.copyWith(
            color: i == 0 ? cs.error : cs.onSurfaceVariant,
            fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      );
    });
  }
}
