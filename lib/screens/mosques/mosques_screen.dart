import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';

class MosquesScreen extends StatelessWidget {
  const MosquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsProvider>().isArabic;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? 'المساجد القريبة' : 'Nearby Mosques')),
      body: Column(children: [
        // Map placeholder
        Container(
          height: 200,
          margin: const EdgeInsets.all(AppTheme.marginMobile),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            color: cs.surfaceContainerHighest,
          ),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.map_rounded, size: 48, color: cs.outline),
              const SizedBox(height: 8),
              Text(isAr ? 'الخريطة' : 'Map placeholder',
                  style: AppTypography.bodyMedium.copyWith(color: cs.outline)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.my_location_rounded, size: 18),
                label: Text(isAr ? 'تحديد موقعي' : 'Find My Location'),
              ),
            ]),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
            children: _mosques.map((m) => _MosqueTile(m: m, isAr: isAr)).toList(),
          ),
        ),
      ]),
    );
  }
}

class _MosqueTile extends StatelessWidget {
  final Map<String, String> m;
  final bool isAr;
  const _MosqueTile({required this.m, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: cs.primaryContainer.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.mosque_rounded, color: cs.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isAr ? m['nameAr']! : m['name']!,
                style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.location_on_rounded, size: 14, color: cs.outline),
              const SizedBox(width: 4),
              Text(m['distance']!,
                  style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant)),
            ]),
          ]),
        ),
        IconButton(
          icon: Icon(Icons.directions_rounded, color: cs.primary),
          onPressed: () {},
        ),
      ]),
    );
  }
}

const _mosques = [
  {'name': 'Al-Noor Grand Mosque', 'nameAr': 'مسجد النور الكبير', 'distance': '0.3 km'},
  {'name': 'Omar Ibn Al-Khattab Mosque', 'nameAr': 'مسجد عمر بن الخطاب', 'distance': '0.8 km'},
  {'name': 'Al-Taqwa Mosque', 'nameAr': 'مسجد التقوى', 'distance': '1.2 km'},
  {'name': 'Bilal Mosque', 'nameAr': 'مسجد بلال', 'distance': '1.5 km'},
  {'name': 'Al-Rahma Mosque', 'nameAr': 'مسجد الرحمة', 'distance': '2.1 km'},
];
