import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String cityName;
  final String? error;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.cityName = '',
    this.error,
  });

  bool get isSuccess => error == null;
}

class LocationService {
  static const _keyLat = 'user_lat';
  static const _keyLng = 'user_lng';

  static final LocationService _instance = LocationService._();
  factory LocationService() => _instance;
  LocationService._();

  Future<LocationResult?> tryGetCached() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_keyLat);
    final lng = prefs.getDouble(_keyLng);
    if (lat == null || lng == null) return null;
    final city = await _resolveCity(lat, lng);
    return LocationResult(latitude: lat, longitude: lng, cityName: city);
  }

  Future<LocationResult> resolve() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult(
        latitude: 0, longitude: 0,
        error: 'GPS is disabled — enable location in device settings',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return const LocationResult(
        latitude: 0, longitude: 0,
        error: 'Location permission denied — grant permission to detect location',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(
        latitude: 0, longitude: 0,
        error: 'Location permission permanently denied — enable in app settings',
      );
    }

    Position? position;

    try {
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) position = lastPos;
    } catch (_) {}

    if (position == null) {
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        ).timeout(const Duration(seconds: 10));
      } catch (_) {}
    }

    if (position == null) {
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (_) {}
    }

    if (position == null) {
      return const LocationResult(
        latitude: 0, longitude: 0,
        error: 'GPS couldn\'t get a fix — go outdoors or check GPS',
      );
    }

    await _cache(position.latitude, position.longitude);
    final city = await _resolveCity(position.latitude, position.longitude);

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: city,
    );
  }

  Future<String> _resolveCity(double lat, double lng) async {
    try {
      final places = await placemarkFromCoordinates(lat, lng);
      if (places.isEmpty) return _fallbackName(lat, lng);
      final place = places.first;
      final city = [
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
        place.country,
      ].firstWhere(
        (v) => v != null && v.trim().isNotEmpty,
        orElse: () => null,
      );
      if (city == null) return _fallbackName(lat, lng);
      final country = place.country;
      if (country == null || country.trim().isEmpty || city == country) return city;
      return '$city, $country';
    } catch (_) {
      return _fallbackName(lat, lng);
    }
  }

  String _fallbackName(double lat, double lng) =>
      '${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)}';

  Future<void> _cache(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyLat, lat);
    await prefs.setDouble(_keyLng, lng);
  }

  Future<String> resolveCityName(double lat, double lng) => _resolveCity(lat, lng);

  Future<void> cacheLocation(double lat, double lng) => _cache(lat, lng);

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLat);
    await prefs.remove(_keyLng);
  }
}
