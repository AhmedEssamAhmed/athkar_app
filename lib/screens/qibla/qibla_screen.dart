import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/storage/hive_service.dart';

/// Qibla Compass screen — shows real-time direction to Kaaba
/// using the device magnetometer and GPS coordinates.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});
  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  // Kaaba coordinates
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  double? _qiblaBearing; // degrees from north to Qibla
  double _currentHeading = 0; // device heading from north
  double? _userLat;
  double? _userLng;

  StreamSubscription<CompassEvent>? _compassSub;
  String _status = 'initializing'; // initializing, ready, no_sensor, no_location, error
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Try to load cached location first
    final cachedLat = HiveService.getCachedValue('user_lat');
    final cachedLng = HiveService.getCachedValue('user_lng');
    if (cachedLat != null && cachedLng != null) {
      _userLat = (cachedLat as num).toDouble();
      _userLng = (cachedLng as num).toDouble();
      _qiblaBearing = _calculateQiblaBearing(_userLat!, _userLng!);
    }

    // Get fresh location
    await _getLocation();

    // Start compass
    if (kIsWeb) {
      setState(() {
        _status = _qiblaBearing != null ? 'ready' : 'no_sensor';
        _errorMsg = 'Compass not available on web platform';
      });
      return;
    }

    _startCompass();
  }

  Future<void> _getLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (_qiblaBearing == null) {
          setState(() {
            _status = 'no_location';
            _errorMsg = 'Location services are disabled';
          });
        }
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (_qiblaBearing == null) {
            setState(() {
              _status = 'no_location';
              _errorMsg = 'Location permission denied';
            });
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (_qiblaBearing == null) {
          setState(() {
            _status = 'no_location';
            _errorMsg = 'Location permission permanently denied';
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _userLat = position.latitude;
      _userLng = position.longitude;
      _qiblaBearing = _calculateQiblaBearing(_userLat!, _userLng!);

      // Cache location
      await HiveService.cacheValue('user_lat', _userLat);
      await HiveService.cacheValue('user_lng', _userLng);

      if (mounted) setState(() {});
    } catch (e) {
      if (_qiblaBearing == null && mounted) {
        setState(() {
          _status = 'error';
          _errorMsg = e.toString();
        });
      }
    }
  }

  void _startCompass() {
    _compassSub = FlutterCompass.events?.listen((event) {
      if (event.heading != null && mounted) {
        setState(() {
          _currentHeading = event.heading!;
          if (_qiblaBearing != null) {
            _status = 'ready';
          }
        });
      }
    }, onError: (_) {
      if (mounted) {
        setState(() {
          _status = _qiblaBearing != null ? 'ready' : 'no_sensor';
          _errorMsg = 'Compass sensor not available';
        });
      }
    });

    // If no events after 2 seconds, sensor might be unavailable
    Future.delayed(const Duration(seconds: 2), () {
      if (_status == 'initializing' && mounted) {
        setState(() {
          _status = _qiblaBearing != null ? 'ready' : 'no_sensor';
        });
      }
    });
  }

  /// Calculate bearing from user location to Kaaba using the great-circle formula.
  double _calculateQiblaBearing(double lat, double lng) {
    final lat1 = lat * math.pi / 180;
    final lng1 = lng * math.pi / 180;
    final lat2 = _kaabaLat * math.pi / 180;
    final lng2 = _kaabaLng * math.pi / 180;

    final dLng = lng2 - lng1;
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  /// Recalibrate: re-fetch location, recalculate Qibla bearing, restart compass.
  Future<void> _recalibrate() async {
    // Cancel existing compass subscription
    _compassSub?.cancel();

    setState(() {
      _status = 'initializing';
      _currentHeading = 0;
    });

    // Re-fetch fresh location
    await _getLocation();

    // Restart compass stream
    if (!kIsWeb) {
      _startCompass();
    } else {
      setState(() {
        _status = _qiblaBearing != null ? 'ready' : 'no_sensor';
      });
    }
  }

  String _getDirectionLabel(double bearing, bool isAr) {
    final directions = isAr
        ? ['شمال', 'شمال شرق', 'شرق', 'جنوب شرق', 'جنوب', 'جنوب غرب', 'غرب', 'شمال غرب']
        : ['North', 'North-East', 'East', 'South-East', 'South', 'South-West', 'West', 'North-West'];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsProvider>().isArabic;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? 'اتجاه القبلة' : 'Qibla Direction')),
      body: SafeArea(
        child: _status == 'initializing'
            ? _buildLoading(cs, isAr)
            : _status == 'no_sensor' || _status == 'no_location' || _status == 'error'
                ? _buildError(cs, isAr)
                : _buildCompass(cs, isAr),
      ),
    );
  }

  Widget _buildLoading(ColorScheme cs, bool isAr) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: cs.primary, strokeWidth: 2),
          const SizedBox(height: 20),
          Text(
            isAr ? 'جاري تحديد الموقع والبوصلة...' : 'Detecting location & compass...',
            style: AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ColorScheme cs, bool isAr) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.marginMobile),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _status == 'no_sensor' ? Icons.explore_off_rounded : Icons.location_off_rounded,
              size: 64, color: cs.outline,
            ),
            const SizedBox(height: 20),
            Text(
              _status == 'no_sensor'
                  ? (isAr ? 'مستشعر البوصلة غير متاح' : 'Compass sensor not available')
                  : (isAr ? 'تعذر تحديد الموقع' : 'Could not determine location'),
              style: AppTypography.titleLarge.copyWith(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMsg,
              style: AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _status = 'initializing');
                _initialize();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(isAr ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass(ColorScheme cs, bool isAr) {

    return Column(
      children: [
        const Spacer(),
        // Instruction
        Text(
          isAr ? 'وجّه هاتفك نحو الاتجاه المُشار إليه' : 'Point your device in the indicated direction',
          style: AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spaceLg),

        // Compass
        SizedBox(
          width: 300, height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating compass dial
              AnimatedRotation(
                turns: -_currentHeading / 360,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: _CompassDial(cs: cs, isAr: isAr),
              ),

              // Qibla needle
              AnimatedRotation(
                turns: ((_qiblaBearing ?? 0) - _currentHeading) / 360,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: SizedBox(
                  width: 300, height: 300,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.navigation_rounded, size: 40, color: cs.primary),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isAr ? 'القبلة' : 'Qibla',
                              style: AppTypography.labelMedium.copyWith(color: cs.onPrimary, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Kaaba center icon
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: AppColors.goldenAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.goldenAccent.withAlpha(60), blurRadius: 20),
                  ],
                ),
                child: const Icon(Icons.adjust_rounded, color: Colors.white, size: 26),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spaceMd),
        // Bearing info
        Text(
          '${_qiblaBearing?.toStringAsFixed(1) ?? "---"}°',
          style: AppTypography.headlineLarge.copyWith(color: cs.primary),
        ),
        Text(
          _qiblaBearing != null
              ? _getDirectionLabel(_qiblaBearing!, isAr)
              : '---',
          style: AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant),
        ),

        if (_userLat != null && _userLng != null) ...[
          const SizedBox(height: 8),
          Text(
            '${_userLat!.toStringAsFixed(4)}°, ${_userLng!.toStringAsFixed(4)}°',
            style: AppTypography.labelMedium.copyWith(color: cs.outline),
          ),
        ],

        const Spacer(),

        // Recalibrate button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _recalibrate,
              icon: const Icon(Icons.explore_rounded, size: 20),
              label: Text(isAr ? 'إعادة معايرة البوصلة' : 'Recalibrate Compass'),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.primary,
                side: BorderSide(color: cs.primary.withAlpha(120)),
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Calibration tip
        Padding(
          padding: const EdgeInsets.fromLTRB(AppTheme.marginMobile, 0, AppTheme.marginMobile, AppTheme.marginMobile),
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
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Compass Dial Widget
// ════════════════════════════════════════════════════════════════

class _CompassDial extends StatelessWidget {
  final ColorScheme cs;
  final bool isAr;
  const _CompassDial({required this.cs, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(300, 300),
      painter: _CompassPainter(cs: cs, isAr: isAr),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final ColorScheme cs;
  final bool isAr;
  _CompassPainter({required this.cs, required this.isAr});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    canvas.drawCircle(
      center, radius - 2,
      Paint()..color = cs.outlineVariant.withAlpha(80)..style = PaintingStyle.stroke..strokeWidth = 2,
    );

    // Inner circle
    canvas.drawCircle(
      center, radius - 40,
      Paint()..color = cs.primary.withAlpha(15)..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center, radius - 40,
      Paint()..color = cs.primary.withAlpha(30)..style = PaintingStyle.stroke..strokeWidth = 1,
    );

    // Tick marks and labels
    final tickPaint = Paint()..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    final cardinals = isAr ? ['ش', 'شر', 'ج', 'غ'] : ['N', 'E', 'S', 'W'];

    for (int i = 0; i < 360; i += 15) {
      final angle = i * math.pi / 180 - math.pi / 2;
      final isCardinal = i % 90 == 0;
      final isMajor = i % 45 == 0;
      final outerR = radius - 4;
      final innerR = isCardinal ? radius - 25 : (isMajor ? radius - 18 : radius - 12);

      final p1 = Offset(center.dx + outerR * math.cos(angle), center.dy + outerR * math.sin(angle));
      final p2 = Offset(center.dx + innerR * math.cos(angle), center.dy + innerR * math.sin(angle));

      tickPaint.color = isCardinal
          ? (i == 0 ? Colors.red : cs.onSurface)
          : cs.outline.withAlpha(100);
      tickPaint.strokeWidth = isCardinal ? 2.5 : 1.5;

      canvas.drawLine(p1, p2, tickPaint);

      // Cardinal labels
      if (isCardinal) {
        final labelR = radius - 32;
        final labelPos = Offset(
          center.dx + labelR * math.cos(angle),
          center.dy + labelR * math.sin(angle),
        );
        final tp = TextPainter(
          text: TextSpan(
            text: cardinals[i ~/ 90],
            style: TextStyle(
              color: i == 0 ? Colors.red : cs.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(labelPos.dx - tp.width / 2, labelPos.dy - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) => false;
}
