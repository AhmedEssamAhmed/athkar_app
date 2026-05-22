import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/prayer_time_provider.dart';
import '../../modules/prayer_module.dart';
import '../../main.dart';
import '../qibla/qibla_screen.dart';
import '../mosques/mosques_screen.dart';
import '../reminders/reminders_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _latitude = PrayerData.defaultLatitude;
  double _longitude = PrayerData.defaultLongitude;
  String _locationName = PrayerData.defaultLocationName;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      final position = await _determinePosition();

      // Start with coordinates as fallback
      String locationName =
          '${position.latitude.toStringAsFixed(3)}, '
          '${position.longitude.toStringAsFixed(3)}';

      // Try reverse geocoding for a friendly city name
      try {
        final places = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (places.isNotEmpty) {
          final place = places.first;
          final city = place.locality?.isNotEmpty == true
              ? place.locality
              : place.administrativeArea;
          final country = place.country;
          locationName = [
            if (city != null && city.isNotEmpty) city,
            if (country != null && country.isNotEmpty) country,
          ].join(', ');
        }
      } catch (_) {
        // Keep coordinates if reverse geocoding fails
      }

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationName = locationName;
        _isLoadingLocation = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _latitude = PrayerData.defaultLatitude;
        _longitude = PrayerData.defaultLongitude;
        _locationName = PrayerData.defaultLocationName;
        _isLoadingLocation = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final prayerProvider = context.watch<PrayerTimeProvider>();
    final isAr = settings.isArabic;
    final tt = Theme.of(context).textTheme;
    final hijri = prayerProvider.hijriDate;
    final prayers = prayerProvider.prayers;

    return Scaffold(
      body: SafeArea(
        child: prayerProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.marginMobile,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTheme.spaceMd),

                    _GreetingHeader(
                      isArabic: isAr,
                      hijri: hijri,
                      isLoadingLocation: _isLoadingLocation,
                      locationName: _locationName,
                    ),

                    const SizedBox(height: AppTheme.spaceMd),

                    _CurrentPrayerCard(prayers: prayers, isArabic: isAr),

                    const SizedBox(height: AppTheme.spaceMd),

                    Text(
                      isAr ? 'مواقيت الصلاة' : 'Prayer Times',
                      style: tt.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    _PrayerTimesList(prayers: prayers, isArabic: isAr),

                    const SizedBox(height: AppTheme.spaceMd),

                    _SpecialTimesCard(
                      isArabic: isAr,
                      midnight: prayerProvider.midnightTime,
                      lastThird: prayerProvider.lastThirdTime,
                      duha: prayerProvider.duhaTime,
                    ),

                    const SizedBox(height: AppTheme.spaceMd),

                    _NotificationTimingsGrid(
                      isArabic: isAr,
                      morningAthkar: prayerProvider.morningAthkarTime,
                      eveningAthkar: prayerProvider.eveningAthkarTime,
                      fourthSixth: prayerProvider.fourthSixthTime,
                    ),

                    const SizedBox(height: AppTheme.spaceLg),

                    Text(
                      isAr ? 'الوصول السريع' : 'Quick Access',
                      style: tt.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    _QuickAccessGrid(isArabic: isAr),

                    const SizedBox(height: AppTheme.spaceLg),
                  ],
                ),
              ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final bool isArabic;
  final dynamic hijri;
  final bool isLoadingLocation;
  final String locationName;

  const _GreetingHeader({
    required this.isArabic,
    required this.hijri,
    required this.isLoadingLocation,
    required this.locationName,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(),
          style: AppTypography.headlineLarge.copyWith(
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isArabic ? hijri.formattedAr : hijri.formatted,
          style: AppTypography.bodyMedium.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 16,
              color: cs.primary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                isLoadingLocation
                    ? (isArabic
                        ? 'جاري تحديد الموقع...'
                        : 'Detecting location...')
                    : locationName,
                style: AppTypography.bodyMedium.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CurrentPrayerCard extends StatelessWidget {
  final List<PrayerTime> prayers;
  final bool isArabic;

  const _CurrentPrayerCard({required this.prayers, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (prayers.isEmpty) {
      return const SizedBox.shrink();
    }

    final current = prayers.firstWhere(
      (p) => p.isCurrent,
      orElse: () => prayers.first,
    );

    final currentIdx = prayers.indexOf(current);
    final next = currentIdx + 1 < prayers.length
        ? prayers[currentIdx + 1]
        : prayers.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            cs.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withAlpha(25),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'الصلاة الحالية' : 'Current Prayer',
            style: AppTypography.labelLarge.copyWith(
              color: Colors.white.withAlpha(180),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? current.nameAr : current.name,
                style: AppTypography.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                current.time,
                style: AppTypography.headlineLarge.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              isArabic
                  ? 'التالية: ${next.nameAr} – ${next.time}'
                  : 'Next: ${next.name} – ${next.time}',
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimesList extends StatelessWidget {
  final List<PrayerTime> prayers;
  final bool isArabic;

  const _PrayerTimesList({required this.prayers, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: prayers.map((prayer) {
        final isCurrent = prayer.isCurrent;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.gutter,
            vertical: AppTheme.spaceSm,
          ),
          decoration: BoxDecoration(
            color: isCurrent
                ? cs.primaryContainer.withAlpha(30)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: isCurrent
                ? Border.all(color: cs.primary.withAlpha(60), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent
                          ? AppColors.goldenAccent
                          : prayer.isPassed
                              ? AppColors.mutedSage
                              : cs.outline.withAlpha(60),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isArabic ? prayer.nameAr : prayer.name,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isCurrent ? cs.primary : cs.onSurface,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Text(
                prayer.time,
                style: AppTypography.bodyLarge.copyWith(
                  color: isCurrent ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SpecialTimesCard extends StatelessWidget {
  final bool isArabic;
  final String midnight;
  final String lastThird;
  final String duha;

  const _SpecialTimesCard({
    required this.isArabic,
    required this.midnight,
    required this.lastThird,
    required this.duha,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final items = [
      {
        'icon': Icons.nights_stay_rounded,
        'titleEn': 'Midnight',
        'titleAr': 'منتصف الليل',
        'time': midnight,
      },
      {
        'icon': Icons.star_rounded,
        'titleEn': 'Last Third',
        'titleAr': 'الثلث الأخير',
        'time': lastThird,
      },
      {
        'icon': Icons.wb_sunny_rounded,
        'titleEn': 'Duha',
        'titleAr': 'الضحى',
        'time': duha,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'أوقات مهمة' : 'Important Times',
          style: tt.titleLarge,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          children: items.map((item) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: item == items.last ? 0 : 6,
                  left: item == items.first ? 0 : 6,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: cs.outlineVariant.withAlpha(80),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: cs.primary,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['time'] as String,
                      style: AppTypography.titleLarge.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isArabic ? item['titleAr'] as String : item['titleEn'] as String,
                      style: AppTypography.labelMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
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
        color: cs.primaryContainer,
        tabIndex: 1,
      ),
      _QuickItem(
        icon: Icons.menu_book_rounded,
        labelEn: 'Quran',
        labelAr: 'القرآن',
        color: cs.tertiaryContainer,
        tabIndex: 3,
      ),
      _QuickItem(
        icon: Icons.touch_app_rounded,
        labelEn: 'Tasbeeh',
        labelAr: 'المسبحة',
        color: AppColors.goldenAccent,
        tabIndex: 2,
      ),
      _QuickItem(
        icon: Icons.explore_rounded,
        labelEn: 'Qibla',
        labelAr: 'القبلة',
        color: cs.secondaryContainer,
        screen: const QiblaScreen(),
      ),
      _QuickItem(
        icon: Icons.mosque_rounded,
        labelEn: 'Mosques',
        labelAr: 'المساجد',
        color: cs.primaryContainer,
        screen: const MosquesScreen(),
      ),
      _QuickItem(
        icon: Icons.notifications_rounded,
        labelEn: 'Reminders',
        labelAr: 'التذكيرات',
        color: cs.tertiaryContainer,
        screen: const RemindersScreen(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppTheme.spaceSm,
        crossAxisSpacing: AppTheme.spaceSm,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _QuickAccessTile(item: item, isArabic: isArabic);
      },
    );
  }
}

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
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: () {
          if (item.tabIndex != null) {
            AppShell.navigateTo(context, item.tabIndex!);
          } else if (item.screen != null) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => item.screen!));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: cs.outlineVariant.withAlpha(80),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic ? item.labelAr : item.labelEn,
                style: AppTypography.labelMedium.copyWith(
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTimingsGrid extends StatelessWidget {
  final bool isArabic;
  final String morningAthkar;
  final String eveningAthkar;
  final String fourthSixth;

  const _NotificationTimingsGrid({
    required this.isArabic,
    required this.morningAthkar,
    required this.eveningAthkar,
    required this.fourthSixth,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final items = [
      {
        'icon': Icons.wb_sunny_outlined,
        'titleEn': 'Morning Athkar',
        'titleAr': 'أذكار الصباح',
        'time': morningAthkar,
      },
      {
        'icon': Icons.nightlight_round,
        'titleEn': 'Evening Athkar',
        'titleAr': 'أذكار المساء',
        'time': eveningAthkar,
      },
      {
        'icon': Icons.star_border,
        'titleEn': '4th Sixth',
        'titleAr': 'السدس الرابع',
        'time': fourthSixth,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'مواقيت الإشعارات' : 'Notification Timings',
          style: tt.titleLarge,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          children: items.map((item) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: item == items.last ? 0 : 6,
                  left: item == items.first ? 0 : 6,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: cs.outlineVariant.withAlpha(80),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: cs.tertiary,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['time'] as String,
                      style: AppTypography.titleLarge.copyWith(
                        color: cs.tertiary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isArabic ? item['titleAr'] as String : item['titleEn'] as String,
                      style: AppTypography.labelMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
