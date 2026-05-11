import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../modules/quran_data.dart';
import 'quran_reader_screen.dart';

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
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  void _openReader(int page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuranReaderScreen(initialPage: page)),
    );
  }

  void _showQuickJump(bool isAr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (ctx) => _QuickJumpSheet(
        isAr: isAr,
        onJump: (page) {
          Navigator.pop(ctx);
          _openReader(page);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsProvider>().isArabic;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'القرآن الكريم' : 'The Holy Quran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: isAr ? 'انتقال سريع' : 'Quick Jump',
            onPressed: () => _showQuickJump(isAr),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.goldenAccent,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurfaceVariant,
          tabs: [
            Tab(text: isAr ? 'السور' : 'Surahs'),
            Tab(text: isAr ? 'الأجزاء' : 'Juz'),
            Tab(text: isAr ? 'الصفحات' : 'Pages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _SurahList(isAr: isAr, onTap: _openReader),
          _JuzList(isAr: isAr, onTap: _openReader),
          _PageGrid(isAr: isAr, onTap: _openReader),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Tab 1: All 114 Surahs
// ════════════════════════════════════════════════════════════════

class _SurahList extends StatelessWidget {
  final bool isAr;
  final void Function(int page) onTap;
  const _SurahList({required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.marginMobile),
      itemCount: QuranMeta.surahs.length,
      separatorBuilder: (_, __) => Divider(
        color: AppColors.mutedSage.withAlpha(40), thickness: 0.5, height: 1,
      ),
      itemBuilder: (context, i) {
        final s = QuranMeta.surahs[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          leading: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('${s.number}',
                  style: AppTypography.labelLarge.copyWith(color: cs.primary)),
            ),
          ),
          title: Text(
            isAr ? s.nameAr : s.nameEn,
            style: AppTypography.bodyLarge,
          ),
          subtitle: Text(
            '${s.verses} ${isAr ? "آية" : "verses"} • ${isAr ? s.typeAr : s.type}',
            style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant),
          ),
          trailing: Text(
            s.nameAr,
            style: AppTypography.arabicHeadline.copyWith(color: cs.primary, fontSize: 20),
          ),
          onTap: () => onTap(s.startPage),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Tab 2: All 30 Juz (Interactive)
// ════════════════════════════════════════════════════════════════

class _JuzList extends StatelessWidget {
  final bool isAr;
  final void Function(int page) onTap;
  const _JuzList({required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.marginMobile),
      itemCount: QuranMeta.juzList.length,
      itemBuilder: (context, i) {
        final j = QuranMeta.juzList[i];
        final startSurah = QuranMeta.getSurah(j.startSurah);
        // Find end surah (next juz start - 1 page, or last page)
        final endPage = i + 1 < QuranMeta.juzList.length
            ? QuranMeta.juzList[i + 1].startPage - 1
            : QuranMeta.totalPages;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
            leading: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.goldenAccent.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('${j.number}',
                    style: AppTypography.labelLarge.copyWith(
                        color: AppColors.goldenAccent, fontWeight: FontWeight.w700)),
              ),
            ),
            title: Text(
              isAr ? 'الجزء ${j.number} — ${j.nameAr}' : 'Juz ${j.number}',
              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  isAr
                      ? 'يبدأ من: ${startSurah.nameAr} آية ${j.startAyah}'
                      : 'Starts: ${startSurah.nameEn}, Ayah ${j.startAyah}',
                  style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant),
                ),
                Text(
                  isAr
                      ? 'الصفحات: ${j.startPage} – $endPage'
                      : 'Pages: ${j.startPage} – $endPage',
                  style: AppTypography.labelMedium.copyWith(color: cs.outline),
                ),
              ],
            ),
            trailing: Icon(
              isAr ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
              color: AppColors.goldenAccent,
            ),
            onTap: () => onTap(j.startPage),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Tab 3: Page Grid (1–604)
// ════════════════════════════════════════════════════════════════

class _PageGrid extends StatelessWidget {
  final bool isAr;
  final void Function(int page) onTap;
  const _PageGrid({required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.marginMobile),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: QuranMeta.totalPages,
      itemBuilder: (context, i) {
        final pageNum = i + 1;
        // Highlight juz boundaries
        final isJuzStart = QuranMeta.juzList.any((j) => j.startPage == pageNum);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            onTap: () => onTap(pageNum),
            child: Container(
              decoration: BoxDecoration(
                color: isJuzStart
                    ? AppColors.goldenAccent.withAlpha(25)
                    : cs.surfaceContainerHighest.withAlpha(40),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: isJuzStart
                    ? Border.all(color: AppColors.goldenAccent.withAlpha(80), width: 1)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$pageNum',
                    style: AppTypography.labelLarge.copyWith(
                      color: isJuzStart ? AppColors.goldenAccent : cs.onSurface,
                      fontWeight: isJuzStart ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Quick Jump Bottom Sheet
// ════════════════════════════════════════════════════════════════

class _QuickJumpSheet extends StatefulWidget {
  final bool isAr;
  final void Function(int page) onJump;
  const _QuickJumpSheet({required this.isAr, required this.onJump});

  @override
  State<_QuickJumpSheet> createState() => _QuickJumpSheetState();
}

class _QuickJumpSheetState extends State<_QuickJumpSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAr = widget.isAr;

    // Filter surahs by search query
    final filteredSurahs = _query.isEmpty
        ? QuranMeta.surahs
        : QuranMeta.surahs.where((s) {
            final q = _query.toLowerCase();
            return s.nameAr.contains(q) ||
                s.nameEn.toLowerCase().contains(q) ||
                s.number.toString() == q;
          }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollCtrl) {
        return Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isAr ? 'انتقال سريع' : 'Quick Jump',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 12),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: isAr ? 'ابحث عن سورة أو رقم صفحة...' : 'Search surah or page number...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Check if query is a page number
            if (_query.isNotEmpty && int.tryParse(_query) != null)
              _buildPageJumpTile(int.parse(_query), cs, isAr),

            // Surah results
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filteredSurahs.length,
                itemBuilder: (_, i) {
                  final s = filteredSurahs[i];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: cs.primaryContainer.withAlpha(30),
                      child: Text('${s.number}',
                          style: AppTypography.labelMedium.copyWith(color: cs.primary)),
                    ),
                    title: Text(isAr ? s.nameAr : s.nameEn, style: AppTypography.bodyMedium),
                    subtitle: Text(
                      '${isAr ? "صفحة" : "Page"} ${s.startPage} • ${s.verses} ${isAr ? "آية" : "verses"}',
                      style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant),
                    ),
                    trailing: Text(s.nameAr,
                        style: TextStyle(fontFamily: 'Amiri', fontSize: 16, color: cs.primary)),
                    onTap: () => widget.onJump(s.startPage),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageJumpTile(int pageNum, ColorScheme cs, bool isAr) {
    if (pageNum < 1 || pageNum > QuranMeta.totalPages) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.menu_book_rounded, color: AppColors.goldenAccent),
          title: Text(
            isAr ? 'انتقال إلى الصفحة $pageNum' : 'Jump to page $pageNum',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.arrow_forward_rounded),
          onTap: () => widget.onJump(pageNum),
        ),
      ),
    );
  }
}
