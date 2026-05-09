import 'api_client.dart';

/// Data class for reverse-geocoded location info.
class LocationInfo {
  final String city;
  final String country;
  final String formatted;

  const LocationInfo({
    required this.city,
    required this.country,
    required this.formatted,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) => LocationInfo(
        city: json['city'] as String,
        country: json['country'] as String,
        formatted: json['formatted'] as String,
      );
}

/// Communicates with the FastAPI `/api/location/geocode` endpoint.
class LocationService {
  final ApiClient _api;

  LocationService({ApiClient? api}) : _api = api ?? ApiClient();

  /// Reverse-geocode [lat], [lng] into city + country.
  Future<LocationInfo> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    final data = await _api.get('/api/location/geocode', queryParams: {
      'lat': lat.toString(),
      'lng': lng.toString(),
    });

    return LocationInfo.fromJson(data);
  }
}
