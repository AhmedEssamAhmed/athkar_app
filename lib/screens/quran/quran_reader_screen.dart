import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/quran_page_service.dart';
import '../../modules/quran_data.dart';

/// Full-screen Quran reader — page-by-page like a real Mushaf.
class QuranReaderScreen extends StatefulWidget {
  final int initialPage; // 1-based Quran page number
  const QuranReaderScreen({super.key, this.initialPage = 1});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  late PageController _pageCtrl;
  late int _currentPage;
  final QuranPageService _service = QuranPageService();
  final Map<int, List<PageAyah>> _pageCache = {};
  final Set<int> _loadingPages = {};
  final Set<int> _failedPages = {};
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    // PageView is 0-indexed, Quran pages are 1-indexed
    _pageCtrl = PageController(initialPage: _currentPage - 1);
    _loadPage(_currentPage);
    // Pre-load adjacent pages
    if (_currentPage > 1) _loadPage(_currentPage - 1);
    if (_currentPage < QuranMeta.totalPages) _loadPage(_currentPage + 1);
  }

  Future<void> _loadPage(int pageNum) async {
    if (_pageCache.containsKey(pageNum) || _loadingPages.contains(pageNum)) return;
    _loadingPages.add(pageNum);
    try {
      final ayahs = await _service.fetchPage(pageNum);
      if (mounted) {
        setState(() {
          _pageCache[pageNum] = ayahs;
          _failedPages.remove(pageNum);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _failedPages.add(pageNum));
    } finally {
      _loadingPages.remove(pageNum);
    }
  }

  void _onPageChanged(int index) {
    final newPage = index + 1;
    setState(() => _currentPage = newPage);
    // Pre-load adjacent pages
    if (newPage > 1) _loadPage(newPage - 1);
    _loadPage(newPage);
    if (newPage < QuranMeta.totalPages) _loadPage(newPage + 1);
  }

  void _jumpToPage(int page) {
    _pageCtrl.jumpToPage(page - 1);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsProvider>().isArabic;
    final cs = Theme.of(context).colorScheme;
    final surah = QuranMeta.surahForPage(_currentPage);
    final juz = QuranMeta.juzForPage(_currentPage);

    return Scaffold(
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          children: [
            // Page content
            Directionality(
              textDirection: TextDirection.rtl,
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: _onPageChanged,
                reverse: false, // Swipe left-to-right to go to next page (like a real Quran)
                itemCount: QuranMeta.totalPages,
                itemBuilder: (context, index) {
                  final pageNum = index + 1;
                  return _buildQuranPage(pageNum, cs, isAr);
                },
              ),
            ),

            // Top bar
            if (_showControls)
              Positioned(
                top: 0, left: 0, right: 0,
                child: _TopBar(
                  surahName: isAr ? surah.nameAr : surah.nameEn,
                  juzNumber: juz.number,
                  isAr: isAr,
                  onBack: () => Navigator.pop(context),
                  onJump: () => _showJumpDialog(context, isAr),
                ),
              ),

            // Bottom page indicator
            if (_showControls)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: _BottomBar(
                  currentPage: _currentPage,
                  totalPages: QuranMeta.totalPages,
                  onPageSlide: (p) => _jumpToPage(p),
                  cs: cs,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuranPage(int pageNum, ColorScheme cs, bool isAr) {
    final ayahs = _pageCache[pageNum];

    if (ayahs == null && _failedPages.contains(pageNum)) {
      return _ErrorPage(
        pageNum: pageNum,
        isAr: isAr,
        onRetry: () {
          _failedPages.remove(pageNum);
          _loadPage(pageNum);
        },
      );
    }

    if (ayahs == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: cs.primary, strokeWidth: 2),
            const SizedBox(height: 16),
            Text(
              isAr ? 'جاري تحميل الصفحة $pageNum...' : 'Loading page $pageNum...',
              style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    // Group ayahs by surah for header rendering
    final groups = <int, List<PageAyah>>{};
    for (final a in ayahs) {
      groups.putIfAbsent(a.surahNumber, () => []).add(a);
    }

    return Container(
      color: cs.brightness == Brightness.dark
          ? const Color(0xFF1A1A1A)
          : const Color(0xFFFFF8F0),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
          child: Column(
            children: [
              // Page header ornament
              _PageOrnament(cs: cs),
              const SizedBox(height: 8),

              // Quran text
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final entry in groups.entries)
                        _buildSurahSection(entry.key, entry.value, cs, pageNum),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              // Page number
              Text(
                '$pageNum',
                style: AppTypography.labelMedium.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahSection(int surahNum, List<PageAyah> ayahs, ColorScheme cs, int pageNum) {
    final isFirstAyah = ayahs.first.numberInSurah == 1;
    final widgets = <Widget>[];

    // Surah header if first ayah of surah appears on this page
    if (isFirstAyah) {
      widgets.add(_SurahHeader(surahNum: surahNum, cs: cs));
      widgets.add(const SizedBox(height: 12));

      // Bismillah for all surahs except At-Tawbah (9) and Al-Fatiha (already has it as ayah)
      if (surahNum != 9 && surahNum != 1) {
        widgets.add(
          Text(
            'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
            style: AppTypography.arabicBody.copyWith(
              color: cs.primary,
              fontSize: 20,
              height: 2.0,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        );
        widgets.add(const SizedBox(height: 12));
      }
    }

    // Ayah text — combine into flowing paragraph with ayah markers
    final buffer = StringBuffer();
    for (final ayah in ayahs) {
      buffer.write(ayah.text);
      buffer.write(' ﴿${_toArabicNum(ayah.numberInSurah)}﴾ ');
    }

    widgets.add(
      Text(
        buffer.toString(),
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 22,
          height: 2.0,
          color: cs.onSurface,
          letterSpacing: 0,
          wordSpacing: 2,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
    );
    widgets.add(const SizedBox(height: 8));

    return Column(children: widgets);
  }

  void _showJumpDialog(BuildContext context, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => _JumpDialog(
        isAr: isAr,
        onJump: (page) {
          Navigator.pop(ctx);
          _jumpToPage(page);
        },
      ),
    );
  }

  /// Convert integer to Arabic-Indic numerals.
  static String _toArabicNum(int num) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return num.toString().split('').map((c) => digits[int.parse(c)]).join();
  }
}

// ════════════════════════════════════════════════════════════════
// Surah Header Widget
// ════════════════════════════════════════════════════════════════

class _SurahHeader extends StatelessWidget {
  final int surahNum;
  final ColorScheme cs;
  const _SurahHeader({required this.surahNum, required this.cs});

  @override
  Widget build(BuildContext context) {
    final surah = QuranMeta.getSurah(surahNum);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withAlpha(30),
            cs.primaryContainer.withAlpha(20),
            cs.primary.withAlpha(30),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: cs.primary.withAlpha(50), width: 1),
      ),
      child: Text(
        'سُورَةُ ${surah.nameAr}',
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: cs.primary,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Page Ornament (decorative line)
// ════════════════════════════════════════════════════════════════

class _PageOrnament extends StatelessWidget {
  final ColorScheme cs;
  const _PageOrnament({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.goldenAccent.withAlpha(60))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.auto_awesome, size: 14, color: AppColors.goldenAccent.withAlpha(100)),
        ),
        Expanded(child: Container(height: 1, color: AppColors.goldenAccent.withAlpha(60))),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Top Bar
// ════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  final String surahName;
  final int juzNumber;
  final bool isAr;
  final VoidCallback onBack;
  final VoidCallback onJump;

  const _TopBar({
    required this.surahName,
    required this.juzNumber,
    required this.isAr,
    required this.onBack,
    required this.onJump,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cs.surface, cs.surface.withAlpha(0)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: onBack,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    surahName,
                    style: AppTypography.titleLarge.copyWith(color: cs.onSurface),
                  ),
                  Text(
                    isAr ? 'الجزء $juzNumber' : 'Juz $juzNumber',
                    style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded),
              tooltip: isAr ? 'انتقال سريع' : 'Quick Jump',
              onPressed: onJump,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Bottom Bar with slider
// ════════════════════════════════════════════════════════════════

class _BottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageSlide;
  final ColorScheme cs;

  const _BottomBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageSlide,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [cs.surface, cs.surface.withAlpha(0)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current page number badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.goldenAccent,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldenAccent.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$currentPage / $totalPages',
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('1', style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant)),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Slider(
                      value: currentPage.toDouble(),
                      min: 1,
                      max: totalPages.toDouble(),
                      activeColor: AppColors.goldenAccent,
                      inactiveColor: AppColors.mutedSage.withAlpha(60),
                      label: '$currentPage',
                      divisions: totalPages - 1,
                      onChanged: (v) => onPageSlide(v.round()),
                    ),
                  ),
                ),
                Text('$totalPages', style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Jump Dialog
// ════════════════════════════════════════════════════════════════

class _JumpDialog extends StatefulWidget {
  final bool isAr;
  final void Function(int page) onJump;
  const _JumpDialog({required this.isAr, required this.onJump});

  @override
  State<_JumpDialog> createState() => _JumpDialogState();
}

class _JumpDialogState extends State<_JumpDialog> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _pageCtrl = TextEditingController();
  final _ayahCtrl = TextEditingController();
  int? _selectedSurah;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _pageCtrl.dispose();
    _ayahCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAr = widget.isAr;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
      child: SizedBox(
        height: 420,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                isAr ? 'انتقال سريع' : 'Quick Jump',
                style: AppTypography.titleLarge,
              ),
            ),
            TabBar(
              controller: _tabCtrl,
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicatorColor: AppColors.goldenAccent,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              tabs: [
                Tab(text: isAr ? 'سورة' : 'Surah'),
                Tab(text: isAr ? 'جزء' : 'Juz'),
                Tab(text: isAr ? 'صفحة' : 'Page'),
                Tab(text: isAr ? 'آية' : 'Ayah'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildSurahJump(cs, isAr),
                  _buildJuzJump(cs, isAr),
                  _buildPageJump(cs, isAr),
                  _buildAyahJump(cs, isAr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahJump(ColorScheme cs, bool isAr) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: QuranMeta.surahs.length,
      itemBuilder: (_, i) {
        final s = QuranMeta.surahs[i];
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: cs.primaryContainer.withAlpha(40),
            child: Text('${s.number}', style: AppTypography.labelMedium.copyWith(color: cs.primary)),
          ),
          title: Text(isAr ? s.nameAr : s.nameEn, style: AppTypography.bodyMedium),
          subtitle: Text('${s.verses} ${isAr ? "آية" : "verses"}',
              style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant)),
          onTap: () => widget.onJump(s.startPage),
        );
      },
    );
  }

  Widget _buildJuzJump(ColorScheme cs, bool isAr) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: QuranMeta.juzList.length,
      itemBuilder: (_, i) {
        final j = QuranMeta.juzList[i];
        final startSurah = QuranMeta.getSurah(j.startSurah);
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.goldenAccent.withAlpha(40),
            child: Text('${j.number}', style: AppTypography.labelMedium.copyWith(color: AppColors.goldenAccent)),
          ),
          title: Text(isAr ? 'الجزء ${j.number}' : 'Juz ${j.number}', style: AppTypography.bodyMedium),
          subtitle: Text(
            isAr ? '${startSurah.nameAr} : ${j.startAyah}' : '${startSurah.nameEn} : ${j.startAyah}',
            style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant),
          ),
          onTap: () => widget.onJump(j.startPage),
        );
      },
    );
  }

  Widget _buildPageJump(ColorScheme cs, bool isAr) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            isAr ? 'أدخل رقم الصفحة (1-604)' : 'Enter page number (1-604)',
            style: AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pageCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: isAr ? 'رقم الصفحة' : 'Page number',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final p = int.tryParse(_pageCtrl.text);
              if (p != null && p >= 1 && p <= QuranMeta.totalPages) {
                widget.onJump(p);
              }
            },
            child: Text(isAr ? 'انتقال' : 'Go'),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahJump(ColorScheme cs, bool isAr) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Surah dropdown
          DropdownButtonFormField<int>(
            initialValue: _selectedSurah,
            hint: Text(isAr ? 'اختر سورة' : 'Select Surah'),
            isExpanded: true,
            items: QuranMeta.surahs.map((s) {
              return DropdownMenuItem(
                value: s.number,
                child: Text('${s.number}. ${isAr ? s.nameAr : s.nameEn}',
                    style: AppTypography.bodyMedium),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedSurah = v),
          ),
          const SizedBox(height: 12),
          // Ayah number input - when we jump by ayah, we go to surah start page
          // (exact ayah navigation requires knowing ayah positions)
          ElevatedButton(
            onPressed: () {
              if (_selectedSurah != null) {
                final s = QuranMeta.getSurah(_selectedSurah!);
                widget.onJump(s.startPage);
              }
            },
            child: Text(isAr ? 'انتقال للسورة' : 'Go to Surah'),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Error Page
// ════════════════════════════════════════════════════════════════

class _ErrorPage extends StatelessWidget {
  final int pageNum;
  final bool isAr;
  final VoidCallback onRetry;
  const _ErrorPage({required this.pageNum, required this.isAr, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: cs.outline),
          const SizedBox(height: 16),
          Text(
            isAr ? 'تعذر تحميل الصفحة $pageNum' : 'Failed to load page $pageNum',
            style: AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(isAr ? 'إعادة المحاولة' : 'Retry'),
          ),
        ],
      ),
    );
  }
}
