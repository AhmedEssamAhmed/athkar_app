import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/tasbeeh_provider.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});
  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pulse = Tween(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  void _onTap(TasbeehProvider p) {
    p.increment();
    _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final t = context.watch<TasbeehProvider>();
    final isAr = s.isArabic;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'المسبحة الرقمية' : 'Digital Tasbeeh'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _resetDialog(context, t, isAr),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          const Spacer(),
          Text(t.currentDhikr,
              style: AppTypography.arabicDisplay.copyWith(color: cs.primary),
              textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.spaceMd),
          ScaleTransition(
            scale: _pulse,
            child: GestureDetector(
              onTap: () => _onTap(t),
              child: SizedBox(
                width: 200, height: 200,
                child: Stack(alignment: Alignment.center, children: [
                  CustomPaint(size: const Size(200, 200),
                      painter: _RingPainter(
                          progress: t.progress,
                          track: AppColors.mutedSage.withAlpha(60),
                          fill: AppColors.goldenAccent)),
                  Container(
                    width: 170, height: 170,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.isComplete ? AppColors.goldenAccent : cs.primaryContainer,
                        boxShadow: [BoxShadow(
                            color: (t.isComplete ? AppColors.goldenAccent : cs.primary).withAlpha(40),
                            blurRadius: 30, offset: const Offset(0, 8))]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${t.count}',
                            style: AppTypography.displayLarge.copyWith(
                                color: t.isComplete ? Colors.white : cs.onPrimaryContainer,
                                fontSize: 48)),
                        Text('/ ${t.targetCount}',
                            style: AppTypography.labelMedium.copyWith(
                                color: (t.isComplete ? Colors.white : cs.onPrimaryContainer).withAlpha(160))),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(isAr ? 'اضغط للتسبيح' : 'Tap to count',
              style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant)),
          const Spacer(),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
              itemCount: TasbeehProvider.presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final p = TasbeehProvider.presets[i];
                final sel = t.currentDhikr == p['text'];
                return ChoiceChip(
                  label: Text(p['text'] as String,
                      style: AppTypography.labelMedium.copyWith(
                          fontFamily: 'Amiri', fontSize: 14,
                          color: sel ? cs.onPrimary : cs.onSurface)),
                  selected: sel,
                  selectedColor: cs.primary,
                  backgroundColor: cs.surfaceContainerHighest,
                  shape: const StadiumBorder(),
                  onSelected: (_) => t.selectPreset(p),
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
        ]),
      ),
    );
  }

  void _resetDialog(BuildContext ctx, TasbeehProvider t, bool isAr) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
      title: Text(isAr ? 'إعادة تعيين' : 'Reset Counter'),
      content: Text(isAr ? 'إعادة العداد إلى صفر؟' : 'Reset to zero?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text(isAr ? 'إلغاء' : 'Cancel')),
        ElevatedButton(onPressed: () { t.reset(); Navigator.pop(c); },
            child: Text(isAr ? 'إعادة' : 'Reset')),
      ],
    ));
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color track, fill;
  _RingPainter({required this.progress, required this.track, required this.fill});

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2);
    final r = (s.width - 4) / 2;
    c.drawCircle(center, r, Paint()..color = track..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round);
    c.drawArc(Rect.fromCircle(center: center, radius: r), -math.pi / 2, 2 * math.pi * progress, false,
        Paint()..color = fill..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _RingPainter o) => o.progress != progress;
}
