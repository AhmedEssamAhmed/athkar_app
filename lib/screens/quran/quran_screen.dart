import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsProvider>().isArabic;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'القرآن الكريم' : 'The Holy Quran'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.goldenAccent,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurfaceVariant,
          tabs: [
            Tab(text: isAr ? 'السور' : 'Surahs'),
            Tab(text: isAr ? 'الأجزاء' : 'Juz'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _SurahList(isAr: isAr),
          _JuzList(isAr: isAr),
        ],
      ),
    );
  }
}

class _SurahList extends StatelessWidget {
  final bool isAr;
  const _SurahList({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.marginMobile),
      itemCount: _surahs.length,
      separatorBuilder: (_, __) => Divider(
        color: AppColors.mutedSage.withAlpha(40),
        thickness: 0.5,
        height: 1,
      ),
      itemBuilder: (context, i) {
        final s = _surahs[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('${s['num']}',
                  style: AppTypography.labelLarge.copyWith(color: cs.primary)),
            ),
          ),
          title: Text(isAr ? s['nameAr'] as String : s['name'] as String,
              style: AppTypography.bodyLarge),
          subtitle: Text(
            '${s['verses']} ${isAr ? "آية" : "verses"} • ${isAr ? s['typeAr'] : s['type']}',
            style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant),
          ),
          trailing: Text(s['nameAr'] as String,
              style: AppTypography.arabicHeadline.copyWith(
                  color: cs.primary, fontSize: 20)),
          onTap: () {},
        );
      },
    );
  }
}

class _JuzList extends StatelessWidget {
  final bool isAr;
  const _JuzList({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.marginMobile),
      itemCount: 30,
      itemBuilder: (context, i) {
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
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.goldenAccent.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('${i + 1}',
                    style: AppTypography.labelLarge.copyWith(
                        color: AppColors.goldenAccent)),
              ),
            ),
            title: Text(
              isAr ? 'الجزء ${i + 1}' : 'Juz ${i + 1}',
              style: AppTypography.bodyLarge,
            ),
            subtitle: Text(
              isAr ? '${(i * 20) + 1} - ${(i + 1) * 20} صفحة' : 'Pages ${(i * 20) + 1} - ${(i + 1) * 20}',
              style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant),
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}

const _surahs = [
  {'num': 1, 'name': 'Al-Fatiha', 'nameAr': 'الفاتحة', 'verses': 7, 'type': 'Meccan', 'typeAr': 'مكية'},
  {'num': 2, 'name': 'Al-Baqarah', 'nameAr': 'البقرة', 'verses': 286, 'type': 'Medinan', 'typeAr': 'مدنية'},
  {'num': 3, 'name': 'Al-Imran', 'nameAr': 'آل عمران', 'verses': 200, 'type': 'Medinan', 'typeAr': 'مدنية'},
  {'num': 4, 'name': 'An-Nisa', 'nameAr': 'النساء', 'verses': 176, 'type': 'Medinan', 'typeAr': 'مدنية'},
  {'num': 36, 'name': 'Ya-Sin', 'nameAr': 'يس', 'verses': 83, 'type': 'Meccan', 'typeAr': 'مكية'},
  {'num': 55, 'name': 'Ar-Rahman', 'nameAr': 'الرحمن', 'verses': 78, 'type': 'Medinan', 'typeAr': 'مدنية'},
  {'num': 67, 'name': 'Al-Mulk', 'nameAr': 'الملك', 'verses': 30, 'type': 'Meccan', 'typeAr': 'مكية'},
  {'num': 112, 'name': 'Al-Ikhlas', 'nameAr': 'الإخلاص', 'verses': 4, 'type': 'Meccan', 'typeAr': 'مكية'},
  {'num': 113, 'name': 'Al-Falaq', 'nameAr': 'الفلق', 'verses': 5, 'type': 'Meccan', 'typeAr': 'مكية'},
  {'num': 114, 'name': 'An-Nas', 'nameAr': 'الناس', 'verses': 6, 'type': 'Meccan', 'typeAr': 'مكية'},
];
