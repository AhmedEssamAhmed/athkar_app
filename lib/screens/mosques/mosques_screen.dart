import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/mosque_service.dart';
import '../../core/services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MosquesScreen extends StatefulWidget {
  const MosquesScreen({super.key});

  @override
  State<MosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends State<MosquesScreen> {
  final MosqueService _mosqueService = MosqueService();
  List<Mosque>? _mosques;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMosques();
  }

  Future<void> _fetchMosques() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await LocationService().resolve();
      if (!result.isSuccess) throw Exception(result.error ?? 'Could not determine location');

      final data = await _mosqueService.fetchNearby(
        lat: result.latitude,
        lng: result.longitude,
      );

      for (var m in data) {
        m.distance = Geolocator.distanceBetween(
          result.latitude, result.longitude, m.lat, m.lng,
        );
      }
      data.sort((a, b) => a.distance.compareTo(b.distance));

      setState(() {
        _mosques = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsProvider>().isArabic;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'المساجد القريبة' : 'Nearby Mosques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _fetchMosques,
          )
        ],
      ),
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
                onPressed: _fetchMosques,
                icon: const Icon(Icons.my_location_rounded, size: 18),
                label: Text(isAr ? 'تحديد موقعي' : 'Find My Location'),
              ),
            ]),
          ),
        ),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        isAr ? 'حدث خطأ أثناء جلب البيانات:\n$_error' : 'Error fetching data:\n$_error',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.error),
                      ),
                    ),
                  )
                : _mosques == null || _mosques!.isEmpty
                    ? Center(child: Text(isAr ? 'لم يتم العثور على مساجد قريبة.' : 'No nearby mosques found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.marginMobile),
                        itemCount: _mosques!.length,
                        itemBuilder: (context, index) => _MosqueTile(m: _mosques![index], isAr: isAr),
                      ),
        ),
      ]),
    );
  }
}

class _MosqueTile extends StatelessWidget {
  final Mosque m;
  final bool isAr;
  const _MosqueTile({required this.m, required this.isAr});

  String _formatDistance(double meters, bool isAr) {
    if (meters < 1000) {
      return '${meters.toInt()} ${isAr ? "متر" : "m"}';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} ${isAr ? "كم" : "km"}';
    }
  }

  Future<void> _launchMaps(Mosque m) async {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${m.lat},${m.lng}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(url);
    }
  }

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
            Text(m.name.isNotEmpty ? m.name : (isAr ? 'مسجد غير مسمى' : 'Unnamed Mosque'),
                style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.location_on_rounded, size: 14, color: cs.outline),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  m.address.isNotEmpty ? m.address : (isAr ? 'موقع المسجد' : 'Mosque location'),
                  style: AppTypography.labelMedium.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDistance(m.distance, isAr),
                style: AppTypography.labelMedium.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]),
          ]),
        ),
        IconButton(
          icon: Icon(Icons.directions_rounded, color: cs.primary),
          onPressed: () => _launchMaps(m),
        ),
      ]),
    );
  }
}
